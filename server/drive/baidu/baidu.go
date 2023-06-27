package baidu

import (
	"bytes"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"mime/multipart"
	"net/http"
	"net/url"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

const (
	phoAppKey    = "8wylQfdIzIpNFOGHZSnOOQ98QLDFvl1U"
	phoSecretKey = "lKAurWfMvbUqPddUmOFVgim3Ui1oM56M"
)

type BaiduNetdisk struct {
	refreshToken  string
	accessToken   string
	TokenExpireAt int64
	tokenLock     sync.RWMutex
	rootPath      string
	httpc         *http.Client
	fsIDMap       sync.Map
}

type generalRsp struct {
	Errno  int    `json:"errno"`
	ErrMsg string `json:"errmsg"`
}

func NewBaiduNetdiskDrive(refreshToken, accessToken string) (*BaiduNetdisk, error) {
	d := &BaiduNetdisk{
		refreshToken: refreshToken,
		accessToken:  accessToken,
		httpc:        &http.Client{},
		rootPath:     "/apps/pho",
	}
	err := d.MkdirAll(d.rootPath)
	if err != nil {
		return nil, fmt.Errorf("mkdir root path[%s] error: %v", d.rootPath, err)
	}
	return d, nil
}

func (d *BaiduNetdisk) IsExist(path string) (bool, error) {
	if d.rootPath == "" {
		return false, fmt.Errorf("root path is empty")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return false, err
		}
	}
	fullPath := filepath.Join(d.rootPath, path)
	return d.isExist(fullPath, false)
}

func (d *BaiduNetdisk) Download(path string) (io.ReadCloser, int64, error) {
	return d.DownloadWithOffset(path, 0)
}

func (d *BaiduNetdisk) DownloadWithOffset(path string, offset int64) (io.ReadCloser, int64, error) {
	if d.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return nil, 0, err
		}
	}
	fullPath := filepath.Join(d.rootPath, path)
	retried := 0
RETRY:
	v, ok := d.fsIDMap.Load(fullPath)
	if !ok {
		err := d.refreshFileInfo(fullPath)
		if err == nil {
			v, ok = d.fsIDMap.Load(fullPath)
			if ok {
				goto FSID_FOUND
			}
		} else {
			return nil, 0, fmt.Errorf("refresh file info error: %v", err)
		}
		return nil, 0, fmt.Errorf("file not exist")
	}
FSID_FOUND:
	info := v.(*BaiduFileInfo)
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&access_token=%s&fsids=[%d]&dlink=1", d.AccessToken(), info.FsID)
	req, err := http.NewRequest("GET", reqUrl, nil)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	resp, err := d.httpc.Do(req)
	if err != nil {
		return nil, 0, err
	}
	defer resp.Body.Close()
	var rsp struct {
		generalRsp
		List []BaiduFileInfo `json:"list"`
	}
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, 0, err
	}
	if err := json.Unmarshal(data, &rsp); err != nil {
		return nil, 0, err
	}
	if rsp.Errno != ErrorNoSuccess {
		if rsp.Errno == ErrorNoAccessToken {
			d.refreshAccessToken()
		}
		return nil, 0, fmt.Errorf("baidu netdisk (DownloadWithOffset) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
	}
	if len(rsp.List) != 1 {
		// 可能是fsid索引过期,刷新后重试
		err = d.refreshFileInfo(fullPath)
		if err == nil && retried < 1 {
			retried++
			goto RETRY
		}
		return nil, 0, fmt.Errorf("baidu netdisk error: file not exist")
	}
	downloadLink := rsp.List[0].Dlink
	fileSize := rsp.List[0].Size()
	if downloadLink == "" {
		return nil, 0, fmt.Errorf("baidu netdisk error: file Dlink is empty")
	}
	req, err = http.NewRequest("GET", fmt.Sprintf("%s&access_token=%s", downloadLink, d.AccessToken()), nil)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	if offset > 0 {
		req.Header.Set("Range", fmt.Sprintf("bytes=%d-", offset))
	}
	resp, err = d.httpc.Do(req)
	if err != nil {
		return nil, 0, err
	}
	return resp.Body, fileSize, nil
}

func (d *BaiduNetdisk) Delete(path string) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return err
		}
	}
	fullPath := filepath.Join(d.rootPath, path)
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=filemanager&access_token=%s&opera=delete", d.AccessToken())
	formData := url.Values{
		"async":    {"0"},
		"filelist": {`["` + fullPath + `"]`},
	}
	resp, err := http.PostForm(reqUrl, formData)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	var rsp generalRsp
	if err := json.NewDecoder(resp.Body).Decode(&rsp); err != nil {
		return err
	}
	if rsp.Errno != ErrorNoSuccess {
		if rsp.Errno == ErrorNoAccessToken {
			d.refreshAccessToken()
		}
		return fmt.Errorf("baidu netdisk (Delete) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
	}
	return nil
}

func (d *BaiduNetdisk) Upload(path string, reader io.ReadCloser, size int64, lastModified time.Time) error {
	if reader == nil {
		return fmt.Errorf("reader is nil")
	}
	defer reader.Close()
	if size >= 100*1024*1024 {
		return fmt.Errorf("file size too large, only support file size less than 100MB for now")
	}
	if d.rootPath == "" {
		return fmt.Errorf("root path not set")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return err
		}
	}
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.MkdirAll(filepath.Dir(fullPath))
	if err != nil {
		return err
	}
	// Upload
	// TODO: use temp file
	// 这里用内存存下来整个文件,传输大文件很可能爆内存.后续改成使用临时文件
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=precreate&access_token=%s", d.AccessToken())
	blockMd5 := md5.New()
	blockList := make([]string, 0)
	buf := make([]byte, 4*1024*1024)
	fileData := make([]byte, 0, size)
	for {
		finishRead := false
		n, err := io.ReadFull(reader, buf)
		if err != nil {
			if err == io.EOF || err == io.ErrUnexpectedEOF {
				finishRead = true
			} else {
				return err
			}
		}
		blockMd5.Reset()
		blockMd5.Write(buf[:n])
		blockList = append(blockList, fmt.Sprintf(`"%s"`, hex.EncodeToString(blockMd5.Sum(nil))))
		fileData = append(fileData, buf[:n]...)
		if finishRead {
			break
		}
	}
	blockListStr := fmt.Sprintf("[%s]", strings.Join(blockList, ","))
	formData := url.Values{
		"path":       {fullPath},
		"size":       {fmt.Sprintf("%d", size)},
		"isdir":      {"0"},
		"rtype":      {"3"},
		"autoinit":   {"1"},
		"block_list": {blockListStr},
	}
	resp, err := http.PostForm(reqUrl, formData)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	var preRsp struct {
		generalRsp
		UploadID  string `json:"uploadid"`
		BlockList []int  `json:"block_list"`
	}
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(data, &preRsp); err != nil {
		return err
	}
	if preRsp.Errno != ErrorNoSuccess {
		if preRsp.Errno == ErrorNoAccessToken {
			d.refreshAccessToken()
		}
		return fmt.Errorf("baidu netdisk (Upload precreate) error: [%d] %s", preRsp.Errno, preRsp.ErrMsg)
	}
	uploadID := preRsp.UploadID
	// Upload block
	for _, partseq := range preRsp.BlockList {
		reqUrl = fmt.Sprintf("https://c.pcs.baidu.com/rest/2.0/pcs/superfile2?method=upload&access_token=%s&uploadid=%s&path=%s&type=tmpfile&partseq=%d", d.AccessToken(), uploadID, fullPath, partseq)
		body := &bytes.Buffer{}
		writer := multipart.NewWriter(body)
		start := partseq * 4 * 1024 * 1024
		end := (partseq + 1) * 4 * 1024 * 1024
		if end > len(fileData) {
			end = len(fileData)
		}
		part, err := writer.CreateFormFile("file", filepath.Base(fullPath))
		if err != nil {
			return fmt.Errorf("create form file error: %v", err)
		}
		_, err = part.Write(fileData[start:end])
		if err != nil {
			return fmt.Errorf("write form file error: %v", err)
		}
		err = writer.Close()
		if err != nil {
			return fmt.Errorf("close writer error: %v", err)
		}
		req, err := http.NewRequest("POST", reqUrl, body)
		if err != nil {
			return fmt.Errorf("create request error: %v", err)
		}
		req.Header.Set("Content-Type", writer.FormDataContentType())
		resp, err := d.httpc.Do(req)
		if err != nil {
			return fmt.Errorf("upload block error: %v", err)
		}
		var rsp struct {
			Errno  int    `json:"error_code"`
			ErrMsg string `json:"error_msg"`
		}
		data, err := io.ReadAll(resp.Body)
		if err != nil {
			return fmt.Errorf("upload block error: %v", err)
		}
		if err := json.Unmarshal(data, &rsp); err != nil {
			return fmt.Errorf("upload block error: %v", err)
		}
		if rsp.Errno != ErrorNoSuccess {
			if rsp.Errno == ErrorNoAccessToken {
				d.refreshAccessToken()
			}
			return fmt.Errorf("baidu netdisk (Upload block) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
		}
		if resp.StatusCode != http.StatusOK {
			return fmt.Errorf("upload block error: %s", resp.Status)
		}
		resp.Body.Close()
	}
	// Create file
	reqUrl = fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=create&access_token=%s", d.AccessToken())
	formData = url.Values{
		"path":       {fullPath},
		"size":       {fmt.Sprintf("%d", size)},
		"isdir":      {"0"},
		"rtype":      {"3"},
		"uploadid":   {uploadID},
		"block_list": {blockListStr},
	}
	resp, err = http.PostForm(reqUrl, formData)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	var createRsp generalRsp
	if err := json.NewDecoder(resp.Body).Decode(&createRsp); err != nil {
		return err
	}
	if createRsp.Errno != ErrorNoSuccess {
		if createRsp.Errno == ErrorNoAccessToken {
			d.refreshAccessToken()
		}
		return fmt.Errorf("baidu netdisk (Upload create) error: [%d] %s", createRsp.Errno, createRsp.ErrMsg)
	}
	return nil
}

func (d *BaiduNetdisk) Range(dir string, deal func(fs.FileInfo) bool) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path not set")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return err
		}
	}
	fullpath := filepath.ToSlash(filepath.Join(d.rootPath, dir))
	err := d.rangeFullDir(fullpath, deal)
	return err
}

func (d *BaiduNetdisk) rangeFullDir(fullDir string, deal func(fs.FileInfo) bool) error {
	start := 0
	for {
		reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=%s&dir=%s&order=time&desc=1&limit=1000&start=%d", d.AccessToken(), fullDir, start)
		req, err := http.NewRequest("GET", reqUrl, nil)
		if err != nil {
			return err
		}
		req.Header.Set("User-Agent", "pan.baidu.com")
		resp, err := d.httpc.Do(req)
		if err != nil {
			return err
		}
		defer resp.Body.Close()
		var rsp struct {
			generalRsp
			List []BaiduFileInfo `json:"list"`
		}
		data, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		if err := json.Unmarshal(data, &rsp); err != nil {
			return err
		}
		if rsp.Errno != ErrorNoSuccess {
			if rsp.Errno == ErrorNoAccessToken {
				d.refreshAccessToken()
			}
			return fmt.Errorf("baidu netdisk (Range) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
		}
		for i, item := range rsp.List {
			clone := item
			d.fsIDMap.Store(item.Path, &clone)
			if !deal(&rsp.List[i]) {
				return nil
			}
		}
		if len(rsp.List) < 1000 {
			break
		}
		start += 1000
	}
	return nil
}

func (d *BaiduNetdisk) refreshFileInfo(fullpath string) error {
	dir := filepath.Dir(fullpath)
	err := d.rangeFullDir(dir, func(fi fs.FileInfo) bool {
		if fi.Name() == filepath.Base(fullpath) {
			return false
		}
		return true
	})
	return err
}

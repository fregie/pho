package baidu

import (
	"bytes"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"log"
	"mime/multipart"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

const (
	PhoAppKey    = "8wylQfdIzIpNFOGHZSnOOQ98QLDFvl1U"
	PhoSecretKey = "lKAurWfMvbUqPddUmOFVgim3Ui1oM56M"
	// androidDefaultTempFilePath = "/data/data/com.example.img_syncer/baidu_tmp"
)

type BaiduNetdisk struct {
	refreshToken  string
	accessToken   string
	TokenExpireAt int64
	tokenLock     sync.RWMutex
	rootPath      string
	httpc         *http.Client
	// fsIDMap       sync.Map
	dlinkMap   sync.Map
	dlinkChan  chan string
	fsCache    *fsNode
	cacheRLock sync.RWMutex
	tmpFileDir string
}

type generalRsp struct {
	Errno  int    `json:"errno"`
	ErrMsg string `json:"errmsg"`
}

func NewBaiduNetdiskDrive(refreshToken, accessToken string) (*BaiduNetdisk, error) {
	d := &BaiduNetdisk{
		refreshToken: refreshToken,
		accessToken:  accessToken,
		httpc: &http.Client{
			Transport: &http.Transport{
				Proxy: http.ProxyFromEnvironment,
				DialContext: (&net.Dialer{
					KeepAlive: 30 * time.Second, // 设置TCP连接的保活时间
				}).DialContext,
				MaxIdleConns:          100,              // 最大空闲连接数
				MaxIdleConnsPerHost:   10,               // 每个主机的最大空闲连接数
				IdleConnTimeout:       90 * time.Second, // 空闲连接超时时间
				TLSHandshakeTimeout:   10 * time.Second, // TLS握手超时时间
				ExpectContinueTimeout: 1 * time.Second,  // 等待`Expect: 100-continue`响应超时时间
			},
		},
		rootPath:  "/apps/pho",
		dlinkChan: make(chan string, 100),
	}
	go d.dlinkCacher()
	err := d.MkdirAll(d.rootPath)
	if err != nil {
		return nil, fmt.Errorf("mkdir root path[%s] error: %v", d.rootPath, err)
	}
	return d, nil
}

func (d *BaiduNetdisk) SetTmpDir(dir string) {
	d.tmpFileDir = dir
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
	return d.isDirExist(fullPath)
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
	downloadLink, fileSize, err := d.getDlink(fullPath)
	if err != nil {
		return nil, 0, fmt.Errorf("get download link error: %v", err)
	}
	req, err := http.NewRequest("GET", fmt.Sprintf("%s&access_token=%s", downloadLink, d.AccessToken()), nil)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	if offset > 0 {
		req.Header.Set("Range", fmt.Sprintf("bytes=%d-", offset))
	}
	resp, err := d.httpc.Do(req)
	if err != nil {
		return nil, 0, err
	}
	return resp.Body, fileSize, nil
}

func (d *BaiduNetdisk) getDlink(fullPath string) (string, int64, error) {
	v1, ok := d.dlinkMap.Load(fullPath)
	if ok {
		info := v1.(*BaiduFileInfo)
		if info.Dlink != "" || info.Size() != 0 {
			return info.Dlink, info.Size(), nil
		}
	}
	retried := 0
RETRY:
	fsID, err := d.getFsID(fullPath)
	if err != nil {
		return "", 0, fmt.Errorf("get fsid error: %v", err)
	}

	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&access_token=%s&fsids=[%d]&dlink=1", d.AccessToken(), fsID)
	req, err := http.NewRequest("GET", reqUrl, nil)
	if err != nil {
		return "", 0, err
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	resp, err := d.httpc.Do(req)
	if err != nil {
		return "", 0, err
	}
	defer resp.Body.Close()
	var rsp struct {
		generalRsp
		List []BaiduFileInfo `json:"list"`
	}
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", 0, err
	}
	if err := json.Unmarshal(data, &rsp); err != nil {
		return "", 0, err
	}
	if rsp.Errno != ErrorNoSuccess {
		if rsp.Errno == ErrorNoAccessToken {
			d.refreshAccessToken()
		}
		return "", 0, fmt.Errorf("baidu netdisk (DownloadWithOffset) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
	}
	if len(rsp.List) != 1 {
		// 可能是fsid索引过期,刷新后重试
		err = d.refreshFileInfo(fullPath)
		if err == nil && retried < 1 {
			retried++
			goto RETRY
		}
		return "", 0, fmt.Errorf("baidu netdisk error: file not exist")
	}
	dlink := rsp.List[0].Dlink
	size := rsp.List[0].Size()
	if dlink == "" || size == 0 {
		return "", 0, fmt.Errorf("baidu netdisk error: dlink is empty or size is 0")
	}
	d.dlinkMap.Store(fullPath, &rsp.List[0])
	return rsp.List[0].Dlink, rsp.List[0].Size(), nil
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
	// if size >= 100*1024*1024 {
	// 	return fmt.Errorf("file size too large, only support file size less than 100MB for now")
	// }
	if d.rootPath == "" {
		return fmt.Errorf("root path not set")
	}
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return err
		}
	}
	if d.tmpFileDir == "" {
		return fmt.Errorf("tmp file dir not set")
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
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=precreate&access_token=%s", d.AccessToken())
	blockMd5 := md5.New()
	blockList := make([]string, 0)
	buf := make([]byte, 4*1024*1024)
	tmpFilePath := filepath.Join(d.tmpFileDir, fmt.Sprintf("baidu_tmp_%s", filepath.Base(fullPath)))
	tmpFile, err := os.OpenFile(tmpFilePath, os.O_CREATE|os.O_TRUNC|os.O_RDWR, 0644)
	if err != nil {
		return fmt.Errorf("open temp file error: %v", err)
	}
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
		_, err = tmpFile.Write(buf[:n])
		if err != nil {
			return fmt.Errorf("write temp file error: %v", err)
		}
		if finishRead {
			break
		}
	}
	err = tmpFile.Sync()
	if err != nil {
		return fmt.Errorf("sync temp file error: %v", err)
	}
	tmpFile.Close()
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
	wg := sync.WaitGroup{}
	wg.Add(len(preRsp.BlockList))
	var e error

	tmpFile, err = os.OpenFile(tmpFilePath, os.O_RDONLY, 0644)
	if err != nil {
		return fmt.Errorf("open temp file error: %v", err)
	}
	for _, partseq := range preRsp.BlockList {
		buffer := make([]byte, 4*1024*1024)
		n, err := io.ReadFull(tmpFile, buffer)
		if err != nil {
			if err == io.EOF || err == io.ErrUnexpectedEOF {
			} else {
				return fmt.Errorf("read temp file error: %v", err)
			}
		}
		go func(partseq int) {
			defer wg.Done()
			time.Sleep(time.Duration(partseq) * 100 * time.Millisecond)
			reqUrl = fmt.Sprintf("https://c.pcs.baidu.com/rest/2.0/pcs/superfile2?method=upload&access_token=%s&uploadid=%s&path=%s&type=tmpfile&partseq=%d", d.AccessToken(), uploadID, fullPath, partseq)
			body := &bytes.Buffer{}
			writer := multipart.NewWriter(body)
			part, err := writer.CreateFormFile("file", filepath.Base(fullPath))
			if err != nil {
				e = fmt.Errorf("create form file error: %v", err)
				return
			}
			_, err = part.Write(buffer[:n])
			if err != nil {
				e = fmt.Errorf("write form file error: %v", err)
				return
			}
			err = writer.Close()
			if err != nil {
				e = fmt.Errorf("close writer error: %v", err)
				return
			}
			req, err := http.NewRequest("POST", reqUrl, body)
			if err != nil {
				e = fmt.Errorf("create request error: %v", err)
				return
			}
			req.Header.Set("Content-Type", writer.FormDataContentType())
			resp, err := d.httpc.Do(req)
			if err != nil {
				e = fmt.Errorf("upload block error: %v", err)
				return
			}
			defer resp.Body.Close()
			var rsp struct {
				Errno  int    `json:"error_code"`
				ErrMsg string `json:"error_msg"`
			}
			data, err := io.ReadAll(resp.Body)
			if err != nil {
				e = fmt.Errorf("upload block error: %v", err)
				return
			}
			if err := json.Unmarshal(data, &rsp); err != nil {
				e = fmt.Errorf("upload block error: %v", err)
				return
			}
			if rsp.Errno != ErrorNoSuccess {
				if rsp.Errno == ErrorNoAccessToken {
					d.refreshAccessToken()
				}
				if rsp.Errno == 10 {
					return
				}
				e = fmt.Errorf("baidu netdisk (Upload block) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
				return
			}
			if resp.StatusCode != http.StatusOK {
				e = fmt.Errorf("upload block error: %s", resp.Status)
				return
			}
		}(partseq)
	}
	wg.Wait()
	if e != nil {
		return e
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
	if fullpath == d.rootPath {
		d.cacheDir(true)
	}
	err := d.rangeFullDir(fullpath, deal)
	return err
}

func (d *BaiduNetdisk) refreshFileInfo(fullpath string) error {
	dir := filepath.Dir(fullpath)
	err := d.rangeFullDir(dir, func(fi fs.FileInfo) bool {
		return true
	})
	return err
}

func (d *BaiduNetdisk) dlinkCacher() {
	ticker := time.NewTicker(2 * time.Second)
	fsIDs := make([]string, 0, 100)
	for {
		select {
		case fsID := <-d.dlinkChan:
			_, ok := d.dlinkMap.Load(fsID)
			if !ok {
				fsIDs = append(fsIDs, fsID)
			}
			if len(fsIDs) >= 100 {
				go func(fsIDs []string) {
					err := d.cacheDlinks(fsIDs)
					if err != nil {
						log.Printf("cache dlinks error: %v", err)
					}
				}(fsIDs)
				fsIDs = make([]string, 0, 100)
				ticker.Reset(2 * time.Second)
			}
		case <-ticker.C:
			if len(fsIDs) > 0 {
				go func(fsIDs []string) {
					err := d.cacheDlinks(fsIDs)
					if err != nil {
						log.Printf("cache dlinks error: %v", err)
					}
				}(fsIDs)
				fsIDs = make([]string, 0, 100)
			}
		}
	}
}

func (d *BaiduNetdisk) cacheDlinks(fsIDs []string) error {
	if len(fsIDs) == 0 {
		return nil
	}
	for start := 0; start < len(fsIDs); start += 100 {
		end := start + 100
		if end > len(fsIDs) {
			end = len(fsIDs)
		}
		reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&access_token=%s&fsids=[%s]&dlink=1", d.AccessToken(), strings.Join(fsIDs[start:end], ","))
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
			return fmt.Errorf("baidu netdisk (DownloadWithOffset) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
		}
		for i := range rsp.List {
			if rsp.List[i].Dlink != "" && rsp.List[i].Size() > 0 {
				d.dlinkMap.Store(rsp.List[i].Path, &rsp.List[i])
			}
		}
	}

	return nil
}

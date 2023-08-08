package baidu

import (
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type BaiduFileInfo struct {
	FsID             uint64 `json:"fs_id"`
	Path             string `json:"path"`
	Dlink            string `json:"dlink"`
	ServerFilename   string `json:"server_filename"`
	FileSize         uint   `json:"size"` // Byte
	ServerModifyTime uint   `json:"server_mtime"`
	ServerCreateTime uint   `json:"server_ctime"`
	LocalModifyTime  uint   `json:"local_mtime"`
	LocalCreateTime  uint   `json:"local_ctime"`
	FileIsDir        uint   `json:"isdir"` // 0:file 1:dir
}

func (i *BaiduFileInfo) Name() string {
	return i.ServerFilename
}
func (i *BaiduFileInfo) Size() int64 {
	return int64(i.FileSize)
}
func (i *BaiduFileInfo) Mode() fs.FileMode {
	if i.FileIsDir == 1 {
		return fs.ModeDir
	}
	return 0
}
func (i *BaiduFileInfo) ModTime() time.Time {
	return time.Unix(int64(i.ServerModifyTime), 0)
}
func (i *BaiduFileInfo) IsDir() bool {
	return i.FileIsDir == 1
}
func (i *BaiduFileInfo) Sys() any {
	return nil
}

func (d *BaiduNetdisk) isDirExist(fullpath string) (bool, error) {
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return false, err
		}
	}
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=%s&dir=%s&folder=1", d.AccessToken(), fullpath)
	req, err := http.NewRequest("GET", reqUrl, nil)
	if err != nil {
		return false, err
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	resp, err := d.httpc.Do(req)
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()
	var rsp generalRsp
	if err := json.NewDecoder(resp.Body).Decode(&rsp); err != nil {
		return false, err
	}
	switch rsp.Errno {
	case ErrorNoSuccess:
		return true, nil
	case ErrorNoFileNotExist, ErrorNoFileNotExist2, ErrorNoFileNotExist3:
		return false, nil
	}
	return false, fmt.Errorf("baidu netdisk(isExist) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
}

func (d *BaiduNetdisk) MkdirAll(dirPath string) (err error) {
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return err
		}
	}
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=create&access_token=%s", d.AccessToken())
	formData := url.Values{
		"path":  {dirPath},
		"isdir": {"1"},
		"rtype": {"0"},
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
		} else if rsp.Errno == ErrorAlreadyExists {
			return nil
		}
		return fmt.Errorf("baidu netdisk (Mkdir) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
	}

	return nil
}

type fsNode struct {
	name       string
	isDir      bool
	info       *BaiduFileInfo
	children   map[string]*fsNode
	UpdateTime time.Time
}

func (d *BaiduNetdisk) cacheDir(force bool) error {
	d.cacheRLock.Lock()
	defer d.cacheRLock.Unlock()
	if !force && d.fsCache != nil && time.Since(d.fsCache.UpdateTime) < 10*time.Minute {
		return nil
	}
	d.fsCache = &fsNode{
		name:       "",
		isDir:      true,
		UpdateTime: time.Now(),
		children:   make(map[string]*fsNode),
	}
	start := 0
	limit := 2000
	for {
		reqUrl := fmt.Sprintf("http://pan.baidu.com/rest/2.0/xpan/multimedia?method=listall&path=%s&access_token=%s&web=1&recursion=1&start=%d&limit=%d&order=time", d.rootPath, d.AccessToken(), start, limit)
		req, err := http.NewRequest("GET", reqUrl, nil)
		if err != nil {
			return fmt.Errorf("create request error: %v", err)
		}
		req.Header.Set("User-Agent", "pan.baidu.com")
		resp, err := d.httpc.Do(req)
		if err != nil {
			return fmt.Errorf("do request error: %v", err)
		}
		defer resp.Body.Close()
		var rsp struct {
			generalRsp
			Cursor  int             `json:"cursor"`
			HasMore int             `json:"has_more"`
			List    []BaiduFileInfo `json:"list"`
		}
		data, err := io.ReadAll(resp.Body)
		if err != nil {
			return fmt.Errorf("read response error: %v", err)
		}
		if err := json.Unmarshal(data, &rsp); err != nil {
			return fmt.Errorf("unmarshal response error: %v", err)
		}
		if rsp.Errno != ErrorNoSuccess {
			if rsp.Errno == ErrorNoAccessToken {
				d.refreshAccessToken()
			}
			return fmt.Errorf("baidu netdisk (cacheDir) error: [%d] %s", rsp.Errno, rsp.ErrMsg)
		}
		for i, item := range rsp.List {
			eles := strings.Split(item.Path, "/")
			currentDir := d.fsCache
			for j, name := range eles {
				if name == "" {
					continue
				}
				isDir := true
				if j == len(eles)-1 && item.FileIsDir == 0 {
					isDir = false
				}
				v, ok := currentDir.children[name]
				if !ok {
					v = &fsNode{
						name:       name,
						isDir:      isDir,
						children:   make(map[string]*fsNode),
						UpdateTime: time.Now(),
					}
					if j == len(eles)-1 {
						v.info = &rsp.List[i]
					} else {
						v.info = &BaiduFileInfo{
							FileIsDir:      1,
							ServerFilename: name,
							Path:           "/" + strings.Join(eles[:j+1], "/"),
						}
						if len(v.info.Path) > 0 && v.info.Path[0] != '/' {
							v.info.Path = "/" + v.info.Path
						}
					}
					currentDir.children[name] = v
				}
				currentDir = v
			}
			if item.FsID != 0 {
				d.dlinkChan <- strconv.FormatUint(item.FsID, 10)
			}
		}
		if rsp.HasMore == 0 {
			break
		}
		start = rsp.Cursor
	}
	return nil
}

func (d *BaiduNetdisk) getFsID(fullPath string) (uint64, error) {
	if d.getRootFsNode() == nil {
		err := d.cacheDir(false)
		if err != nil {
			return 0, fmt.Errorf("cache dir error: %v", err)
		}
	}
	retried := false
RETRY:
	eles := strings.Split(fullPath, "/")
	currentDir := d.getRootFsNode()
	for _, name := range eles {
		if name == "" {
			continue
		}
		v, ok := currentDir.children[name]
		if !ok {
			if !retried {
				err := d.cacheDir(true)
				if err != nil {
					return 0, fmt.Errorf("cache dir error: %v", err)
				}
				retried = true
				goto RETRY
			}
			return 0, fmt.Errorf("path not exist: %s", fullPath)
		}
		currentDir = v
	}
	if currentDir.isDir {
		return 0, fmt.Errorf("path is dir: %s", fullPath)
	}
	return currentDir.info.FsID, nil
}

func (d *BaiduNetdisk) getRootFsNode() *fsNode {
	d.cacheRLock.RLock()
	defer d.cacheRLock.RUnlock()
	return d.fsCache
}

func (d *BaiduNetdisk) rangeFullDir(fullDir string, deal func(fs.FileInfo) bool) error {
	eles := strings.Split(fullDir, "/")
	currentDir := d.getRootFsNode()
	if currentDir == nil || time.Since(currentDir.UpdateTime) > 10*time.Minute {
		err := d.cacheDir(true)
		if err != nil {
			log.Printf("cache dir error: %v", err)
			goto NOCACHE
		}
		currentDir = d.getRootFsNode()
	}
	for _, name := range eles {
		if name == "" {
			continue
		}
		v, ok := currentDir.children[name]
		if !ok {
			log.Printf("not found %s in %s", name, fullDir)
			goto NOCACHE
		}
		currentDir = v
	}
	if !currentDir.isDir {
		log.Printf("%s is not dir", currentDir.name)
		goto NOCACHE
	}
	for _, v := range currentDir.children {
		info := *v.info
		if !deal(&info) {
			break
		}
	}
	return nil

NOCACHE:
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
			if !item.IsDir() {
				clone := item
				// d.fsIDMap.Store(clone.Path, &clone)
				d.dlinkChan <- strconv.FormatUint(clone.FsID, 10)
			}
			clone := rsp.List[i]
			if !deal(&clone) {
				goto FINISH
			}
		}
		if len(rsp.List) < 1000 {
			break
		}
		start += 1000
	}
FINISH:
	return nil
}

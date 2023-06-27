package baidu

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"net/url"
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

func (d *BaiduNetdisk) isExist(fullpath string, isDir bool) (bool, error) {
	if !d.isTokenAvaliable() {
		if err := d.refreshAccessToken(); err != nil {
			return false, err
		}
	}
	paraFolder := "0"
	if isDir {
		paraFolder = "1"
	}
	reqUrl := fmt.Sprintf("https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=%s&dir=%s&folder=%s", d.AccessToken(), fullpath, paraFolder)
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

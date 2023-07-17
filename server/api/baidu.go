package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	login_success_html "github.com/fregie/img_syncer/assets/html/login_success"
	pb "github.com/fregie/img_syncer/proto"
	baidu "github.com/fregie/img_syncer/server/drive/baidu"
)

type authRsp struct {
	Error        string `json:"error"`
	ErrDesc      string `json:"error_description"`
	RefreshToken string `json:"refresh_token"`
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
}

func (a *api) SetDriveBaiduNetDisk(ctx context.Context, req *pb.SetDriveBaiduNetDiskRequest) (rsp *pb.SetDriveBaiduNetDiskResponse, e error) {
	rsp = &pb.SetDriveBaiduNetDiskResponse{Success: true}
	if req.RefreshToken == "" {
		rsp.Success, rsp.Message = false, "param error: refresh token is empty"
		return
	}
	d, err := baidu.NewBaiduNetdiskDrive(req.RefreshToken, req.AccessToken)
	if err != nil {
		rsp.Success, rsp.Message = false, err.Error()
		return
	}
	if req.TmpDir != "" {
		d.SetTmpDir(req.TmpDir)
	}
	a.im.SetDrive(d)
	return
}

func (a *api) StartBaiduNetdiskLogin(ctx context.Context, req *pb.StartBaiduNetdiskLoginRequest) (rsp *pb.StartBaiduNetdiskLoginResponse, e error) {
	rsp = &pb.StartBaiduNetdiskLoginResponse{Success: true}
	if a.baiduLogginInChan != nil {
		rsp.Success, rsp.Message = false, "login in progress"
		return
	}
	newCtx, cancel := context.WithTimeout(ctx, 5*time.Minute)
	defer cancel()
	a.baiduLogginInChan = make(chan *pb.StartBaiduNetdiskLoginResponse)
	select {
	case <-newCtx.Done():
		rsp.Success, rsp.Message = false, "login timeout"
	case rsp = <-a.baiduLogginInChan:
	}
	if rsp.Success && req.TmpDir != "" {
		d := a.im.Drive()
		baidu, ok := d.(*baidu.BaiduNetdisk)
		if ok {
			baidu.SetTmpDir(req.TmpDir)
		}
	}
	close(a.baiduLogginInChan)
	a.baiduLogginInChan = nil
	return
}

var finishLock sync.Mutex

func (a *api) finishBaiduLogin(rsp *pb.StartBaiduNetdiskLoginResponse) {
	finishLock.Lock()
	defer finishLock.Unlock()
	if a.baiduLogginInChan != nil {
		a.baiduLogginInChan <- rsp
	}
}

func (a *api) httpBaiduCallback(w http.ResponseWriter, r *http.Request) {
	loginRsp := &pb.StartBaiduNetdiskLoginResponse{Success: true}
	var err error
	defer func() {
		if err != nil {
			loginRsp.Success, loginRsp.Message = false, err.Error()
		}
		a.finishBaiduLogin(loginRsp)
	}()
	code := r.URL.Query().Get("code")
	if code == "" {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("code is empty"))
		return
	}
	reqUrl := fmt.Sprintf("https://openapi.baidu.com/oauth/2.0/token?grant_type=authorization_code&code=%s&client_id=%s&client_secret=%s&redirect_uri=http://localhost.pho.tools:%d/baidu/callback", code, baidu.PhoAppKey, baidu.PhoSecretKey, a.httpPort)
	req, err := http.NewRequest(http.MethodGet, reqUrl, nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	req.Header.Set("User-Agent", "pan.baidu.com")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	var auth authRsp
	err = json.Unmarshal(body, &auth)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	if auth.Error != "" {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(auth.ErrDesc))
		return
	}
	d, err := baidu.NewBaiduNetdiskDrive(auth.RefreshToken, auth.AccessToken)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	loginRsp.RefreshToken = auth.RefreshToken
	loginRsp.AccessToken = auth.AccessToken
	loginRsp.ExiresAt = int64(auth.ExpiresIn) + time.Now().Unix()
	a.im.SetDrive(d)
	w.Write(login_success_html.Html)
}

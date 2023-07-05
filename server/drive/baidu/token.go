package baidu

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

type tokenResp struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExipresIn    int    `json:"expires_in"`
}

func (d *BaiduNetdisk) RefreshToken() string {
	d.tokenLock.RLock()
	defer d.tokenLock.RUnlock()
	return d.refreshToken
}

func (d *BaiduNetdisk) AccessToken() string {
	d.tokenLock.RLock()
	defer d.tokenLock.RUnlock()
	return d.accessToken
}

func (d *BaiduNetdisk) isTokenAvaliable() bool {
	d.tokenLock.RLock()
	defer d.tokenLock.RUnlock()
	if d.accessToken == "" {
		return false
	}
	if d.TokenExpireAt > 0 && d.TokenExpireAt < time.Now().Unix() {
		return false
	}
	return true
}

func (d *BaiduNetdisk) refreshAccessToken() error {
	if d.refreshToken == "" {
		return fmt.Errorf("refresh token is empty")
	}
	url := fmt.Sprintf("https://openapi.baidu.com/oauth/2.0/token?grant_type=refresh_token&refresh_token=%s&client_id=%s&client_secret=%s", d.RefreshToken(), PhoAppKey, PhoSecretKey)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}
	resp, err := d.httpc.Do(req)
	if err != nil {
		return fmt.Errorf("refresh token failed: %v", err)
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(resp.Body)
	log.Printf("refresh token resp: %s", string(data))
	var token tokenResp
	if err := json.Unmarshal(data, &token); err != nil {
		return fmt.Errorf("refresh token failed: %v", err)
	}
	d.tokenLock.Lock()
	d.accessToken = token.AccessToken
	d.refreshToken = token.RefreshToken
	d.TokenExpireAt = time.Now().Unix() + int64(token.ExipresIn)
	d.tokenLock.Unlock()
	return nil
}

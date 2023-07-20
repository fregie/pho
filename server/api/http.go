package api

import (
	"fmt"
	"io"
	"log"
	"mime"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

func (a *api) SetHttpPort(port int) {
	a.httpPort = port
}

func (a *api) HttpHandler() http.Handler {
	return http.HandlerFunc(a.httpHandler)
}

func (a *api) httpHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/baidu/callback" {
		a.httpBaiduCallback(w, r)
		return
	}
	switch r.Method {
	case http.MethodGet:
		if strings.HasPrefix(r.URL.Path, "/thumbnail/") {
			a.httpDownloadThumbnail(w, r)
		} else {
			a.httpDownload(w, r)
		}
	case http.MethodPost:
		if strings.HasPrefix(r.URL.Path, "/thumbnail/") {
			a.httpUploadThumbnail(w, r)
		} else {
			a.httpUpload(w, r)
		}
	}
}

func (a *api) httpUpload(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	if path == "" {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if r.ContentLength == 0 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	date := r.Header.Get("Image-Date")
	length := r.ContentLength
	var err error
	dateTime, err := time.Parse("2006:01:02 15:04:05", date)
	if err != nil {
		dateTime = time.Now()
	}
	name := strings.TrimPrefix(path, "/")
	if isVideo(path) {
		err = a.im.UploadVideo(r.Body, nil, length, 0, encodeName(dateTime, name), dateTime)
	} else {
		err = a.im.UploadImg(r.Body, nil, length, 0, encodeName(dateTime, name), dateTime)
	}
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	r.Body.Close()
	w.WriteHeader(http.StatusOK)
}

func (a *api) httpUploadThumbnail(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	if path == "" {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if r.ContentLength == 0 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	name := strings.TrimPrefix(path, "/thumbnail/")
	date := r.Header.Get("Image-Date")
	length := r.ContentLength
	dateTime, err := time.Parse("2006:01:02 15:04:05", date)
	if err != nil {
		dateTime = time.Now()
	}
	err = a.im.UploadImg(nil, r.Body, 0, length, encodeName(dateTime, name), dateTime)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	r.Body.Close()
	w.WriteHeader(http.StatusOK)
}

func (a *api) httpDownload(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	if path == "" {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	contentType := mime.TypeByExtension(filepath.Ext(path))
	rangeHeader := r.Header.Get("Range")
	if rangeHeader != "" {
		rangeHeader = strings.TrimSpace(rangeHeader)
		kv := strings.Split(rangeHeader, "=")
		if len(kv) != 2 || kv[0] != "bytes" {
			http.Error(w, "bad range", http.StatusBadRequest)
			return
		}
		parts := strings.Split(kv[1], "-")
		if len(parts) == 0 {
			http.Error(w, "bad range", http.StatusBadRequest)
			return
		}
		start, err := strconv.ParseInt(parts[0], 10, 64)
		if err != nil {
			http.Error(w, "bad range", http.StatusBadRequest)
			return
		}
		img, err := a.im.GetOffset(path, start)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer img.Content.Close()
		var readLen int64 = img.Size - start
		end := img.Size - 1
		if len(parts) > 1 && parts[1] != "" {
			end, err = strconv.ParseInt(parts[1], 10, 64) // 解析 end 部分
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			if end > img.Size-1 {
				end = img.Size - 1
			}
			readLen = end - start + 1
		}
		w.Header().Add("Content-Type", contentType)
		w.Header().Add("Content-Length", strconv.FormatInt(readLen, 10))
		w.Header().Add("Content-Range", fmt.Sprintf("bytes %d-%d/%d", start, end, img.Size))
		w.WriteHeader(http.StatusPartialContent)
		_, err = io.CopyN(w, img.Content, readLen)
		if err != nil {
			log.Printf("Error copying image content: %v", err)
			return
		}
		return
	}

	img, err := a.im.GetImg(path)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	defer img.Content.Close()
	w.Header().Add("Content-Length", strconv.FormatInt(img.Size, 10))
	w.Header().Add("Content-Type", contentType)
	w.WriteHeader(http.StatusOK)
	_, err = io.Copy(w, img.Content)
	if err != nil {
		w.Write([]byte(err.Error()))
		return
	}
}

func (a *api) httpDownloadThumbnail(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	if path == "" {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	realPath := strings.TrimPrefix(path, "/thumbnail")
	img, err := a.im.GetThumbnail(realPath)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	contentType := mime.TypeByExtension(filepath.Ext(realPath))
	defer img.Content.Close()
	w.Header().Add("Content-Length", strconv.FormatInt(img.Size, 10))
	w.Header().Add("Content-Type", contentType)
	w.WriteHeader(http.StatusOK)
	_, err = io.Copy(w, img.Content)
	if err != nil {
		w.Write([]byte(err.Error()))
		return
	}
}

func encodeName(time time.Time, name string) string {
	return fmt.Sprintf("%s_%s", time.Format("20060102030405"), name)
}

func decodeName(encoded string) (time.Time, string, error) {
	if len(encoded) < 15 {
		return time.Time{}, "", fmt.Errorf("invalid encoded name")
	}
	timeStr := encoded[:14]
	name := encoded[15:]
	t, err := time.Parse("20060102030405", timeStr)
	if err != nil {
		return time.Time{}, "", err
	}
	return t, name, nil
}

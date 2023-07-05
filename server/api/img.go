package api

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"runtime/pprof"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/imgmanager"
)

type api struct {
	im                *imgmanager.ImgManager
	httpPort          int
	baiduLogginInChan chan *pb.StartBaiduNetdiskLoginResponse

	pb.UnimplementedImgSyncerServer
}

func NewApi(im *imgmanager.ImgManager) *api {
	a := &api{
		im: im,
	}
	return a
}

func (a *api) ListByDate(ctx context.Context, req *pb.ListByDateRequest) (rsp *pb.ListByDateResponse, err error) {
	rsp = &pb.ListByDateResponse{Success: true}
	if req.MaxReturn <= 0 {
		req.MaxReturn = 100
	}
	if req.Offset <= 0 {
		req.Offset = 0
	}
	var e error
	start := time.Now()
	if req.Date != "" {
		start, e = time.Parse("2006:01:02", req.Date)
		if e != nil {
			rsp.Success, rsp.Message = false, fmt.Sprintf("param error: date format error: %s", req.Date)
			return
		}
	}
	rsp.Paths = make([]string, 0, req.MaxReturn)
	offset := req.Offset
	needReturn := req.MaxReturn
	e = a.im.RangeByDate(start, func(path string, size int64) bool {
		if offset > 0 {
			offset--
			return true
		}
		rsp.Paths = append(rsp.Paths, path)
		needReturn--
		return needReturn > 0
	})
	if e != nil {
		rsp.Success, rsp.Message = false, e.Error()
		return
	}
	return
}

func (a *api) Delete(ctx context.Context, req *pb.DeleteRequest) (rsp *pb.DeleteResponse, err error) {
	rsp = &pb.DeleteResponse{Success: true}
	a.im.DeleteImg(req.Paths)
	return
}

func (a *api) FilterNotUploaded(ctx context.Context, req *pb.FilterNotUploadedRequest) (rsp *pb.FilterNotUploadedResponse, err error) {
	rsp = &pb.FilterNotUploadedResponse{Success: true}
	if len(req.Names) == 0 {
		rsp.Success, rsp.Message = false, "param error: names is empty"
		return
	}
	all := make(map[string]bool)
	a.im.RangeByDate(time.Now(), func(path string, size int64) bool {
		name := filepath.Base(path)
		all[name] = true
		return true
	})
	rsp.NotUploaed = make([]string, 0, 100)
	for _, name := range req.Names {
		if !all[name] {
			rsp.NotUploaed = append(rsp.NotUploaed, name)
		}
	}
	return
}

func saveGoroutineProfile() {
	f, err := os.Create("goroutine_profile.out")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create goroutine profile file: %v\n", err)
		return
	}
	defer f.Close()

	p := pprof.Lookup("goroutine")
	if p == nil {
		fmt.Fprintf(os.Stderr, "Failed to find goroutine profile\n")
		return
	}

	err = p.WriteTo(f, 1)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to write goroutine profile: %v\n", err)
	} else {
		fmt.Println("Goroutine profile saved to goroutine_profile.out")
	}
}

func isVideo(name string) bool {
	ext := filepath.Ext(name)
	switch ext {
	case ".mp4", ".avi", ".rmvb", ".rm", ".flv", ".wmv", ".mkv", ".mov", ".mpg", ".mpeg", ".3gp", ".3g2", ".asf", ".asx", ".vob", ".m2ts", ".mts", ".ts":
		return true
	}
	return false
}

package api

import (
	"context"
	"fmt"
	"io"
	"path/filepath"
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

func (a *api) FilterNotUploaded(stream pb.ImgSyncer_FilterNotUploadedServer) error {
	all := make(map[string]bool)
	a.im.RangeByDate(time.Now(), func(path string, size int64) bool {
		name := filepath.Base(path)
		all[name] = true
		return true
	})
	for {
		r, err := stream.Recv()
		if err != nil {
			if err == io.EOF {
				break
			}
			return err
		}
		rsp := &pb.FilterNotUploadedResponse{Success: true, IsFinished: r.IsFinished}
		rsp.NotUploaedIDs = make([]string, 0, len(r.Photos))
		for _, info := range r.Photos {
			t, err := time.Parse("2006:01:02 15:04:05", info.Date)
			if err != nil {
				continue
			}
			if !all[encodeName(t, info.Name)] {
				rsp.NotUploaedIDs = append(rsp.NotUploaedIDs, info.Id)
			}
		}
		if err := stream.Send(rsp); err != nil {
			return err
		}
		if rsp.IsFinished {
			break
		}
	}
	return nil
}

// func (a *api) FilterNotUploaded(ctx context.Context, req *pb.FilterNotUploadedRequest) (rsp *pb.FilterNotUploadedResponse, err error) {
// 	rsp = &pb.FilterNotUploadedResponse{Success: true}
// 	if len(req.Photos) == 0 {
// 		rsp.Success, rsp.Message = false, "param error: names is empty"
// 		return
// 	}
// 	all := make(map[string]bool)
// 	a.im.RangeByDate(time.Now(), func(path string, size int64) bool {
// 		name := filepath.Base(path)
// 		all[name] = true
// 		return true
// 	})
// 	rsp.NotUploaedIDs = make([]string, 0, 100)
// 	for _, info := range req.Photos {
// 		t, err := time.Parse("2006:01:02 15:04:05", info.Date)
// 		if err != nil {
// 			continue
// 		}
// 		if !all[encodeName(t, info.Name)] {
// 			rsp.NotUploaedIDs = append(rsp.NotUploaedIDs, info.Id)
// 		}
// 	}
// 	return
// }

func isVideo(name string) bool {
	ext := filepath.Ext(name)
	switch ext {
	case ".mp4", ".avi", ".rmvb", ".rm", ".flv", ".wmv", ".mkv", ".mov", ".mpg", ".mpeg", ".3gp", ".3g2", ".asf", ".asx", ".vob", ".m2ts", ".mts", ".ts":
		return true
	}
	return false
}

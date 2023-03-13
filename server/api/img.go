package api

import (
	"context"
	"fmt"
	"io"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/imgmanager"
)

type api struct {
	im *imgmanager.ImgManager
	pb.UnimplementedImgSyncerServer
}

func NewApi(im *imgmanager.ImgManager) *api {
	return &api{
		im: im,
	}
}

func (a *api) Hello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloResponse, error) {
	return &pb.HelloResponse{Message: "Hello " + in.Name}, nil
}

func (a *api) Upload(stream pb.ImgSyncer_UploadServer) error {
	rsp := &pb.UploadResponse{Success: true}
	req, err := stream.Recv()
	if err != nil {
		return err
	}
	if req.Name == "" {
		rsp.Success, rsp.Message = false, "param error: name is empty"
		return stream.SendAndClose(rsp)
	}
	reader, writer := io.Pipe()
	defer reader.Close()
	defer writer.Close()
	var e error
	go func() {
		defer writer.Close()
		if len(req.Data) > 0 {
			_, err = writer.Write(req.Data)
			if err != nil {
				e = err
				return
			}
		}
		for {
			req, err := stream.Recv()
			if err != nil {
				if err == io.EOF {
					break
				} else {
					e = err
					return
				}
			}
			_, err = writer.Write(req.Data)
			if err != nil {
				e = err
				return
			}
		}
	}()
	err = a.im.UploadImg(reader, req.Name, req.Date)
	if err != nil {
		rsp.Success, rsp.Message = false, err.Error()
		return stream.SendAndClose(rsp)
	}
	if e != nil {
		return e
	}
	return stream.SendAndClose(rsp)
}

func (a *api) Get(req *pb.GetRequest, stream pb.ImgSyncer_GetServer) error {
	if req.Path == "" {
		return fmt.Errorf("param error: path is empty")
	}
	img, err := a.im.GetImg(req.Path)
	if err != nil {
		return err
	}
	defer img.Content.Close()
	for {
		data := make([]byte, 64*1024)
		n, err := img.Content.Read(data)
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return err
			}
		}
		err = stream.Send(&pb.GetResponse{Data: data[:n]})
		if err != nil {
			return err
		}
	}

	return nil
}

func (a *api) GetThumbnail(ctx context.Context, req *pb.GetThumbnailRequest) (rsp *pb.GetThumbnailResponse, err error) {
	rsp = &pb.GetThumbnailResponse{Success: true}
	img, e := a.im.GetThumbnail(req.Path)
	if e != nil {
		rsp.Success, rsp.Message = false, e.Error()
		return
	}
	rsp.Data, e = io.ReadAll(img.Content)
	if e != nil {
		rsp.Success, rsp.Message = false, e.Error()
		return
	}
	return
}

func (a *api) ListByDate(ctx context.Context, req *pb.ListByDateRequest) (rsp *pb.ListByDateResponse, err error) {
	rsp = &pb.ListByDateResponse{Success: true}
	if req.Offset < 0 || req.MaxReturn < 0 {
		rsp.Success, rsp.Message = false, "param error: offset or maxReturn is less than 0"
		return
	}
	start, err := time.Parse("2006:01:02", req.Date)
	if err != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("param error: date format error: %s", req.Date)
		return
	}
	rsp.Paths = make([]string, 0, req.MaxReturn)
	offset := req.Offset
	needReturn := req.MaxReturn
	a.im.RangeByDate(start, func(path string, size int64) bool {
		if offset > 0 {
			offset--
			return true
		}
		rsp.Paths = append(rsp.Paths, path)
		needReturn--
		return needReturn > 0
	})
	return
}

func (a *api) Delete(ctx context.Context, req *pb.DeleteRequest) (rsp *pb.DeleteResponse, err error) {
	rsp = &pb.DeleteResponse{Success: true}
	a.im.DeleteImg(req.Paths)
	return
}

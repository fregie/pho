package api

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"runtime/pprof"
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
	thumbReader, thumbWriter := io.Pipe()
	defer reader.Close()
	defer thumbReader.Close()
	defer writer.Close()
	defer thumbWriter.Close()
	var e error
	go func() {
		defer writer.Close()
		defer thumbWriter.Close()
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
			if len(req.Data) > 0 {
				_, err = writer.Write(req.Data)
				if err != nil {
					e = err
					return
				}
			}
			if len(req.ThumbnailData) > 0 {
				_, err = thumbWriter.Write(req.ThumbnailData)
				if err != nil {
					e = err
					return
				}
			}
		}
	}()
	err = a.im.UploadImg(reader, thumbReader, req.Name, req.Date)
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
		stream.Send(&pb.GetResponse{Success: false, Message: "param error: path is empty"})
		return nil
	}
	img, err := a.im.GetImg(req.Path)
	if err != nil {
		stream.Send(&pb.GetResponse{Success: false, Message: err.Error()})
		return nil
	}
	defer img.Content.Close()
	data := make([]byte, 1024*10)
	for {
		n, err := img.Content.Read(data)
		if n > 0 {
			err = stream.Send(&pb.GetResponse{Data: data[:n], Success: true})
			if err != nil {
				return fmt.Errorf("send data error: %s", err.Error())
			}
		}
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return fmt.Errorf("read data error: %s", err.Error())
			}
		}
	}

	return nil
}

func (a *api) GetThumbnail(req *pb.GetThumbnailRequest, stream pb.ImgSyncer_GetThumbnailServer) error {
	if req.Path == "" {
		stream.Send(&pb.GetThumbnailResponse{Success: false, Message: "param error: path is empty"})
		return nil
	}
	img, e := a.im.GetThumbnail(req.Path)
	if e != nil {
		stream.Send(&pb.GetThumbnailResponse{Success: false, Message: fmt.Sprintf("get thumbnail %s error: %s", req.Path, e.Error())})
		return nil
	}
	defer img.Content.Close()
	data := make([]byte, 1024*10)
	for {
		n, err := img.Content.Read(data)
		if n > 0 {
			err = stream.Send(&pb.GetThumbnailResponse{Data: data[:n], Success: true})
			if err != nil {
				return err
			}
		}
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return err
			}
		}
	}
	return nil
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

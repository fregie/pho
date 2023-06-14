package main

import (
	"context"
	"io"
	"log"
	"os"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"google.golang.org/grpc"
)

func main() {
	grpcConn, err := grpc.Dial("192.168.100.233:10000", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}
	srv := pb.NewImgSyncerClient(grpcConn)
	f, err := os.Open("/home/fregie/download/20230606_124207.mp4")
	if err != nil {
		panic(err)
	}
	defer f.Close()
	cli, err := srv.Upload(context.Background())
	if err != nil {
		panic(err)
	}
	err = cli.Send(&pb.UploadRequest{
		Name: "20230606_124207.mp4",
		Date: "2023:06:07 17:34:33",
	})
	if err != nil {
		panic(err)
	}
	start := time.Now()
	transfered := 0
	buf := make([]byte, 1024*1024)
	for {
		n, err := f.Read(buf)
		if err != nil {
			if err == io.EOF {
				err = cli.Send(&pb.UploadRequest{
					Data: buf[:n],
				})
				if err != nil {
					panic(err)
				}
				transfered += n
				break
			}
			panic(err)
		}
		if n == 0 {
			break
		}
		err = cli.Send(&pb.UploadRequest{
			Data: buf[:n],
		})
		if err != nil {
			panic(err)
		}
		transfered += n
	}
	rsp, err := cli.CloseAndRecv()
	if err != nil {
		panic(err)
	}
	if !rsp.Success {
		panic(rsp.Message)
	}
	log.Printf("upload success, size: %d, time: %s, speed: %dmbps", transfered, time.Since(start).String(), transfered*8/int(time.Since(start).Seconds())/1024/1024)
}

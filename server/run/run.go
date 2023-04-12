package run

import (
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"os"

	"github.com/fregie/img_syncer/server/api"
	"github.com/fregie/img_syncer/server/imgmanager"
	_ "golang.org/x/mobile/bind"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	pb "github.com/fregie/img_syncer/proto"
)

var (
	imgManager *imgmanager.ImgManager
)

func RunGrpcServer() (int, error) {
	imgManager = imgmanager.NewImgManager(imgmanager.Option{})
	var lis net.Listener
	var err error
	var port int
	for start := 10000; start < 20000; start++ {
		lis, err = net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", start))
		if err != nil {
			Info.Printf("Listen on %d failed, try next port", start)
			continue
		} else {
			port = start
			break
		}
	}
	if err != nil {
		Error.Printf("Listen on all port failed, err: %v", err)
		return 0, err
	}

	api := api.NewApi(imgManager)
	grpcServer := grpc.NewServer()
	pb.RegisterImgSyncerServer(grpcServer, api)
	reflection.Register(grpcServer)

	Info.Printf("Listening grpc on %s", lis.Addr().String())
	go grpcServer.Serve(lis)
	return port, nil
}

var (
	//Debug print debug informantion
	Debug *log.Logger
	//Info print Info informantion
	Info *log.Logger
	//Error print Error informantion
	Error *log.Logger
)

func init() {
	Info = log.New(os.Stdout, "[INFO] ", log.Ldate|log.Ltime)
	Error = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.Ltime|log.Lshortfile)
	Debug = log.New(ioutil.Discard, "[DEBUG] ", log.Ldate|log.Ltime|log.Lshortfile)
}

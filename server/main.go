package main

import (
	"flag"
	"net"
	"os"

	version "github.com/fregie/PrintVersion"
	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/api"
	"github.com/fregie/img_syncer/server/imgmanager"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr    = flag.String("grpcAddr", "0.0.0.0:50051", "grpc addr example: 0.0.0.0:50051")
	showVersion = flag.Bool("version", false, "Displays version and exit.")
	debug       = flag.Bool("d", false, "debug mode")
)

var (
	imgManager *imgmanager.ImgManager
)

func main() {
	flag.Parse()
	if *showVersion {
		version.PrintVersion()
		return
	}
	if *debug {
		Debug.SetOutput(os.Stdout)
	}
	imgManager = imgmanager.NewImgManager(imgmanager.Option{})

	lis, err := net.Listen("tcp", *grpcAddr)
	if err != nil {
		Error.Fatalf("failed to listen: %v", err)
	}

	api := api.NewApi(imgManager)

	grpcServer := grpc.NewServer()
	pb.RegisterImgSyncerServer(grpcServer, api)
	reflection.Register(grpcServer)
	Info.Printf("Listening grpc on %s", lis.Addr().String())
	Error.Fatal(grpcServer.Serve(lis))
}

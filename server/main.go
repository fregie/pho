package main

import (
	"flag"
	"net"
	"os"

	"net/http"
	_ "net/http/pprof"

	version "github.com/fregie/PrintVersion"
	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/api"
	"github.com/fregie/img_syncer/server/imgmanager"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr    = flag.String("grpcAddr", "0.0.0.0:50051", "grpc addr example: 0.0.0.0:50051")
	httpAddr    = flag.String("httpAddr", "0.0.0.0:8000", "http addr example: 0.0.0.0:8000")
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
		Debug.Printf("pprof listen at 0.0.0.0:6060")
		go http.ListenAndServe("0.0.0.0:6060", nil)
	}
	imgManager = imgmanager.NewImgManager(imgmanager.Option{})

	lis, err := net.Listen("tcp", *grpcAddr)
	if err != nil {
		Error.Fatalf("failed to listen: %v", err)
	}

	apiServer := api.NewApi(imgManager)
	Info.Printf("Listening http on %s", *httpAddr)
	go http.ListenAndServe(*httpAddr, apiServer.HttpHandler())

	grpcServer := grpc.NewServer()
	pb.RegisterImgSyncerServer(grpcServer, apiServer)
	reflection.Register(grpcServer)
	Info.Printf("Listening grpc on %s", lis.Addr().String())
	Error.Fatal(grpcServer.Serve(lis))
}

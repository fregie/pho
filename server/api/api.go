package api

import (
	"context"

	pb "github.com/fregie/img_syncer/proto"
)

type api struct {
	pb.UnimplementedImgSyncerServer
}

func NewApi() *api {
	return &api{}
}

func (a *api) Hello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloResponse, error) {
	return &pb.HelloResponse{Message: "Hello " + in.Name}, nil
}

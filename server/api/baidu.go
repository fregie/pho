package api

import (
	"context"

	pb "github.com/fregie/img_syncer/proto"
	baidu "github.com/fregie/img_syncer/server/drive/baidu"
)

func (a *api) SetDriveBaiduNetDisk(ctx context.Context, req *pb.SetDriveBaiduNetDiskRequest) (rsp *pb.SetDriveBaiduNetDiskResponse, e error) {
	rsp = &pb.SetDriveBaiduNetDiskResponse{Success: true}
	if req.RefreshToken == "" {
		rsp.Success, rsp.Message = false, "param error: refresh token is empty"
		return
	}
	d, err := baidu.NewBaiduNetdiskDrive(req.RefreshToken, req.AccessToken)
	if err != nil {
		rsp.Success, rsp.Message = false, err.Error()
		return
	}
	a.im.SetDrive(d)
	return
}

package api

import (
	"context"
	"fmt"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/drive/nfs"
)

func (a *api) SetDriveNFS(ctx context.Context, req *pb.SetDriveNFSRequest) (rsp *pb.SetDriveNFSResponse, e error) {
	rsp = &pb.SetDriveNFSResponse{Success: true}
	if req.Addr == "" {
		rsp.Success, rsp.Message = false, "param error: url is empty"
		return
	}
	d, err := nfs.NewNfsDrive(req.Addr)
	if err != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("new nfs drive failed: %s", err.Error())
		return
	}
	a.im.SetDrive(d)
	if req.Root != "" {
		err := d.SetRootPath(req.Root)
		if err != nil {
			rsp.Success, rsp.Message = false, fmt.Sprintf("set root path failed: %s", err.Error())
			return
		}
	}
	return
}

func (a *api) ListDriveNFSDir(ctx context.Context, req *pb.ListDriveNFSDirRequest) (rsp *pb.ListDriveNFSDirResponse, e error) {
	rsp = &pb.ListDriveNFSDirResponse{Success: true}
	dri := a.im.Drive()
	if dri == nil {
		rsp.Success, rsp.Message = false, "drive is not set"
		return
	}
	nfs, ok := dri.(*nfs.Nfs)
	if !ok {
		rsp.Success, rsp.Message = false, "drive is not nfs"
		return
	}
	if req.Dir == "" {
		req.Dir = "/"
	}
	rsp.Dirs = make([]string, 0)
	cli := nfs.Cli()
	if cli == nil {
		rsp.Success, rsp.Message = false, "nfs client is not set"
		return
	}
	infos, err := cli.ReadDirPlus(req.Dir)
	if err != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("list dir failed: %s", err.Error())
		return
	}
	for _, info := range infos {
		if info.IsDir() {
			rsp.Dirs = append(rsp.Dirs, info.Name())
		}
	}
	return
}

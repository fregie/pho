package api

import (
	"context"
	"fmt"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/drive/webdav"
)

func (a *api) SetDriveWebdav(ctx context.Context, req *pb.SetDriveWebdavRequest) (rsp *pb.SetDriveWebdavResponse, e error) {
	rsp = &pb.SetDriveWebdavResponse{Success: true}
	if req.Addr == "" {
		rsp.Success, rsp.Message = false, "param error: url is empty"
		return
	}
	d := webdav.NewWebdavDrive(req.Addr, req.Username, req.Password)
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

func (a *api) ListDriveWebdavDir(ctx context.Context, req *pb.ListDriveWebdavDirRequest) (rsp *pb.ListDriveWebdavDirResponse, e error) {
	rsp = &pb.ListDriveWebdavDirResponse{Success: true}
	dri := a.im.Drive()
	if dri == nil {
		rsp.Success, rsp.Message = false, "drive is not set"
		return
	}
	webdav, ok := dri.(*webdav.Webdav)
	if !ok {
		rsp.Success, rsp.Message = false, "drive is not webdav"
		return
	}
	if req.Dir == "" {
		req.Dir = "/"
	}
	rsp.Dirs = make([]string, 0)
	cli := webdav.Cli()
	if cli == nil {
		rsp.Success, rsp.Message = false, "webdav client is not set"
		return
	}
	infos, err := cli.ReadDir(req.Dir)
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

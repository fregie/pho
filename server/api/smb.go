package api

import (
	"context"
	"fmt"
	"net"
	"strings"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/server/drive/smb"
)

func (a *api) SetDriveSMB(ctx context.Context, req *pb.SetDriveSMBRequest) (rsp *pb.SetDriveSMBResponse, err error) {
	rsp = &pb.SetDriveSMBResponse{Success: true}
	if req.Addr == "" {
		rsp.Success, rsp.Message = false, "param error: addr is empty"
		return
	}
	if strings.Index(req.Addr, ":") < 0 {
		req.Addr = req.Addr + ":445"
	}
	_, e := net.Dial("tcp", req.Addr)
	if err != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("connect to %s failed: %s", req.Addr, e.Error())
		return
	}
	s := smb.NewSmbDrive(req.Addr, req.Username, req.Password)
	a.im.SetDrive(s)
	if req.Share != "" {
		e := s.SetShare(req.Share)
		if e != nil {
			rsp.Success, rsp.Message = false, fmt.Sprintf("set share failed: %s", e.Error())
			return
		}
		if req.Root != "" {
			e := s.SetRootPath(req.Root)
			if e != nil {
				rsp.Success, rsp.Message = false, fmt.Sprintf("set root path failed: %s", e.Error())
				return
			}
		}
	}
	return
}

func (a *api) ListDriveSMBShares(ctx context.Context, req *pb.ListDriveSMBSharesRequest) (rsp *pb.ListDriveSMBSharesResponse, err error) {
	rsp = &pb.ListDriveSMBSharesResponse{Success: true}
	dri := a.im.Drive()
	if dri == nil {
		rsp.Success, rsp.Message = false, "drive is not set"
		return
	}
	smb, ok := dri.(*smb.Smb)
	if !ok {
		rsp.Success, rsp.Message = false, "drive is not smb"
		return
	}
	shares, e := smb.ListShare()
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("list share failed: %s", e.Error())
		return
	}
	rsp.Shares = shares

	return
}

func (a *api) ListDriveSMBDir(ctx context.Context, req *pb.ListDriveSMBDirRequest) (rsp *pb.ListDriveSMBDirResponse, err error) {
	rsp = &pb.ListDriveSMBDirResponse{Success: true}
	dri := a.im.Drive()
	if dri == nil {
		rsp.Success, rsp.Message = false, "drive is not set"
		return
	}
	smb, ok := dri.(*smb.Smb)
	if !ok {
		rsp.Success, rsp.Message = false, "drive is not smb"
		return
	}
	if req.Dir == "" {
		req.Dir = "."
	}
	sess, e := smb.Dial()
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("dial failed: %s", e.Error())
		return
	}
	defer sess.Logoff()
	share, e := sess.Mount(req.Share)
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("mount share failed: %s", e.Error())
		return
	}
	defer share.Umount()
	infos, e := share.ReadDir(req.Dir)
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("read dir failed: %s", e.Error())
		return
	}
	rsp.Dirs = make([]string, 0)
	for _, info := range infos {
		if info.IsDir() {
			rsp.Dirs = append(rsp.Dirs, info.Name())
		}
	}

	return
}

func (a *api) SetDriveSMBShare(ctx context.Context, req *pb.SetDriveSMBShareRequest) (rsp *pb.SetDriveSMBShareResponse, err error) {
	rsp = &pb.SetDriveSMBShareResponse{Success: true}
	dri := a.im.Drive()
	if dri == nil {
		rsp.Success, rsp.Message = false, "drive is not set"
		return
	}
	smb, ok := dri.(*smb.Smb)
	if !ok {
		rsp.Success, rsp.Message = false, "drive is not smb"
		return
	}
	e := smb.SetShare(req.Share)
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("set share failed: %s", e.Error())
		return
	}
	e = smb.SetRootPath(req.Root)
	if e != nil {
		rsp.Success, rsp.Message = false, fmt.Sprintf("set root path failed: %s", e.Error())
		return
	}
	return
}

package api_test

import (
	"bytes"
	"io"
	"testing"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/test/static"
	"github.com/hirochachacha/go-smb2"
	"github.com/stretchr/testify/suite"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type DriveTestSuite struct {
	suite.Suite
	srv   pb.ImgSyncerClient
	share *smb2.Share
}

func TestDriveTestSuite(t *testing.T) {
	suite.Run(t, new(DriveTestSuite))
}

func (s *DriveTestSuite) SetupTest() {
	err := cleanSmb()
	s.Nilf(err, "failed to clean smb share: %s", err)
	err = initSmbDir()
	s.Nilf(err, "failed to init smb dir: %s", err)
	grpcConn, err := grpc.Dial(grpcAddr, grpc.WithInsecure())
	s.Nil(err)
	s.srv = pb.NewImgSyncerClient(grpcConn)
	s.share, err = initSmbShare()
	s.Nil(err)
}

func (s *DriveTestSuite) TestSetDriveSMB() {
	ctx := context.Background()
	// test set drive smb
	rsp1, err := s.srv.SetDriveSMB(ctx, &pb.SetDriveSMBRequest{
		Addr:     smbSrvAddr,
		Username: smbUser,
		Password: smbPass,
	})
	s.Nil(err)
	s.True(rsp1.Success)
	// test list drive smb shares
	rsp2, err := s.srv.ListDriveSMBShares(ctx, &pb.ListDriveSMBSharesRequest{})
	s.Nil(err)
	s.Truef(rsp2.Success, "failed to list smb shares: %s", rsp2.Message)
	s.Containsf(rsp2.Shares, smbShare, "shares %v not contains %s", rsp2.Shares, smbShare)
	rsp2_1, err := s.srv.ListDriveSMBDir(ctx, &pb.ListDriveSMBDirRequest{
		Share: smbShare,
		Dir:   ".",
	})
	s.Nil(err)
	s.Truef(rsp2_1.Success, "failed to list smb dir: %s", rsp2_1.Message)
	s.Containsf(rsp2_1.Dirs, smbRootDir, "files %v not contains %s", rsp2_1.Dirs, smbRootDir)
	// test set drive smb share
	rsp3, err := s.srv.SetDriveSMBShare(ctx, &pb.SetDriveSMBShareRequest{
		Share: smbShare,
		Root:  smbRootDir,
	})
	s.Nil(err)
	s.Truef(rsp3.Success, "failed to set smb share: %s", rsp3.Message)

	cli, err := s.srv.Upload(ctx)
	s.Nil(err)
	// test upload file
	reader := bytes.NewReader(static.Pic1)
	err = cli.Send(&pb.UploadRequest{
		Name: "pic1.jpg",
	})
	s.Nil(err)
	buf := make([]byte, 4096)
	for {
		n, err := reader.Read(buf)
		if err != nil {
			if err == io.EOF {
				break
			} else {
				s.Nil(err)
			}
		}
		err = cli.Send(&pb.UploadRequest{
			Data: buf[:n],
		})
		s.Nil(err)
	}
	rsp4, err := cli.CloseAndRecv()
	s.Nil(err)
	s.Truef(rsp4.Success, "failed to upload file: %s", rsp4.Message)
	filePath := "storage/2022/11/08/pic1.jpg"
	s.waitFile(filePath, 5*time.Second)
	fdata, err := s.share.ReadFile(filePath)
	s.Nilf(err, "failed to read file: %s", err)
	s.Equal(static.Pic1, fdata)
}

func (s *DriveTestSuite) waitFile(path string, timeout time.Duration) {
	start := time.Now()
	for {
		_, err := s.share.Stat(path)
		if err == nil {
			break
		}
		if time.Since(start) > timeout {
			s.FailNowf("wait file timeout", "wait file %s timeout", path)
		}
		time.Sleep(200 * time.Millisecond)
	}
}

package api_test

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"testing"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/test/static"
	"github.com/stretchr/testify/suite"
	"google.golang.org/grpc"
)

type ImageTestSuite struct {
	suite.Suite
	srv pb.ImgSyncerClient
}

func TestImageTestSuite(t *testing.T) {
	suite.Run(t, new(ImageTestSuite))
}

func (s *ImageTestSuite) SetupTest() {
	err := cleanSmb()
	s.Nilf(err, "failed to clean smb share: %s", err)
	err = initSmbDir()
	s.Nilf(err, "failed to init smb dir: %s", err)
	grpcConn, err := grpc.Dial(grpcAddr, grpc.WithInsecure())
	s.Nil(err)
	s.srv = pb.NewImgSyncerClient(grpcConn)
	s.setupSmbDrive()
}

func (s *ImageTestSuite) setupSmbDrive() {
	rsp1, err := s.srv.SetDriveSMB(context.Background(), &pb.SetDriveSMBRequest{
		Addr:     smbSrvAddr,
		Username: smbUser,
		Password: smbPass,
		Share:    smbShare,
		Root:     smbRootDir,
	})
	s.Nil(err)
	s.True(rsp1.Success)
}

func (s *ImageTestSuite) TestUploadGet() {
	ctx := context.Background()
	err := s.uploadPic1(ctx)
	s.Nil(err)
	s.Nil(waitfile(s.srv, pic1ShouldPath, 5*time.Second))
	data, err := s.get(ctx, pic1ShouldPath)
	s.Nilf(err, "get pic failed: %v", err)
	s.Equal(len(static.Pic1), len(data))
}

func (s *ImageTestSuite) get(ctx context.Context, path string) ([]byte, error) {
	cli, err := s.srv.Get(ctx, &pb.GetRequest{
		Path: path,
	})
	if err != nil {
		return nil, err
	}
	buf := new(bytes.Buffer)
	for {
		rsp, err := cli.Recv()
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return nil, err
			}
		}
		_, err = buf.Write(rsp.Data)
		if err != nil {
			return nil, err
		}
	}
	return buf.Bytes(), nil
}

func (s *ImageTestSuite) uploadPic1(ctx context.Context) error {
	cli, err := s.srv.Upload(ctx)
	if err != nil {
		return err
	}
	reader := bytes.NewReader(static.Pic1)
	err = cli.Send(&pb.UploadRequest{
		Name: "pic1.jpg",
	})
	if err != nil {
		return err
	}
	buf := make([]byte, 4096)
	for {
		n, err := reader.Read(buf)
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return err
			}
		}
		err = cli.Send(&pb.UploadRequest{
			Data: buf[:n],
		})
		if err != nil {
			return err
		}
	}
	rsp, err := cli.CloseAndRecv()
	if err != nil {
		return err
	}
	if !rsp.Success {
		return fmt.Errorf("upload failed: %s", rsp.Message)
	}
	return nil
}

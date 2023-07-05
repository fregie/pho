package api_test

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
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

func (s *ImageTestSuite) TestGetThumnail() {
	ctx := context.Background()
	err := s.uploadPic1(ctx)
	s.Nil(err)
	s.Nil(waitfile(s.srv, pic1ShouldPath, 5*time.Second))
	data, err := s.get(ctx, pic1ShouldPath)
	s.Nilf(err, "get pic failed: %v", err)
	s.Equal(static.Pic1, data)
	resp, err := http.Get(fmt.Sprintf("http://%s/thumbnail/%s", httpAddr, pic1ShouldPath))
	s.Nilf(err, "get thumbnail failed: %v", err)
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	s.Nilf(err, "read thumbnail failed: %v", err)
	s.Equalf(http.StatusOK, resp.StatusCode, "body: %s", body)
	s.Truef(len(body) > 0, "thumbnail is empty")
}

func (s *ImageTestSuite) TestList() {
	ctx := context.Background()
	rsp1, err := s.srv.ListByDate(ctx, &pb.ListByDateRequest{})
	s.Nilf(err, "list failed: %v", err)
	s.Truef(rsp1.Success, "list failed: %s", rsp1.Message)
	s.Equal(0, len(rsp1.Paths))
	err = s.uploadPic1(ctx)
	s.Nil(err)
	s.Nil(waitfile(s.srv, pic1ShouldPath, 5*time.Second))
	rsp2, err := s.srv.ListByDate(ctx, &pb.ListByDateRequest{})
	s.Nilf(err, "list failed: %v", err)
	s.Truef(rsp2.Success, "list failed: %s", rsp2.Message)
	s.Equal(1, len(rsp2.Paths))
	s.Equalf(pic1ShouldPath, rsp2.Paths[0], "path: %s", rsp2.Paths[0])
}

func (s *ImageTestSuite) TestDelete() {
	ctx := context.Background()
	err := s.uploadPic1(ctx)
	s.Nil(err)
	s.Nil(waitfile(s.srv, pic1ShouldPath, 5*time.Second))
	rsp2, err := s.srv.ListByDate(ctx, &pb.ListByDateRequest{})
	s.Nilf(err, "list failed: %v", err)
	s.Truef(rsp2.Success, "list failed: %s", rsp2.Message)
	s.Equal(1, len(rsp2.Paths))
	rsp3, err := s.srv.Delete(ctx, &pb.DeleteRequest{
		Paths: []string{pic1ShouldPath},
	})
	s.Nilf(err, "delete failed: %v", err)
	s.Truef(rsp3.Success, "delete: %s", rsp3.Message)
	rsp4, err := s.srv.ListByDate(ctx, &pb.ListByDateRequest{})
	s.Nilf(err, "list failed: %v", err)
	s.Equal(0, len(rsp4.Paths))
}

func (s *ImageTestSuite) get(ctx context.Context, path string) ([]byte, error) {
	resp, err := http.Get(fmt.Sprintf("http://%s/%s", httpAddr, path))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("http status: %d", resp.StatusCode)
	}
	return io.ReadAll(resp.Body)
}

func (s *ImageTestSuite) uploadPic1(ctx context.Context) error {
	name := "pic1.jpg"
	req, err := http.NewRequest(http.MethodPost, fmt.Sprintf("http://%s/%s", httpAddr, name), bytes.NewReader(static.Pic1))
	req.Header.Set("Content-Type", "image/jpeg")
	req.Header.Set("Image-Date", "2022:11:08 12:34:36")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("http status: %d", resp.StatusCode)
	}
	io.Copy(io.Discard, resp.Body)

	req, err = http.NewRequest(http.MethodPost, fmt.Sprintf("http://%s/thumbnail/%s", httpAddr, name), bytes.NewReader(static.Pic1))
	req.Header.Set("Content-Type", "image/jpeg")
	req.Header.Set("Image-Date", "2022:11:08 12:34:36")
	resp, err = http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("http status: %d", resp.StatusCode)
	}
	io.Copy(io.Discard, resp.Body)
	return nil
}

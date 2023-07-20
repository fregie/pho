package api_test

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"path/filepath"
	"strings"
	"testing"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/fregie/img_syncer/test/static"
	"github.com/stretchr/testify/suite"
	"github.com/vmware/go-nfs-client/nfs"
	"github.com/vmware/go-nfs-client/nfs/rpc"
	"google.golang.org/grpc"
)

const (
	nfsUrl    = "192.168.23.10:/nfs"
	nfsSrvUrl = "nfs:/nfs"
	// nfsUrl      = "127.0.0.1:/mnt/nfs"
	// nfsSrvUrl   = "127.0.0.1:/mnt/nfs"
	nfsRootPath = "storage"
)

type DriveNFSTestSuite struct {
	suite.Suite
	srv pb.ImgSyncerClient
	cli *nfs.Target
}

func TestDriveNFSTestSuite(t *testing.T) {
	// util.DefaultLogger.SetDebug(true)
	suite.Run(t, new(DriveNFSTestSuite))
}

func (s *DriveNFSTestSuite) SetupTest() {
	err := cleanNFS()
	s.Nilf(err, "failed to clean nfs: %s", err)
	err = initNFSDir()
	s.Nilf(err, "failed to init nfs dir: %s", err)
	grpcConn, err := grpc.Dial(grpcAddr, grpc.WithInsecure())
	s.Nil(err)
	s.srv = pb.NewImgSyncerClient(grpcConn)
	s.cli, err = getNFSTarget()
	s.Nil(err)
}

// TestSetDriveWebdav tests set drive webdav
func (s *DriveNFSTestSuite) TestSetDriveNFS() {
	ctx := context.Background()
	// test set drive nfs
	rsp1, err := s.srv.SetDriveNFS(ctx, &pb.SetDriveNFSRequest{
		Addr: nfsSrvUrl,
	})
	s.Nilf(err, "set drive nfs failed: %v", err)
	s.Truef(rsp1.Success, "set drive nfs failed: %v", rsp1.Message)
	// test list drive nfs dirs
	rsp2, err := s.srv.ListDriveNFSDir(ctx, &pb.ListDriveNFSDirRequest{})
	s.Nilf(err, "list drive nfs dirs failed: %v", err)
	s.True(rsp2.Success)
	s.Containsf(rsp2.Dirs, nfsRootPath, "list drive nfs dirs failed: %v", err)
	// test set drive webdav with root path
	rsp3, err := s.srv.SetDriveNFS(ctx, &pb.SetDriveNFSRequest{
		Addr: nfsSrvUrl,
		Root: nfsRootPath,
	})
	s.Nilf(err, "set drive nfs failed: %v", err)
	s.True(rsp3.Success)
}

func (s *DriveNFSTestSuite) TestUploadDownload() {
	ctx := context.Background()
	// test set drive nfs with root path
	rsp1, err := s.srv.SetDriveNFS(ctx, &pb.SetDriveNFSRequest{
		Addr: nfsSrvUrl,
		Root: nfsRootPath,
	})
	s.Nilf(err, "set drive nfs failed: %v", err)
	s.True(rsp1.Success)
	// test upload
	req, err := http.NewRequest(http.MethodPost, fmt.Sprintf("http://%s/pic1.jpg", httpAddr), bytes.NewReader(static.Pic1))
	s.Nilf(err, "new request failed: %v", err)
	req.Header.Set("Content-Type", "image/jpeg")
	req.Header.Set("Image-Date", "2022:11:08 12:34:36")
	resp, err := http.DefaultClient.Do(req)
	s.Nilf(err, "upload pic failed: %v", err)
	s.Equal(http.StatusOK, resp.StatusCode)
	filePath := "/storage/2022/11/08/20221108123436_pic1.jpg"
	s.waitFile(filePath, 5*time.Second)
	f, err := s.cli.Open(filePath)
	s.Nil(err)
	defer f.Close()
	data, err := io.ReadAll(f)
	s.Nil(err)
	s.Equal(static.Pic1, data)
}

// get file content
func (s *DriveNFSTestSuite) get(ctx context.Context, path string) ([]byte, error) {
	if path[0] != '/' {
		path = "/" + path
	}
	resp, err := http.Get(fmt.Sprintf("http://%s%s", httpAddr, path))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf(resp.Status)
	}
	return io.ReadAll(resp.Body)
}

// waitFile waits for file to exist
func (s *DriveNFSTestSuite) waitFile(path string, timeout time.Duration) {
	if path == "" {
		s.FailNow("path is empty")
	}
	path = filepath.ToSlash(path)
	start := time.Now()
	if path[0] != '/' {
		path = "/" + path
	}
	for {
		_, _, err := s.cli.Lookup(path)
		if err == nil {
			return
		}
		if time.Since(start) > timeout {
			s.FailNowf("wait file timeout: %s", path)
		}
		time.Sleep(200 * time.Millisecond)
	}
}

func initNFSDir() error {
	cli, err := getNFSTarget()
	if err != nil {
		return err
	}
	_, err = cli.Mkdir(nfsRootPath, 0755)
	if err != nil {
		return err
	}
	return nil
}

func cleanNFS() error {
	cli, err := getNFSTarget()
	if err != nil {
		return err
	}
	entries, err := cli.ReadDirPlus("/")
	if err != nil {
		return fmt.Errorf("failed to read dir: %s", err)
	}
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		if entry.Name() == "." || entry.Name() == ".." {
			continue
		}
		err = cli.RemoveAll(filepath.Join("/", entry.Name()))
		if err != nil {
			return fmt.Errorf("failed to remove dir: %s", err)
		}
	}
	return nil
}

func getNFSTarget() (*nfs.Target, error) {
	re := strings.Split(nfsUrl, ":")
	if len(re) != 2 {
		return nil, fmt.Errorf("url format error")
	}
	host := re[0]
	targetStr := re[1]
	mount, err := nfs.DialMount(host)
	if err != nil {
		return nil, fmt.Errorf("failed to dial mount: %s", err)
	}
	auth := rpc.NewAuthUnix("root", 0, 0)
	target, err := mount.Mount(targetStr, auth.Auth())
	if err != nil {
		return nil, fmt.Errorf("failed to mount: %s", err)
	}
	return target, nil
}

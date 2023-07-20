package api_test

import (
	"context"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"time"

	pb "github.com/fregie/img_syncer/proto"
	"github.com/hirochachacha/go-smb2"
)

const (
	grpcAddr   = "127.0.0.1:50051"
	httpAddr   = "127.0.0.1:8000"
	smbSrvAddr = "smb"
	smbAddr    = "127.0.0.1:445"
	smbUser    = "fregie"
	smbPass    = "password"
	smbShare   = "photos"
	smbRootDir = "storage"

	pic1ShouldPath = "2022/11/08/20221108123436_pic1.jpg"
)

func initSmbShare() (*smb2.Share, error) {
	conn, err := net.Dial("tcp", smbAddr)
	if err != nil {
		return nil, err
	}
	d := &smb2.Dialer{
		Initiator: &smb2.NTLMInitiator{
			User:     smbUser,
			Password: smbPass,
		},
	}
	s, err := d.Dial(conn)
	if err != nil {
		return nil, err
	}
	share, err := s.Mount(smbShare)
	if err != nil {
		return nil, err
	}
	return share, nil
}

func getSmbShare() (*smb2.Share, error) {
	conn, err := net.Dial("tcp", smbAddr)
	if err != nil {
		return nil, err
	}
	d := &smb2.Dialer{
		Initiator: &smb2.NTLMInitiator{
			User:     smbUser,
			Password: smbPass,
		},
	}
	s, err := d.Dial(conn)
	if err != nil {
		return nil, err
	}
	share, err := s.Mount(smbShare)
	if err != nil {
		return nil, err
	}
	return share, nil
}

func cleanSmb() error {
	share, err := getSmbShare()
	if err != nil {
		return err
	}
	retriedTimes := 0
Retry:
	dirs, err := share.ReadDir(".")
	if err != nil {
		return err
	}
	for _, dir := range dirs {
		if dir.IsDir() {
			if err := share.RemoveAll(dir.Name()); err != nil {
				if retriedTimes <= 3 {
					time.Sleep(300 * time.Microsecond)
					retriedTimes++
					goto Retry
				}
				fmt.Printf("remove %s error: %v\n", dir.Name(), err)
				continue
			}
		} else {
			if err := share.Remove(dir.Name()); err != nil {
				if retriedTimes <= 3 {
					time.Sleep(300 * time.Microsecond)
					retriedTimes++
					goto Retry
				}
				fmt.Printf("remove %s error: %v\n", dir.Name(), err)
				continue
			}
		}
	}
	return nil
}

func initSmbDir() error {
	share, err := getSmbShare()
	if err != nil {
		return err
	}
	if err := share.Mkdir(smbRootDir, os.ModePerm); err != nil {
		return err
	}
	return nil
}

func waitfile(srv pb.ImgSyncerClient, path string, timeout time.Duration) error {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	if path[0] != '/' {
		path = "/" + path
	}
	defer cancel()
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
			resp, err := http.Get(fmt.Sprintf("http://%s%s", httpAddr, path))
			if err != nil {
				goto CONTINUE
			}
			defer resp.Body.Close()
			data, err := io.ReadAll(resp.Body)
			if err != nil {
				goto CONTINUE
			}
			rsp := string(data)
			rsp = rsp
			if resp.StatusCode != http.StatusOK {
				goto CONTINUE
			}
			return nil
		}
	CONTINUE:
		time.Sleep(200 * time.Millisecond)
	}
}

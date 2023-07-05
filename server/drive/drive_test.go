package drive_test

import (
	"bytes"
	"fmt"
	"io"
	"io/fs"
	"net"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	nfsdrive "github.com/fregie/img_syncer/server/drive/nfs"
	"github.com/fregie/img_syncer/server/drive/smb"
	"github.com/fregie/img_syncer/server/drive/webdav"
	"github.com/fregie/img_syncer/server/imgmanager"
	"github.com/fregie/img_syncer/test/static"
	"github.com/hirochachacha/go-smb2"
	"github.com/stretchr/testify/suite"
	"github.com/studio-b12/gowebdav"
	"github.com/vmware/go-nfs-client/nfs"
	"github.com/vmware/go-nfs-client/nfs/rpc"
)

const (
	smbAddr    = "127.0.0.1:445"
	smbUser    = "fregie"
	smbPass    = "password"
	smbShare   = "photos"
	smbRootDir = "storage"

	webdavUrl      = "http://127.0.0.1:8080"
	webdavUser     = "fregie"
	webdavPass     = "password"
	webdavRootPath = "storage"

	nfsUrl      = "192.168.23.10:/nfs"
	nfsRootPath = "storage"
)

type DriveTest struct {
	suite.Suite
}

func TestDriveSuite(t *testing.T) {
	suite.Run(t, new(DriveTest))
}

func (d *DriveTest) TestNFS() {
	err := initNFS()
	d.Nilf(err, "init nfs failed: %v", err)
	dri, err := nfsdrive.NewNfsDrive(nfsUrl)
	d.Nilf(err, "new nfs drive failed: %v", err)
	err = dri.SetRootPath(nfsRootPath)
	d.Nilf(err, "set root path failed: %v", err)

	d.testDrive(dri)
	d.testDownloadOffset(dri)
}

func (d *DriveTest) TestWebdav() {
	err := initWebdav()
	d.Nilf(err, "init webdav failed: %v", err)
	dri := webdav.NewWebdavDrive(webdavUrl, webdavUser, webdavPass)
	err = dri.SetRootPath(webdavRootPath)
	d.Nilf(err, "set root path failed: %v", err)

	d.testDrive(dri)
	d.testDownloadOffset(dri)
}

func (d *DriveTest) TestSMB() {
	err := initSmbShare()
	d.Nilf(err, "init smb share failed: %v", err)
	dri := smb.NewSmbDrive(smbAddr, smbUser, smbPass)
	err = dri.SetShare(smbShare)
	d.Nilf(err, "set share failed: %v", err)
	err = dri.SetRootPath(smbRootDir)
	d.Nilf(err, "set root path failed: %v", err)

	d.testDrive(dri)
	d.testDownloadOffset(dri)
}

func initNFS() error {
	re := strings.Split(nfsUrl, ":")
	if len(re) != 2 {
		return fmt.Errorf("url format error")
	}
	host := re[0]
	targetStr := re[1]
	mount, err := nfs.DialMount(host)
	if err != nil {
		return fmt.Errorf("failed to dial mount: %s", err)
	}
	auth := rpc.NewAuthUnix("root", 0, 0)
	cli, err := mount.Mount(targetStr, auth.Auth())
	if err != nil {
		return fmt.Errorf("failed to mount: %s", err)
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
	_, err = cli.Mkdir(nfsRootPath, 0755)
	if err != nil {
		return err
	}
	return nil
}

func initWebdav() error {
	cli := gowebdav.NewClient(webdavUrl, webdavUser, webdavPass)
	dirs, err := cli.ReadDir("/")
	if err != nil {
		return err
	}
	for _, dir := range dirs {
		err = cli.RemoveAll("/" + dir.Name() + "/")
		if err != nil {
			return err
		}
	}
	if err := cli.Mkdir(webdavRootPath, os.ModePerm); err != nil {
		return err
	}
	return nil
}

func initSmbShare() error {
	conn, err := net.Dial("tcp", smbAddr)
	if err != nil {
		return err
	}
	d := &smb2.Dialer{
		Initiator: &smb2.NTLMInitiator{
			User:     smbUser,
			Password: smbPass,
		},
	}
	s, err := d.Dial(conn)
	if err != nil {
		return err
	}
	share, err := s.Mount(smbShare)
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
	if err := share.Mkdir(smbRootDir, os.ModePerm); err != nil {
		return err
	}
	return nil
}

func (d *DriveTest) testDrive(dri imgmanager.StorageDrive) {
	d.NotNilf(dri, "drive is nil")
	filePath := "/dir/pic1.jpg"
	// check exist
	// exist, err := dri.IsExist(filePath)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.False(exist)
	// test upload
	reader := bytes.NewReader(static.Pic1)
	err := dri.Upload(filePath, io.NopCloser(reader), int64(len(static.Pic1)), time.Now())
	d.Nilf(err, "upload failed: %v", err)
	// check exist
	// exist, err = dri.IsExist(filePath)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.True(exist)
	// test download
	reader2, length, err := dri.Download(filePath)
	d.Nilf(err, "download failed: %v", err)
	data, err := io.ReadAll(reader2)
	reader2.Close()
	d.Nilf(err, "read data failed: %v", err)
	d.Equal(len(static.Pic1), len(data))
	d.Equal(int64(len(static.Pic1)), length)
	// test delete
	err = dri.Delete(filePath)
	d.Nilf(err, "delete failed: %v", err)
	// check exist
	// exist, err = dri.IsExist(filePath)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.False(exist)

	// check Range
	filePath2 := "/dir/pic2.jpg"
	reader.Seek(0, io.SeekStart)
	err = dri.Upload(filePath, io.NopCloser(reader), int64(len(static.Pic1)), time.Now())
	d.Nilf(err, "upload failed: %v", err)
	reader.Seek(0, io.SeekStart)
	err = dri.Upload(filePath2, io.NopCloser(reader), int64(len(static.Pic1)), time.Now())
	d.Nilf(err, "upload failed: %v", err)
	// check exist
	// exist, err = dri.IsExist(filePath)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.True(exist)
	// // check exist
	// exist, err = dri.IsExist(filePath2)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.True(exist)
	// test Range
	files := make([]string, 0)
	err = dri.Range("/dir", func(fi fs.FileInfo) bool {
		files = append(files, fi.Name())
		return true
	})
	d.Nilf(err, "range failed: %v", err)
	d.Containsf(files, "pic1.jpg", "range failed: %v", files)
	d.Containsf(files, "pic2.jpg", "range failed: %v", files)
}

func (d *DriveTest) testDownloadOffset(dri imgmanager.StorageDrive) {
	d.NotNilf(dri, "drive is nil")
	filePath := "/dir/pic1.jpg"
	// upload
	reader := bytes.NewReader(static.Pic1)
	err := dri.Upload(filePath, io.NopCloser(reader), int64(len(static.Pic1)), time.Now())
	d.Nilf(err, "upload failed: %v", err)
	// check exist
	// exist, err := dri.IsExist(filePath)
	// d.Nilf(err, "check exist failed: %v", err)
	// d.True(exist)
	// test download
	reader2, length, err := dri.DownloadWithOffset(filePath, 256)
	d.Nilf(err, "download failed: %v", err)
	buf1 := make([]byte, 256)
	io.ReadFull(reader2, buf1)
	reader2.Close()
	d.Equal(static.Pic1[256:256+256], buf1)
	d.Equal(int64(len(static.Pic1)), length)
}

package nfs

import (
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync/atomic"
	"time"

	"github.com/vmware/go-nfs-client/nfs"
	"github.com/vmware/go-nfs-client/nfs/rpc"
)

type Nfs struct {
	host              string
	target            string
	rootPath          string
	mount             *nfs.Mount
	cli               *nfs.Target
	lastConnTimestamp int64
}

func NewNfsDrive(url string) (*Nfs, error) {
	re := strings.Split(url, ":")
	if len(re) != 2 {
		return nil, fmt.Errorf("url format error")
	}
	d := &Nfs{
		host:   re[0],
		target: re[1],
	}
	mount, err := nfs.DialMount(d.host)
	if err != nil {
		return nil, err
	}
	auth := rpc.NewAuthUnix("root", 0, 0)
	target, err := mount.Mount(d.target, auth.Auth())
	if err != nil {
		return nil, err
	}
	d.mount = mount
	d.cli = target
	return d, nil
}

func (d *Nfs) Cli() *nfs.Target {
	return d.cli
}

func (d *Nfs) lastConnTime() time.Time {
	ts := atomic.LoadInt64(&d.lastConnTimestamp)
	return time.Unix(ts, 0)
}

func (d *Nfs) updateLastConnTime() {
	atomic.StoreInt64(&d.lastConnTimestamp, time.Now().Unix())
}

func (d *Nfs) cleanLastConnTime() {
	atomic.StoreInt64(&d.lastConnTimestamp, 0)
}

func (d *Nfs) checkConn() error {
	if time.Since(d.lastConnTime()) < 2*time.Minute {
		return nil
	}
	if d.cli != nil {
		_, err := d.cli.FSInfo()
		if err == nil {
			return nil
		}
		d.cli.Close()
	}
	if d.mount != nil {
		d.mount.Close()
	}
	mount, err := nfs.DialMount(d.host)
	if err != nil {
		return err
	}
	auth := rpc.NewAuthUnix("root", 0, 0)
	target, err := mount.Mount(d.target, auth.Auth())
	if err != nil {
		return err
	}
	d.mount = mount
	d.cli = target
	d.updateLastConnTime()
	return nil
}

func (d *Nfs) IsRootPathSet() bool {
	return d.rootPath != ""
}

func (d *Nfs) SetRootPath(rootPath string) error {
	if rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	rootPath = filepath.ToSlash(rootPath)
	if rootPath[0] != '/' {
		rootPath = "/" + rootPath
	}
	if rootPath[len(rootPath)-1] != '/' {
		rootPath = rootPath + "/"
	}
	_, err := d.cli.ReadDirPlus(rootPath)
	if err != nil {
		return err
	}
	d.rootPath = rootPath
	return nil
}

func (d *Nfs) IsExist(path string) (bool, error) {
	if err := d.checkConn(); err != nil {
		return false, err
	}
	if d.rootPath == "" {
		return false, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	_, _, err := d.cli.Lookup(fullPath)
	if err != nil {
		if err, ok := err.(*nfs.Error); ok {
			if err.ErrorNum == nfs.NFS3ErrIsDir {
				d.updateLastConnTime()
				return true, nil
			}
		}
		if errors.Is(err, os.ErrNotExist) {
			d.updateLastConnTime()
			return false, nil
		}
		d.cleanLastConnTime()
		return false, err
	}
	d.updateLastConnTime()
	return true, nil
}

func (d *Nfs) Download(path string) (io.ReadCloser, int64, error) {
	if err := d.checkConn(); err != nil {
		return nil, 0, err
	}
	if d.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	file, err := d.cli.Open(fullPath)
	if err != nil {
		d.cleanLastConnTime()
		return nil, 0, fmt.Errorf("open file error: %v", err)
	}
	var length int64 = 0
	info, _, err := d.cli.Lookup(fullPath)
	if err != nil {
		fmt.Printf("get file info error: %v\n", err)
	} else {
		length = int64(info.Size())
	}
	return file, length, nil
}

func (d *Nfs) DownloadWithOffset(path string, offset int64) (io.ReadCloser, int64, error) {
	if err := d.checkConn(); err != nil {
		return nil, 0, err
	}
	if d.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	file, err := d.cli.Open(fullPath)
	if err != nil {
		d.cleanLastConnTime()
		return nil, 0, fmt.Errorf("open file error: %v", err)
	}
	var length int64 = 0
	info, _, err := d.cli.Lookup(fullPath)
	if err != nil {
		fmt.Printf("get file info error: %v\n", err)
	} else {
		length = int64(info.Size())
	}
	if length > 0 && offset >= length {
		return nil, length, fmt.Errorf("offset is out of range")
	}
	_, err = file.Seek(offset, io.SeekStart)
	if err != nil {
		return nil, length, err
	}
	return file, length, nil
}

func (d *Nfs) Delete(path string) error {
	if err := d.checkConn(); err != nil {
		return err
	}
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.cli.Remove(fullPath)
	if err != nil {
		return err
	}
	d.updateLastConnTime()
	return nil
}

func (d *Nfs) Upload(path string, reader io.ReadCloser, size int64, lastModified time.Time) error {
	if err := d.checkConn(); err != nil {
		return err
	}
	if reader == nil {
		return fmt.Errorf("reader is nil")
	}
	defer reader.Close()
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.MkdirAll(filepath.Dir(fullPath), 0755)
	if err != nil {
		d.cleanLastConnTime()
		return fmt.Errorf("mkdir %s error: %v", filepath.Dir(fullPath), err)
	}
	_, err = d.cli.Create(fullPath, 0644)
	if err != nil {
		d.cleanLastConnTime()
		return fmt.Errorf("create file error: %v", err)
	}
	f, err := d.cli.OpenFile(fullPath, 0644)
	if err != nil {
		d.cleanLastConnTime()
		return fmt.Errorf("open file error: %v", err)
	}
	defer f.Close()
	_, err = io.Copy(f, reader)
	if err != nil {
		return err
	}
	d.updateLastConnTime()
	return nil
}

func (d *Nfs) Range(dir string, deal func(fs.FileInfo) bool) error {
	if err := d.checkConn(); err != nil {
		return err
	}
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, dir)
	infos, err := d.cli.ReadDirPlus(fullPath)
	if err != nil {
		d.cleanLastConnTime()
		return err
	}
	sort.Sort(desc(infos))
	for _, info := range infos {
		if info.Name() == "." || info.Name() == ".." {
			continue
		}
		if !deal(info) {
			break
		}
	}
	d.updateLastConnTime()
	return nil
}

type desc []*nfs.EntryPlus

func (d desc) Len() int      { return len(d) }
func (d desc) Swap(i, j int) { d[i], d[j] = d[j], d[i] }
func (d desc) Less(i, j int) bool {
	return d[i].ModTime().After(d[j].ModTime())
}

// MkdirAll makes a directory path and all parents that does not exist by d.cli.Mkdir.
func (d *Nfs) MkdirAll(path string, perm fs.FileMode) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	eles := strings.Split(path, "/")
	if len(eles) == 0 {
		return nil
	}
	for i := 1; i <= len(eles); i++ {
		dir := "/" + filepath.Join(eles[:i]...)
		_, err := d.cli.Mkdir(dir, perm)
		if err != nil {
			continue
		}
	}

	return nil
}

package nfs

import (
	"fmt"
	"io"
	"io/fs"
	"log"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/vmware/go-nfs-client/nfs"
	"github.com/vmware/go-nfs-client/nfs/rpc"
)

type Nfs struct {
	host     string
	target   string
	rootPath string
	mount    *nfs.Mount
	cli      *nfs.Target
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
	if d.rootPath == "" {
		return false, fmt.Errorf("root path is empty")
	}
	path = filepath.ToSlash(path)
	if path[0] != '/' {
		path = "/" + path
	}
	if path[len(path)-1] != '/' {
		path = path + "/"
	}
	_, _, err := d.cli.Lookup(path)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (d *Nfs) Download(path string) (io.ReadCloser, int64, error) {
	if d.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	file, err := d.cli.Open(fullPath)
	if err != nil {
		return nil, 0, err
	}
	length := 0
	info, err := file.FSInfo()
	if err != nil {
		log.Printf("get file info error: %v", err)
	} else {
		length = int(info.Size)
	}
	return file, int64(length), nil
}

func (d *Nfs) Delete(path string) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.cli.Remove(fullPath)
	if err != nil {
		return err
	}
	return nil
}

func (d *Nfs) Upload(path string, reader io.ReadCloser, size int64, lastModified time.Time) error {
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
		return fmt.Errorf("mkdir %s error: %v", filepath.Dir(fullPath), err)
	}
	_, err = d.cli.Create(fullPath, 0644)
	if err != nil {
		return fmt.Errorf("create file error: %v", err)
	}
	f, err := d.cli.OpenFile(fullPath, 0644)
	if err != nil {
		return fmt.Errorf("open file error: %v", err)
	}
	defer f.Close()
	_, err = io.Copy(f, reader)
	if err != nil {
		return err
	}

	return nil
}

func (d *Nfs) Range(dir string, deal func(fs.FileInfo) bool) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, dir)
	infos, err := d.cli.ReadDirPlus(fullPath)
	if err != nil {
		return err
	}
	sort.Sort(desc(infos))
	for _, info := range infos {
		if !deal(info) {
			break
		}
	}
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

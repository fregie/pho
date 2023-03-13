package smb

import (
	"fmt"
	"io"
	"io/fs"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync/atomic"
	"time"

	"github.com/hirochachacha/go-smb2"
)

type Smb struct {
	addr              string
	username          string
	password          string
	shareName         string
	rootPath          string
	fs                *smb2.Share
	lastConnTimestamp int64
}

func NewSmbDrive(addr, username, password string) *Smb {
	if strings.Index(addr, ":") < 0 {
		addr = addr + ":445"
	}
	smb := &Smb{
		addr:     addr,
		username: username,
		password: password,
	}

	return smb
}

func (s *Smb) lastConnTime() time.Time {
	ts := atomic.LoadInt64(&s.lastConnTimestamp)
	return time.Unix(ts, 0)
}

func (s *Smb) updateLastConnTime() {
	atomic.StoreInt64(&s.lastConnTimestamp, time.Now().Unix())
}

func (s *Smb) cleanLastConnTime() {
	atomic.StoreInt64(&s.lastConnTimestamp, 0)
}

func (s *Smb) checkConn() error {
	if time.Since(s.lastConnTime()) < 5*time.Minute {
		return nil
	}
	if s.fs != nil {
		_ = s.fs.Umount()
	}
	return s.Connect()
}

func (s *Smb) Dial() (*smb2.Session, error) {
	if s.addr == "" || s.username == "" || s.password == "" {
		return nil, fmt.Errorf("smb config error: addr=%s, username=%s, password=%s, shareName=%s", s.addr, s.username, s.password, s.shareName)
	}
	conn, err := net.Dial("tcp", s.addr)
	if err != nil {
		return nil, err
	}
	d := &smb2.Dialer{
		Initiator: &smb2.NTLMInitiator{
			User:     s.username,
			Password: s.password,
		},
	}
	sess, err := d.Dial(conn)
	if err != nil {
		return nil, err
	}
	return sess, nil
}

func (s *Smb) Connect() error {
	if s.shareName == "" {
		return fmt.Errorf("smb share name is empty")
	}
	sess, err := s.Dial()
	if err != nil {
		return err
	}

	s.fs, err = sess.Mount(s.shareName)
	if err != nil {
		return err
	}
	s.updateLastConnTime()
	return nil
}

func (s *Smb) ListShare() ([]string, error) {
	sess, err := s.Dial()
	if err != nil {
		return nil, err
	}
	defer sess.Logoff()
	shares, err := sess.ListSharenames()
	if err != nil {
		return nil, err
	}
	return shares, nil
}

func (s *Smb) SetShare(shareName string) error {
	shares, err := s.ListShare()
	if err != nil {
		return err
	}
	for _, share := range shares {
		if share == shareName {
			s.shareName = shareName
			return nil
		}
	}
	return fmt.Errorf("share %s not exist", shareName)
}

func (s *Smb) IsShareSet() bool {
	return s.shareName != ""
}

func (s *Smb) IsRootPathSet() bool {
	return s.rootPath != ""
}

func (s *Smb) SetRootPath(rootPath string) error {
	if err := s.checkConn(); err != nil {
		return err
	}
	_, err := s.fs.Stat(rootPath)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("root path %s not exist", rootPath)
		}
		return err
	}
	s.rootPath = rootPath
	return nil
}

func (s *Smb) Upload(path string, content io.ReadCloser, size int64) error {
	defer content.Close()
	if err := s.checkConn(); err != nil {
		return err
	}
	if s.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(s.rootPath, path)
	if err := s.fs.MkdirAll(filepath.Dir(fullPath), 0755); err != nil {
		s.cleanLastConnTime()
		return err
	}
	f, err := s.fs.Create(fullPath)
	if err != nil {
		s.cleanLastConnTime()
		return err
	}
	defer f.Close()
	_, err = io.Copy(f, content)
	if err != nil {
		s.cleanLastConnTime()
		return err
	}
	s.updateLastConnTime()

	return nil
}

func (s *Smb) IsExist(path string) (bool, error) {
	if err := s.checkConn(); err != nil {
		return false, err
	}
	if s.rootPath == "" {
		return false, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(s.rootPath, path)
	_, err := s.fs.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			s.updateLastConnTime()
			return false, nil
		}
		s.cleanLastConnTime()
		return false, err
	}
	s.updateLastConnTime()
	return true, nil
}

func (s *Smb) Download(path string) (io.ReadCloser, int64, error) {
	if err := s.checkConn(); err != nil {
		return nil, 0, err
	}
	if s.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(s.rootPath, path)
	f, err := s.fs.Open(fullPath)
	if err != nil {
		s.cleanLastConnTime()
		return nil, 0, err
	}
	fi, err := f.Stat()
	if err != nil {
		s.cleanLastConnTime()
		return nil, 0, err
	}
	s.updateLastConnTime()
	return f, fi.Size(), nil
}

func (s *Smb) Delete(path string) error {
	if err := s.checkConn(); err != nil {
		return err
	}
	if s.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(s.rootPath, path)
	err := s.fs.Remove(fullPath)
	if err != nil {
		s.cleanLastConnTime()
		return err
	}
	s.updateLastConnTime()

	return nil
}

func (s *Smb) Range(dir string, deal func(fs.FileInfo) bool) {
	if err := s.checkConn(); err != nil {
		return
	}
	if s.rootPath == "" {
		return
	}
	fullPath := filepath.Join(s.rootPath, dir)
	infos, err := s.fs.ReadDir(fullPath)
	if err != nil {
		s.cleanLastConnTime()
		return
	}
	s.updateLastConnTime()
	for _, info := range infos {
		if !deal(info) {
			break
		}
	}
}

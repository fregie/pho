package imgmanager

import (
	"errors"
	"io"
	"io/fs"
	"time"
)

type StorageDrive interface {
	Upload(string, io.ReadCloser, int64, time.Time) error
	// IsExist(path string) (bool, error)
	Download(path string) (io.ReadCloser, int64, error)
	DownloadWithOffset(path string, offset int64) (io.ReadCloser, int64, error)
	Delete(path string) error
	Range(dir string, deal func(fs.FileInfo) bool) error
}

type Image struct {
	Content io.ReadCloser
	Path    string
	Size    int64
	ImageMetadata
}

const (
	// ContentTypeJpeg = "image/jpeg"
	// ContentTypePng  = "image/png"
	// ContentTypeGif  = "image/gif"

	JpegSuffix = ".jpg"
	PngSuffix  = ".png"
	DngSuffix  = ".dng"
)

type UnimplementedDrive struct{}

func (d *UnimplementedDrive) Upload(_ string, _ io.ReadCloser, _ int64, _ time.Time) error {
	return errors.New("no available drive")
}

func (d *UnimplementedDrive) IsExist(path string) (bool, error) {
	return false, errors.New("no available drive")
}

func (d *UnimplementedDrive) Download(path string) (io.ReadCloser, int64, error) {
	return nil, 0, errors.New("no available drive")
}

func (d *UnimplementedDrive) DownloadWithOffset(path string, offset int64) (io.ReadCloser, int64, error) {
	return nil, 0, errors.New("no available drive")
}

func (d *UnimplementedDrive) Delete(path string) error {
	return errors.New("no available drive")
}

func (d *UnimplementedDrive) Range(dir string, deal func(fs.FileInfo) bool) error {
	return errors.New("no available drive")
}

package imgmanager

import (
	"bytes"
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"io"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/Workiva/go-datastructures/queue"
	"github.com/nfnt/resize"
)

const (
	defaultWorkerNum          = 2
	defaultThumbnailMaxWidth  = 500
	defaultThumbnailMaxHeight = 500
	defaultThumbnailDir       = ".thumbnail"
)

type ImgManager struct {
	dri      StorageDrive
	actQueue *queue.Queue
	logger   *log.Logger
	opt      Option
}

type Option struct {
	WorkerNum          int
	ThumbnailMaxWidth  int
	ThumbnailMaxHeight int
	ThumbbailQuality   int
}

func NewImgManager(opt Option) *ImgManager {
	if opt.WorkerNum <= 0 {
		opt.WorkerNum = defaultWorkerNum
	}
	if opt.ThumbnailMaxWidth <= 0 {
		opt.ThumbnailMaxWidth = defaultThumbnailMaxWidth
	}
	if opt.ThumbnailMaxHeight <= 0 {
		opt.ThumbnailMaxHeight = defaultThumbnailMaxHeight
	}
	im := &ImgManager{
		actQueue: queue.New(10),
		logger:   log.New(os.Stdout, "[ImgManager] ", log.LstdFlags),
		opt:      opt,
		dri:      &UnimplementedDrive{},
	}
	for i := 0; i < im.opt.WorkerNum; i++ {
		go im.runWorker()
	}
	return im
}

func (im *ImgManager) SetDrive(dri StorageDrive) {
	im.dri = dri
}

func (im *ImgManager) Drive() StorageDrive {
	return im.dri
}

type actType int

const (
	actGenerateThumbnail = iota
	actUpload
	actDelete
)

type action struct {
	t            actType
	path         string
	content      []byte
	lastModified time.Time
}

func (im *ImgManager) runWorker() {
	for {
		item, err := im.actQueue.Get(1)
		if err != nil {
			im.logger.Println("Error getting action from queue:", err)
			continue
		}
		if len(item) == 0 {
			continue
		}
		act := item[0].(action)
		switch act.t {
		case actUpload:
			err := im.dri.Upload(
				act.path,
				io.NopCloser(bytes.NewReader(act.content)), int64(len(act.content)), act.lastModified)
			if err != nil {
				im.logger.Println("Error uploading image:", err)
			}
		case actGenerateThumbnail:
			err := im.GenerateThumbnail(act.path, act.content)
			if err != nil {
				im.logger.Println("Error generating thumbnail:", err)
			}
		case actDelete:
			err := im.dri.Delete(act.path)
			if err != nil {
				im.logger.Println("Error deleting image:", err)
			}
		}
	}
}

func (im *ImgManager) GenerateThumbnail(path string, content []byte) error {
	var err error
	var imghdl image.Image
	switch strings.ToLower(filepath.Ext(path)) {
	case JpegSuffix:
		imghdl, err = jpeg.Decode(bytes.NewReader(content))
	case PngSuffix:
		imghdl, err = png.Decode(bytes.NewReader(content))
	// case DngSuffix:
	// 	imghdl, err = dng.Decode(bytes.NewReader(content))
	default:
		return fmt.Errorf("unsupported image format: %s", filepath.Ext(path))
	}
	if err != nil {
		return err
	}
	newImghdl := resize.Thumbnail(uint(im.opt.ThumbnailMaxWidth), uint(im.opt.ThumbnailMaxHeight), imghdl, resize.Bilinear)
	buf := bytes.NewBuffer(make([]byte, 0))
	err = jpeg.Encode(buf, newImghdl, &jpeg.Options{Quality: 75})
	if err != nil {
		return err
	}
	thumbPath := filepath.Join(defaultThumbnailDir, path)
	err = im.dri.Upload(thumbPath, io.NopCloser(buf), int64(buf.Len()), time.Time{})
	if err != nil {
		return err
	}

	return nil
}

func (im *ImgManager) UploadImgAsync(path string, content []byte, lastModified time.Time) {
	im.actQueue.Put(action{
		t:            actUpload,
		path:         path,
		content:      content,
		lastModified: lastModified,
	})
}

func (im *ImgManager) GenerateThumbnailAsync(path string, content []byte) {
	im.actQueue.Put(action{
		t:       actGenerateThumbnail,
		path:    path,
		content: content,
	})
}

func (im *ImgManager) UploadVideo(content, thumbnailContent io.Reader, contentSize, thumbnailSize int64, name string, date time.Time) error {
	path := filepath.Join(date.Format("2006/01/02"), name)
	wg := sync.WaitGroup{}
	wg.Add(2)
	var err error
	go func() {
		defer wg.Done()
		if content == nil {
			return
		}
		e := im.dri.Upload(path, io.NopCloser(content), contentSize, date)
		if e != nil {
			im.logger.Println("Error uploading video:", e)
			err = fmt.Errorf("error uploading video: %w", e)
		}
	}()
	go func() {
		defer wg.Done()
		if thumbnailContent == nil {
			return
		}
		e := im.dri.Upload(filepath.Join(defaultThumbnailDir, path),
			io.NopCloser(thumbnailContent), thumbnailSize, date)
		if e != nil {
			im.logger.Println("Error uploading video:", err)
			err = fmt.Errorf("error uploading video thumbnail: %w", e)
		}
	}()
	wg.Wait()
	return err
}

func (im *ImgManager) UploadImg(content, thumbnailContent io.Reader, contentSize, thumbnailSize int64, name string, date time.Time) error {
	errCh := make(chan error, 2)
	var data []byte
	var thumbData []byte
	go func() {
		var err error
		if content != nil {
			data, err = io.ReadAll(content)
		}
		errCh <- err
	}()
	go func() {
		var err error
		if thumbnailContent != nil {
			thumbData, err = io.ReadAll(thumbnailContent)
		}
		errCh <- err
	}()
	for i := 0; i < 2; i++ {
		err := <-errCh
		if err != nil {
			return err
		}
	}
	if len(data) == 0 && len(thumbData) == 0 {
		return fmt.Errorf("no image data")
	}
	if date.IsZero() && len(data) > 0 {
		// try to get image time from metadata
		meta, err := GetImageMetadata(data)
		if err == nil {
			im.logger.Printf("Image metadata: %+v", meta)
			var dateStr string
			if meta.Datetime != "" {
				dateStr = meta.Datetime
			} else if meta.DateTimeOriginal != "" {
				dateStr = meta.DateTimeOriginal
			} else if meta.CreateDate != "" {
				dateStr = meta.CreateDate
			} else if meta.ModifyDate != "" {
				dateStr = meta.ModifyDate
			}
			if dateStr != "" {
				date, err = time.Parse("2006:01:02 15:04:05", dateStr)
				if err != nil {
					im.logger.Println("Error parsing date:", err)
				}
			}
		}
	}
	if date.Before(time.Date(1990, 1, 1, 0, 0, 0, 0, time.UTC)) {
		date = time.Now()
	}
	// try to get image time from given date
	if date.IsZero() {
		date = time.Now()
	}
	path := filepath.Join(date.Format("2006/01/02"), name)
	var err error
	// TODO: check if file exist
	if len(data) > 0 {
		err = im.dri.Upload(path,
			io.NopCloser(bytes.NewReader(data)), int64(len(data)), date)
		if err != nil {
			im.logger.Println("Error uploading image:", err)
			return err
		}
	}
	if len(thumbData) > 0 {
		err = im.dri.Upload(filepath.Join(defaultThumbnailDir, path),
			io.NopCloser(bytes.NewReader(thumbData)), int64(len(thumbData)), date)
		if err != nil {
			im.logger.Println("Error uploading thumbnail:", err)
			return err
		}
	}
	return nil
}

func (im *ImgManager) GetImg(path string) (*Image, error) {
	img := &Image{}
	var err error
	img.Content, img.Size, err = im.dri.Download(path)
	if err != nil {
		return img, err
	}
	img.Path = path
	return img, nil
}

func (im *ImgManager) GetOffset(path string, offset int64) (*Image, error) {
	img := &Image{}
	var err error
	img.Content, img.Size, err = im.dri.DownloadWithOffset(path, offset)
	if err != nil {
		return img, err
	}
	img.Path = path
	return img, nil
}

func (im *ImgManager) GetThumbnail(path string) (*Image, error) {
	img := &Image{}
	var err error
	thumbnailPath := filepath.Join(defaultThumbnailDir, path)
	img.Content, img.Size, err = im.dri.Download(thumbnailPath)
	if err != nil {
		return img, fmt.Errorf("error downloading thumbnail: %w", err)
	}
	img.Path = thumbnailPath
	return img, nil
}

func (im *ImgManager) DeleteSingleImg(path string) error {
	if path != "" {
		return im.dri.Delete(path)
	}
	return nil
}

func (im *ImgManager) DeleteSingleImgAsync(path string) {
	if path != "" {
		im.actQueue.Put(action{t: actDelete, path: path})
	}
}

func (im *ImgManager) DeleteImg(paths []string) {
	for _, path := range paths {
		if path != "" {
			im.DeleteSingleImgAsync(path)
		}
	}
}

func (im *ImgManager) RangeByDate(date time.Time, f func(path string, size int64) bool) error {
	t := date
	if t.IsZero() {
		t = time.Now()
	}
	year, month, day := t.Date()
	yDir, err := im.listDir(".")
	if err != nil {
		im.logger.Println("Error listing year dir:", err)
		return err
	}
	sort.Sort(desc(yDir))
	for _, yinfo := range yDir {
		if !yinfo.IsDir() {
			continue
		}
		yNum, err := strconv.Atoi(yinfo.Name())
		if err != nil {
			continue
		}
		if yNum > year {
			continue
		}
		mDir, err := im.listDir(filepath.Base(yinfo.Name()))
		if err != nil {
			im.logger.Println("Error listing month dir:", err)
			continue
		}
		sort.Sort(desc(mDir))
		for _, minfo := range mDir {
			if !minfo.IsDir() {
				continue
			}
			mNum, err := strconv.Atoi(minfo.Name())
			if err != nil {
				continue
			}
			if yNum == year && mNum > int(month) {
				continue
			}
			dDir, err := im.listDir(filepath.Join(yinfo.Name(), minfo.Name()))
			if err != nil {
				im.logger.Println("Error listing day dir:", err)
				continue
			}
			sort.Sort(desc(dDir))
			for _, dinfo := range dDir {
				if !dinfo.IsDir() {
					continue
				}
				dNum, err := strconv.Atoi(dinfo.Name())
				if err != nil {
					continue
				}
				if yNum == year && mNum == int(month) && dNum > day {
					continue
				}
				dirPath := filepath.Join(yinfo.Name(), minfo.Name(), dinfo.Name())
				goOn := true
				im.dri.Range(dirPath, func(info fs.FileInfo) bool {
					if info.IsDir() {
						return true
					}
					goOn = f(filepath.Join(dirPath, info.Name()), info.Size())
					return goOn
				})
				if !goOn {
					goto BREAK
				}
			}
		}
	}
BREAK:
	return nil
}

func (im *ImgManager) listDir(path string) ([]fs.FileInfo, error) {
	infos := make([]fs.FileInfo, 0)
	err := im.dri.Range(path, func(info fs.FileInfo) bool {
		infos = append(infos, info)
		return true
	})
	return infos, err
}

type asc []fs.FileInfo

func (a asc) Len() int      { return len(a) }
func (a asc) Swap(i, j int) { a[i], a[j] = a[j], a[i] }
func (a asc) Less(i, j int) bool {
	yi, err := strconv.Atoi(a[i].Name())
	if err != nil {
		return false
	}
	yj, err := strconv.Atoi(a[j].Name())
	if err != nil {
		return true
	}
	return yi < yj
}

type desc []fs.FileInfo

func (d desc) Len() int      { return len(d) }
func (d desc) Swap(i, j int) { d[i], d[j] = d[j], d[i] }
func (d desc) Less(i, j int) bool {
	yi, err := strconv.Atoi(d[i].Name())
	if err != nil {
		return false
	}
	yj, err := strconv.Atoi(d[j].Name())
	if err != nil {
		return true
	}
	return yi > yj
}

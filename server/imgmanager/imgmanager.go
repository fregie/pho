package imgmanager

import (
	"bytes"
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
	"time"

	"github.com/Workiva/go-datastructures/queue"
	"github.com/nfnt/resize"
)

const (
	defaultWorkerNum          = 5
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
	t       actType
	path    string
	content []byte
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
				io.NopCloser(bytes.NewReader(act.content)),
				int64(len(act.content)))
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
	switch filepath.Ext(path) {
	case JpegSuffix:
		imghdl, err = jpeg.Decode(bytes.NewReader(content))
	case PngSuffix:
		imghdl, err = png.Decode(bytes.NewReader(content))
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
	err = im.dri.Upload(thumbPath, io.NopCloser(buf), int64(buf.Len()))
	if err != nil {
		return err
	}

	return nil
}

func (im *ImgManager) UploadImgAsync(path string, content []byte) {
	im.actQueue.Put(action{
		t:       actUpload,
		path:    path,
		content: content,
	})
}

func (im *ImgManager) GenerateThumbnailAsync(path string, content []byte) {
	im.actQueue.Put(action{
		t:       actGenerateThumbnail,
		path:    path,
		content: content,
	})
}

func (im *ImgManager) UploadImg(content io.Reader, name, date string) error {
	data, err := io.ReadAll(content)
	if err != nil {
		return err
	}
	var imgTime time.Time
	// try to get image time from metadata
	meta, err := GetImageMetadata(data)
	if err == nil {
		im.logger.Printf("Image metadata: %+v", meta)
		var date string
		if meta.Datetime != "" {
			date = meta.Datetime
		} else if meta.DateTimeOriginal != "" {
			date = meta.DateTimeOriginal
		} else if meta.CreateDate != "" {
			date = meta.CreateDate
		} else if meta.ModifyDate != "" {
			date = meta.ModifyDate
		}
		t, err := time.Parse("2006:01:02 15:04:05", date)
		if err == nil {
			imgTime = t
		}
	} else {
		im.logger.Println("Error getting image metadata:", err)
	}
	// try to get image time from given date
	if imgTime.IsZero() {
		t, err := time.Parse("2006:01:02 15:04:05", date)
		if err == nil {
			imgTime = t
		}
	}
	if imgTime.IsZero() {
		// use current time
		imgTime = time.Now()
	}
	path := filepath.Join(imgTime.Format("2006/01/02"), name)
	// TODO: check if file exist

	im.UploadImgAsync(path, data)
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

func (im *ImgManager) GetThumbnail(path string) (*Image, error) {
	img := &Image{}
	var err error
	thumbnailPath := filepath.Join(defaultThumbnailDir, path)
	exist, err := im.dri.IsExist(thumbnailPath)
	if err != nil {
		return img, err
	}
	if !exist {
		img.Content, img.Size, err = im.dri.Download(path)
		if err != nil {
			return img, err
		}
		content, err := io.ReadAll(img.Content)
		if err != nil {
			return img, err
		}
		img.Content.Close()
		err = im.GenerateThumbnail(path, content)
		if err != nil {
			return img, err
		}
	}
	img.Content, img.Size, err = im.dri.Download(thumbnailPath)
	if err != nil {
		return img, err
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

func (im *ImgManager) RangeByDate(start time.Time, f func(path string, size int64) bool) {
	t := start
	year, month, day := t.Date()
	yDir, err := im.listDir(".")
	if err != nil {
		im.logger.Println("Error listing year dir:", err)
		return
	}
	sort.Sort(asc(yDir))
	for _, yinfo := range yDir {
		if !yinfo.IsDir() {
			continue
		}
		yNum, err := strconv.Atoi(yinfo.Name())
		if err != nil {
			continue
		}
		if yNum < year {
			continue
		}
		mDir, err := im.listDir(filepath.Base(yinfo.Name()))
		if err != nil {
			im.logger.Println("Error listing month dir:", err)
			continue
		}
		sort.Sort(asc(mDir))
		for _, minfo := range mDir {
			if !minfo.IsDir() {
				continue
			}
			mNum, err := strconv.Atoi(minfo.Name())
			if err != nil {
				continue
			}
			if yNum == year && mNum < int(month) {
				continue
			}
			dDir, err := im.listDir(filepath.Join(yinfo.Name(), minfo.Name()))
			if err != nil {
				im.logger.Println("Error listing day dir:", err)
				continue
			}
			sort.Sort(asc(dDir))
			for _, dinfo := range dDir {
				if !dinfo.IsDir() {
					continue
				}
				dNum, err := strconv.Atoi(dinfo.Name())
				if err != nil {
					continue
				}
				if yNum == year && mNum == int(month) && dNum < day {
					continue
				}
				dirPath := filepath.Join(yinfo.Name(), minfo.Name(), dinfo.Name())
				var goOn bool
				im.dri.Range(dirPath, func(info fs.FileInfo) bool {
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
}

func (im *ImgManager) listDir(path string) ([]fs.FileInfo, error) {
	infos := make([]fs.FileInfo, 0)
	im.dri.Range(path, func(info fs.FileInfo) bool {
		infos = append(infos, info)
		return true
	})
	return infos, nil
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

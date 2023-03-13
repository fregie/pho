package imgmanager

import (
	"errors"

	"github.com/dsoprea/go-exif/v3"
	exifcommon "github.com/dsoprea/go-exif/v3/common"
)

type ImageMetadata struct {
	Model            string
	Datetime         string
	CreateDate       string
	DateTimeOriginal string
	ModifyDate       string
}

func GetImageMetadata(content []byte) (ImageMetadata, error) {
	rawExif, err := exif.SearchAndExtractExif(content)
	if err != nil {
		return ImageMetadata{}, err
	}
	ifdMapping, err := exifcommon.NewIfdMappingWithStandard()
	if err != nil {
		return ImageMetadata{}, err
	}
	ti := exif.NewTagIndex()
	_, index, err := exif.Collect(ifdMapping, ti, rawExif)
	if err != nil {
		return ImageMetadata{}, err
	}
	rootIfd := index.RootIfd
	im := ImageMetadata{}
	im.Model, _ = getExifValue(rootIfd, "Model")
	im.Datetime, _ = getExifValue(rootIfd, "DateTime")
	im.CreateDate, _ = getExifValue(rootIfd, "CreateDate")
	im.DateTimeOriginal, _ = getExifValue(rootIfd, "DateTimeOriginal")
	im.ModifyDate, _ = getExifValue(rootIfd, "ModifyDate")

	return im, nil
}

func getExifValue(rootIfd *exif.Ifd, name string) (string, error) {
	results, err := rootIfd.FindTagWithName(name)
	if err != nil {
		return "", err
	}
	if len(results) != 1 {
		return "", errors.New("there wasn't exactly one result of img metadata[" + name + "]")
	}
	value, err := results[0].Value()
	if err != nil {
		return "", err
	}
	var strValue string
	if str, ok := value.(string); ok {
		strValue = str
	}
	return strValue, nil
}

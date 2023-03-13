package static

import (
	_ "embed"
	"time"
)

//go:embed test_pic_01.jpg
var Pic1 []byte
var Pic1Name = "test_pic_01.png"
var Pic1Data = time.Date(2022, 11, 8, 23, 56, 44, 0, time.FixedZone("UTC+8", 8*60*60))

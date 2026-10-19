package imgmanager

import (
	"bytes"
	"testing"
	"time"

	"github.com/fregie/img_syncer/test/static"
)

// 复现测试：GitHub issue #83 / #82（数据丢失类）
//
// 问题描述：
//   - #83: 同步 mov 视频时"备份失败"，但源视频被删除、云端文件损坏无法打开
//   - #82: HEIC 照片同步后损坏（上传的文件不完整）
//
// 根因：服务端 Upload 链路（imgmanager.Upload → StorageDrive.Upload）
// 对 reader 实际产出的字节数不做校验：io.Copy/io.ReadAll 遇到"提前 EOF"
// 的 reader 时返回 nil error，截断的文件被当作完整文件保存并返回 200。
func TestUpload_TruncatedReader_ShouldBeRejected(t *testing.T) {
	md := newMockDrive()
	im := NewImgManager(Option{WorkerNum: 1})
	defer im.Close()
	im.dri = md

	truncated := static.Pic1[:len(static.Pic1)/2]
	declaredSize := int64(len(static.Pic1))
	if declaredSize < 2 {
		t.Fatalf("test fixture too small: %d", declaredSize)
	}

	err := im.Upload(
		bytes.NewReader(truncated),
		declaredSize,
		"IMG_0001.jpg",
		time.Date(2023, 1, 1, 10, 0, 0, 0, time.Local),
	)

	if err == nil {
		t.Fatalf("BUG REPRODUCED (#83/#82): truncated upload (%d bytes declared, %d bytes actual) was accepted without error; "+
			"remote would store a corrupt file and client marks it as synced", declaredSize, len(truncated))
	}

	if _, ok := md.files["2023/01/01/IMG_0001.jpg"]; ok {
		t.Fatalf("truncated file should not be stored when upload is rejected")
	}
}

func TestUpload_TruncatedReader_NoPartialFileStored(t *testing.T) {
	md := newMockDrive()
	im := NewImgManager(Option{WorkerNum: 1})
	defer im.Close()
	im.dri = md

	truncated := static.Pic1[:len(static.Pic1)/2]
	declaredSize := int64(len(static.Pic1))

	err := im.Upload(
		bytes.NewReader(truncated),
		declaredSize,
		"IMG_0002.jpg",
		time.Date(2023, 1, 1, 10, 0, 0, 0, time.Local),
	)
	if err == nil {
		t.Fatalf("truncated upload should have been rejected (issue #83/#82)")
	}
	if _, ok := md.files["2023/01/01/IMG_0002.jpg"]; ok {
		t.Fatalf("truncated file should NOT be stored when upload is rejected")
	}
}

// 对照组：声明 size 与实际字节一致时上传必须成功，防止 size check 误伤正常上传
func TestUpload_FullReader_Success(t *testing.T) {
	md := newMockDrive()
	im := NewImgManager(Option{WorkerNum: 1})
	defer im.Close()
	im.dri = md

	err := im.Upload(
		bytes.NewReader(static.Pic1),
		int64(len(static.Pic1)),
		"IMG_0003.jpg",
		time.Date(2023, 1, 1, 10, 0, 0, 0, time.Local),
	)
	if err != nil {
		t.Fatalf("full upload should succeed: %v", err)
	}
	stored, ok := md.files["2023/01/01/IMG_0003.jpg"]
	if !ok {
		t.Fatalf("file not stored")
	}
	if int64(len(stored)) != int64(len(static.Pic1)) {
		t.Fatalf("stored size mismatch: got %d, want %d", len(stored), len(static.Pic1))
	}
}

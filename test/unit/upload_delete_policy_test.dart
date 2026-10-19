import 'package:flutter_test/flutter_test.dart';
import 'package:img_syncer/storage/storage.dart';

void main() {
  group('shouldDeleteLocalFileAfterUpload（issue #83/#82 删除决策）', () {
    test('iOS 且上传成功 → 删除源文件', () {
      expect(
          shouldDeleteLocalFileAfterUpload(isIOS: true, uploadSucceeded: true),
          isTrue);
    });

    test('iOS 且上传失败 → 不删除源文件（#83：失败不得丢源文件）', () {
      expect(
          shouldDeleteLocalFileAfterUpload(isIOS: true, uploadSucceeded: false),
          isFalse);
    });

    test('非 iOS（Android/桌面）→ 不删除源文件', () {
      expect(
          shouldDeleteLocalFileAfterUpload(isIOS: false, uploadSucceeded: true),
          isFalse);
      expect(
          shouldDeleteLocalFileAfterUpload(
              isIOS: false, uploadSucceeded: false),
          isFalse);
    });
  });
}

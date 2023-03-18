import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/storage/storage.dart';

class Asset {
  bool hasLocal = false;
  bool hasRemote = false;
  AssetEntity? local;
  RemoteImage? remote;
  Uint8List defaultData = Uint8List.fromList([0]);

  Asset({this.local, this.remote}) {
    if (local != null) {
      hasLocal = true;
    }
    if (remote != null) {
      hasRemote = true;
    }
  }

  Future<Uint8List> thumbnailData() async {
    if (hasLocal) {
      final data = await local!.thumbnailData;
      return data!;
    }
    if (hasRemote) {
      return await remote!.thumbnail();
    }
    return defaultData;
  }

  Future<Uint8List> imageData() async {
    if (hasLocal) {
      final data = await local!.originBytes;
      return data!;
    }
    if (hasRemote) {
      return await remote!.imageData();
    }
    return defaultData;
  }
}

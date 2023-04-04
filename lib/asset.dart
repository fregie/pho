import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class Asset extends ImageProvider<Asset> {
  bool hasLocal = false;
  bool hasRemote = false;
  AssetEntity? local;
  RemoteImage? remote;
  final Uint8List _defaultData = Uint8List.fromList([]);
  Completer<Uint8List>? _thumbnailDataCompleter;
  Uint8List? _thumbnailData;
  Completer<Uint8List>? _dataAsyncCompleter;
  Uint8List? _data;

  String? make;
  String? model;
  int? imageWidth;
  int? imageHeight;
  double imageSize = 0;
  String? date;
  String? iSO;
  String? exposureTime;
  String? fNumber;
  String? focalLength;

  Asset({this.local, this.remote}) {
    if (local != null) {
      hasLocal = true;
    }
    if (remote != null) {
      hasRemote = true;
    }
  }

  bool isLocal() {
    return hasLocal;
  }

  String? name() {
    if (hasLocal) {
      return local!.title;
    }
    if (hasRemote) {
      return basename(remote!.path);
    }
    return "";
  }

  Uint8List thumbnailData() {
    if (_thumbnailData != null) {
      return _thumbnailData!;
    }
    return _defaultData;
  }

  Future<Uint8List> thumbnailDataAsync() async {
    if (_thumbnailData != null) {
      return _thumbnailData!;
    }
    if (_thumbnailDataCompleter != null) {
      return _thumbnailDataCompleter!.future;
    }
    _thumbnailDataCompleter = Completer<Uint8List>();
    Uint8List? data;
    if (hasLocal) {
      data = await local!.thumbnailData;
    }
    if (hasRemote) {
      data = await remote!.thumbnail();
    }
    if (data == null) {
      _thumbnailDataCompleter!.complete(_defaultData);
      return _defaultData;
    } else {
      _thumbnailDataCompleter!.complete(data);
      _thumbnailData = data;
      return data;
    }
  }

  Future<Uint8List> imageDataAsync() async {
    if (_data != null) {
      return _data!;
    }
    if (_dataAsyncCompleter != null) {
      return _dataAsyncCompleter!.future;
    }
    _dataAsyncCompleter = Completer<Uint8List>();
    Uint8List? data;
    try {
      if (hasLocal) {
        data = await local!.originBytes;
      }
      if (hasRemote) {
        data = await remote!.imageData();
      }
    } catch (e) {
      print(e);
    }
    if (data == null) {
      _dataAsyncCompleter!.complete(_defaultData);
      return _defaultData;
    } else {
      _dataAsyncCompleter!.complete(data);
      _data = data;
      return data;
    }
  }

  String path() {
    if (hasLocal) {
      if (local!.relativePath == null) {
        return "unknown";
      }
      return "${local!.relativePath!}${local!.title}";
    }
    if (hasRemote) {
      return remote!.path;
    }
    return "";
  }

  Future<void> delete() async {
    if (hasLocal) {
      await PhotoManager.editor.deleteWithIds([local!.id]);
    }
    if (hasRemote) {
      final rsp = await remote!.cli.delete(DeleteRequest(
        paths: [remote!.path],
      ));
      if (!rsp.success) {
        throw Exception("delete failed: ${rsp.message}");
      }
    }
  }

  AssetEntity? getLocal() {
    return local;
  }

  bool _isInfoReaded = false;
  bool _isSizeInfoReadedFinished = false;
  bool _isExifInfoReadedFinished = false;

  bool isInfoReady() {
    return _isSizeInfoReadedFinished && _isExifInfoReadedFinished;
  }

  void readInfoFromData() async {
    if (_isInfoReaded) {
      return;
    }
    _isInfoReaded = true;
    final data = await imageDataAsync();
    if (isLocal()) {
      imageWidth = getLocal()!.width;
      imageHeight = getLocal()!.height;
      imageSize = data.length / 1024 / 1024;
      _isSizeInfoReadedFinished = true;
    } else {
      compute(img.decodeImage, data).then((image) {
        if (image != null) {
          imageWidth = image.width;
          imageHeight = image.height;
          imageSize = data.length / 1024 / 1024;
        }
        _isSizeInfoReadedFinished = true;
      });
    }
    compute(readExifFromBytes, data).then((exifData) {
      if (exifData.isEmpty) {
        print("No Exif data found");
      } else {
        for (String key in exifData.keys) {
          // print("$key: ${exifData[key]!.printable}");
          switch (key) {
            case 'Image Make':
              make = exifData[key]!.toString();
              break;
            case 'Image Model':
              model = exifData[key]!.toString();
              break;
            case 'Image DateTime':
              final v = exifData[key]!.toString();
              if (v != "") {
                try {
                  DateTime dateTime = DateTime.parse(
                      v.replaceAll(':', '').replaceAll(' ', 'T'));
                  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                  date = dateFormat.format(dateTime);
                } catch (e) {
                  print(e);
                }
              }
              break;
            case 'EXIF ISOSpeedRatings':
              iSO = exifData[key]!.toString();
              break;
            case 'EXIF ExposureTime':
              exposureTime = exifData[key]!.toString();
              break;
            case 'EXIF FNumber':
              try {
                final v = exifData[key]!.toString();
                List<String> parts = v.split('/');

                int numerator = int.parse(parts[0]);
                int denominator = int.parse(parts[1]);

                double value = numerator / denominator;
                fNumber = value.toStringAsFixed(1);
              } catch (e) {
                print(e);
              }
              break;
            case "EXIF FocalLength":
              try {
                final v = exifData[key]!.toString();
                List<String> parts = v.split('/');

                int numerator = int.parse(parts[0]);
                int denominator = int.parse(parts[1]);
                double value = numerator / denominator;
                focalLength = value.toStringAsFixed(2);
              } catch (e) {
                print(e);
              }
              break;
            default:
              break;
          }
        }
      }
      _isExifInfoReadedFinished = true;
    });
  }

  @override
  Future<Asset> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Asset>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(Asset key, DecoderBufferCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(Asset key, DecoderBufferCallback decode) async {
    final Uint8List data = await imageDataAsync();
    if (data.isEmpty) {
      throw Exception("no data");
    }
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return ImageInfo(image: fi.image);
  }

  @override
  String toString() => 'Asset(local: $local, remote: $remote)';
}

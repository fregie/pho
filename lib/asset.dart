import 'dart:async';
import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';
import 'package:img_syncer/global.dart';
import 'package:img_syncer/logger/logger.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:img_syncer/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class Asset extends ImageProvider<Asset> {
  bool hasLocal = false;
  bool hasRemote = false;
  AssetEntity? local;
  RemoteImage? remote;
  Completer<Uint8List>? _thumbnailDataCompleter;
  Uint8List? _thumbnailData;
  bool _isThumbnailDataValid = true;
  bool _thumbnailLoadFailed = false;
  DateTime? _thumbnailRetryAfter;
  Completer<Uint8List>? _dataAsyncCompleter;
  Uint8List? _data;
  bool _isDataValid = true;
  Duration? _cachedDuration;
  bool _durationLoading = false;
  /// 原图加载进度 (0.0~1.0), -1 表示未在加载/已完成
  final ValueNotifier<double> imageLoadProgress = ValueNotifier<double>(-1);

  String? make;
  String? model;
  int? imageWidth;
  int? imageHeight;
  double? imageSize = 0;
  String? date;
  String? iSO;
  String? exposureTime;
  String? fNumber;
  String? focalLength;

  File? localFile;
  String? localTitle;

  Asset({this.local, this.remote}) {
    if (local != null) {
      hasLocal = true;
      if (assetModel.titleCache.containsKey(local!.id)) {
        localTitle = assetModel.titleCache[local!.id];
      }
    }
    if (remote != null) {
      hasRemote = true;
    }
  }

  bool isLocal() {
    return hasLocal;
  }

  bool hasGotTitle() {
    return localTitle != null;
  }

  Future<File?> getLocalFile() async {
    if (localFile != null) {
      return localFile;
    }
    if (hasLocal) {
      await Future.wait([
        local!.originFile.then((value) => localFile = value),
      ]);
    }
    return localFile;
  }

  Future<String> name() async {
    if (hasLocal) {
      String title;
      if (local!.title != null && local!.title != "") {
        assetModel.addTitleCache(local!.id, local!.title!);
        localTitle = local!.title!;
        title = local!.title!;
      } else if (localTitle != null && localTitle != "") {
        title = localTitle!;
      } else if (assetModel.titleCache.containsKey(local!.id)) {
        localTitle = assetModel.titleCache[local!.id];
        title = localTitle!;
      } else {
        localTitle = await local!.titleAsync;
        assetModel.addTitleCache(local!.id, localTitle!);
        title = localTitle!;
      }
      return title;
    }
    if (hasRemote) {
      return basename(remote!.path);
    }
    return "";
  }

  Future<String> nameDecoded() async {
    if (hasLocal) {
      return await name();
    }
    final realName = basename(remote!.path);
    if (realName.length < 15 || realName[14] != '_') {
      return realName;
    }
    return realName.substring(15);
  }

  Future<String> originName() async {
    if (hasLocal) {
      return await name();
    } else {
      String oName = await nameDecoded();
      if (extension(oName) == ".aes") {
        oName = oName.substring(0, oName.length - 4);
      }
      return oName;
    }
  }

  Future<String?> mimeType() async {
    String fileName = await name();
    if (extension(fileName) == ".aes") {
      fileName = fileName.substring(0, fileName.length - 4);
    }
    final RegExp regex = RegExp(r'\.([a-zA-Z0-9]+)$');
    final Match? match = regex.firstMatch(fileName);

    if (match != null && match.groupCount > 0) {
      final String extensionName = match.group(1)?.toLowerCase() ?? '';
      return mimeTypeByExtension(extensionName);
    } else {
      return null;
    }
  }

  DateTime dateCreated() {
    if (hasLocal) {
      return local!.createDateTime;
    }
    if (hasRemote) {
      final filePath = remote!.path;
      var format1 = RegExp(r'^(\d{4})/(\d{2})/(\d{2})/');
      var format2 = RegExp(r'^(\d{4})(\d{2})(\d{2})/');

      // Check if file path matches the first format.
      var match = format1.firstMatch(filePath);
      if (match != null) {
        var year = match.group(1);
        var month = match.group(2);
        var day = match.group(3);
        return DateTime.parse('$year$month$day');
      }

      // Check if file path matches the second format.
      match = format2.firstMatch(filePath);
      if (match != null) {
        var year = match.group(1);
        var month = match.group(2);
        var day = match.group(3);
        return DateTime.parse('$year$month$day');
      }
    }
    return DateTime.now();
  }

  // Uint8List thumbnailData() {
  //   if (_thumbnailData != null) {
  //     return _thumbnailData!;
  //   }
  //   return Uint8List(0);
  // }

  bool isVideo() {
    if (hasLocal) {
      return local!.type == AssetType.video;
    }
    if (hasRemote) {
      return remote!.isVideo();
    }
    return false;
  }

  Future<Duration> videoDuration() async {
    if (!isVideo()) {
      return Duration.zero;
    }
    if (hasLocal) {
      return local!.videoDuration;
    }
    if (hasRemote) {
      if (_cachedDuration != null) {
        return _cachedDuration!;
      }
      if (_durationLoading) {
        return Duration.zero;
      }
      _durationLoading = true;
      try {
        var uri = remote!.path;
        if (uri[0] != '/') {
          uri = "/$uri";
        }
        final url = "$httpBaseUrl$uri";
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
        );
        await controller.initialize();
        _cachedDuration = controller.value.duration;
        controller.dispose();
        return _cachedDuration ?? Duration.zero;
      } catch (e) {
        logger.addLog("Failed to get remote video duration: $e");
        return Duration.zero;
      } finally {
        _durationLoading = false;
      }
    }
    return Duration.zero;
  }

  bool isLivePhoto() {
    if (hasLocal) {
      return local!.isLivePhoto;
    }
    if (hasRemote) {
      return remote!.isLivePhoto;
    }
    return false;
  }

  Future<VideoPlayerController?> getLivePhotoVideoController() async {
    if (hasLocal) {
      final File? videoFile = await local!.fileWithSubtype;
      if (videoFile != null) {
        return VideoPlayerController.file(videoFile);
      }
    }
    if (hasRemote) {
      var uri = remote!.path;
      if (uri[0] != '/') {
        uri = "/$uri";
      }
      final url = "$httpBaseUrl/live$uri";
      final controller = VideoPlayerController.network(url);
      return controller;
    }
    return null;
  }

  bool loadThumbnailFinished() {
    return _thumbnailData != null || _thumbnailLoadFailed;
  }

  ImageProvider thumbnailProvider() {
    try {
      if (_thumbnailData != null && _thumbnailData!.isNotEmpty) {
        return MemoryImage(_thumbnailData!);
      }
    } catch (e) {
      logger.addLog(e.toString());
    }
    return Image.asset(_thumbnailLoadFailed
            ? "assets/images/broken.png"
            : "assets/images/gray.jpg")
        .image;
  }

  Future<Uint8List> thumbnailDataAsync() async {
    if (_thumbnailData != null) {
      return _thumbnailData!;
    }
    if (_thumbnailDataCompleter != null) {
      return _thumbnailDataCompleter!.future;
    }
    final retryAfter = _thumbnailRetryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) {
      return _loadBrokenThumbnail();
    }
    final completer = Completer<Uint8List>();
    _thumbnailDataCompleter = completer;
    Uint8List? data;
    if (hasLocal) {
      data = await local!
          .thumbnailDataWithSize(const ThumbnailSize.square(200), quality: 80);
    }
    if (hasRemote) {
      data = await remote!.thumbnail();
    }
    // 失败或不可解码的缩略图不写入缓存，5 秒后允许重试（issue #89）
    if (data == null || data.isEmpty || !await isValidImage(data)) {
      _isThumbnailDataValid = false;
      _thumbnailLoadFailed = true;
      _thumbnailRetryAfter = DateTime.now().add(const Duration(seconds: 5));
      if (identical(_thumbnailDataCompleter, completer)) {
        _thumbnailDataCompleter = null;
      }
      final broken = await _loadBrokenThumbnail();
      completer.complete(broken);
      return broken;
    }
    _isThumbnailDataValid = true;
    _thumbnailLoadFailed = false;
    _thumbnailRetryAfter = null;
    _thumbnailData = data;
    if (identical(_thumbnailDataCompleter, completer)) {
      _thumbnailDataCompleter = null;
    }
    completer.complete(data);
    return data;
  }

  Future<Uint8List> _loadBrokenThumbnail() async {
    final broken = await rootBundle.load("assets/images/broken.png");
    return broken.buffer.asUint8List();
  }

  Future<Uint8List> imageDataAsync({bool reportProgress = false}) async {
    if (_data != null) {
      return _data!;
    }
    if (_dataAsyncCompleter != null) {
      return _dataAsyncCompleter!.future;
    }
    _dataAsyncCompleter = Completer<Uint8List>();
    // 非下载场景通过 imageLoadProgress 轻量通知进度，不触发 notifyListeners
    final bool useLightProgress = !reportProgress && hasRemote && !remote!.isVideo();
    if (useLightProgress) {
      imageLoadProgress.value = 0;
    }
    Uint8List? data;
    try {
      if (hasLocal) {
        if (local!.type == AssetType.image) {
          data = await local!.originBytes;
        } else if (local!.type == AssetType.video) {
          data = await local!
              .thumbnailDataWithSize(const ThumbnailSize.square(800));
        }
      }
      if (hasRemote) {
        if (!remote!.isVideo()) {
          data = await remote!.imageData(
            reportProgress: reportProgress,
            onProgress: useLightProgress
                ? (downloaded, total) {
                    if (total > 0) {
                      imageLoadProgress.value = downloaded / total;
                    }
                  }
                : null,
          );
        } else {
          data = await remote!.thumbnail();
        }
      }
    } catch (e) {
      logger.addLog("Get image data failed: $e");
    }
    if (useLightProgress) {
      imageLoadProgress.value = 1;
    }
    if (data == null || data.isEmpty) {
      final brokenData = await rootBundle.load("assets/images/broken.png");
      _dataAsyncCompleter!.complete(brokenData.buffer.asUint8List());
      return brokenData.buffer.asUint8List();
    } else {
      _dataAsyncCompleter!.complete(data);
      _data = data;
      return data;
    }
  }

  Future<String> downloadToTmpFilePath() async {
    if (hasLocal) {
      final file = await local!.originFile;
      return file!.path;
    } else {
      final stream = remote!.dataStream();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${originName()}';
      final file = File(filePath);
      final fileStream = file.openWrite();
      await for (var data in stream) {
        fileStream.add(data);
      }
      await fileStream.close();
      return filePath;
    }
  }

  Future<String> path() async {
    if (hasLocal) {
      if (localFile != null) {
        return localFile!.path;
      }
      localFile = await local!.originFile;
      return localFile!.path;
    }
    if (hasRemote) {
      return remote!.path;
    }
    return "";
  }

  Future<String> unencryptedPath() async {
    String p = await path();
    if (extension(p) == ".aes") {
      p = p.substring(0, p.length - 4);
    }
    return p;
  }

  Future<void> delete() async {
    if (hasLocal) {
      await PhotoManager.editor.deleteWithIds([local!.id]);
    }
    if (hasRemote) {
      final rsp =
          await remote!.cli.delete(DeleteRequest(paths: [remote!.path]));
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

  Future<double> size() async {
    if (!isVideo() && imageSize != null && imageSize != 0) {
      return imageSize!;
    }
    if (hasLocal) {
      final f = await local!.originFile;
      if (f != null) {
        imageSize = await f.length() / 1024 / 1024;
        return imageSize!;
      }
    }
    if (hasRemote && remote!.size != null) {
      imageSize = remote!.size! / 1024 / 1024;
      return imageSize!;
    }
    return 0;
  }

  Future<void> readInfoFromData() async {
    if (_isInfoReaded) {
      return;
    }
    _isInfoReaded = true;
    final data = await imageDataAsync();
    imageSize = data.length / 1024 / 1024;
    if (isLocal()) {
      imageWidth = getLocal()!.width;
      imageHeight = getLocal()!.height;
      imageSize = data.length / 1024 / 1024;
      _isSizeInfoReadedFinished = true;
    } else {
      img.Decoder? decoder = img.findDecoderForNamedImage(await originName());
      decoder ??= img.findDecoderForData(data);
      if (decoder != null) {
        compute(decoder.decode, data).then((image) {
          if (image != null) {
            imageWidth = image.width;
            imageHeight = image.height;
          }
          _isSizeInfoReadedFinished = true;
        }, onError: (e) {
          logger.addLog(e);
          _isSizeInfoReadedFinished = true;
        });
      } else {
        _isSizeInfoReadedFinished = true;
      }
    }
    compute(readExifFromBytes, data).then((exifData) {
      if (exifData.isEmpty) {
        logger.addLog("No Exif data found");
      } else {
        int? exifWidth;
        int? exifHeight;
        int? Rotated;
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
                  logger.addLog(e.toString());
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
                logger.addLog(e.toString());
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
                logger.addLog(e.toString());
              }
              break;
            case "EXIF ExifImageWidth":
              final w = int.parse(exifData[key]!.toString());
              if (w > 0 && imageHeight == null) {
                exifWidth = w;
              }
              break;
            case "EXIF ExifImageLength":
              final h = int.parse(exifData[key]!.toString());
              if (h > 0 && imageWidth == null) {
                exifHeight = h;
              }
              break;
            case "Image Orientation":
              RegExp regex = RegExp(r'(\d+)');
              Match? match = regex.firstMatch(exifData[key]!.toString());
              if (match != null) {
                Rotated = int.parse(match.group(1)!);
              }
              break;
            default:
              break;
          }
        }
        if (imageWidth == null &&
            imageHeight == null &&
            exifWidth != null &&
            exifHeight != null) {
          if (Rotated == 0 || Rotated == 180) {
            imageWidth = exifWidth;
            imageHeight = exifHeight;
          } else {
            imageWidth = exifHeight;
            imageHeight = exifWidth;
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
    return MultiFrameImageStreamCompleter(
      codec: _loadAsyncMultiFrame(key, decode),
      scale: 1,
      informationCollector: () sync* {
        yield ErrorDescription('Image provider: ${describeIdentity(key)}');
      },
    );
    // if (extension(unencryptedPath()) == ".gif") {
    // }
    // return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(Asset key, DecoderBufferCallback decode) async {
    Uint8List data = await imageDataAsync();
    if (data.isEmpty) {
      data = await thumbnailDataAsync();
    }
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(data);
      final ui.FrameInfo fi = await codec.getNextFrame();
      return ImageInfo(image: fi.image);
    } catch (e) {
      logger.addLog(e.toString());
      _isDataValid = false;
    }
    return await loadImage("assets/images/gray.jpg");
  }

  Future<ui.Codec> _loadAsyncMultiFrame(
      Asset key, DecoderBufferCallback decode) async {
    Uint8List data = await imageDataAsync();
    if (data.isEmpty) {
      data = await thumbnailDataAsync();
    }
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(data);
      return codec;
    } catch (e) {
      logger.addLog("find codec failed: $e");
      _isDataValid = false;
    }
    // If the data is invalid, you might want to load a fallback image.
    // For this, you'll need to load the bytes for the fallback image and instantiate the codec for that.
    // However, be careful, as this is a potential infinite loop if the fallback image fails to load too.
    data = await _loadFallbackImageData();
    return ui.instantiateImageCodec(data);
  }

  Future<Uint8List> _loadFallbackImageData() async {
    ByteData data = await rootBundle.load("assets/images/gray.jpg");
    return data.buffer.asUint8List();
  }

  @override
  String toString() => 'Asset(local: $local, remote: $remote)';
}

Future<bool> isValidImage(Uint8List imageData) async {
  try {
    final ui.Codec codec = await ui.instantiateImageCodec(imageData);
    return codec != null;
  } catch (e) {
    return false;
  }
}

Future<ImageInfo> loadImage(String path) async {
  final Completer<ImageInfo> completer = Completer();
  final ImageProvider provider = AssetImage(path);
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener((ImageInfo info, bool _) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }
  });

  stream.addListener(listener);
  completer.future.then((_) => stream.removeListener(listener));

  return completer.future;
}

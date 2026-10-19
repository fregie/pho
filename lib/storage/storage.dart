import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:grpc/grpc.dart';
import 'package:img_syncer/logger/logger.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:date_format/date_format.dart';
import 'package:img_syncer/state_model.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:img_syncer/util.dart';
import 'package:img_syncer/storage/storage_interface.dart';

/// 将 EncryptionType 转为 HTTP 头字符串
String encryptionTypeName(EncryptionType type) {
  switch (type) {
    case EncryptionType.none:
      return 'None';
    case EncryptionType.aesCfb:
      return 'AES_128_CFB';
    case EncryptionType.aesGcm:
      return 'AES_256_GCM';
  }
}

RemoteStorage storage = RemoteStorage("127.0.0.1", 10000);

/// 上传完成后是否删除本地源文件：仅 iOS 且上传成功时删除。
/// 原 finally 块无条件删除，同步失败时源文件会丢失（issue #83/#82）。
bool shouldDeleteLocalFileAfterUpload({
  required bool isIOS,
  required bool uploadSucceeded,
}) =>
    isIOS && uploadSucceeded;

/// 测试注入用的 override，非 null 时替换 storage 全局变量
RemoteStorageClient? _storageOverride;
RemoteStorageClient get storageClient => _storageOverride ?? storage;
void setStorageForTest(RemoteStorageClient v) => _storageOverride = v;

class RemoteStorage implements RemoteStorageClient {
  int bufferSize = 1024 * 1024;
  /// 共享 HTTP 客户端，复用连接减少 TCP 握手开销
  http.Client httpClient = http.Client();
  ImgSyncerClient cli = ImgSyncerClient(ClientChannel(
    "127.0.0.1",
    port: 50051,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      keepAlive: ClientKeepAliveOptions(
        pingInterval: Duration(seconds: 20),
        permitWithoutCalls: true,
      ),
    ),
  ));
  RemoteStorage(String addr, int port) {
    final channel = ClientChannel(
      addr,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    cli = ImgSyncerClient(channel);
  }

  Future<void> uploadXFile(XFile file) async {
    await checkServer();
    final name = basename(file.path);
    final date = await file.lastModified();
    final dateStr =
        formatDate(date, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    var thumbnailSize = 200;
    if (isVideoByPath(file.path)) {
      thumbnailSize = 800;
    }
    var thumbnailData = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: thumbnailSize,
      minHeight: thumbnailSize,
      quality: 90,
    );
    int uploaded = 0;
    final imgLen = await file.length();
    // final thumbLen = thumbnailData!.length;
    final totalLen = imgLen;
    var req = http.StreamedRequest("POST", Uri.parse("$httpBaseUrl/$name"));
    req.headers['Image-Date'] = dateStr;
    req.contentLength = imgLen;
    file.openRead().listen((chunk) {
      uploaded += chunk.length;
      req.sink.add(chunk);
    }, onDone: () {
      req.sink.close();
    }, onError: (e) {
      req.sink.close();
      throw Exception("file read error: $e");
    });
    final response = await req.send();
    if (response.statusCode != 200) {
      throw Exception("upload failed: ${response.statusCode}");
    }
    final thumbRsp = await http.post(
      Uri.parse("$httpBaseUrl/thumbnail/$name"),
      body: thumbnailData,
      headers: {
        'Image-Date': dateStr,
      },
    );
    if (thumbRsp.statusCode != 200) {
      throw Exception("upload thumbnail failed: ${thumbRsp.statusCode}");
    }
  }

  Future<void> uploadAssetEntity(AssetEntity asset) async {
    await checkServer();
    final file = await asset.originFile;
    if (file == null) {
      throw Exception("asset file is null");
    }
    String? name = asset.title;
    name ??= await asset.titleAsync;
    // print("upload $name");
    var date = asset.createDateTime;
    if (date.isBefore(DateTime(1990, 1, 1))) {
      date = asset.modifiedDateTime;
    }
    final dateStr =
        formatDate(date, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    var thumbnailSize = const ThumbnailSize.square(200);
    if (asset.type == AssetType.video) {
      thumbnailSize = const ThumbnailSize.square(800);
    }
    final thumbnailData =
        await asset.thumbnailDataWithSize(thumbnailSize, quality: 90);
    // 缩略图生成失败（视频/HEIC 等）时降级：跳过缩略图继续上传原件（issue #64/#57）
    File? liveVideoFile;
    final imgLen = await file.length();
    final thumbLen = thumbnailData?.length ?? 0;
    int totalLen = imgLen + thumbLen;
    stateModel.updateUploadProgress(asset.id, 1, totalLen);
    int maxRetries = 3;
    int retryCount = 0;
    bool succeeded = false;
    while (!succeeded) {
      int uploaded = 0;
      try {
        // live 视频在重试循环内重新获取：iCloud 优化存储下视频可能未下载，
        // 首轮拿不到（返回 null），重试时可能已下载完成。
        // 拿不到视频时不静默跳过——抛异常走 catch，失败则不加入 syncedIDs。
        liveVideoFile = null;
        if (asset.isLivePhoto) {
          liveVideoFile = await asset.originFileWithSubtype;
          if (liveVideoFile == null) {
            throw Exception(
                "live video file not available (iCloud not downloaded?)");
          }
          totalLen = imgLen + thumbLen + await liveVideoFile.length();
        }
        // upload thumbnail（缩略图缺失时跳过，不中止上传）
        if (thumbnailData != null) {
          final thumbRsp = await http.post(
            Uri.parse("$httpBaseUrl/thumbnail/$name"),
            body: thumbnailData,
            headers: {
              'Image-Date': dateStr,
              'Image-Is-Live-Photo': asset.isLivePhoto ? "true" : "false",
              'Image-Encrypt-Type': settingModel.enableEncrypt
                  ? encryptionTypeName(settingModel.encryptionType)
                  : "None",
              'Image-Encrypt-Password': settingModel.enableEncrypt
                  ? settingModel.encryptionPassword
                  : "",
            },
          );
          stateModel.updateUploadProgress(
              asset.id, uploaded + thumbLen, totalLen);
          if (thumbRsp.statusCode != 200) {
            stateModel.finishUpload(asset.id, false);
            logger.addLog(
                "upload $name thumbnail failed: ${thumbRsp.statusCode} ${thumbRsp.body}");
            throw Exception(
                "upload thumbnail failed: [${thumbRsp.statusCode}] ${thumbRsp.body}");
          }
        }
        // upload origin image
        var req = http.StreamedRequest("POST", Uri.parse("$httpBaseUrl/$name"));
        req.headers['Image-Date'] = dateStr;
        req.headers['Image-Is-Live-Photo'] =
            asset.isLivePhoto ? "true" : "false";
        if (settingModel.enableEncrypt) {
          req.headers['Image-Encrypt-Type'] =
              encryptionTypeName(settingModel.encryptionType);
          req.headers['Image-Encrypt-Password'] =
              settingModel.encryptionPassword;
        }
        req.contentLength = await file.length();
        file.openRead().listen((chunk) {
          uploaded += chunk.length;
          stateModel.updateUploadProgress(
              asset.id, uploaded + thumbLen, totalLen);
          req.sink.add(chunk);
        }, onDone: () {
          req.sink.close();
        }, onError: (e) {
          req.sink.close();
          throw Exception("file read error: $e");
        });
        final response = await req.send();
        if (response.statusCode != 200) {
          stateModel.finishUpload(asset.id, false);
          final body = await response.stream.bytesToString();
          throw Exception("upload failed: [${response.statusCode}] $body");
        }
        // upload Live Photo video
        if (asset.isLivePhoto && liveVideoFile != null) {
          final videoName = await asset.titleAsyncWithSubtype;
          var req = http.StreamedRequest(
              "POST", Uri.parse("$httpBaseUrl/live/$videoName"));
          req.headers['Image-Date'] = dateStr;
          req.headers['Image-Is-Live-Photo'] =
              asset.isLivePhoto ? "true" : "false";
          if (settingModel.enableEncrypt) {
            req.headers['Image-Encrypt-Type'] =
                encryptionTypeName(settingModel.encryptionType);
            req.headers['Image-Encrypt-Password'] =
                settingModel.encryptionPassword;
          }
          req.contentLength = await liveVideoFile.length();
          liveVideoFile.openRead().listen((chunk) {
            uploaded += chunk.length;
            stateModel.updateUploadProgress(
                asset.id, uploaded + thumbLen, totalLen);
            req.sink.add(chunk);
          }, onDone: () {
            req.sink.close();
          }, onError: (e) {
            req.sink.close();
            throw Exception("file read error: $e");
          });
          final response = await req.send();
          if (response.statusCode != 200) {
            stateModel.finishUpload(asset.id, false);
            final body = await response.stream.bytesToString();
            throw Exception("upload failed: [${response.statusCode}] $body");
          }
        }
        stateModel.finishUpload(asset.id, true);
        succeeded = true;
      } catch (e) {
        stateModel.finishUpload(asset.id, false);
        retryCount++;
        if (retryCount >= maxRetries) {
          logger.addLog("upload $name failed: $e");
          rethrow;
        }
      } finally {
        if (shouldDeleteLocalFileAfterUpload(
            isIOS: Platform.isIOS, uploadSucceeded: succeeded)) {
          Future.delayed(const Duration(milliseconds: 200), () {
            try {
              file.deleteSync();
              liveVideoFile?.deleteSync();
            } catch (e) {
              logger.addLog("delete file failed: $e");
            }
          });
        }
      }
    }
  }

  // @protected
  // Stream<UploadRequest> uploadStream(Stream<List<int>> dataReader,
  //     Stream<Uint8List> thumbnailReader, String name, date) async* {
  //   yield UploadRequest(name: name, date: date);
  //   await for (var data in dataReader) {
  //     yield UploadRequest(data: data);
  //   }
  //   await for (var data in thumbnailReader) {
  //     yield UploadRequest(thumbnailData: data);
  //   }
  // }

  Future<List<RemoteImage>> listImages(
      String date, int offset, maxReturn) async {
    final rsp = await cli
        .listByDate(
          ListByDateRequest(
            date: date,
            offset: offset,
            maxReturn: maxReturn,
          ),
        )
        .timeout(const Duration(seconds: 60));
    if (!rsp.success) {
      throw Exception("list images failed: ${rsp.message}");
    }
    return rsp.infos
        .map((e) => RemoteImage(cli, e.path.replaceAll('\\', '/'),
            size: e.size.toInt(),
            isLivePhoto: e.isLivePhoto,
            httpClient: httpClient))
        .toList();
  }
}

class RemoteImage {
  ImgSyncerClient cli;
  String path;
  int? size;
  Uint8List? data;
  Uint8List? thumbnailData;
  bool isLivePhoto = false;
  /// 共享 HTTP 客户端，复用连接减少 TCP 握手开销
  late http.Client httpClient;

  RemoteImage(
    this.cli,
    this.path, {
    this.data,
    this.thumbnailData,
    this.size,
    this.isLivePhoto = false,
    required this.httpClient,
  });

  bool isVideo() {
    return isVideoByPath(path);
  }

  Stream<Uint8List> thumbnailStream() async* {
    await checkServer();
    var urlPath = path;
    if (urlPath[0] == '/') {
      urlPath = urlPath.substring(1);
    }
    final url = '$httpBaseUrl/thumbnail/$urlPath';
    final request = http.Request('GET', Uri.parse(url));
    if (settingModel.enableEncrypt) {
      request.headers['Image-Encrypt-Type'] =
          encryptionTypeName(settingModel.encryptionType);
      request.headers['Image-Encrypt-Password'] =
          settingModel.encryptionPassword;
    }
    final response = await httpClient.send(request);
    if (response.statusCode != 200) {
      final errMsg = await response.stream.bytesToString();
      throw Exception(
          "get [$urlPath] thumbnail failed: [${response.reasonPhrase}] $errMsg");
    }
    await for (var data in response.stream) {
      yield data as Uint8List;
    }
  }

  Future<Uint8List?> thumbnail() async {
    if (thumbnailData != null) {
      return thumbnailData;
    }
    int maxRetries = 3;
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        var currentData = BytesBuilder();
        var dataStream = thumbnailStream();
        await for (var d in dataStream) {
          currentData.add(d);
        }
        final bytes = currentData.takeBytes();
        if (bytes.isEmpty) {
          throw Exception("empty thumbnail");
        }
        thumbnailData = bytes;
        return bytes;
      } catch (e) {
        logger.addLog("get $path thumbnail failed: $e");
        retryCount++;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    // 失败不写入缓存，交给调用方重试（issue #89）
    return null;
  }

  Stream<Uint8List> dataStream({
    bool reportProgress = true,
    void Function(int downloaded, int total)? onProgress,
  }) async* {
    await checkServer();
    if (path[0] == '/') {
      path = path.substring(1);
    }
    final url = '$httpBaseUrl/$path';
    final request = http.Request('GET', Uri.parse(url));
    if (settingModel.enableEncrypt) {
      request.headers['Image-Encrypt-Type'] =
          encryptionTypeName(settingModel.encryptionType);
      request.headers['Image-Encrypt-Password'] =
          settingModel.encryptionPassword;
    }
    final response = await httpClient.send(request);
    if (response.statusCode != 200) {
      throw Exception("get image failed: ${response.statusCode}");
    }
    final total = response.contentLength ?? -1;
    if (reportProgress) {
      stateModel.updateDownloadProgress(basename(path), 1, total);
    }
    if (onProgress != null) {
      onProgress(1, total);
    }
    int downloaded = 0;
    await for (var data in response.stream) {
      downloaded += data.length;
      if (reportProgress) {
        stateModel.updateDownloadProgress(basename(path), downloaded, total);
      }
      if (onProgress != null) {
        onProgress(downloaded, total);
      }
      yield data as Uint8List;
    }
    if (reportProgress) {
      stateModel.finishDownload(basename(path), true);
    }
    if (onProgress != null) {
      onProgress(downloaded, total);
    }
  }

  Future<Uint8List> imageData({
    bool reportProgress = true,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    if (data != null) {
      return data!;
    }
    var currentData = BytesBuilder();
    var stream = dataStream(
      reportProgress: reportProgress,
      onProgress: onProgress,
    );
    await for (var d in stream) {
      currentData.add(d);
    }
    data = currentData.takeBytes();
    return data!;
  }
}

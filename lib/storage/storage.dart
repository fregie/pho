import 'dart:typed_data';
import 'package:grpc/grpc.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:date_format/date_format.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

RemoteStorage storage = RemoteStorage("127.0.0.1", 10000);

class RemoteStorage {
  int bufferSize = 1024 * 1024;
  ImgSyncerClient cli = ImgSyncerClient(ClientChannel(
    "127.0.0.1",
    port: 50051,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
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
    final name = basename(file.path);
    final lastModified = await file.lastModified();
    final date = formatDate(
        lastModified, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    var req = http.StreamedRequest("POST", Uri.parse("$httpBaseUrl/$name"));
    req.headers['Image-Date'] = date;
    req.contentLength = await file.length();
    file.openRead().listen((chunk) {
      req.sink.add(chunk);
    }, onDone: () {
      req.sink.close();
    });
    final response = await req.send();
    if (response.statusCode != 200) {
      throw Exception("upload failed: ${response.statusCode}");
    }
  }

  Future<void> uploadAssetEntity(AssetEntity asset) async {
    final name = asset.title;
    if (name == null) {
      throw Exception("asset name is null");
    }
    var date = asset.createDateTime;
    if (date.isBefore(DateTime(1990, 1, 1))) {
      date = asset.modifiedDateTime;
    }
    final dateStr =
        formatDate(date, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    final f = await asset.file;
    if (f == null) {
      throw Exception("asset file is null");
    }
    var thumbnailSize = const ThumbnailSize.square(200);
    if (asset.type == AssetType.video) {
      thumbnailSize = const ThumbnailSize.square(800);
    }
    final thumbnailData =
        await asset.thumbnailDataWithSize(thumbnailSize, quality: 90);
    if (thumbnailData == null) {
      throw Exception("asset thumbnail is null");
    }
    var req = http.StreamedRequest("POST", Uri.parse("$httpBaseUrl/$name"));
    req.headers['Image-Date'] = dateStr;
    req.contentLength = await f.length();
    f.openRead().listen((chunk) {
      req.sink.add(chunk);
    }, onDone: () {
      req.sink.close();
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
    return rsp.paths.map((e) => RemoteImage(cli, e)).toList();
  }
}

class RemoteImage {
  ImgSyncerClient cli;
  String path;
  Uint8List? data;
  Uint8List? thumbnailData;

  RemoteImage(
    this.cli,
    this.path, {
    this.data,
    this.thumbnailData,
  });

  bool isVideo() {
    switch (extension(path)) {
      case ".mp4":
      case ".avi":
      case ".mov":
      case ".mkv":
      case ".flv":
      case ".rmvb":
      case ".rm":
      case ".3gp":
      case ".wmv":
      case ".mpeg":
      case ".mpg":
      case ".webm":
        return true;
    }
    return false;
  }

  Stream<Uint8List> thumbnailStream() async* {
    var urlPath = path;
    if (urlPath[0] == '/') {
      urlPath = urlPath.substring(1);
    }
    final url = '$httpBaseUrl/thumbnail/$urlPath';
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);
    if (response.statusCode != 200) {
      final errMsg = await response.stream.bytesToString();
      throw Exception(
          "get [$urlPath] thumbnail failed: [${response.reasonPhrase}] $errMsg");
    }
    await for (var data in response.stream) {
      yield data as Uint8List;
    }
  }

  Future<Uint8List> thumbnail() async {
    if (thumbnailData != null) {
      return thumbnailData!;
    }
    int maxRetries = 3;
    int retryCount = 0;
    bool succeeded = false;
    while (retryCount < maxRetries && !succeeded) {
      try {
        var currentData = BytesBuilder();
        var dataStream = thumbnailStream();
        await for (var d in dataStream) {
          currentData.add(d);
        }
        thumbnailData = currentData.takeBytes();
        succeeded = true;
      } catch (e) {
        print("get $path thumbnail failed: $e");
        retryCount++;
      }
    }
    if (!succeeded) {
      final data = await rootBundle.load("assets/images/broken.png");
      thumbnailData = data.buffer.asUint8List();
    }
    return thumbnailData!;
  }

  Stream<Uint8List> dataStream() async* {
    if (path[0] == '/') {
      path = path.substring(1);
    }
    final url = '$httpBaseUrl/$path';
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);
    if (response.statusCode != 200) {
      throw Exception("get image failed: ${response.statusCode}");
    }
    await for (var data in response.stream) {
      yield data as Uint8List;
    }
  }

  Future<Uint8List> imageData() async {
    if (data != null) {
      return data!;
    }
    var currentData = BytesBuilder();
    var stream = dataStream();
    await for (var d in stream) {
      currentData.add(d);
    }
    data = currentData.takeBytes();
    return data!;
  }
}

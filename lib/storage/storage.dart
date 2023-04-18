import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:date_format/date_format.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

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

  Future<UploadResponse> uploadXFile(XFile file) async {
    final name = basename(file.path);
    final lastModified = await file.lastModified();
    final date = formatDate(
        lastModified, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    final dataReader = file.openRead();
    return cli.upload(
        uploadStream(dataReader, const Stream<Uint8List>.empty(), name, date));
  }

  Future<UploadResponse> uploadAssetEntity(AssetEntity asset) async {
    final name = asset.title;
    if (name == null) {
      throw Exception("asset name is null");
    }
    final createDate = asset.createDateTime;
    final date = formatDate(
        createDate, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    final f = await asset.file;
    if (f == null) {
      throw Exception("asset file is null");
    }
    final dataReader = f.openRead().map((e) => e as Uint8List);
    final thumbnailData = await asset.thumbnailData;
    if (thumbnailData == null) {
      throw Exception("asset thumbnail is null");
    }
    final thumbnailDataReader = Stream.value(thumbnailData);
    return cli
        .upload(uploadStream(dataReader, thumbnailDataReader, name, date));
  }

  @protected
  Stream<UploadRequest> uploadStream(Stream<Uint8List> dataReader,
      Stream<Uint8List> thumbnailReader, String name, date) async* {
    yield UploadRequest(name: name, date: date);
    await for (var data in dataReader) {
      yield UploadRequest(data: data);
    }
    await for (var data in thumbnailReader) {
      yield UploadRequest(thumbnailData: data);
    }
  }

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
        .timeout(const Duration(seconds: 5));
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

  Stream<Uint8List> thumbnailStream() async* {
    var rspStream = cli.getThumbnail(GetThumbnailRequest(path: path));
    await for (var rsp in rspStream) {
      if (!rsp.success) {
        throw Exception("get thumbnail failed: ${rsp.message}");
      }
      yield Uint8List.fromList(rsp.data);
    }
  }

  Future<Uint8List> thumbnail() async {
    if (thumbnailData != null) {
      return thumbnailData!;
    }
    var currentData = BytesBuilder();
    var dataStream = thumbnailStream();
    await for (var d in dataStream) {
      currentData.add(d);
    }
    thumbnailData = currentData.takeBytes();
    return thumbnailData!;
  }

  Stream<Uint8List> dataStream() async* {
    print("get data stream: $path");
    var rspStream = cli.get(GetRequest(path: path));
    await for (var rsp in rspStream) {
      if (!rsp.success) {
        throw Exception("get data failed: ${rsp.message}");
      }
      yield Uint8List.fromList(rsp.data);
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

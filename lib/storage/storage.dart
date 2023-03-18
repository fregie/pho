import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:toast/toast.dart';
import 'package:date_format/date_format.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

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
    return upload(dataReader, name, date);
  }

  Future<UploadResponse> upload(
      Stream<Uint8List> dataReader, String name, date) async {
    final rsp = await cli.upload(uploadStream(dataReader, name, date));
    return rsp;
  }

  @protected
  Stream<UploadRequest> uploadStream(
      Stream<Uint8List> dataReader, String name, date) async* {
    yield UploadRequest(name: name, date: date);
    await for (var data in dataReader) {
      yield UploadRequest(data: data);
    }
  }

  Future<List<RemoteImage>> listImages(
      String date, int offset, maxReturn) async {
    final rsp = await cli.listByDate(ListByDateRequest(
      date: date,
      offset: offset,
      maxReturn: maxReturn,
    ));
    print("path: ${rsp.paths}");
    return rsp.paths.map((e) => RemoteImage(cli, e)).toList();
  }
}

class RemoteImage {
  ImgSyncerClient cli;
  late String path;
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
    try {
      var dataStream = thumbnailStream();
      await for (var d in dataStream) {
        print("thumbnail $path length: ${d.length}");
        currentData.add(d);
      }
    } catch (e) {
      print(e);
    }
    print("finish");
    thumbnailData = currentData.takeBytes();
    return thumbnailData!;
  }

  Stream<Uint8List> dataStream() async* {
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
    try {
      var stream = dataStream();
      await for (var d in stream) {
        print("image $path length: ${d.length}");
        currentData.add(d);
      }
    } catch (e) {
      print(e);
    }
    print("finish");
    data = currentData.takeBytes();
    return data!;
  }
}

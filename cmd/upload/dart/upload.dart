import 'package:grpc/grpc.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'dart:io';

void main() async {
  const filePath = "/home/fregie/download/20230606_124207.mp4";
  final channel = ClientChannel(
    // "192.168.100.235",
    // port: 50051,
    "192.168.100.233",
    port: 10000,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
    ),
  );
  final cli = ImgSyncerClient(channel);
  final file = File(filePath);
  final dataReader = file.openRead();
  final start = DateTime.now();
  final rsp = await cli.upload(
      uploadStream(dataReader, "20230606_124207.mp4", "2023:06:06 12:42:07"));
  if (!rsp.success) {
    print("upload failed: ${rsp.message}");
    return;
  }
  final end = DateTime.now();
  print("upload ${file.lengthSync()}bytes in ${end.difference(start)}s");
  print(
      "speed: ${file.lengthSync() * 1000 * 8 / end.difference(start).inMilliseconds / 1024 / 1024}mbps");
  exit(0);
}

Stream<UploadRequest> uploadStream(
    Stream<List<int>> dataReader, String name, date) async* {
  yield UploadRequest(name: name, date: date);
  await for (var data in dataReader) {
    yield UploadRequest(data: data);
  }
}

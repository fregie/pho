import 'package:flutter/material.dart';
import 'package:photo_album_manager/photo_album_manager.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:grpc/grpc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Gallery App';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        home: MyHomePage(title: 'UNI Gallery'),
      );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        // body: Image.asset('assets/images/20221108_123436_01.jpg'),
        body: const GalleryPage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            grpcHello("fregie");
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

void grpcHello(String name) async {
  final channel = ClientChannel(
    '192.168.100.235',
    port: 50051,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
    ),
  );
  final stub = ImgSyncerClient(channel);
  try {
    final response = await stub.hello(
      HelloRequest()..name = name,
    );
    Toast.show('Greeter client received: ${response.message}', duration: 5);
  } catch (e) {
    Toast.show('Caught error: $e', duration: 5);
  }
  await channel.shutdown();
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<AlbumModelEntity> photos = [];

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  Future<List<AlbumModelEntity>> getPhotos() async {
    //先权限申请
    PermissionStatus status = await PhotoAlbumManager.checkPermissions();
    if (status == PermissionStatus.granted) {
      Toast.show("权限同意");
    } else {
      Toast.show("权限拒绝");
    }
    var p = await PhotoAlbumManager.getDescAlbum(maxCount: 6);
    return p;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(4),
      child: FutureBuilder<List<AlbumModelEntity>>(
        future: getPhotos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            photos = snapshot.data!;
            var children = <Widget>[];
            final totalwidth = MediaQuery.of(context).size.width - 10;
            for (var photo in photos) {
              File file = File(photo.originalPath!);
              var child = Container(
                width: totalwidth * 0.5,
                height: totalwidth * 0.75 * 0.5,
                padding: const EdgeInsets.all(0),
                color: Colors.teal[100],
                child: Image.file(file, fit: BoxFit.cover),
              );
              children.add(child);
            }
            return Wrap(
              spacing: 2.0, // 主轴(水平)方向间距
              runSpacing: 2.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.center, //沿主轴方向居中
              children: children,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      //'assets/images/batgirl_artwork-2560x1440.jpg'
    );
  }
}

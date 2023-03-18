import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_album_manager/photo_album_manager.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:img_syncer/GalleryViewerRoute.dart';
import 'package:img_syncer/theme/theme.dart';
import 'package:img_syncer/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_syncer/asset.dart';

RemoteStorage storeage = RemoteStorage("127.0.0.1", 50051);

void main() {
  storeage = RemoteStorage("192.168.100.235", 50051);
  storeage.cli
      .setDriveSMB(SetDriveSMBRequest(
    addr: "192.168.100.235",
    username: "fregie",
    password: "password",
    share: "photos",
    root: "storage",
  ))
      .then((rsp) {
    if (rsp.success) {
      Toast.show("设置成功");
    } else {
      Toast.show("设置失败:$rsp.msg");
    }
  });
  Global.init().then((e) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Goo photo';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: _title),
        theme: customLightTheme,
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title,
      //       style: Theme.of(context).textTheme.headlineMedium),
      //   automaticallyImplyLeading: true,
      //   // scrolledUnderElevation: scrolledUnderElevation,
      //   shadowColor: Theme.of(context).shadowColor,
      //   backgroundColor: Theme.of(context).secondaryHeaderColor,
      //   foregroundColor: Theme.of(context).primaryColor,
      // ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GalleryPage(
        useLocal: _selectedIndex == 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker _picker = ImagePicker();
          // Pick an image
          final XFile? image =
              await _picker.pickImage(source: ImageSource.gallery);
          if (image == null) {
            return;
          } else {
            var rsp = await storeage.uploadXFile(image);
            if (rsp.success) {
              Toast.show("上传成功");
            } else {
              Toast.show("上传失败:${rsp.message}");
            }
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        shadowColor: Theme.of(context).shadowColor,
        surfaceTintColor: Theme.of(context).hoverColor,
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.phone_android),
            label: 'Local',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'Cloud',
          ),
        ],
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  bool useLocal = true;
  GalleryPage({
    Key? key,
    this.useLocal = true,
  }) : super(key: key);
  // List<RemoteImage> photos = [];

  Future<List<Asset>> getPhotos({bool useLocal = true}) async {
    List<Asset> all = [];
    if (useLocal) {
      //先权限申请
      final PermissionState _ps = await PhotoManager.requestPermissionExtend();
      if (_ps.isAuth) {
        // Granted.
        Toast.show("权限同意");
      } else {
        // Limited(iOS) or Rejected, use `==` for more precise judgements.
        // You can call `PhotoManager.openSetting()` to open settings for further steps.
        Toast.show("权限拒绝");
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
      for (var path in paths) {
        print("path: ${path.name}");
        if (path.name == "Pictures") {
          final List<AssetEntity> entities =
              await path.getAssetListRange(start: 0, end: 20);
          for (var entity in entities) {
            all.add(Asset(local: entity));
          }
        }
      }
    } else {
      final List<RemoteImage> images = await storeage.listImages("", 0, 10);
      for (var image in images) {
        all.add(Asset(remote: image));
      }
    }

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        snap: false,
        floating: false,
        expandedHeight: 100.0,
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: const EdgeInsets.all(5),
          title: Text(
            'Goo Photos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // background: const FlutterLogo(),
        ),
      ),
      SliverToBoxAdapter(
        child: FutureBuilder<List<Asset>>(
          future: getPhotos(useLocal: useLocal),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final photos = snapshot.data!;
              var children = <Widget>[];
              final totalwidth = MediaQuery.of(context).size.width - 4;
              for (var photo in photos) {
                // print("title: ${photo.title}");
                var child = GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewRoute(asset: photo),
                        ),
                      );
                    },
                    child: FutureBuilder(
                      future: photo.thumbnailData(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        print("data length: ${snapshot.data?.length}");
                        Uint8List bytes = snapshot.data as Uint8List;
                        return Container(
                            width: totalwidth / 3,
                            height: totalwidth / 3,
                            padding: const EdgeInsets.all(0),
                            color: Colors.teal[100],
                            child: Image.memory(bytes, fit: BoxFit.cover));
                      },
                    ));
                children.add(child);
              }
              return Wrap(
                spacing: 2, // 主轴(水平)方向间距
                runSpacing: 2.0, // 纵轴（垂直）方向间距
                alignment: WrapAlignment.start, //沿主轴方向居中
                children: children,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )
    ]
        //'assets/images/batgirl_artwork-2560x1440.jpg'
        );
  }
}

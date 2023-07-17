import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'state_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/global.dart';
import 'package:flutter/services.dart';

class ChooseAlbumRoute extends StatefulWidget {
  const ChooseAlbumRoute({Key? key}) : super(key: key);
  @override
  ChooseAlbumRouteState createState() => ChooseAlbumRouteState();
}

class ChooseAlbumRouteState extends State<ChooseAlbumRoute> {
  List<AssetPathEntity> albums = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAlbums().then((value) {
        setState(() {
          albums = value;
        });
      });
    });
  }

  Future<List<AssetPathEntity>> getAlbums() async {
    await requestPermission();
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common, hasAll: true);
    // ignore: deprecated_member_use
    paths.sort((a, b) => b.assetCount.compareTo(a.assetCount));
    return paths;
  }

  Future<Uint8List?> getFirstPhotoThumbnail(AssetPathEntity path) async {
    final List<AssetEntity> entities =
        await path.getAssetListPaged(page: 0, size: 1);
    if (entities.isNotEmpty) {
      final entity = entities[0];
      final data = await entity.thumbnailData;
      return data!;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (var path in albums) {
      children.add(
        FutureBuilder(
          future: getFirstPhotoThumbnail(path),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // return const Center(
              //   child: Text('No album found'),
              // );
              return const SizedBox();
            }
            return AlbumCard(
              path: path,
              thumbnail: snapshot.data as Uint8List,
            );
          },
        ),
      );
    }
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: Text(i18n.chooseAlbum,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: CustomScrollView(
          primary: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                children: children,
              ),
            ),
          ],
        ));
  }
}

class AlbumCard extends StatelessWidget {
  final AssetPathEntity path;
  final Uint8List thumbnail;
  const AlbumCard({
    Key? key,
    required this.path,
    required this.thumbnail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1.5,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      clipBehavior: Clip.antiAlias,
      // elevation: Theme.of(context).cardTheme.elevation,
      color: Theme.of(context).cardColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight - 80,
                  child: Image.memory(thumbnail, fit: BoxFit.cover)),
              Container(
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(path.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Ubuntu-condensed',
                            )),
                      ),
                    ],
                  )),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: FutureBuilder(
                          future: path.assetCountAsync,
                          builder: (context, snapshot) => Text(
                              snapshot.hasData
                                  ? "${snapshot.data} ${i18n.pics}"
                                  : 'unknown count pics',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 120,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: FilledButton(
                        style: Theme.of(context).textButtonTheme.style,
                        onPressed: () {
                          settingModel.setLocalFolder(path.name);
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString("localFolder", path.name);
                          });
                          Navigator.pop(context);
                        },
                        child: Text(i18n.choose),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

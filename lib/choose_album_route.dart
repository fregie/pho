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
    final re = await requestPermission();
    if (!re) return [];
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common, hasAll: true);
    // sort by asset count by assetCountAsync
    // 使用Future.wait来获取所有异步值并保存到Map中
    final Map<AssetPathEntity, int> assetCountMap = {};
    await Future.wait(paths.map((path) async {
      int assetCount = await path.assetCountAsync;
      assetCountMap[path] = assetCount;
    }));

    // 使用sort方法对paths进行排序
    paths.sort((a, b) {
      int countA = assetCountMap[a] ?? 0;
      int countB = assetCountMap[b] ?? 0;
      return countB.compareTo(countA); // 从大到小排序
    });
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
            return AlbumCard(
              path: path,
              thumbnail: snapshot.data,
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
          title: Text(l10n.chooseAlbum,
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
  final Uint8List? thumbnail;
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
                  child: thumbnail != null
                      ? Image.memory(thumbnail!, fit: BoxFit.cover)
                      : Image.asset("assets/images/gray.jpg")),
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
                                  ? "${snapshot.data} ${l10n.pics}"
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
                        child: Text(l10n.choose),
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

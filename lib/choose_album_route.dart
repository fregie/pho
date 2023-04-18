import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'state_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseAlbumRoute extends StatelessWidget {
  const ChooseAlbumRoute({Key? key}) : super(key: key);

  Future<List<AssetPathEntity>> getAlbums() async {
    //先权限申请
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    for (var path in paths) {
      if (path.name == 'Recent') {
        paths.remove(path);
        break;
      }
    }
    return paths;
  }

  Future<Uint8List> getFirstPhotoThumbnail(AssetPathEntity path) async {
    final List<AssetEntity> entities =
        await path.getAssetListPaged(page: 0, size: 1);
    final entity = entities[0];
    final data = await entity.thumbnailData;
    return data!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        title:
            Text('Choose album', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: FutureBuilder(
        future: getAlbums(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No album found'),
            );
          }
          final totalwidth = MediaQuery.of(context).size.width;
          var children = <Widget>[];
          for (var path in snapshot.data as List<AssetPathEntity>) {
            children.add(
              FutureBuilder(
                future: getFirstPhotoThumbnail(path),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No album found'),
                    );
                  }
                  return AlbumCard(
                    path: path,
                    thumbnail: snapshot.data as Uint8List,
                  );
                },
              ),
            );
          }
          return CustomScrollView(
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
          );
        },
      ),
    );
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
                        width: constraints.maxWidth * 0.5,
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          path.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        width: constraints.maxWidth * 0.5,
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: FutureBuilder(
                          future: path.assetCountAsync,
                          builder: (context, snapshot) => Text(
                              snapshot.hasData
                                  ? "${snapshot.data} photos"
                                  : 'unknown count photos',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ],
                  )),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                height: 40,
                child: Consumer<SettingModel>(
                    builder: (context, state, child) => FilledButton(
                          style: Theme.of(context).textButtonTheme.style,
                          onPressed: () {
                            state.setLocalFolder(path.name);
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString("localFolder", path.name);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Choose'),
                        )),
              )
            ],
          );
        },
      ),
    );
  }
}

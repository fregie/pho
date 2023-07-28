import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/background_sync_route.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/state_model.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:img_syncer/choose_album_route.dart';
import 'package:img_syncer/setting_storage_route.dart';
import 'package:img_syncer/global.dart';
import 'package:path/path.dart';

class SyncBody extends StatefulWidget {
  const SyncBody({
    Key? key,
    required this.localFolder,
  }) : super(key: key);

  final String localFolder;

  @override
  SyncBodyState createState() => SyncBodyState();
}

class SyncBodyState extends State<SyncBody> {
  final ScrollController _scrollController = ScrollController();
  final _scrollSubject = PublishSubject<double>();

  @protected
  int pageSize = 20;
  List<Asset> all = [];
  // List<Asset> toShow = [];
  bool syncing = false;
  bool _needStopSync = false;

  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    getPhotos();
    _scrollSubject.stream
        .debounceTime(const Duration(milliseconds: 150))
        .listen((scrollPosition) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 1500) {
        // loadMore();
      }
      setState(() {
        scrollOffset = scrollPosition;
      });
    });
    _scrollController.addListener(() {
      _scrollSubject.add(_scrollController.position.pixels);
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   refreshUnsynchronized();
    // });
  }

  @override
  void didUpdateWidget(SyncBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (all.isEmpty) {
      getPhotos();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollSubject.close();
  }

  // bool _isLoadingMore = false;
  // Future<void> loadMore() async {
  //   if (_isGettingPhotos != null) {
  //     await _isGettingPhotos!.future;
  //   }
  //   if (syncing) {
  //     return;
  //   }
  //   if (_isLoadingMore) {
  //     return;
  //   }
  //   _isLoadingMore = true;
  //   toUpload = stateModel.notSyncedIDs.length;
  //   Map ids = {};
  //   for (final id in stateModel.notSyncedIDs) {
  //     ids[id] = true;
  //   }
  //   int count = 0;
  //   int originLength = toShow.length;
  //   for (var asset in all) {
  //     final id = asset.id;
  //     if (ids[id] == true) {
  //       count++;
  //       if (count <= originLength) {
  //         continue;
  //       }
  //       final a = Asset(local: asset);
  //       await a.getLocalFile();
  //       toShow.add(a);
  //       if (count >= originLength + 2000) {
  //         break;
  //       }
  //     }
  //   }

  //   setState(() {
  //     _isLoadingMore = false;
  //   });
  // }

  Completer<bool>? _isGettingPhotos = null;
  Future<void> getPhotos() async {
    if (_isGettingPhotos != null) {
      await _isGettingPhotos!.future;
      return;
    }
    _isGettingPhotos = Completer();
    all.clear();
    final re = await requestPermission();
    if (!re) return;
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common, hasAll: true);
    for (var path in paths) {
      if (path.name == settingModel.localFolder) {
        final newpath = await path.fetchPathProperties(
            filterOptionGroup: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        ));
        int assetOffset = 0;
        int assetPageSize = 300;
        while (true) {
          final List<AssetEntity> assets = await newpath!.getAssetListRange(
              start: assetOffset, end: assetOffset + assetPageSize);
          if (assets.isEmpty) {
            break;
          }
          for (var i = 0; i < assets.length; i++) {
            all.add(Asset(local: assets[i]));
          }
          assetOffset += assetPageSize;
        }
        break;
      }
    }
    setState(() {});
    _isGettingPhotos!.complete(true);
    _isGettingPhotos = null;
  }

  Widget settingRows() {
    final ButtonStyle style = FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ));
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: constraints.maxWidth * 0.5,
                  padding: const EdgeInsets.fromLTRB(15, 8, 10, 8),
                  child: FilledButton.tonal(
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChooseAlbumRoute()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_outlined,
                          // color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.localFolder),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  width: constraints.maxWidth * 0.5,
                  padding: const EdgeInsets.fromLTRB(10, 8, 15, 8),
                  child: FilledButton.tonal(
                    style: style,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingStorageRoute(),
                          ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_outlined,
                          // color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.cloudStorage),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (Platform.isAndroid)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 60,
                    width: constraints.maxWidth * 0.5,
                    padding: const EdgeInsets.fromLTRB(15, 8, 10, 8),
                    child: FilledButton.tonal(
                      style: style,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BackgroundSyncSettingRoute()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_sync_outlined,
                          ),
                          const SizedBox(width: 10),
                          Text(l10n.backgroundSync),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void syncPhotos() async {
    _needStopSync = false;
    if (syncing) {
      return;
    }
    setState(() {
      syncing = true;
    });
    Map ids = {};
    for (final id in stateModel.notSyncedIDs) {
      ids[id] = true;
    }
    for (var asset in all) {
      if (_needStopSync) {
        break;
      }
      final id = asset.local!.id;
      if (ids[id] != true) {
        continue;
      }
      try {
        await storage.uploadAssetEntity(asset.local!);
      } catch (e) {
        print(e);
        SnackBarManager.showSnackBar("${l10n.uploadFailed}: $e");
        continue;
      }
    }
    setState(() {
      syncing = false;
    });
    eventBus.fire(RemoteRefreshEvent());
  }

  void stopSync() {
    _needStopSync = true;
  }

  Widget columnBuilder(BuildContext context, StateModel model, Widget? child) {
    Map notUploadedIds = {};
    for (final id in stateModel.notSyncedIDs) {
      notUploadedIds[id] = true;
    }
    List<Widget> listChildren = [];
    double currentScrollOffset = 0;
    for (var asset in all) {
      final id = asset.local!.id;
      if (notUploadedIds[id] != true) {
        continue;
      }
      final totalHeight = MediaQuery.of(context).size.height;
      bool needLoadThumbnail = false;
      if (currentScrollOffset > scrollOffset - (2 * totalHeight) &&
          currentScrollOffset < scrollOffset + (3 * totalHeight)) {
        needLoadThumbnail = true;
        if (!asset.loadThumbnailFinished()) {
          asset.thumbnailDataAsync().then((value) => setState(() {}));
        }
        if (!asset.hasGotTitle()) {
          asset.getLocalFile().then((value) => setState(() {}));
        }
      }
      Widget child = ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          child: needLoadThumbnail && asset.loadThumbnailFinished()
              ? Image(image: asset.thumbnailProvider(), fit: BoxFit.cover)
              : Container(color: Colors.grey),
        ),
        title: Text(
          asset.name()!,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: needLoadThumbnail
            ? Consumer<StateModel>(
                builder: (context, stateModel, child) {
                  final percent = stateModel.getUploadPercent(asset.local!.id);
                  if (percent > 0) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: LinearProgressIndicator(value: percent),
                    );
                  }
                  if (stateModel.notSyncedIDs.contains(asset.local!.id)) {
                    return Text(l10n.notUploaded,
                        style: const TextStyle(color: Colors.grey));
                  }
                  return Text(
                    l10n.uploaded,
                    style:
                        const TextStyle(color: Color.fromARGB(255, 75, 154, 0)),
                  );
                },
              )
            : Container(),
      );
      listChildren.add(child);
      currentScrollOffset += 72; // ListTile's height
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l10n.cloudSync,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
            alignment: Alignment.bottomRight,
            child: Text(
              "${listChildren.length} ${l10n.notSync}",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "refresh",
            tooltip: 'Refresh unsynchronized photos',
            // label: const Text('Refresh'),
            elevation: 2,
            onPressed: () => syncing ||
                    model.refreshingUnsynchronized ||
                    model.isDownloading() ||
                    model.isUploading()
                ? null
                : refreshUnsynchronized(),
            child: model.refreshingUnsynchronized
                ? CircularProgress()
                : const Icon(Icons.refresh),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: FloatingActionButton.extended(
                heroTag: "sync",
                elevation: 2,
                onPressed: () {
                  if (!settingModel.isRemoteStorageSetted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingStorageRoute(),
                        ));
                    return;
                  }
                  if (syncing ||
                      model.refreshingUnsynchronized ||
                      model.isDownloading() ||
                      model.isUploading()) {
                    stopSync();
                  } else {
                    syncPhotos();
                  }
                },
                icon: syncing ? CircularProgress() : const Icon(Icons.sync),
                label: Text(syncing ? l10n.stop : l10n.sync)),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          settingRows(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                child: Text(
                  l10n.unsynchronizedPhotos,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
              const Flexible(
                child: Divider(
                  height: 10,
                  thickness: 1,
                  indent: 0,
                  endIndent: 15,
                ),
              ),
            ],
          ),
          if (!settingModel.isRemoteStorageSetted)
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Center(
                heightFactor: 10,
                child: Text(l10n.setRemoteStroage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )),
              ),
            ),
          model.refreshingUnsynchronized && listChildren.isEmpty
              ? Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Center(
                    heightFactor: 10,
                    child: Text(l10n.refreshingPleaseWait,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        )),
                  ),
                )
              : Flexible(
                  child: ListView(
                  controller: _scrollController,
                  children: listChildren,
                )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SettingModel>(context, listen: true).addListener(() {
      getPhotos();
    });
    return Consumer<StateModel>(
      builder: columnBuilder,
    );
  }

  Widget CircularProgress() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );
  }

  Future<void> refreshUnsynchronized() async {
    if (!settingModel.isRemoteStorageSetted) {
      stateModel.setNotSyncedPhotos([]);
      return;
    }
    await Future.wait([
      refreshUnsynchronizedPhotos(),
      getPhotos(),
    ]);
  }
}

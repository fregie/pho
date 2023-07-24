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
  List<AssetEntity> all = [];
  List<Asset> toShow = [];
  bool syncing = false;
  bool refreshing = false;
  bool _needStopSync = false;
  Map<String, String> uploadState = {};
  int toUpload = 0;

  @override
  void initState() {
    super.initState();
    getPhotos().then((value) => loadMore());
    _scrollSubject.stream
        .debounceTime(const Duration(milliseconds: 100))
        .listen((scrollPosition) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 1500) {
        loadMore();
      }
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
    // if (all.isEmpty) {
    //   getPhotos().then((value) => loadMore());
    // } else if (toShow.isEmpty) {
    //   loadMore();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollSubject.close();
  }

  bool _isLoadingMore = false;
  Future<void> loadMore() async {
    if (syncing) {
      return;
    }
    if (_isLoadingMore) {
      return;
    }
    _isLoadingMore = true;
    toUpload = stateModel.notSyncedIDs.length;
    Map ids = {};
    for (final id in stateModel.notSyncedIDs) {
      ids[id] = true;
    }
    int count = 0;
    int originLength = toShow.length;
    for (var asset in all) {
      final id = asset.id;
      if (ids[id] == true) {
        count++;
        if (count <= originLength) {
          continue;
        }
        final a = Asset(local: asset);
        await a.getLocalFile();
        await a.thumbnailDataAsync();
        toShow.add(a);
        if (count >= originLength + pageSize) {
          break;
        }
      }
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  bool _isGettingPhotos = false;
  Future<void> getPhotos() async {
    if (_isGettingPhotos) {
      return;
    }
    _isGettingPhotos = true;
    all.clear();
    final re = await requestPermission();
    if (!re) return;
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.common);
    for (var path in paths) {
      if (path.name == widget.localFolder) {
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
        int assetPageSize = 100;
        while (true) {
          final List<AssetEntity> assets = await newpath!.getAssetListRange(
              start: assetOffset, end: assetOffset + assetPageSize);
          if (assets.isEmpty) {
            break;
          }
          for (var asset in assets) {
            all.add(asset);
          }
          assetOffset += assetPageSize;
        }
        break;
      }
    }
    setState(() {
      _isGettingPhotos = false;
    });
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
                        Text(i18n.localFolder),
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
                        Text(i18n.cloudStorage),
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
                          Text(i18n.backgroundSync),
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
      final id = asset.id;
      if (ids[id] != true) {
        continue;
      }
      setState(() {
        uploadState[id] = i18n.uploading;
      });
      try {
        await storage.uploadAssetEntity(asset);
      } catch (e) {
        print(e);
        setState(() {
          uploadState[id] = "${i18n.uploadFailed}: $e";
        });
        continue;
      }
      setState(() {
        toUpload -= 1;
        uploadState[id] = i18n.uploaded;
      });
    }
    setState(() {
      syncing = false;
    });
    eventBus.fire(RemoteRefreshEvent());
    refreshUnsynchronizedPhotos();
  }

  void stopSync() {
    _needStopSync = true;
  }

  Widget columnBuilder(BuildContext context, StateModel model, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          i18n.cloudSync,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
            alignment: Alignment.bottomRight,
            child: Text(
              "$toUpload ${i18n.notSync}",
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
                    refreshing ||
                    model.isDownloading ||
                    model.isUploading
                ? null
                : refreshUnsynchronized(),
            child: refreshing ? CircularProgress() : const Icon(Icons.refresh),
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
                      refreshing ||
                      model.isDownloading ||
                      model.isUploading) {
                    stopSync();
                  } else {
                    syncPhotos();
                  }
                },
                icon: syncing ? CircularProgress() : const Icon(Icons.sync),
                label: Text(syncing ? i18n.stop : i18n.sync)),
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
                  i18n.unsynchronizedPhotos,
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
                child: Text(i18n.setRemoteStroage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )),
              ),
            ),
          refreshing
              ? Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Center(
                    heightFactor: 10,
                    child: Text(i18n.refreshingPleaseWait,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        )),
                  ),
                )
              : Flexible(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: toShow.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image(
                              image: toShow[index].thumbnailProvider(),
                              fit: BoxFit.cover),
                        ),
                        title: Text(toShow[index].name()!),
                        subtitle: Text(uploadState[toShow[index].local!.id] ??
                            i18n.notUploaded),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SettingModel>(context, listen: true).addListener(() {
      setState(() {
        all = [];
        toShow = [];
        uploadState = {};
        toUpload = 0;
      });
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
    setState(() {
      refreshing = true;
      toShow = [];
    });
    await refreshUnsynchronizedPhotos();
    await getPhotos();
    await loadMore();
    setState(() {
      refreshing = false;
    });
  }
}

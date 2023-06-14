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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    toUpload = stateModel.notSyncedNames.length;
    Map names = {};
    for (final name in stateModel.notSyncedNames) {
      names[name] = true;
    }
    int count = 0;
    int originLength = toShow.length;
    for (var asset in all) {
      if (names[asset.title] == true) {
        count++;
        if (count <= originLength) {
          continue;
        }
        final a = Asset(local: asset);
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
    await requestPermission();
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
          all.addAll(assets);
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
                        Text(AppLocalizations.of(context).localFolder),
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
                        Icon(
                          Icons.cloud_outlined,
                          // color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context).cloudStorage),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                        Icon(
                          Icons.cloud_sync_outlined,
                        ),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context).backgroundSync),
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

  void syncPhotots() async {
    _needStopSync = false;
    if (syncing) {
      return;
    }
    setState(() {
      syncing = true;
    });
    Map names = {};
    for (final name in stateModel.notSyncedNames) {
      names[name] = true;
    }
    stateModel.setUploadState(true);
    for (var asset in all) {
      if (_needStopSync) {
        break;
      }
      if (names[asset.title] != true) {
        continue;
      }
      if (asset.title == null) {
        continue;
      }
      setState(() {
        uploadState[asset.title!] = AppLocalizations.of(context).uploading;
      });
      try {
        await storage.uploadAssetEntity(asset);
      } catch (e) {
        print(e);
        setState(() {
          uploadState[asset.title!] =
              "${AppLocalizations.of(context).uploadFailed}: $e";
        });
        continue;
      }
      setState(() {
        toUpload -= 1;
        uploadState[asset.title!] = AppLocalizations.of(context).uploaded;
      });
    }
    stateModel.setUploadState(false);
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
          AppLocalizations.of(context).cloudSync,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
            alignment: Alignment.bottomRight,
            child: Text(
              "$toUpload ${AppLocalizations.of(context).notSync}",
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
                onPressed: syncing ||
                        refreshing ||
                        model.isDownloading ||
                        model.isUploading
                    ? stopSync
                    : syncPhotots,
                icon: syncing ? CircularProgress() : const Icon(Icons.sync),
                label: Text(syncing
                    ? AppLocalizations.of(context).stop
                    : AppLocalizations.of(context).sync)),
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
                  AppLocalizations.of(context).unsynchronizedPhotos,
                  style: TextStyle(
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
          Flexible(
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
                  subtitle: Text(uploadState[toShow[index].name()] ??
                      AppLocalizations.of(context).notUploaded),
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

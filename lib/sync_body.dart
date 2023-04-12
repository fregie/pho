import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'state_model.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshUnsynchronized(Provider.of<StateModel>(context, listen: false));
    });
  }

  @override
  void didUpdateWidget(SyncBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (all.isEmpty) {
      getPhotos().then((value) => loadMore());
    } else if (toShow.isEmpty) {
      loadMore();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollSubject.close();
  }

  Future<void> loadMore() async {
    if (syncing) {
      return;
    }
    final model = Provider.of<StateModel>(context, listen: false);
    toUpload = model.notSyncedNames.length;
    Map names = {};
    for (final name in model.notSyncedNames) {
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

    setState(() {});
  }

  Future<void> getPhotos() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
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
    setState(() {});
  }

  Widget columnBuilder(BuildContext context, StateModel model, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Cloud sync',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
            alignment: Alignment.bottomRight,
            child: Text(
              "$toUpload not synced",
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
            onPressed: () =>
                syncing || refreshing ? null : refreshUnsynchronized(model),
            child: refreshing ? CircularProgress() : const Icon(Icons.refresh),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: FloatingActionButton.extended(
                heroTag: "sync",
                elevation: 2,
                onPressed: syncing || refreshing
                    ? null
                    : () async {
                        setState(() {
                          syncing = true;
                        });
                        Map names = {};
                        for (final name in model.notSyncedNames) {
                          names[name] = true;
                        }
                        for (var asset in all) {
                          if (names[asset.title] != true) {
                            continue;
                          }
                          if (asset.title == null) {
                            continue;
                          }
                          setState(() {
                            uploadState[asset.title!] = "Uploading";
                          });
                          try {
                            final rsp = await storage.uploadAssetEntity(asset);
                            if (!rsp.success) {
                              setState(() {
                                uploadState[asset.title!] =
                                    "Upload failed: ${rsp.message}";
                              });
                              continue;
                            }
                          } catch (e) {
                            setState(() {
                              uploadState[asset.title!] = "Upload failed: $e";
                            });
                            continue;
                          }
                          setState(() {
                            toUpload -= 1;
                            uploadState[asset.title!] = "Uploaded";
                          });
                        }
                        setState(() {
                          syncing = false;
                        });
                        eventBus.fire(RemoteRefreshEvent());
                      },
                icon: syncing ? CircularProgress() : const Icon(Icons.sync),
                label: const Text("Sync")),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: toShow.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              width: 60,
              height: 60,
              child: Image(
                  image: toShow[index].thumbnailProvider(), fit: BoxFit.cover),
            ),
            title: Text(toShow[index].name()!),
            subtitle: Text(uploadState[toShow[index].name()] ?? "Not uploaded"),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<StateModel>(context, listen: true).addListener(() {
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

  Future<void> refreshUnsynchronized(StateModel model) async {
    if (!model.isRemoteStorageSetted) {
      model.setNotSyncedPhotos([]);
      return;
    }
    setState(() {
      refreshing = true;
    });
    final localFloder = model.localFolder;
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    for (var path in paths) {
      if (path.name == localFloder) {
        final newpath = await path.fetchPathProperties(
            filterOptionGroup: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        ));
        FilterNotUploadedRequest req =
            FilterNotUploadedRequest(names: List<String>.empty(growable: true));
        int offset = 0;
        int pageSize = 100;

        while (true) {
          final List<AssetEntity> assets = await newpath!
              .getAssetListRange(start: offset, end: offset + pageSize);
          if (assets.isEmpty) {
            break;
          }
          for (var asset in assets) {
            if (asset.type == AssetType.image && asset.title != null) {
              req.names.add(asset.title!);
            }
          }
          offset += pageSize;
        }
        final rsp = await storage.cli.filterNotUploaded(req);
        if (rsp.success) {
          model.setNotSyncedPhotos(rsp.notUploaed);
        } else {
          throw Exception(
              "Refresh unsynchronized photos failed: ${rsp.message}");
        }
      }
    }
    setState(() {
      refreshing = false;
    });
  }
}

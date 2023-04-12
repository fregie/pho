import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_syncer/proto/img_syncer.pb.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/gallery_viewer_route.dart';
import 'package:img_syncer/asset.dart';
import 'component.dart';
import 'package:flutter/services.dart';
import 'event_bus.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class GalleryBody extends StatefulWidget {
  const GalleryBody({Key? key, required this.useLocal}) : super(key: key);
  final bool useLocal;

  @override
  GalleryBodyState createState() => GalleryBodyState();
}

class GalleryBodyState extends State<GalleryBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();
  final _scrollSubject = PublishSubject<double>();
  int columCount = 4;

  final Map<int, bool> _selectedIndices = {};

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    _scrollSubject.stream
        .debounceTime(const Duration(milliseconds: 100))
        .listen((scrollPosition) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 2000) {
        getPhotos();
      }
    });
    _scrollController.addListener(() {
      _scrollSubject.add(_scrollController.position.pixels);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final all =
          widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
      if (all.isEmpty) {
        refresh();
      }
    });
  }

  @override
  void didUpdateWidget(GalleryBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final all =
        widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    if (all.isEmpty) {
      refresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollSubject.close();
  }

  bool _isRefreshing = false;
  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    if (widget.useLocal) {
      await assetModel.refreshLocal();
    } else {
      await assetModel.refreshRemote();
    }
    _isRefreshing = false;
  }

  void getPhotos() {
    if (widget.useLocal) {
      assetModel.getLocalPhotos();
    } else {
      assetModel.getRemotePhotos();
    }
  }

  void toggleSelection(int index) {
    if (_selectedIndices[index] == null) {
      _selectedIndices[index] = true;
    } else {
      _selectedIndices[index] = !_selectedIndices[index]!;
    }
    var hasSelected = false;
    _selectedIndices.forEach((key, value) {
      if (value) {
        hasSelected = true;
      }
    });
    selectionModeModel.setSelectionMode(hasSelected);

    if (!hasSelected && _bottomSheetController != null) {
      _bottomSheetController?.close(); // 关闭BottomSheet
      _bottomSheetController = null;
    } else {
      if (hasSelected && _bottomSheetController == null) {
        _showBottomSheet(context); // 显示BottomSheet
      }
    }

    setState(() {});
  }

  void clearSelection() {
    _selectedIndices.clear();
    selectionModeModel.setSelectionMode(false);
    if (_bottomSheetController != null) {
      _bottomSheetController?.close(); // 关闭BottomSheet
      _bottomSheetController = null;
    }
    setState(() {});
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete selected photos?'),
        content: const Text("This action can't be undone."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              var toDelete = <Asset>[];
              try {
                final all = widget.useLocal
                    ? assetModel.localAssets
                    : assetModel.remoteAssets;
                _selectedIndices.forEach((key, value) async {
                  if (value) {
                    toDelete.add(all[key]);
                  }
                });
                if (widget.useLocal) {
                  PhotoManager.editor
                      .deleteWithIds(toDelete.map((e) => e.local!.id).toList())
                      .then((value) => eventBus.fire(LocalRefreshEvent()));
                } else {
                  storage.cli
                      .delete(DeleteRequest(
                        paths: toDelete.map((e) => e.remote!.path).toList(),
                      ))
                      .then((rsp) => eventBus.fire(RemoteRefreshEvent()));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${toDelete.length} photos.'),
                ),
              );
              clearSelection();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareAsset() async {
    if (!selectionModeModel.isSelectionMode) {
      return;
    }
    final all =
        widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    final assets = <Asset>[];
    _selectedIndices.forEach((key, isSelected) {
      if (isSelected) {
        assets.add(all[key]);
      }
    });
    List<XFile> xfiles = [];
    for (var asset in assets) {
      final data = await asset.imageDataAsync();
      xfiles.add(XFile.fromData(
        data,
        name: asset.name(),
        mimeType: asset.mimeType(),
      ));
    }
    Share.shareXFiles(xfiles);
  }

  void downloadSelected() async {
    if (widget.useLocal || !selectionModeModel.isSelectionMode) {
      return;
    }
    // 检查并请求存储权限
    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Permission denied"),
        ));
        return;
      }
    }
    final all =
        widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    final assets = <Asset>[];
    _selectedIndices.forEach((key, isSelected) {
      if (isSelected) {
        assets.add(all[key]);
      }
    });
    int count = 0;
    try {
      for (var asset in assets) {
        if (asset.name() == null) {
          continue;
        }
        final data = await asset.imageDataAsync();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${asset.name()}');

        await file.writeAsBytes(data);
        await file.setLastModified(asset.dateCreated());
        final result = await ImageGallerySaver.saveFile(
            '${tempDir.path}/${asset.name()}',
            name: asset.name());
        if (!result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Download ${asset.name()} failed"),
          ));
          continue;
        }
        count++;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Download failed: $e"),
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Download $count photos"),
    ));
    eventBus.fire(LocalRefreshEvent());
    clearSelection();
  }

  void uploadSelected() async {
    if (!widget.useLocal || !selectionModeModel.isSelectionMode) {
      return;
    }
    if (!stateModel.isRemoteStorageSetted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Remote storage is not setted,please set it first"),
      ));
      return;
    }
    final all =
        widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    final assets = <Asset>[];
    _selectedIndices.forEach((key, isSelected) {
      if (isSelected) {
        assets.add(all[key]);
      }
    });
    for (var asset in assets) {
      final entity = asset.local!;
      if (entity.title == null) {
        continue;
      }
      try {
        final rsp = await storage.uploadAssetEntity(entity);
        if (!rsp.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Upload failed: ${rsp.message}"),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Upload failed: $e"),
        ));
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Successfully upload ${assets.length} photos"),
    ));
    eventBus.fire(RemoteRefreshEvent());

    clearSelection();
  }

  void _showBottomSheet(BuildContext context) {
    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (BuildContext context) {
        return Container(
          height: 100,
          child: Column(
            children: [
              // 抓手
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              Container(
                height: 80,
                child: Row(
                  children: [
                    _bottomSheetIconButtun(
                        Icons.share_outlined, 'Share', _shareAsset),
                    _bottomSheetIconButtun(Icons.delete_outline, 'Delete',
                        () => _showDeleteDialog(context)),
                    if (widget.useLocal)
                      _bottomSheetIconButtun(Icons.cloud_upload_outlined,
                          'Upload', uploadSelected),
                    if (!widget.useLocal)
                      _bottomSheetIconButtun(Icons.cloud_download_outlined,
                          'Download', downloadSelected),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    _bottomSheetController!.closed.then((value) => clearSelection());
  }

  Widget appBar() {
    return SliverAppBar(
      pinned: false,
      snap: false,
      floating: true,
      expandedHeight: 70,
      toolbarHeight: 70,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        widget.useLocal ? chooseAlbumButtun(context) : Container(),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(5),
        title: Text(
          'Goo Photos',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  Widget _bottomSheetIconButtun(IconData icon, String text, Function()? onTap) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      // padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: InkResponse(
        containedInkWell: true,
        radius: 40,
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refresh,
      child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            appBar(),
            SliverToBoxAdapter(child: GestureDetector(
              child: Consumer<AssetModel>(builder: (context, model, child) {
                final all =
                    widget.useLocal ? model.localAssets : model.remoteAssets;
                var children = <Widget>[];
                final totalwidth =
                    MediaQuery.of(context).size.width - columCount * 2;

                var currentChildren = <Widget>[];
                DateTime? currentDateTime;
                for (int i = 0; i < all.length; i++) {
                  final date = all[i].dateCreated();
                  if (currentDateTime == null ||
                      date.year != currentDateTime.year ||
                      date.month != currentDateTime.month ||
                      date.day != currentDateTime.day) {
                    children.add(Wrap(
                      spacing: 2, // 主轴(水平)方向间距
                      runSpacing: 2.0, // 纵轴（垂直）方向间距
                      alignment: WrapAlignment.start,
                      children: currentChildren,
                    ));
                    currentChildren = <Widget>[];
                    DateFormat format = DateFormat('MMMM dd,yyyy EEEEE');
                    children.add(Container(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        format.format(date),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 87, 87, 87),
                            fontSize: 16),
                      ),
                    ));
                  }
                  var child = GestureDetector(
                      onTap: () {
                        if (selectionModeModel.isSelectionMode) {
                          toggleSelection(i);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryViewerRoute(
                                useLocal: widget.useLocal,
                                originIndex: i,
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!selectionModeModel.isSelectionMode) {
                          toggleSelection(i);
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: totalwidth / columCount,
                            height: totalwidth / columCount,
                            padding: const EdgeInsets.all(0),
                            child: Image(
                                image: all[i].thumbnailProvider(),
                                fit: BoxFit.cover),
                          ),
                          if (selectionModeModel.isSelectionMode)
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Checkbox(
                                    value: _selectedIndices[i] ?? false,
                                    onChanged: (value) {
                                      toggleSelection(i);
                                    },
                                    fillColor: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ));
                  currentChildren.add(child);
                  currentDateTime = all[i].dateCreated();

                  if (i == all.length - 1) {
                    children.add(Wrap(
                      spacing: 2, // 主轴(水平)方向间距
                      runSpacing: 2.0, // 纵轴（垂直）方向间距
                      alignment: WrapAlignment.start,
                      children: currentChildren,
                    ));
                  }
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                );
              }),
            )),
          ]
          //'assets/images/batgirl_artwork-2560x1440.jpg'
          ),
    );
  }
}

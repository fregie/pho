import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_syncer/proto/img_syncer.pb.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/gallery_viewer_route.dart';
import 'package:img_syncer/asset.dart';
import 'component.dart';
import 'event_bus.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:image_picker/image_picker.dart';

class GalleryBody extends StatefulWidget {
  const GalleryBody({Key? key, required this.useLocal}) : super(key: key);
  final bool useLocal;

  @override
  GalleryBodyState createState() => GalleryBodyState();
}

class GalleryBodyState extends State<GalleryBody>
    with AutomaticKeepAliveClientMixin {
  bool _showToTopBtn = false;
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
      if (_scrollController.offset > 1000 && !_showToTopBtn) {
        setState(() {
          _showToTopBtn = true;
        });
      } else if (_scrollController.offset <= 1000 && _showToTopBtn) {
        setState(() {
          _showToTopBtn = false;
        });
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final all =
    //       widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    //   if (all.isEmpty) {
    //     refresh();
    //   }
    // });
  }

  @override
  void didUpdateWidget(GalleryBody oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollSubject.close();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  bool _isRefreshing = false;
  Future<void> refresh() async {
    if (stateModel.isDownloading || stateModel.isUploading) {
      return;
    }
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    if (widget.useLocal) {
      await assetModel.refreshLocal();
    } else {
      await assetModel.refreshRemote();
    }
    if (mounted &&
        !widget.useLocal &&
        assetModel.remoteAssets.isEmpty &&
        assetModel.remoteLastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(assetModel.remoteLastError!),
          duration: const Duration(seconds: 3),
        ),
      );
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
    stateModel.setSelectionMode(hasSelected);

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
    stateModel.setSelectionMode(false);
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
    if (!stateModel.isSelectionMode) {
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
    if (widget.useLocal || !stateModel.isSelectionMode) {
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
    if (settingModel.localFolderAbsPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please set local folder first"),
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
    int count = 0;
    stateModel.setDownloadState(true);
    try {
      for (var asset in assets) {
        if (asset.name() == null) {
          continue;
        }
        final data = await asset.imageDataAsync();
        final absPath = '${settingModel.localFolderAbsPath}/${asset.name()}';
        final file = File(absPath);
        await file.writeAsBytes(data);
        await file.setLastModified(asset.dateCreated());
        await scanFile(absPath);

        // final tempDir = await getTemporaryDirectory();
        // final file = File('${tempDir.path}/${asset.name()}');
        // final result =
        //     await ImageGallerySaver.saveFile(absPath, name: asset.name());
        // if (!result['isSuccess']) {
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text("Download ${asset.name()} failed"),
        //   ));
        //   continue;
        // }
        count++;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Download failed: $e"),
      ));
    }
    stateModel.setDownloadState(false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Download $count photos"),
    ));
    eventBus.fire(LocalRefreshEvent());
    clearSelection();
  }

  void uploadSelected() async {
    if (!widget.useLocal || !stateModel.isSelectionMode) {
      return;
    }
    if (!settingModel.isRemoteStorageSetted) {
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
    stateModel.setUploadState(true);
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
    stateModel.setUploadState(false);
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
              Consumer<StateModel>(
                  builder: (context, model, child) => Container(
                        height: 80,
                        child: Row(
                          children: [
                            _bottomSheetIconButtun(
                                Icons.share_outlined, 'Share', _shareAsset),
                            _bottomSheetIconButtun(Icons.delete_outline,
                                'Delete', () => _showDeleteDialog(context)),
                            if (widget.useLocal)
                              _bottomSheetIconButtun(
                                  Icons.cloud_upload_outlined,
                                  'Upload',
                                  uploadSelected,
                                  isEnable: !model.isDownloading &&
                                      !model.isUploading),
                            if (!widget.useLocal)
                              _bottomSheetIconButtun(
                                  Icons.cloud_download_outlined,
                                  'Download',
                                  downloadSelected,
                                  isEnable: !model.isDownloading &&
                                      !model.isUploading),
                          ],
                        ),
                      )),
            ],
          ),
        );
      },
    );
    _bottomSheetController!.closed.then((value) => clearSelection());
  }

  Widget appBar() {
    return Consumer<StateModel>(
      builder: (context, model, child) {
        String text = 'Pho';
        if (model.isUploading) {
          text = 'Uploading...';
        } else if (model.isDownloading) {
          text = 'Downloading...';
        }
        return SliverAppBar(
          pinned: false,
          snap: false,
          floating: true,
          expandedHeight: 70,
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            widget.useLocal
                ? chooseAlbumButtun(context)
                : setRemoteStorageButtun(context)
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.all(5),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Image.asset(
                    'assets/icon/pho_icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSheetIconButtun(IconData icon, String text, Function()? onTap,
      {bool isEnable = true}) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      // padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: InkResponse(
        containedInkWell: true,
        radius: 40,
        onTap: isEnable ? onTap : null,
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
                color: isEnable ? Colors.black : Colors.grey,
              ),
              Text(text,
                  style:
                      TextStyle(color: isEnable ? Colors.black : Colors.grey)),
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
      child: Stack(
        children: [
          CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                appBar(),
                SliverToBoxAdapter(child: GestureDetector(
                  child: Consumer<AssetModel>(builder: (context, model, child) {
                    final all = widget.useLocal
                        ? model.localAssets
                        : model.remoteAssets;
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
                            if (stateModel.isSelectionMode) {
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
                            if (!stateModel.isSelectionMode) {
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
                              if (stateModel.isSelectionMode)
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
          // 回到顶部按钮
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.useLocal)
                  FloatingActionButton(
                    heroTag: "upload",
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image == null) {
                        return;
                      } else {
                        var rsp = await storage.uploadXFile(image);
                        if (rsp.success) {}
                      }
                    },
                    tooltip: 'Upload',
                    child: const Icon(Icons.add),
                  ),
                Offstage(
                  offstage: !_showToTopBtn,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: FloatingActionButton(
                      onPressed: _scrollToTop,
                      heroTag: 'gallery_body_${widget.useLocal}_toTop',
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

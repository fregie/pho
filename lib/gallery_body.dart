import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:img_syncer/proto/img_syncer.pb.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/gallery_viewer_route.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/event_bus.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_syncer/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:vibration/vibration.dart';
import 'package:img_syncer/choose_album_route.dart';
import 'package:img_syncer/setting_storage_route.dart';

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
  double scrollOffset = 0;

  final Map<int, bool> _selectedIndices = {};

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    _scrollSubject.stream
        .debounceTime(const Duration(milliseconds: 150))
        .listen((scrollPosition) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 4000) {
        getPhotos();
      }
      setState(() {
        scrollOffset = scrollPosition;
      });
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  bool _isRefreshing = false;
  Future<void> refresh() async {
    if (stateModel.isDownloading() || stateModel.isUploading()) {
      return;
    }
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    if (widget.useLocal) {
      assetModel.refreshLocal();
    } else {
      assetModel.refreshRemote();
    }
    // if (mounted &&
    //     !widget.useLocal &&
    //     assetModel.remoteAssets.isEmpty &&
    //     assetModel.remoteLastError != null) {
    //   SnackBarManager.showSnackBar(assetModel.remoteLastError!);
    // }
    _isRefreshing = false;
  }

  void getPhotos() {
    if (widget.useLocal) {
      assetModel.getLocalPhotos();
    } else {
      assetModel.getRemotePhotos();
    }
  }

  void toggleSelection(int index) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator!) {
      Vibration.vibrate(duration: 10);
    }
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
        title: Text("${l10n.deleteThisPhotos}?"),
        content: Text(l10n.cantBeUndone),
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
                SnackBarManager.showSnackBar(e.toString());
              }
              SnackBarManager.showSnackBar(
                  '${l10n.delete} ${toDelete.length} ${l10n.photos}.');
              clearSelection();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text(l10n.yes),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
    if (settingModel.localFolderAbsPath == null) {
      SnackBarManager.showSnackBar(l10n.setLocalFirst);
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
    try {
      for (var asset in assets) {
        if (asset.name() == null) {
          continue;
        }
        Uint8List data;
        if (!asset.isVideo()) {
          data = await asset.imageDataAsync();
        } else {
          data = await asset.remote!.imageData();
        }
        if (Platform.isAndroid) {
          final absPath = '${settingModel.localFolderAbsPath}/${asset.name()}';
          final file = File(absPath);
          await file.writeAsBytes(data);
          await file.setLastModified(asset.dateCreated());
          await scanFile(absPath);
        } else if (Platform.isIOS) {
          var appDocDir = await getTemporaryDirectory();
          String savePath = "${appDocDir.path}/${asset.name()}";
          final file = File(savePath);
          await file.writeAsBytes(data);
          await file.setLastModified(asset.dateCreated());
          await GallerySaver.saveImage(savePath, toDcim: true);
        }

        count++;
      }
    } catch (e) {
      SnackBarManager.showSnackBar("${l10n.downloadFailed}: $e");
    }
    SnackBarManager.showSnackBar("${l10n.download} $count ${l10n.photos}");
    eventBus.fire(LocalRefreshEvent());
    clearSelection();
  }

  void uploadSelected() async {
    if (!widget.useLocal || !stateModel.isSelectionMode) {
      return;
    }
    if (!settingModel.isRemoteStorageSetted) {
      SnackBarManager.showSnackBar(l10n.storageNotSetted);
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
      try {
        await storage.uploadAssetEntity(entity);
      } catch (e) {
        SnackBarManager.showSnackBar("${l10n.uploadFailed}: $e");
      }
    }
    SnackBarManager.showSnackBar(
        "${l10n.successfullyUpload} ${assets.length} ${l10n.photos}");
    eventBus.fire(RemoteRefreshEvent());

    clearSelection();
  }

  void _showBottomSheet(BuildContext context) {
    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (BuildContext context) {
        return SizedBox(
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
                  builder: (context, model, child) => SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            _bottomSheetIconButtun(
                                Icons.share_outlined, l10n.share, _shareAsset),
                            _bottomSheetIconButtun(Icons.delete_outline,
                                l10n.delete, () => _showDeleteDialog(context)),
                            if (widget.useLocal)
                              _bottomSheetIconButtun(
                                  Icons.cloud_upload_outlined,
                                  l10n.upload,
                                  uploadSelected,
                                  isEnable: !model.isDownloading() &&
                                      !model.isUploading()),
                            if (!widget.useLocal)
                              _bottomSheetIconButtun(
                                  Icons.cloud_download_outlined,
                                  l10n.download,
                                  downloadSelected,
                                  isEnable: !model.isDownloading() &&
                                      !model.isUploading()),
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
            // titlePadding: const EdgeInsets.all(5),
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
                size: 24,
                color: isEnable ? Colors.black : Colors.grey,
              ),
              Text(text,
                  style: TextStyle(
                      color: isEnable ? Colors.black : Colors.grey,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget contentBuilder(BuildContext context, AssetModel model, Widget? child) {
    final all = widget.useLocal ? model.localAssets : model.remoteAssets;
    var children = <Widget>[];
    final totalwidth = MediaQuery.of(context).size.width - columCount * 2;
    final totalHeight = MediaQuery.of(context).size.height;
    final imgWidth = totalwidth / columCount;
    final imgHeight = imgWidth;

    var currentChildren = <Widget>[];
    DateTime? currentDateTime;
    double currentScrollOffset = 0;
    for (int i = 0; i < all.length; i++) {
      if (all[i].name() == null) {
        continue;
      }
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
        currentScrollOffset -= 2;
        currentChildren = <Widget>[];
        DateFormat format = DateFormat('yyyy MMMM d${l10n.chineseday}  EEEEE',
            Localizations.localeOf(context).languageCode);
        children.add(Container(
          height: 55,
          padding: const EdgeInsets.all(15),
          child: Text(
            format.format(date),
            style: const TextStyle(
                color: Color.fromARGB(255, 87, 87, 87), fontSize: 16),
          ),
        ));
        currentScrollOffset += 55;
      }
      bool needLoadThumbnail = false;
      if (currentScrollOffset > scrollOffset - (2 * totalHeight) &&
          currentScrollOffset < scrollOffset + (3 * totalHeight)) {
        // print("current offset: $currentScrollOffset");
        // print("scrollOffset: $scrollOffset");
        needLoadThumbnail = true;
        if (!all[i].loadThumbnailFinished()) {
          all[i].thumbnailDataAsync().then((value) => setState(() {}));
        }
      }
      var child = GestureDetector(
          onTap: () async {
            if (stateModel.isSelectionMode) {
              toggleSelection(i);
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (BuildContext context, _, __) =>
                      GalleryViewerRoute(
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
              // image
              Container(
                  width: imgWidth,
                  height: imgHeight,
                  padding: const EdgeInsets.all(0),
                  child: Hero(
                    tag:
                        "asset_${all[i].hasLocal ? "local" : "remote"}_${all[i].path()}",
                    child: needLoadThumbnail && all[i].loadThumbnailFinished()
                        ? Image(
                            image: all[i].thumbnailProvider(),
                            fit: BoxFit.cover)
                        : Container(color: Colors.grey),
                    flightShuttleBuilder: (BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext) {
                      // 自定义过渡动画小部件
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) {
                          return Opacity(
                              opacity: animation.value,
                              child: all[i].loadThumbnailFinished()
                                  ? Image(
                                      image: all[i].thumbnailProvider(),
                                      fit: BoxFit.contain,
                                    )
                                  : Container(color: Colors.grey));
                        },
                      );
                    },
                  )),
              Consumer<StateModel>(builder: (context, stateModel, child) {
                double percent = 0;
                if (!widget.useLocal) {
                  percent = stateModel.getDownloadPercent(all[i].name()!);
                } else {
                  percent = stateModel.getUploadPercent(all[i].local!.id);
                }
                if (percent > 0) {
                  return Positioned(
                    bottom: 2,
                    right: 4,
                    width: 20,
                    height: 20,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                              widget.useLocal
                                  ? Icons.arrow_upward_outlined
                                  : Icons.arrow_downward_outlined,
                              color: Colors.white,
                              size: 16),
                        ),
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                          value: percent,
                        )
                      ],
                    ),
                  );
                }
                var color = Colors.transparent;
                if (widget.useLocal &&
                    stateModel.notSyncedIDs.isNotEmpty &&
                    !stateModel.notSyncedIDs.contains(all[i].local!.id)) {
                  color = Colors.white;
                }
                return Positioned(
                  bottom: 2,
                  right: 4,
                  child: Icon(
                    Icons.cloud_done_outlined,
                    color: color,
                    size: 16,
                  ),
                );
              }),
              // video icon
              if (all[i].isVideo())
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              // selection
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
                            Theme.of(context).colorScheme.secondary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
            ],
          ));
      currentChildren.add(child);
      if (currentChildren.length % columCount == 1) {
        currentScrollOffset += imgHeight + 2;
      }
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
    return SliverList.list(
      children: children,
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
                Consumer<AssetModel>(builder: contentBuilder),
              ]),

          // 回到顶部按钮
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (!widget.useLocal)
                //   FloatingActionButton(
                //     heroTag: "upload",
                //     onPressed: () async {
                //       final ImagePicker picker = ImagePicker();
                //       final XFile? image =
                //           await picker.pickImage(source: ImageSource.gallery);
                //       if (image == null) {
                //         return;
                //       } else {
                //         try {
                //           await storage.uploadXFile(image);
                //         } catch (e) {
                //           SnackBarManager.showSnackBar(e.toString());
                //         }
                //       }
                //     },
                //     tooltip: 'Upload',
                //     child: const Icon(Icons.add),
                //   ),
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

Widget chooseAlbumButtun(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.photo_album),
    color: Theme.of(context).iconTheme.color,
    tooltip: 'Choose album',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChooseAlbumRoute()),
      );
    },
  );
}

Widget setRemoteStorageButtun(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.settings),
    color: Theme.of(context).iconTheme.color,
    tooltip: 'Set remote storage',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingStorageRoute()),
      );
    },
  );
}

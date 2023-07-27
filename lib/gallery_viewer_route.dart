import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/state_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:img_syncer/storage/storage.dart';
import 'event_bus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:img_syncer/video_route.dart';
import 'package:img_syncer/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class GalleryViewerRoute extends StatefulWidget {
  const GalleryViewerRoute({
    Key? key,
    required this.useLocal,
    required this.originIndex,
  }) : super(key: key);
  final bool useLocal;
  final int originIndex;

  @override
  GalleryViewerRouteState createState() => GalleryViewerRouteState();
}

class GalleryViewerRouteState extends State<GalleryViewerRoute> {
  // late final PageController _pageController;
  late final ExtendedPageController _pageController;
  late List<Asset> all;
  late int currentIndex;
  bool showAppBar = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.originIndex;
    _pageController = ExtendedPageController(
      initialPage: widget.originIndex,
      keepPage: true,
    );
    all = widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    all[currentIndex].readInfoFromData();
    assetModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant GalleryViewerRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isShowingImageInfo = false;
  void showImageInfo(BuildContext context) {
    final currentAsset = all[currentIndex];
    if (!currentAsset.isInfoReady()) {
      return;
    }
    if (_isShowingImageInfo) {
      return;
    }
    _isShowingImageInfo = true;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        List<Widget> columns = [];
        columns.add(
          // 抓手
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            height: 4.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        );
        if (currentAsset.date != null) {
          columns.add(ListTile(
              leading: const SizedBox(
                width: 40, // 设置宽度
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: Color.fromARGB(255, 120, 120, 120),
                  ),
                ),
              ),
              title: const Text("Date", style: TextStyle(fontSize: 15)),
              subtitle: Text(
                currentAsset.date!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              )));
        }
        if (currentAsset.make != null && currentAsset.model != null) {
          List<String> children = [
            if (currentAsset.fNumber != null) "f/${currentAsset.fNumber}",
            if (currentAsset.exposureTime != null)
              "${currentAsset.exposureTime!}",
            if (currentAsset.focalLength != null)
              "${currentAsset.focalLength}mm",
            if (currentAsset.iSO != null) "ISO${currentAsset.iSO}",
          ];
          columns.add(
            ListTile(
              leading: const SizedBox(
                width: 40, // 设置宽度
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.camera_outlined,
                    color: Color.fromARGB(255, 120, 120, 120),
                  ),
                ),
              ),
              title: Text("${currentAsset.make} ${currentAsset.model}",
                  style: const TextStyle(fontSize: 15)),
              subtitle: Text(
                children.join("  \u2022  "),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          );
        }
        columns.add(ListTile(
          leading: const SizedBox(
            width: 40, // 设置宽度
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.photo_size_select_actual_outlined,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
            ),
          ),
          title: Text(all[currentIndex].name()!,
              style: const TextStyle(fontSize: 15)),
          subtitle: currentAsset.isVideo()
              ? null
              : RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: currentAsset.imageWidth != null &&
                                currentAsset.imageHeight != null
                            ? "${(currentAsset.imageWidth! * currentAsset.imageHeight! / 1024 / 1024).floor()} MP"
                            : null,
                      ),
                      TextSpan(
                          text: currentAsset.imageWidth != null
                              ? "  \u2022  ${currentAsset.imageWidth!}x${currentAsset.imageHeight!}"
                              : null),
                    ],
                  ),
                ),
        ));

        columns.add(ListTile(
          leading: const SizedBox(
            width: 40, // 设置宽度
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.phone_android,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
            ),
          ),
          title: all[currentIndex].isLocal()
              ? const Text("Local", style: TextStyle(fontSize: 15))
              : const Text("Cloud", style: TextStyle(fontSize: 15)),
          subtitle: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              children: [
                if (!currentAsset.isVideo())
                  TextSpan(
                      text: "${currentAsset.imageSize.toStringAsFixed(1)} MB"),
                if (Platform.isAndroid) ...[
                  const TextSpan(text: "  \u2022  "),
                  TextSpan(text: all[currentIndex].path()),
                ]
              ],
            ),
          ),
        ));

        return IntrinsicHeight(
          child: Column(
            children: columns,
          ),
        );
      },
    ).then((value) => _isShowingImageInfo = false);
  }

  void deleteCurrent(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: const Text("This action can't be undone."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              all[currentIndex].delete().then((value) {
                try {
                  if (all[currentIndex].hasLocal) {
                    eventBus.fire(LocalRefreshEvent());
                  } else {
                    eventBus.fire(RemoteRefreshEvent());
                  }
                } catch (e) {
                  SnackBarManager.showSnackBar(e.toString());
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
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

  void download(Asset asset) async {
    if (asset.isLocal()) {
      return;
    }
    OverlayEntry loadingDialog = OverlayEntry(
      builder: (context) => Center(
        child: Consumer<StateModel>(
          builder: (context, stateModel, child) => CircularProgressIndicator(
            strokeWidth: 5,
            value: stateModel.getDownloadPercent(asset.name()!),
          ),
        ),
      ),
    );

    // 将加载对话框添加到Overlay中
    Overlay.of(context).insert(loadingDialog);
    try {
      if (asset.name() != null) {
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
        }
        if (Platform.isIOS) {
          var appDocDir = await getTemporaryDirectory();
          String savePath = "${appDocDir.path}/${asset.name()}";
          final file = File(savePath);
          await file.writeAsBytes(data);
          await file.setLastModified(asset.dateCreated());
          await GallerySaver.saveImage(savePath, toDcim: true);
        }
      }
      SnackBarManager.showSnackBar("Download ${asset.name()} success");
      eventBus.fire(LocalRefreshEvent());
    } catch (e) {
      SnackBarManager.showSnackBar(e.toString());
    } finally {
      loadingDialog.remove();
    }
  }

  void upload(Asset asset) async {
    if (!asset.isLocal()) {
      return;
    }
    OverlayEntry loadingDialog = OverlayEntry(
      builder: (context) => Center(
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: Consumer<StateModel>(
            builder: (context, value, child) {
              return CircularProgressIndicator(
                strokeWidth: 5,
                value: stateModel.getUploadPercent(asset.local!.id),
              );
            },
          ),
        ),
      ),
    );

    // 将加载对话框添加到Overlay中
    Overlay.of(context).insert(loadingDialog);
    if (!settingModel.isRemoteStorageSetted) {
      SnackBarManager.showSnackBar(
          "Remote storage is not setted,please set it first");
      return;
    }
    final entity = asset.local!;
    try {
      await storage.uploadAssetEntity(entity);
      if (mounted) {
        SnackBarManager.showSnackBar("Upload ${asset.name()} success");
      }
      eventBus.fire(RemoteRefreshEvent());
    } catch (e) {
      print(e);
      SnackBarManager.showSnackBar(e.toString());
    } finally {
      loadingDialog.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: const Color.fromARGB(64, 0, 0, 0),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => deleteCurrent(context),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () async {
                    final data = await all[currentIndex].imageDataAsync();
                    Share.shareXFiles([
                      XFile.fromData(data,
                          name: all[currentIndex].name(),
                          mimeType: all[currentIndex].mimeType()),
                    ]);
                  },
                ),
                if (!all[currentIndex].isLocal())
                  Consumer<StateModel>(builder: (context, model, child) {
                    return IconButton(
                      icon: const Icon(Icons.cloud_download_outlined),
                      onPressed: () =>
                          model.isDownloading() || model.isUploading()
                              ? null
                              : download(all[currentIndex]),
                    );
                  }),
                if (all[currentIndex].isLocal())
                  Consumer<StateModel>(builder: (context, stateModel, child) {
                    return IconButton(
                      icon: stateModel.notSyncedIDs.isNotEmpty &&
                              !stateModel.notSyncedIDs
                                  .contains(all[currentIndex].local!.id)
                          ? const Icon(Icons.cloud_done_outlined)
                          : const Icon(Icons.cloud_upload_outlined),
                      onPressed: () =>
                          stateModel.isDownloading() || stateModel.isUploading()
                              ? null
                              : upload(all[currentIndex]),
                    );
                  }),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    all[currentIndex].imageDataAsync().then(
                          (value) => showImageInfo(context),
                        );
                  },
                ),
              ],
            )
          : null,
      body: Hero(
        tag:
            "asset_${widget.useLocal ? "local" : "remote"}_${all[currentIndex].path()}",
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
                child: ExtendedImage(
                  image: all[currentIndex].thumbnailProvider(),
                  fit: BoxFit.contain,
                ),
              );
            },
          );
        },
        child: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: ExtendedImageGesturePageView.builder(
            itemCount: all.length,
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
              all[index].readInfoFromData().then((value) {
                if (index + 1 >= 0 && index + 1 < all.length) {
                  all[index + 1].readInfoFromData();
                }
                if (index - 1 >= 0 && index - 1 < all.length) {
                  all[index - 1].readInfoFromData();
                }
              });
              if (all.length - index < 5) {
                if (widget.useLocal) {
                  assetModel.getLocalPhotos();
                } else {
                  assetModel.getRemotePhotos();
                }
              }
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ExtendedImage(
                    image: all[index],
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
                      return GestureConfig(
                        minScale: 1.0,
                        maxScale: 3.0,
                        inPageView: true,
                        gestureDetailsIsChanged: (details) {
                          if (details == null) {
                            return;
                          }
                          // 如果是下拉手势则弹出ImageInfo
                          if (details.totalScale == 1.0 &&
                              details.offset!.dy < -100) {
                            showImageInfo(context);
                          }
                        },
                      );
                    },
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return ExtendedImage(
                            image: all[index].thumbnailProvider(),
                            fit: BoxFit.contain,
                          );
                        case LoadState.completed:
                          return null; // Use the high-resolution image.
                        case LoadState.failed:
                          return null;
                        default:
                          return null;
                      }
                    },
                    onDoubleTap: (ExtendedImageGestureState gestureState) {
                      if (gestureState.gestureDetails != null &&
                          gestureState.gestureDetails!.totalScale != null) {
                        double newScale =
                            gestureState.gestureDetails!.totalScale! >= 2.0
                                ? 1.0
                                : 2.0;
                        gestureState.handleDoubleTap(scale: newScale);
                      }
                    },
                  ),
                  if (all[index].isVideo())
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                  GestureDetector(
                    onTap: () {
                      if (all[index].isVideo()) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoRoute(
                              asset: all[index],
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          showAppBar = !showAppBar;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

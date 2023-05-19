import 'dart:io';
import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/state_model.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:img_syncer/storage/storage.dart';
import 'event_bus.dart';
import 'package:extended_image/extended_image.dart';

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
  final bool _isOriginalScale = true;

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

  bool _isShowingAppBar = false;
  void showImageInfo(BuildContext context) {
    final currentAsset = all[currentIndex];
    if (!currentAsset.isInfoReady()) {
      return;
    }
    if (_isShowingAppBar) {
      return;
    }
    _isShowingAppBar = true;
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
          columns.add(ListTile(
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
            subtitle: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                children: [
                  TextSpan(
                    text: (currentAsset.fNumber != null)
                        ? "f/${currentAsset.fNumber}"
                        : null,
                  ),
                  TextSpan(
                      text: currentAsset.exposureTime != null
                          ? "  \u2022  ${currentAsset.exposureTime}"
                          : null),
                  TextSpan(
                      text: currentAsset.focalLength != null
                          ? "  \u2022  ${currentAsset.focalLength}mm"
                          : null),
                  TextSpan(
                      text: currentAsset.iSO != null
                          ? "  \u2022  ISO${currentAsset.iSO}"
                          : null),
                ],
              ),
            ),
          ));
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
          subtitle: RichText(
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
                TextSpan(
                    text: "${currentAsset.imageSize.toStringAsFixed(1)} MB"),
                TextSpan(text: "  \u2022  ${all[currentIndex].path()}"),
              ],
            ),
          ),
        ));

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: columns,
          ),
        );
      },
    ).then((value) => _isShowingAppBar = false);
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                  ));
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 将加载对话框添加到Overlay中
    Overlay.of(context).insert(loadingDialog);
    // 检查并请求存储权限
    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Permission denied"),
        ));
        return;
      }
    }
    stateModel.setDownloadState(true);
    try {
      if (asset.name() != null) {
        final data = await asset.imageDataAsync();
        final absPath = '${settingModel.localFolderAbsPath}/${asset.name()}';
        final file = File(absPath);
        await file.writeAsBytes(data);
        await file.setLastModified(asset.dateCreated());
        await scanFile(absPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    stateModel.setDownloadState(false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Download ${asset.name()} success"),
    ));
    loadingDialog.remove();
  }

  void upload(Asset asset) async {
    if (!asset.isLocal()) {
      return;
    }
    OverlayEntry loadingDialog = OverlayEntry(
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 将加载对话框添加到Overlay中
    Overlay.of(context).insert(loadingDialog);
    if (!settingModel.isRemoteStorageSetted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Remote storage is not setted,please set it first"),
      ));
      return;
    }
    stateModel.setUploadState(true);
    final entity = asset.local!;
    if (entity.title != null) {
      try {
        final rsp = await storage.uploadAssetEntity(entity);
        if (!rsp.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Upload failed: ${rsp.message}"),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
    stateModel.setUploadState(false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Upload ${entity.title} success"),
    ));
    loadingDialog.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
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
                    mimeType: all[currentIndex].mimeType())
              ]);
            },
          ),
          if (!all[currentIndex].isLocal())
            Consumer<StateModel>(
              builder: (context, model, child) => IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () => model.isDownloading || model.isUploading
                    ? null
                    : download(all[currentIndex]),
              ),
            ),
          if (all[currentIndex].isLocal())
            Consumer<StateModel>(
              builder: (context, model, child) => IconButton(
                icon: const Icon(Icons.cloud_upload_outlined),
                onPressed: () => model.isDownloading || model.isUploading
                    ? null
                    : upload(all[currentIndex]),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              all[currentIndex].imageDataAsync().then(
                    (value) => showImageInfo(context),
                  );
            },
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ExtendedImageGesturePageView.builder(
              itemCount: all.length,
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
                all[index].readInfoFromData().then((value) {
                  for (int i = -2; i != 0 && i <= 2; i++) {
                    if (index + i >= 0 && index + i < all.length) {
                      all[index + i].readInfoFromData();
                    }
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
                return ExtendedImage(
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
                            details.offset!.dy < 0) {
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
                );
              },
            ),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onVerticalDragUpdate: _isOriginalScale
            //       ? (details) {
            //           if (details.delta.dy < 0) {
            //             showImageInfo(context);
            //           }
            //         }
            //       : null,
            // ),
          ],
        ),
      ),
    );
  }
}

// PhotoViewGallery.builder(
//   // scrollPhysics: const BouncingScrollPhysics(),
//   wantKeepAlive: true,
//   pageController: _pageController,
//   onPageChanged: (index) {
//     setState(() {
//       currentIndex = index;
//     });
//     all[index].readInfoFromData().then((value) {
//       for (int i = -2; i != 0 && i <= 2; i++) {
//         if (index + i >= 0 && index + i < all.length) {
//           all[index + i].readInfoFromData();
//         }
//       }
//     });
//     if (all.length - index < 5) {
//       if (widget.useLocal) {
//         assetModel.getLocalPhotos();
//       } else {
//         assetModel.getRemotePhotos();
//       }
//     }
//   },
//   builder: (BuildContext context, int index) {
//     return PhotoViewGalleryPageOptions(
//       imageProvider: all[index],
//       // disableGestures: true,
//       initialScale: PhotoViewComputedScale.contained,
//       minScale: PhotoViewComputedScale.contained * 0.5,
//       maxScale: PhotoViewComputedScale.covered * 3,
//       gestureDetectorBehavior: HitTestBehavior.deferToChild,
//       heroAttributes: PhotoViewHeroAttributes(
//           tag:
//               "image-${widget.useLocal ? "local" : "remote"}-$index"),
//     );
//   },
//   loadingBuilder: (context, event) {
//     return PhotoView(
//       imageProvider: all[currentIndex].thumbnailProvider(),
//       minScale: PhotoViewComputedScale.contained,
//       maxScale: PhotoViewComputedScale.covered,
//     );
//   },
//   scaleStateChangedCallback: (value) {
//     if (value == PhotoViewScaleState.initial) {
//       setState(() {
//         _isOriginalScale = true;
//       });
//     } else {
//       setState(() {
//         _isOriginalScale = false;
//       });
//     }
//   },
//   itemCount: all.length,
// ),
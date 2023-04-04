import 'dart:ffi';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:img_syncer/asset.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:img_syncer/state_model.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'event_bus.dart';

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
  late final PageController _pageController;
  late List<Asset> all;
  late int currentIndex;
  bool _isOriginalScale = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.originIndex;

    _pageController = PageController(initialPage: widget.originIndex);
    all = widget.useLocal ? assetModel.localAssets : assetModel.remoteAssets;
    all[currentIndex].readInfoFromData();
  }

  @override
  void didUpdateWidget(covariant GalleryViewerRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void showImageInfo(BuildContext context) {
    final currentAsset = all[currentIndex];
    if (!currentAsset.isInfoReady()) {
      return;
    }
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
    );
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
            onPressed: () {
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
            },
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
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
              all[index].readInfoFromData();
              if (all.length - index < 5) {
                if (widget.useLocal) {
                  assetModel.getLocalPhotos();
                } else {
                  assetModel.getRemotePhotos();
                }
              }
            },
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: all[index],
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(
                    tag:
                        "image-${widget.useLocal ? "local" : "remote"}-$index"),
              );
            },
            loadingBuilder: (context, event) {
              return PhotoView(
                imageProvider: MemoryImage(all[currentIndex].thumbnailData()),
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 3,
                scaleStateChangedCallback: (value) {
                  if (value == PhotoViewScaleState.initial) {
                    setState(() {
                      _isOriginalScale = true;
                    });
                  } else {
                    setState(() {
                      _isOriginalScale = false;
                    });
                  }
                },
              );
            },
            scaleStateChangedCallback: (value) {
              if (value == PhotoViewScaleState.initial) {
                setState(() {
                  _isOriginalScale = true;
                });
              } else {
                setState(() {
                  _isOriginalScale = false;
                });
              }
            },
            itemCount: all.length,
          ),
          GestureDetector(
            onVerticalDragUpdate: _isOriginalScale
                ? (details) {
                    if (details.delta.dy < 0) {
                      showImageInfo(context);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
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

class GalleryBody extends StatefulWidget {
  const GalleryBody({Key? key, required this.useLocal}) : super(key: key);
  final bool useLocal;

  @override
  GalleryBodyState createState() => GalleryBodyState();
}

class GalleryBodyState extends State<GalleryBody> {
  final ScrollController _scrollController = ScrollController();
  final _scrollSubject = PublishSubject<double>();
  int columCount = 3;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
    final all = widget.useLocal
        ? Provider.of<AssetModel>(context, listen: false).localAssets
        : Provider.of<AssetModel>(context, listen: false).remoteAssets;
    if (all.isEmpty) {
      getPhotos();
    }
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

  Future<void> refresh() async {
    if (widget.useLocal) {
      Provider.of<AssetModel>(context, listen: false).refreshLocal();
    } else {
      Provider.of<AssetModel>(context, listen: false).refreshRemote();
    }
  }

  void getPhotos() {
    if (widget.useLocal) {
      Provider.of<AssetModel>(context, listen: false).getLocalPhotos();
    } else {
      Provider.of<AssetModel>(context, listen: false).getRemotePhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refresh,
      child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
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
            ),
            SliverToBoxAdapter(child: GestureDetector(
              child: Consumer<AssetModel>(builder: (context, model, child) {
                final all =
                    widget.useLocal ? model.localAssets : model.remoteAssets;
                var children = <Widget>[];
                final totalwidth = MediaQuery.of(context).size.width - 4;
                for (int i = 0; i < all.length; i++) {
                  var child = GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryViewerRoute(
                              useLocal: widget.useLocal,
                              originIndex: i,
                              // thumbnailData: photo.thumbnailData(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                          width: totalwidth / columCount,
                          height: totalwidth / columCount,
                          padding: const EdgeInsets.all(0),
                          child: Image.memory(all[i].thumbnailData(),
                              fit: BoxFit.cover)));
                  children.add(child);
                }
                return Wrap(
                  spacing: 2, // 主轴(水平)方向间距
                  runSpacing: 2.0, // 纵轴（垂直）方向间距
                  alignment: WrapAlignment.start,
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

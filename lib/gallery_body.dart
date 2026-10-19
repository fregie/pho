import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:img_syncer/design_tokens.dart';
import 'package:img_syncer/proto/img_syncer.pb.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:img_syncer/util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/gallery_viewer_route.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/event_bus.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:img_syncer/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:img_syncer/choose_album_route.dart';
import 'package:img_syncer/setting_storage_route.dart';
import 'package:img_syncer/widgets/thumbnail_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryBody extends StatefulWidget {
  GalleryBody({
    Key? key,
    required this.useLocal,
    this.showAppBar = true,
    this.width,
  }) : super(key: key);
  final bool useLocal;
  bool showAppBar = true;
  double? width;

  @override
  GalleryBodyState createState() => GalleryBodyState();
}

enum LocateType { year, month, day }

class LocateInfo {
  LocateInfo({
    this.location = 0,
    this.count = 0,
  });
  double location;
  int count;
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
  double maxScrollOffset = 0;
  bool dragging = false;

  final Map<int, bool> _selectedIndices = {};

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  PersistentBottomSheetController? _bottomSheetController;

  Map<DateTime, LocateInfo> _dateLocateMap = {};
  LocateType _locateType = LocateType.month;

  double locaterOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollSubject.stream
        .debounceTime(const Duration(milliseconds: 150))
        .listen((scrollPosition) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 4000) {
        // getPhotos();
      }
      setState(() {
        scrollOffset = scrollPosition;
      });
    });
    _scrollSubject.stream.listen((scrollPosition) {
      if (dragging) {
        return;
      }
      if (maxScrollOffset == 0 || maxScrollOffset < scrollPosition) {
        return;
      }
      final totalHeight = MediaQuery.of(context).size.height;
      final paddingTop = MediaQuery.of(context).padding.top + 70;
      const paddingBottom = 130;
      // final paddingBottom = MediaQuery.of(context).padding.bottom + 67;
      final avaliabileHeight = totalHeight - paddingBottom - paddingTop;
      if ((locaterOffset -
                  (paddingTop +
                      (scrollPosition / maxScrollOffset) * avaliabileHeight))
              .abs() <
          5) {
        return;
      }
      setState(() {
        locaterOffset =
            paddingTop + (scrollPosition / maxScrollOffset) * avaliabileHeight;
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
    settingModel.addListener(_onSettingChanged);
  }

  void _onSettingChanged() {
    if (settingModel.galleryColumCount != columCount) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      setState(() {
        columCount = settingModel.galleryColumCount;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final paddingTop = MediaQuery.of(context).padding.top + 70;
    if (locaterOffset < paddingTop) {
      setState(() {
        locaterOffset = paddingTop;
      });
    }
  }

  @override
  void dispose() {
    settingModel.removeListener(_onSettingChanged);
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
      assetModel.refreshLocal(false);
    } else {
      assetModel.refreshRemote(false);
    }
    _isRefreshing = false;
  }

  void toggleSelection(int index) {
    if (_selectedIndices[index] == null) {
      _selectedIndices[index] = true;
    } else {
      _selectedIndices[index] = !_selectedIndices[index]!;
    }
    updateSelection();
  }

  void updateSelection() {
    var hasSelected = false;
    _selectedIndices.forEach((key, value) {
      if (value) {
        hasSelected = true;
      }
    });
    stateModel.setSelectionMode(hasSelected);
    setState(() {});

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
        title: Text(l10n.deleteThisPhotos),
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
                      .then((value) {
                    for (var asset in toDelete) {
                      assetModel.removeLocalAsset(asset);
                    }
                  });
                } else {
                  storage.cli
                      .delete(DeleteRequest(
                    paths: toDelete.map((e) => e.remote!.path).toList(),
                  ))
                      .then((rsp) async {
                    for (var asset in toDelete) {
                      assetModel.removeRemoteAsset(asset);
                      final id = await findLocalIDByAsset(asset);
                      if (id != null) {
                        stateModel.removeSyncedPhotos([id]);
                      }
                    }
                    stateModel.saveSyncedIDs();
                  });
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
      final tempFilePath = await asset.downloadToTmpFilePath();
      xfiles.add(XFile(tempFilePath,
          name: await asset.originName(), mimeType: await asset.mimeType()));
    }
    Share.shareXFiles(xfiles);
  }

  void downloadSelected() async {
    if (widget.useLocal || !stateModel.isSelectionMode) {
      return;
    }
    if (!isDesktop() && settingModel.localFolderAbsPath == null) {
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
    clearSelection();
    int count = 0;
    await keepScreenOn(true);
    try {
      String? path;
      if (isDesktop()) {
        path = await FilePicker.platform.getDirectoryPath();
        if (path == null) {
          return;
        }
      }
      for (var asset in assets) {
        Uint8List data;
        if (!asset.isVideo()) {
          data = await asset.imageDataAsync(reportProgress: true);
        } else {
          data = await asset.remote!.imageData();
        }
        final name = await asset.originName();
        if (Platform.isAndroid) {
          String absPath = '${settingModel.localFolderAbsPath}/$name';
          final file = File(absPath);
          if (file.existsSync()) {
            throw Exception("$name already exists, skip download.");
          }
          await file.writeAsBytes(data);
          await file.setLastModified(asset.dateCreated());
          await scanFile(absPath);
        } else if (Platform.isIOS) {
          var appDocDir = await getTemporaryDirectory();
          String savePath = "${appDocDir.path}/$name";
          final file = File(savePath);
          // if (file.existsSync()) {
          //   throw Exception("$name already exists, skip download.");
          // }
          await file.writeAsBytes(data);
          await file.setLastModified(asset.dateCreated());
          await Gal.putImage(savePath);
        } else if (isDesktop()) {
          String absPath = '$path/$name';
          final file = File(absPath);
          await file.writeAsBytes(data);
        }
        count++;
      }
      SnackBarManager.showSnackBar(
          "${l10n.download} $count ${l10n.photos}${Platform.isIOS ? "\n${l10n.browseInRecents}" : ""}");
    } catch (e) {
      SnackBarManager.showSnackBar("${l10n.downloadFailed}: $e");
    } finally {
      await keepScreenOn(false);
    }
    eventBus.fire(LocalRefreshEvent(refreshUnSync: false));
  }

  void uploadSelected() async {
    if (!widget.useLocal || !stateModel.isSelectionMode) {
      return;
    }
    if (!settingModel.isRemoteStorageSetted) {
      SnackBarManager.showSnackBar(l10n.storageNotSetted);
      return;
    }
    await keepScreenOn(true);
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
    await keepScreenOn(false);
    SnackBarManager.showSnackBar(
        "${l10n.successfullyUpload} ${assets.length} ${l10n.photos}");
    eventBus.fire(RemoteRefreshEvent(refreshUnSync: false));

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
                margin: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm, horizontal: 0),
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.extraSmall),
                ),
              ),
              Consumer<StateModel>(
                  builder: (context, model, child) => SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            if (!isDesktop())
                              _bottomSheetIconButtun(Icons.share_outlined,
                                  l10n.share, _shareAsset),
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
        return SliverAppBar(
          pinned: false,
          snap: false,
          floating: true,
          expandedHeight: 70,
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: const Row(
            children: [],
          ),
          actions: [
            MenuAnchor(
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                );
              },
              menuChildren: [
                widget.useLocal
                    ? MenuItemButton(
                        child: Text(l10n.chooseAlbum),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChooseAlbumRoute()),
                          );
                        },
                      )
                    : MenuItemButton(
                        child: Text(l10n.storageSetting),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SettingStorageRoute()),
                          );
                        },
                      ),
                MenuItemButton(
                  onPressed: settingModel.galleryColumCount > 2
                      ? () async {
                          settingModel.setGalleryColumCount(
                              settingModel.galleryColumCount - 1);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt("galleryColumCount",
                              settingModel.galleryColumCount);
                        }
                      : null,
                  child: Text(l10n.zoomIn),
                ),
                MenuItemButton(
                  onPressed: settingModel.galleryColumCount < 10
                      ? () async {
                          settingModel.setGalleryColumCount(
                              settingModel.galleryColumCount + 1);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt("galleryColumCount",
                              settingModel.galleryColumCount);
                        }
                      : null,
                  child: Text(l10n.zoomOut),
                ),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Image.asset(
                    'assets/icon/pho_icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "Pho",
                  // logo 保留专用手写字体 Sriracha-Regular
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontFamily: "Sriracha-Regular"),
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
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
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
              ),
              Text(text, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDateLocateDialogChildrenDay() {
    List<Widget> children = [];
    _dateLocateMap.forEach(
      (key, value) {
        children.add(ListTile(
          title: Container(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              DateFormat('yyyy MMMM d${l10n.chineseday}',
                      Localizations.localeOf(context).languageCode)
                  .format(key),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          trailing: Badge.count(
            count: value.count,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.pop(context);
            _scrollController.animateTo(
                value.location < 200 ? 0 : value.location - 200,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          },
        ));
      },
    );
    return children;
  }

  List<Widget> _buildDateLocateDialogChildrenMonth() {
    List<Widget> children = [];
    DateTime? lastDateTime;
    double? lastLocation;
    int totalCount = 0;
    int currentCount = 0;
    _dateLocateMap.forEach(
      (key, value) {
        totalCount += 1;
        if (lastDateTime != null &&
            lastDateTime!.year == key.year &&
            lastDateTime!.month == key.month &&
            totalCount != _dateLocateMap.length) {
          currentCount += value.count;
          return;
        }
        if (totalCount == _dateLocateMap.length) {
          currentCount += value.count;
        }
        if (lastDateTime != null && lastLocation != null) {
          double loc = lastLocation! < 200 ? 0 : lastLocation! - 200;
          children.add(ListTile(
            title: Container(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Text(
                DateFormat('yyyy MMMM',
                        Localizations.localeOf(context).languageCode)
                    .format(lastDateTime!),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            trailing: Badge.count(
              count: currentCount,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              textStyle: Theme.of(context).textTheme.labelMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              _scrollController.animateTo(loc,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut);
            },
          ));
          currentCount = 0;
        }
        currentCount += value.count;
        lastDateTime = key;
        lastLocation = value.location;
      },
    );
    return children;
  }

  List<Widget> _buildDateLocateDialogChildrenYear() {
    List<Widget> children = [];
    DateTime? lastDateTime;
    double? lastLocation;
    int totalCount = 0;
    int currentCount = 0;
    _dateLocateMap.forEach(
      (key, value) {
        totalCount += 1;
        if (lastDateTime != null &&
            lastDateTime!.year == key.year &&
            totalCount != _dateLocateMap.length) {
          currentCount += value.count;
          return;
        }
        if (totalCount == _dateLocateMap.length) {
          currentCount += value.count;
        }
        if (lastDateTime != null && lastLocation != null) {
          double loc = lastLocation! < 200 ? 0 : lastLocation! - 200;
          children.add(ListTile(
            title: Container(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Text(
                DateFormat('yyyy', Localizations.localeOf(context).languageCode)
                    .format(lastDateTime!),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            trailing: Badge.count(
              count: currentCount,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              textStyle: Theme.of(context).textTheme.labelMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              _scrollController.animateTo(loc,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut);
            },
          ));
          currentCount = 0;
        }
        currentCount += value.count;
        lastDateTime = key;
        lastLocation = value.location;
      },
    );
    return children;
  }

  void showDateLocateDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.7,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        late List<Widget> children;
                        switch (_locateType) {
                          case LocateType.day:
                            children = _buildDateLocateDialogChildrenDay();
                            break;
                          case LocateType.month:
                            children = _buildDateLocateDialogChildrenMonth();
                            break;
                          case LocateType.year:
                            children = _buildDateLocateDialogChildrenYear();
                            break;
                        }
                        return Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                child: Text(l10n.jumpTo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall)),
                            const Divider(height: 10),
                            Expanded(
                                child: ListView(
                              children: children,
                            )),
                            SegmentedButton<LocateType>(
                              segments: <ButtonSegment<LocateType>>[
                                ButtonSegment<LocateType>(
                                    value: LocateType.day,
                                    label: Text(l10n.day),
                                    icon: Icon(Icons.calendar_view_day)),
                                ButtonSegment<LocateType>(
                                    value: LocateType.month,
                                    label: Text(l10n.month),
                                    icon: Icon(Icons.calendar_view_month)),
                                ButtonSegment<LocateType>(
                                    value: LocateType.year,
                                    label: Text(l10n.year),
                                    icon: Icon(Icons.calendar_view_week)),
                              ],
                              selected: <LocateType>{_locateType},
                              onSelectionChanged: (Set<LocateType> value) {
                                setState(() {
                                  _locateType = value.first;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  )));
        });
  }

  Widget locater() {
    final totalHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top + 70;
    const paddingBottom = 130;
    final avaliabileHeight = totalHeight - paddingBottom - paddingTop;
    List<LocateInfo> mouthLocList = [];
    DateTime? lastDateTime;
    _dateLocateMap.forEach((key, value) {
      if (lastDateTime != null &&
          lastDateTime!.year == key.year &&
          lastDateTime!.month == key.month) {
        return;
      }
      mouthLocList.add(value);
      lastDateTime = key;
    });
    final perMonthHeight = avaliabileHeight / mouthLocList.length;
    return GestureDetector(
      onVerticalDragStart: (details) => setState(() {
        dragging = true;
      }),
      onVerticalDragEnd: (details) => setState(() {
        dragging = false;
      }),
      onVerticalDragUpdate: (details) {
        final realOffset = locaterOffset - paddingTop;
        if (details.delta.dy < 0 && realOffset + details.delta.dy < 0) {
          return;
        }
        if (details.delta.dy > 0 &&
            locaterOffset + details.delta.dy > totalHeight - paddingBottom) {
          return;
        }
        if ((realOffset / perMonthHeight).floor() !=
            ((realOffset + details.delta.dy) / perMonthHeight).floor()) {
          HapticFeedback.lightImpact();
          _scrollController.animateTo(
              mouthLocList[((realOffset + details.delta.dy) / perMonthHeight)
                      .floor()]
                  .location,
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeInOut);
        }
        setState(() {
          locaterOffset += details.delta.dy;
        });
      },
      child: Container(
        height: 50,
        width: 50,
        color: Colors.transparent,
        child: Stack(
          children: [
            ClipOval(
              clipper: CustomHalfCircleClipper(),
              child: Container(
                color: Theme.of(context).colorScheme.secondary.withAlpha(128),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.height,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 23,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBuilder(BuildContext context, AssetModel model, Widget? child) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeCode = Localizations.localeOf(context).languageCode;
    Color textColor = colorScheme.onSurfaceVariant;
    _dateLocateMap = {};
    final all = widget.useLocal ? model.localAssets : model.remoteAssets;
    var children = <Widget>[];
    double totalwidth;
    if (widget.width == null) {
      totalwidth = MediaQuery.of(context).size.width - columCount * 2;
    } else {
      totalwidth = widget.width! - columCount * 2;
    }
    final totalHeight = MediaQuery.of(context).size.height;
    final imgWidth = totalwidth / columCount;
    final imgHeight = imgWidth;

    var currentChildren = <Widget>[];
    DateTime? currentDateTime;
    DateTime? preDateTime;
    double currentScrollOffset = 0;
    for (int i = 0; i < all.length; i++) {
      final date = all[i].dateCreated();
      if (currentDateTime == null ||
          date.year != currentDateTime.year ||
          date.month != currentDateTime.month ||
          date.day != currentDateTime.day) {
        if (currentDateTime != null) {
          final currentChildrenLength = currentChildren.length;
          bool selectedAll = true;
          for (int j = i - 1; i - j <= currentChildrenLength; j--) {
            if (!_selectedIndices.containsKey(j) || !_selectedIndices[j]!) {
              selectedAll = false;
              break;
            }
          }
          DateFormat format = localeCode == 'zh'
              ? DateFormat('M月d日 EEE', 'zh')
              : DateFormat('EEE, MMM d', 'en');
          children.add(GestureDetector(
            child: Container(
              height: 55,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, 0, AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    format.format(currentDateTime),
                    style: textTheme.titleMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                            value: selectedAll,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.small)),
                            onChanged: (isSelect) async {
                              if (isSelect == null) {
                                return;
                              }
                              if (isSelect) {
                                for (int j = i - 1;
                                    i - j <= currentChildrenLength;
                                    j--) {
                                  _selectedIndices[j] = true;
                                }
                              } else {
                                for (int j = i - 1;
                                    i - j <= currentChildrenLength;
                                    j--) {
                                  _selectedIndices.remove(j);
                                }
                              }
                              HapticFeedback.lightImpact();
                              updateSelection();
                            }),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            onTap: () => showDateLocateDialog(),
          ));
        }

        children.add(Wrap(
          spacing: 2, // 主轴(水平)方向间距
          runSpacing: 2.0, // 纵轴（垂直）方向间距
          alignment: WrapAlignment.start,
          children: currentChildren,
        ));
        if (preDateTime != null) {
          _dateLocateMap[preDateTime]!.count = currentChildren.length;
        }
        currentScrollOffset -= 2;
        _dateLocateMap[date] = LocateInfo(location: currentScrollOffset);
        currentChildren = <Widget>[];
        preDateTime = date;
        if (currentDateTime == null || date.month != currentDateTime.month) {
          children.add(
            Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xl, 0, AppSpacing.md),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: localeCode == 'zh'
                          ? '${DateFormat('M', 'zh').format(date)}  '
                          : '${DateFormat('MMMM', 'en').format(date)} ',
                      style: textTheme.headlineLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: DateFormat('yyyy').format(date),
                      style: textTheme.headlineLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          currentScrollOffset += 90;
        }
        currentScrollOffset += 55;
      }
      bool needLoadThumbnail = false;
      if (currentScrollOffset > scrollOffset - (2 * totalHeight) &&
          currentScrollOffset < scrollOffset + (3 * totalHeight)) {
        needLoadThumbnail = true;
        if (!all[i].loadThumbnailFinished()) {
          all[i].thumbnailDataAsync().then((value) {
            if (mounted) setState(() {});
          });
        }
      }
      var child = GestureDetector(
          onTap: () async {
            if (stateModel.isSelectionMode) {
              HapticFeedback.lightImpact();
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
          onLongPress: () async {
            if (!stateModel.isSelectionMode) {
              HapticFeedback.lightImpact();
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
                        "asset_${all[i].hasLocal ? "local" : "remote"}_${all[i].hasLocal ? all[i].local!.id : all[i].remote!.path}",
                    child: needLoadThumbnail && all[i].loadThumbnailFinished()
                        ? Image(
                            image: all[i].thumbnailProvider(),
                            fit: BoxFit.cover)
                        : ThumbnailSkeleton(),
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
                                  : ThumbnailSkeleton());
                        },
                      );
                    },
                  )),
              Consumer<StateModel>(builder: (context, stateModel, child) {
                return FutureBuilder<String>(
                  future: all[i].name(),
                  builder: (context, name) {
                    double percent = 0;
                    if (!widget.useLocal) {
                      percent = name.data == null
                          ? 0
                          : stateModel.getDownloadPercent(name.data as String);
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
                                  color: colorScheme.onPrimary,
                                  size: 16),
                            ),
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                              value: percent,
                            )
                          ],
                        ),
                      );
                    }
                    if (!widget.useLocal ||
                        !settingModel.isRemoteStorageSetted) {
                      return const SizedBox(width: 0, height: 0);
                    }
                    if (stateModel.lastRefreshUnsyncTime == null) {
                      return Positioned(
                          bottom: 2,
                          right: 4,
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ));
                    }
                    var icon = Icons.cloud_off_outlined;
                    if (stateModel.syncedIDs.contains(all[i].local!.id)) {
                      icon = Icons.cloud_done_outlined;
                    }
                    return Positioned(
                      bottom: 2,
                      right: 4,
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                );
              }),
              if (all[i].isLivePhoto())
                Positioned(
                  top: 2,
                  right: 2,
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: Image.asset("assets/icon/live_photos.png"),
                  ),
                ),
              // video icon
              if (needLoadThumbnail && all[i].isVideo()) ...[
                FutureBuilder(
                    future: all[i].videoDuration(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null ||
                          snapshot.data == Duration.zero) {
                        return const SizedBox(width: 0, height: 0);
                      }
                      final duration = snapshot.data!;
                      return Positioned(
                        top: 4,
                        right: 28,
                        child: Text(
                          "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: textTheme.labelMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      );
                    }),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],

              // selection
              if (stateModel.isSelectionMode) ...[
                if (_selectedIndices[i] ?? false)
                  Container(
                    width: imgWidth,
                    height: imgHeight,
                    color: colorScheme.scrim.withValues(alpha: 0.4),
                  ),
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Center(
                      child: Checkbox(
                        value: _selectedIndices[i] ?? false,
                        onChanged: (value) async {
                          toggleSelection(i);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.small)),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ));
      currentChildren.add(child);
      if (currentChildren.length % columCount == 1) {
        currentScrollOffset += imgHeight + 2;
      }
      currentDateTime = all[i].dateCreated();

      if (i == all.length - 1) {
        final currentChildrenLength = currentChildren.length;
        bool selectedAll = true;
        for (int j = i; i - j < currentChildrenLength; j--) {
          if (!_selectedIndices.containsKey(j) || !_selectedIndices[j]!) {
            selectedAll = false;
            break;
          }
        }
        DateFormat format = localeCode == 'zh'
            ? DateFormat('M月d日 EEE', 'zh')
            : DateFormat('EEE, MMM d', 'en');
        children.add(GestureDetector(
          child: Container(
            height: 55,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, 0, AppSpacing.md),
            child: Row(
              children: [
                Text(
                  format.format(currentDateTime),
                  style: textTheme.titleMedium?.copyWith(
                    color: textColor,
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          value: selectedAll,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.small)),
                          onChanged: (isSelect) async {
                            if (isSelect == null) {
                              return;
                            }
                            if (isSelect) {
                              for (int j = i;
                                  i - j < currentChildrenLength;
                                  j--) {
                                _selectedIndices[j] = true;
                              }
                            } else {
                              for (int j = i;
                                  i - j < currentChildrenLength;
                                  j--) {
                                _selectedIndices.remove(j);
                              }
                            }
                            HapticFeedback.lightImpact();
                            updateSelection();
                          }),
                    ),
                  ],
                )),
              ],
            ),
          ),
          onTap: () => showDateLocateDialog(),
        ));
        children.add(Wrap(
          spacing: 2, // 主轴(水平)方向间距
          runSpacing: 2.0, // 纵轴（垂直）方向间距
          alignment: WrapAlignment.start,
          children: currentChildren,
        ));
      }
    }
    maxScrollOffset = currentScrollOffset;
    return SliverList.list(
      children: [
        if ((widget.useLocal &&
                assetModel.localAssets.isEmpty &&
                assetModel.localGetting != null) ||
            (!widget.useLocal &&
                assetModel.remoteAssets.isEmpty &&
                assetModel.remoteGetting != null))
          Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(l10n.refreshing,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ),
        if (all.isEmpty &&
            ((widget.useLocal && assetModel.localGetting == null) ||
                (!widget.useLocal && assetModel.remoteGetting == null)))
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.useLocal
                        ? Icons.photo_library_outlined
                        : Icons.cloud_off_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.useLocal ? l10n.noLocalPhotos : l10n.noCloudPhotos,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  if (!widget.useLocal && !settingModel.isRemoteStorageSetted)
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingStorageRoute()),
                      ),
                      child: Text(l10n.setRemoteStroage),
                    ),
                ],
              ),
            ),
          ),
        ...children
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      // 多选模式下拦截系统返回：先退出多选，避免直接退出应用（issue #86）
      canPop: !stateModel.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (stateModel.isSelectionMode) {
          clearSelection();
        }
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refresh,
        child: Stack(
          children: [
            CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (widget.showAppBar) appBar(),
                  Consumer<AssetModel>(builder: contentBuilder),
                ]),
            if (!isDesktop())
              Positioned(top: locaterOffset, right: 0, child: locater()),
            // 回到顶部按钮
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Offstage(
                    offstage: !_showToTopBtn,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: FloatingActionButton.small(
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
      ),
    );
  }
}

Widget chooseAlbumButtun(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(right: AppSpacing.xs),
    child: TextButton(
      child: Text(l10n.chooseAlbum),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChooseAlbumRoute()),
        );
      },
    ),
  );
}

Widget setRemoteStorageButtun(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(right: AppSpacing.xs),
    child: IconButton.filledTonal(
      icon: const Icon(Icons.settings_outlined),
      color: Theme.of(context).iconTheme.color,
      tooltip: l10n.storageSetting,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingStorageRoute()),
        );
      },
    ),
  );
}

class CustomHalfCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(size.width * 0.4, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class _CustomScaleGestureRecognizer extends ScaleGestureRecognizer {}

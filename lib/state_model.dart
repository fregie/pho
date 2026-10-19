// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:grpc/grpc.dart';
import 'package:flutter/material.dart';
import 'package:img_syncer/logger/logger.dart';
import 'package:img_syncer/util.dart';
import 'event_bus.dart';
import 'package:img_syncer/asset.dart';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

SettingModel settingModel = SettingModel();
AssetModel assetModel = AssetModel();
StateModel stateModel = StateModel();

enum Drive { smb, webDav, nfs }

Map<Drive, String> driveName = {
  Drive.smb: 'SMB',
  Drive.webDav: 'WebDAV',
  Drive.nfs: 'NFS',
};

enum EncryptionType { none, aesCfb, aesGcm }

class SettingModel extends ChangeNotifier {
  String localFolder = "";
  String? localFolderAbsPath;
  bool isRemoteStorageSetted = false;

  bool enableEncrypt = false;
  EncryptionType encryptionType = EncryptionType.none;
  String encryptionPassword = "";

  int galleryColumCount = 4;

  bool setGalleryColumCount(int count) {
    if (galleryColumCount == count) return false;
    galleryColumCount = count;
    notifyListeners();
    return true;
  }

  void setLocalFolder(String folder) {
    if (localFolder == folder && folder != "Recents") return;
    localFolder = folder;
    localFolderAbsPath = null;
    stateModel.setSyncedPhotos([]);
    notifyListeners();
  }

  void setRemoteStorageSetted(bool setted) {
    if (isRemoteStorageSetted == setted) return;
    isRemoteStorageSetted = setted;
    notifyListeners();
  }

  void setEncryptSwitch(bool enable) {
    if (enableEncrypt == enable) return;
    enableEncrypt = enable;
    notifyListeners();
  }

  void setEncryptionType(EncryptionType type) {
    if (encryptionType == type) return;
    encryptionType = type;
    notifyListeners();
  }

  void setEncryptionPassword(String password) {
    if (encryptionPassword == password) return;
    encryptionPassword = password;
    notifyListeners();
  }
}

class transmitState {
  int transmitted = 0;
  int total = 0;
}

class StateModel extends ChangeNotifier {
  bool _isSelectionMode = false;
  bool refreshingUnsynchronized = false;
  List<String> syncedIDs = [];
  DateTime? lastRefreshUnsyncTime;

  Map<String, transmitState> uploadProgress = {};
  Map<String, transmitState> downloadProgress = {};

  bool get isSelectionMode => _isSelectionMode;

  bool needStopSync = false;

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  void setOnline(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    notifyListeners();
  }

  int syncTotal = 0;
  int syncCompleted = 0;
  int syncFailed = 0;
  double get syncPercent => syncTotal == 0 ? 0 : syncCompleted / syncTotal;
  void setSyncProgress(int total, int completed, int failed) {
    syncTotal = total;
    syncCompleted = completed;
    syncFailed = failed;
    notifyListeners();
  }

  void updateLastRefreshUnsyncTime(DateTime? t) {
    lastRefreshUnsyncTime = t;
    notifyListeners();
  }

  void updateUploadProgress(String id, int transmitted, int total) {
    if (!uploadProgress.containsKey(id)) {
      uploadProgress[id] = transmitState();
    }
    uploadProgress[id]!.transmitted = transmitted;
    uploadProgress[id]!.total = total;
    notifyListeners();
  }

  void finishUpload(String id, bool success) {
    uploadProgress.remove(id);
    if (success) {
      syncedIDs.add(id);
      saveSyncedIDs();
    }
    notifyListeners();
  }

  void updateDownloadProgress(String id, int transmitted, int total) {
    if (!downloadProgress.containsKey(id)) {
      downloadProgress[id] = transmitState();
    }
    downloadProgress[id]!.transmitted = transmitted;
    downloadProgress[id]!.total = total;
    notifyListeners();
  }

  void finishDownload(String id, bool success) {
    downloadProgress.remove(id);
    notifyListeners();
  }

  double getUploadPercent(String id) {
    if (!uploadProgress.containsKey(id)) {
      return 0;
    }
    final state = uploadProgress[id]!;
    return state.transmitted / state.total;
  }

  double getDownloadPercent(String id) {
    if (!downloadProgress.containsKey(id)) {
      return 0;
    }
    final state = downloadProgress[id]!;
    return state.transmitted / state.total;
  }

  bool isUploading() {
    return uploadProgress.isNotEmpty;
  }

  bool isDownloading() {
    return downloadProgress.isNotEmpty;
  }

  void setSelectionMode(bool mode) {
    if (_isSelectionMode == mode) return;
    _isSelectionMode = mode;
    notifyListeners();
  }

  void removeSyncedPhotos(List<String> ids) {
    for (var id in ids) {
      syncedIDs.remove(id);
    }
    notifyListeners();
  }

  void setSyncedPhotos(List<String> ids) {
    syncedIDs = ids;
    notifyListeners();
  }

  void setRefreshingUnsynchronized(bool refreshing) {
    if (refreshingUnsynchronized == refreshing) return;
    refreshingUnsynchronized = refreshing;
    notifyListeners();
  }

  Future<void> saveSyncedIDs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(syncedIDs);
    await prefs.setString('synced_ids', jsonString);
    await prefs.setInt(
        'last_refersh_unsync', DateTime.now().millisecondsSinceEpoch);
  }
}

class AssetModel extends ChangeNotifier {
  AssetModel() {
    eventBus
        .on<LocalRefreshEvent>()
        .listen((event) => refreshLocal(event.refreshUnSync));
    eventBus
        .on<RemoteRefreshEvent>()
        .listen((event) => refreshRemote(event.refreshUnSync));
    eventBus.on<FinishGettingLocal>().listen((event) async {
      if (stateModel.lastRefreshUnsyncTime == null) {
        refreshUnsynchronizedPhotos();
      } else {
        if (DateTime.now().difference(stateModel.lastRefreshUnsyncTime!) >
                const Duration(days: 1) &&
            stateModel.syncedIDs.isEmpty) {
          refreshUnsynchronizedPhotos();
        }
      }
    });
    eventBus.on<FinishGettingRemote>().listen((event) async {
      if (stateModel.lastRefreshUnsyncTime == null) {
        refreshUnsynchronizedPhotos();
      } else {
        if (DateTime.now().difference(stateModel.lastRefreshUnsyncTime!) >
                const Duration(days: 1) &&
            stateModel.syncedIDs.isEmpty) {
          refreshUnsynchronizedPhotos();
        }
      }
    });
  }
  List<Asset> localAssets = [];
  List<Asset> remoteAssets = [];
  int columCount = 4;
  int pageSize = 500;
  bool localHasMore = true;
  bool remoteHasMore = true;
  Completer<bool>? localGetting;
  bool localGettingNeedBreak = false;
  Completer<bool>? remoteGetting;
  bool remoteGettingNeedBreak = false;
  bool refreshUnsynchronizedNeedBreak = false;

  Map<String, String> titleCache = {};
  int cacheLastSaveLen = 0;

  String? remoteLastError;

  void addTitleCache(String id, String title) {
    titleCache[id] = title;
    if (titleCache.length - cacheLastSaveLen > 50) {
      cacheLastSaveLen = titleCache.length;
      saveTitleCache();
    }
  }

  Future<void> saveTitleCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(titleCache);
    prefs.setString('title_cache', jsonString);
  }

  Future<void> loadTitleCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('title_cache');
    if (jsonString != null) {
      final cache = jsonDecode(jsonString);
      for (var key in cache.keys) {
        titleCache[key] = cache[key];
      }
    }
  }

  Future<void> refreshLocal(bool refreshSync) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return;
    }
    logger.addLog("refresh local");
    if (localGetting != null) {
      if (localGettingNeedBreak == true) {
        return;
      }
      localGettingNeedBreak = true;
      await localGetting!.future;
    }
    if (stateModel.refreshingUnsynchronized) {
      refreshUnsynchronizedNeedBreak = true;
    }
    if (refreshSync) {
      stateModel.setSyncedPhotos([]);
    }
    localHasMore = true;
    localAssets = [];
    localGettingNeedBreak = false;
    notifyListeners();
    final finished = await getLocalPhotos();
    if (finished && refreshSync) {
      await refreshUnsynchronizedPhotos();
    }
  }

  Future<void> refreshRemote(bool refreshSync) async {
    logger.addLog("refresh remote");
    if (remoteGetting != null) {
      if (remoteGettingNeedBreak == true) {
        return;
      }
      remoteGettingNeedBreak = true;
      await remoteGetting!.future;
    }
    if (stateModel.refreshingUnsynchronized) {
      refreshUnsynchronizedNeedBreak = true;
    }
    remoteHasMore = true;
    remoteAssets = [];
    if (refreshSync) {
      stateModel.setSyncedPhotos([]);
    }
    notifyListeners();
    remoteGetting = null;
    remoteGettingNeedBreak = false;
    final finished = await getRemotePhotos();
    if (finished && refreshSync) {
      await refreshUnsynchronizedPhotos();
    }
  }

  Future<bool> getLocalPhotos() async {
    if (localGetting != null) {
      await localGetting?.future;
    }
    logger.addLog("get local photos");
    final re = await requestPermission();
    if (!re) return false;
    localGetting = Completer<bool>();
    notifyListeners();
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );

    // choose the folder has most photos
    if (settingModel.localFolder == "") {
      int max = 0;
      for (var path in paths) {
        final count = await path.assetCountAsync;
        if (count > max) {
          max = count;
          settingModel.localFolder = path.name;
        }
      }
    }

    for (var path in paths) {
      if (settingModel.localFolder == path.name) {
        var opt = const FilterOption(needTitle: true);
        final newpath = await path.fetchPathProperties(
            filterOptionGroup: FilterOptionGroup(
          imageOption: opt,
          videoOption: opt,
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        ));
        int offset = 0;
        while (localHasMore) {
          if (localGettingNeedBreak) {
            localGettingNeedBreak = false;
            localGetting?.complete(true);
            localGetting = null;
            notifyListeners();
            return false;
          }
          final List<AssetEntity> entities = await newpath!
              .getAssetListRange(start: offset, end: offset + pageSize);
          if (entities.length < pageSize) {
            localHasMore = false;
          }
          offset += entities.length;
          for (var i = 0; i < entities.length; i++) {
            if (localGettingNeedBreak) {
              localGettingNeedBreak = false;
              localGetting?.complete(true);
              localGetting = null;
              notifyListeners();
              return false;
            }
            final asset = Asset(local: entities[i]);
            if (settingModel.localFolderAbsPath == null) {
              final file = await entities[i].originFile;
              if (file != null) {
                settingModel.localFolderAbsPath = file.parent.path;
              }
            }
            // asset.getLocalFile();
            localAssets.add(asset);
            // asset.thumbnailDataAsync().then((value) => notifyListeners());
            if (i % 50 == 0) {
              notifyListeners();
            }
          }
          notifyListeners();
          if (!localHasMore) {
            eventBus.fire(FinishGettingLocal());
            break;
          }
        }
      }
    }

    // 按拍摄日期降序重排，规避 Android 上 photo_manager 按 DATE_ADDED 枚举
    // 与 dateCreated()（DATE_TAKEN）不一致导致的年份穿插（issue #84）
    localAssets = sortByDateDesc(localAssets, (a) => a.dateCreated());

    localGetting?.complete(true);
    localGetting = null;
    notifyListeners();
    return true;
  }

  Future<bool> getRemotePhotos() async {
    await checkServer();
    if (remoteGetting != null) {
      await remoteGetting!.future;
      return false;
    }
    remoteGetting = Completer<bool>();
    notifyListeners();
    logger.addLog("start getting remote assets");
    try {
      while (remoteHasMore) {
        if (remoteGettingNeedBreak) {
          remoteGettingNeedBreak = false;
          remoteGetting?.complete(true);
          remoteGetting = null;
          notifyListeners();
          return false;
        }
        final offset = remoteAssets.length;
        final List<RemoteImage> images =
            await storageClient.listImages("", offset, pageSize);
        if (images.length < pageSize) {
          remoteHasMore = false;
        }
        for (var i = 0; i < images.length; i++) {
          try {
            final asset = Asset(remote: images[i]);
            remoteAssets.add(asset);
            if (i % 50 == 0) {
              notifyListeners();
            }
            // asset.thumbnailDataAsync().then((value) => notifyListeners());
          } catch (e) {
            logger.addLog(e.toString());
          }
        }
        notifyListeners();
      }
    } catch (e) {
      remoteLastError = e.toString();
    }
    if (!remoteHasMore) {
      eventBus.fire(FinishGettingRemote());
    }
    remoteGetting?.complete(true);
    remoteGetting = null;
    remoteGettingNeedBreak = false;
    notifyListeners();
    return true;
  }

  void removeLocalAsset(Asset asset) {
    localAssets.remove(asset);
    notifyListeners();
  }

  void removeLocalAssetsByIDs(List<String> ids) {
    localAssets.removeWhere((element) => ids.contains(element.local!.id));
    notifyListeners();
  }

  void removeRemoteAsset(Asset asset) {
    remoteAssets.remove(asset);
    notifyListeners();
  }
}

Future<String?> findLocalIDByAsset(Asset a) async {
  if (a.hasLocal) {
    return a.local!.id;
  }
  final oName = await a.originName();
  for (var asset in assetModel.localAssets) {
    final name = await asset.originName();
    if (name == oName) {
      return asset.local!.id;
    }
  }
  return null;
}

Future<void> scanFile(String filePath) async {
  if (Platform.isAndroid) {
    try {
      final directory = await getExternalStorageDirectory();
      final path = directory?.path ?? '';
      final mimeType = lookupMimeType(filePath);
      final Map<String, dynamic> params = {
        'path': filePath,
        'volumeName': 'external_primary',
        'relativePath': filePath.replaceFirst('$path/', ''),
        'mimeType': mimeType,
      };

      await const MethodChannel('com.example.img_syncer/RunGrpcServer')
          .invokeMethod('scanFile', params);
    } on PlatformException catch (e) {
      logger.addLog('Failed to scan file $filePath: ${e.message}');
    }
  }
}

Future<void> refreshUnsynchronizedPhotos() async {
  if (assetModel.localGetting != null) {
    await assetModel.localGetting!.future;
  }
  await checkServer();
  if (!settingModel.isRemoteStorageSetted) {
    stateModel.setSyncedPhotos([]);
    return;
  }
  final re = await requestPermission();
  if (!re) return;
  if (stateModel.refreshingUnsynchronized) {
    return;
  }
  logger.addLog("refresh unsynchronized photos");
  stateModel.setRefreshingUnsynchronized(true);
  stateModel.updateLastRefreshUnsyncTime(null);
  final requests = StreamController<FilterNotUploadedRequest>();
  final responses = storageClient.cli.filterNotUploaded(requests.stream);
  // W7-T1: 两阶段提交 - 先积累新ID，成功后一次性替换，避免中断时丢失
  final List<String> newSyncedIDs = [];
  await Future.wait([
    sendFilterNotUploadedRequests(requests),
    receiveResponses(responses, accumulatedIDs: newSyncedIDs),
  ]);

  // 未被中断
  if (!assetModel.refreshUnsynchronizedNeedBreak) {
    // W7-T2: Set 去重后再写入
    stateModel.setSyncedPhotos(newSyncedIDs.toSet().toList());
    await stateModel.saveSyncedIDs();
    stateModel.updateLastRefreshUnsyncTime(DateTime.now());
  }
  assetModel.refreshUnsynchronizedNeedBreak = false;
  stateModel.setRefreshingUnsynchronized(false);
}

Future<void> sendFilterNotUploadedRequests(
    StreamController<FilterNotUploadedRequest> requests) async {
  var photos = List<FilterNotUploadedRequestInfo>.empty(growable: true);
  for (var asset in assetModel.localAssets) {
    if (assetModel.refreshUnsynchronizedNeedBreak) {
      await requests.close();
      return;
    }
    var date = asset.local!.createDateTime;
    if (date.isBefore(DateTime(1990, 1, 1))) {
      date = asset.local!.modifiedDateTime;
    }
    late String name;
    name = await asset.name();
    final dateStr =
        formatDate(date, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
    photos.add(FilterNotUploadedRequestInfo(
      id: asset.local!.id,
      name: name,
      date: dateStr,
    ));
    if (photos.length >= 100) {
      requests.add(FilterNotUploadedRequest(photos: photos));
      photos.clear();
    }
  }
  if (photos.isNotEmpty) {
    requests.add(FilterNotUploadedRequest(photos: photos));
  }
  await requests.close();
}

Future<void> receiveResponses(
    Stream<FilterNotUploadedResponse> responses,
    {List<String>? accumulatedIDs}) async {
  await for (var response in responses) {
    if (!response.success) {
      logger.addLog('Error: ${response.message}');
      SnackBarManager.showSnackBar("Error: ${response.message}");
      continue;
    }
    if (accumulatedIDs != null) {
      // W7-T1: 两阶段提交 - 仅积累，不立即写入
      accumulatedIDs.addAll(response.uploadedIDs);
    } else {
      // W7-T2: Set 去重
      final merged = {...stateModel.syncedIDs, ...response.uploadedIDs}.toList();
      stateModel.setSyncedPhotos(merged);
    }
    // 使用新字段名，兼容旧字段名
    final ids = response.notUploadedIDs.isEmpty
        ? response.notUploaedIDs
        : response.notUploadedIDs;
    logger.addLog('filter: ${ids.length} not uploaded');
  }
}

Future<void> loadUnsynchronizedPhotos() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('synced_ids');
  if (jsonString != null) {
    final cache = jsonDecode(jsonString);
    List<String> newList = [];
    for (var id in cache) {
      newList.add(id);
    }
    stateModel.setSyncedPhotos(newList);
  }
}

Future<FilterNotUploadedRequestInfo> _createFilterNotUploadedRequestInfo(
    asset) async {
  var date = asset.createDateTime;
  if (date.isBefore(DateTime(1990, 1, 1))) {
    date = asset.modifiedDateTime;
  }
  final dateStr =
      formatDate(date, [yyyy, ':', mm, ':', dd, ' ', HH, ':', nn, ':', ss]);
  var name = await asset.titleAsync;
  return FilterNotUploadedRequestInfo(
    id: asset.id,
    name: name,
    date: dateStr,
  );
}

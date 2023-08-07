// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:grpc/grpc.dart';
import 'package:flutter/material.dart';
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

SettingModel settingModel = SettingModel();
AssetModel assetModel = AssetModel();
StateModel stateModel = StateModel();

enum Drive { smb, webDav, nfs, baiduNetdisk }

Map<Drive, String> driveName = {
  Drive.smb: 'SMB',
  Drive.webDav: 'WebDAV',
  Drive.nfs: 'NFS',
  Drive.baiduNetdisk: 'BaiduNetdisk',
};

class SettingModel extends ChangeNotifier {
  String localFolder = "";
  String? localFolderAbsPath;
  bool isRemoteStorageSetted = false;

  void setLocalFolder(String folder) {
    if (localFolder == folder) return;
    localFolder = folder;
    localFolderAbsPath = null;
    eventBus.fire(LocalRefreshEvent());
    notifyListeners();
  }

  void setRemoteStorageSetted(bool setted) {
    if (isRemoteStorageSetted == setted) return;
    isRemoteStorageSetted = setted;
    eventBus.fire(RemoteRefreshEvent());
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
  List<String> notSyncedIDs = [];

  Map<String, transmitState> uploadProgress = {};
  Map<String, transmitState> downloadProgress = {};

  bool get isSelectionMode => _isSelectionMode;

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
      notSyncedIDs.remove(id);
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

  void setNotSyncedPhotos(List<String> ids) {
    notSyncedIDs = ids;
    notifyListeners();
  }

  void setRefreshingUnsynchronized(bool refreshing) {
    if (refreshingUnsynchronized == refreshing) return;
    refreshingUnsynchronized = refreshing;
    notifyListeners();
  }
}

class AssetModel extends ChangeNotifier {
  AssetModel() {
    eventBus.on<LocalRefreshEvent>().listen((event) => refreshLocal());
    eventBus.on<RemoteRefreshEvent>().listen((event) => refreshRemote());
  }
  List<Asset> localAssets = [];
  List<Asset> remoteAssets = [];
  int columCount = 4;
  int pageSize = 500;
  bool localHasMore = true;
  bool remoteHasMore = true;
  Completer<bool>? localGetting;
  Completer<bool>? remoteGetting;

  String? remoteLastError;

  Future<void> refreshLocal() async {
    if (localGetting != null) {
      await localGetting!.future;
    }
    localHasMore = true;
    localAssets = [];
    notifyListeners();
    stateModel.setNotSyncedPhotos([]);
    await getLocalPhotos();
  }

  Future<void> refreshRemote() async {
    if (remoteGetting != null) {
      await remoteGetting!.future;
    }
    remoteHasMore = true;
    remoteAssets = [];
    notifyListeners();
    remoteGetting = null;
    stateModel.setNotSyncedPhotos([]);
    await getRemotePhotos();
  }

  Future<void> getLocalPhotos() async {
    if (localGetting != null) {
      await localGetting?.future;
      return;
    }
    localGetting = Completer<bool>();
    final offset = localAssets.length;
    final re = await requestPermission();
    if (!re) return;
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );

    // choose the folder has most photos
    if (settingModel.localFolder == "") {
      int max = 0;
      for (var path in paths) {
        if (path.assetCount > max) {
          max = path.assetCount;
          settingModel.localFolder = path.name;
        }
      }
    }

    for (var path in paths) {
      if (settingModel.localFolder == path.name) {
        final newpath = await path.fetchPathProperties(
            filterOptionGroup: FilterOptionGroup(
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        ));
        final List<AssetEntity> entities = await newpath!
            .getAssetListRange(start: offset, end: offset + pageSize);
        if (entities.length < pageSize) {
          localHasMore = false;
        }
        for (var i = 0; i < entities.length; i++) {
          final asset = Asset(local: entities[i]);
          if (settingModel.localFolderAbsPath == null) {
            final file = await entities[i].originFile;
            if (file != null) {
              settingModel.localFolderAbsPath = file.parent.path;
            }
          }
          await asset.getLocalFile();
          localAssets.add(asset);
          // asset.thumbnailDataAsync().then((value) => notifyListeners());
          if (i % 100 == 0) {
            notifyListeners();
          }
        }
        notifyListeners();
        if (stateModel.notSyncedIDs.isEmpty) {
          refreshUnsynchronizedPhotos();
        }
      }
    }

    localGetting?.complete(true);
    localGetting = null;
  }

  Future<void> getRemotePhotos() async {
    await checkServer();
    if (remoteGetting != null) {
      await remoteGetting!.future;
      return;
    }
    remoteGetting = Completer<bool>();
    final offset = remoteAssets.length;
    try {
      final List<RemoteImage> images =
          await storage.listImages("", offset, pageSize);
      if (images.length < pageSize) {
        remoteHasMore = false;
      }
      for (var image in images) {
        try {
          final asset = Asset(remote: image);
          remoteAssets.add(asset);
          // asset.thumbnailDataAsync().then((value) => notifyListeners());
        } catch (e) {
          print(e);
        }
      }
      notifyListeners();
    } catch (e) {
      remoteLastError = e.toString();
    }

    remoteGetting?.complete(true);
    remoteGetting = null;
  }
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
      print('Failed to scan file $filePath: ${e.message}');
    }
  }
}

Future<void> refreshUnsynchronizedPhotos() async {
  await checkServer();
  if (!settingModel.isRemoteStorageSetted) {
    stateModel.setNotSyncedPhotos([]);
    return;
  }
  final re = await requestPermission();
  if (!re) return;
  stateModel.setRefreshingUnsynchronized(true);
  stateModel.setNotSyncedPhotos([]);
  final requests = StreamController<FilterNotUploadedRequest>();
  final responses = storage.cli.filterNotUploaded(requests.stream);
  await Future.wait([
    sendFilterNotUploadedRequests(requests),
    receiveResponses(responses),
  ]);

  stateModel.setRefreshingUnsynchronized(false);
}

Future<void> sendFilterNotUploadedRequests(
    StreamController<FilterNotUploadedRequest> requests) async {
  final localFloder = settingModel.localFolder;
  final List<AssetPathEntity> paths =
      await PhotoManager.getAssetPathList(type: RequestType.common);
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
      int offset = 0;
      int pageSize = 50;

      while (true) {
        FilterNotUploadedRequest req = FilterNotUploadedRequest(
            photos: List<FilterNotUploadedRequestInfo>.empty(growable: true));
        final List<AssetEntity> assets = await newpath!
            .getAssetListRange(start: offset, end: offset + pageSize);
        if (assets.isEmpty) {
          req.isFinished = true;
          break;
        }
        var futures = <Future<FilterNotUploadedRequestInfo>>[];
        for (var asset in assets) {
          futures.add(_createFilterNotUploadedRequestInfo(asset));
        }
        req.photos.addAll(await Future.wait(futures));
        offset += pageSize;
        requests.add(req);
      }
      // final rsp = await storage.cli.filterNotUploaded(req);
      // if (rsp.success) {
      //   stateModel.setNotSyncedPhotos(rsp.notUploaedIDs);
      // } else {
      //   throw Exception("Refresh unsynchronized photos failed: ${rsp.message}");
      // }
    }
  }
  await requests.close();
}

Future<void> receiveResponses(
    ResponseStream<FilterNotUploadedResponse> responses) async {
  await for (var response in responses) {
    if (!response.success) {
      print('Error: ${response.message}');
      SnackBarManager.showSnackBar("Error: ${response.message}");
      continue;
    }
    stateModel
        .setNotSyncedPhotos(stateModel.notSyncedIDs + response.notUploaedIDs);
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

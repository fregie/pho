import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:img_syncer/state_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:img_syncer/event_bus.dart';

Timer? autoSyncTimer;

Future<void> reloadAutoSyncTimer() async {
  if (autoSyncTimer != null) {
    autoSyncTimer!.cancel();
  }
  final prefs = await SharedPreferences.getInstance();
  final backgroundSyncEnable = prefs.getBool('backgroundSyncEnabled') ?? false;
  if (!backgroundSyncEnable) return;
  final backgroundSyncInterval =
      Duration(minutes: prefs.getInt('backgroundSyncInterval') ?? 60 * 12);
  print("backgroundSyncInterval: $backgroundSyncInterval");
  autoSyncTimer = Timer.periodic(backgroundSyncInterval, (timer) async {
    print("start auto sync");
    if (settingModel.localFolder == "" || !settingModel.isRemoteStorageSetted) {
      return;
    }
    final wifiOnly = prefs.getBool('backgroundSyncWifiOnly') ?? true;
    if (wifiOnly) {
      final result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.wifi) {
        return;
      }
    }
    if (stateModel.isUploading || stateModel.isDownloading) return;
    await refreshUnsynchronizedPhotos();
    stateModel.setUploadState(true);
    Map names = {};
    for (final name in stateModel.notSyncedNames) {
      names[name] = true;
    }
    final all = await getPhotos();
    for (var asset in all) {
      if (names[asset.title] != true) {
        continue;
      }
      if (asset.title == null) {
        continue;
      }
      try {
        final rsp = await storage.uploadAssetEntity(asset);
        if (!rsp.success) {
          continue;
        }
      } catch (e) {
        print(e);
        continue;
      }
    }
    stateModel.setUploadState(false);
    eventBus.fire(RemoteRefreshEvent());
  });
}

Future<List<AssetEntity>> getPhotos() async {
  List<AssetEntity> all = [];
  final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
  for (var path in paths) {
    if (path.name == settingModel.localFolder) {
      final newpath = await path.fetchPathProperties(
          filterOptionGroup: FilterOptionGroup(
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ));
      int assetOffset = 0;
      int assetPageSize = 100;
      while (true) {
        final List<AssetEntity> assets = await newpath!.getAssetListRange(
            start: assetOffset, end: assetOffset + assetPageSize);
        if (assets.isEmpty) {
          break;
        }
        all.addAll(assets);
        assetOffset += assetPageSize;
      }
      break;
    }
  }
  return all;
}

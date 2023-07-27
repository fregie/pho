import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:img_syncer/state_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:path/path.dart';
import 'package:img_syncer/global.dart';

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
    if (stateModel.isUploading() || stateModel.isDownloading()) return;
    await refreshUnsynchronizedPhotos();
    Map ids = {};
    for (final id in stateModel.notSyncedIDs) {
      ids[id] = true;
    }
    final all = await getPhotos();
    for (var asset in all) {
      final id = asset.id;
      if (ids[id] != true) {
        continue;
      }
      try {
        await storage.uploadAssetEntity(asset);
      } catch (e) {
        print(e);
        continue;
      }
    }
    eventBus.fire(RemoteRefreshEvent());
  });
}

Future<List<AssetEntity>> getPhotos() async {
  List<AssetEntity> all = [];
  final re = await requestPermission();
  if (!re) return all;
  final List<AssetPathEntity> paths =
      await PhotoManager.getAssetPathList(type: RequestType.common);
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

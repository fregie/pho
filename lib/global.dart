import 'package:img_syncer/setting_storage_route.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/run_server.dart';
import 'package:img_syncer/sync_timer.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/logger.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

late String httpBaseUrl;

class Global {
  static Future init() async {
    runServer().then((portsStr) async {
      final ports = portsStr.split(",");
      if (ports.length != 2) {
        logger.e("grpc server start failed");
        return;
      }
      httpBaseUrl = "http://127.0.0.1:${ports[1]}";
      storage = RemoteStorage("127.0.0.1", int.parse(ports[0]));
      // storage = RemoteStorage("192.168.100.235", 50051);
      final prefs = await SharedPreferences.getInstance();
      final localFolder = prefs.getString("localFolder");
      if (localFolder != null && localFolder.isNotEmpty) {
        settingModel.setLocalFolder(localFolder);
      } else {
        await requestPermission();
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
            type: RequestType.common, hasAll: true);
        // ignore: deprecated_member_use
        paths.sort((a, b) => b.assetCount.compareTo(a.assetCount));
        if (paths.isNotEmpty) {
          settingModel.setLocalFolder(paths[0].name);
        }
      }
      var drive = prefs.getString("drive");
      drive ??= "SMB";
      switch (getDrive(drive)) {
        case Drive.smb:
          final addr = prefs.getString("addr");
          final username = prefs.getString("username");
          final password = prefs.getString("password");
          final share = prefs.getString("share");
          final root = prefs.getString("rootPath");
          if (addr != null &&
              username != null &&
              password != null &&
              share != null &&
              root != null) {
            storage.cli
                .setDriveSMB(SetDriveSMBRequest(
              addr: addr,
              username: username,
              password: password,
              share: share,
              root: root,
            ))
                .then((rsp) {
              if (rsp.success) {
                logger.i("set drive smb success");
                settingModel.setRemoteStorageSetted(true);
              } else {
                settingModel.setRemoteStorageSetted(false);
                assetModel.remoteLastError = rsp.message;
              }
            });
          }
          break;
        case Drive.webDav:
          final url = prefs.getString('webdav_url');
          final username = prefs.getString('webdav_username');
          final password = prefs.getString('webdav_password');
          final root = prefs.getString('webdav_root_path');
          if (url != null && root != null) {
            storage.cli
                .setDriveWebdav(SetDriveWebdavRequest(
              addr: url,
              username: username,
              password: password,
              root: root,
            ))
                .then((rsp) {
              if (rsp.success) {
                logger.i("set drive webdav success");
                settingModel.setRemoteStorageSetted(true);
              } else {
                settingModel.setRemoteStorageSetted(false);
                assetModel.remoteLastError = rsp.message;
              }
            });
          }
          break;
        case Drive.nfs:
          final addr = prefs.getString('nfs_url');
          final root = prefs.getString('nfs_root_path');
          if (addr != null && root != null) {
            storage.cli
                .setDriveNFS(SetDriveNFSRequest(
              addr: addr,
              root: root,
            ))
                .then((rsp) {
              if (rsp.success) {
                logger.i("set drive nfs success");
                settingModel.setRemoteStorageSetted(true);
              } else {
                settingModel.setRemoteStorageSetted(false);
                assetModel.remoteLastError = rsp.message;
              }
            });
          }
          break;
      }
      reloadAutoSyncTimer();
    });
  }
}

class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();

  factory SnackBarManager() {
    return _instance;
  }

  SnackBarManager._internal();

  static BuildContext? _context;

  static void init(BuildContext context) {
    _context = context;
  }

  static void showSnackBar(String message) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}

late AppLocalizations i18n;

void initI18n(BuildContext context) {
  i18n = AppLocalizations.of(context);
}

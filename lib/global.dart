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
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

late String httpBaseUrl;
late int grpcPort;
late int httpPort;

class Global {
  static Future init() async {
    runServer().then((portsStr) async {
      final ports = portsStr.split(",");
      if (ports.length != 2) {
        logger.e("grpc server start failed");
        return;
      }
      httpBaseUrl = "http://127.0.0.1:${ports[1]}";
      grpcPort = int.parse(ports[0]);
      httpPort = int.parse(ports[1]);
      storage = RemoteStorage("127.0.0.1", int.parse(ports[0]));
      // storage = RemoteStorage("192.168.100.235", 50051);
      final prefs = await SharedPreferences.getInstance();
      final localFolder = prefs.getString("localFolder");
      if (localFolder != null && localFolder.isNotEmpty) {
        settingModel.setLocalFolder(localFolder);
      } else {
        final re = await requestPermission();
        if (!re) return;
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
            type: RequestType.common, hasAll: true);
        // ignore: deprecated_member_use
        paths.sort((a, b) => b.assetCount.compareTo(a.assetCount));
        if (paths.isNotEmpty) {
          settingModel.setLocalFolder(paths[0].name);
        }
      }
      await initDrive();
      reloadAutoSyncTimer();
    });
  }
}

DateTime? lastAliveTime;
Future<void> checkServer() async {
  if (lastAliveTime != null &&
      DateTime.now().difference(lastAliveTime!) < const Duration(seconds: 60)) {
    return;
  }
  try {
    var socket = await Socket.connect('127.0.0.1', grpcPort);
    socket.destroy();
    lastAliveTime = DateTime.now();
  } catch (e) {
    print("connect 127.0.0.1:$grpcPort failed: $e");
    print("reboot server");
    final portsStr = await runServer();
    final ports = portsStr.split(",");
    if (ports.length != 2) {
      logger.e("grpc server start failed");
      return;
    }
    httpBaseUrl = "http://127.0.0.1:${ports[1]}";
    grpcPort = int.parse(ports[0]);
    httpPort = int.parse(ports[1]);
    storage = RemoteStorage("127.0.0.1", int.parse(ports[0]));
    await initDrive();
  }
}

Future<void> initDrive() async {
  final prefs = await SharedPreferences.getInstance();
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
        final rsp = await storage.cli.setDriveSMB(SetDriveSMBRequest(
          addr: addr,
          username: username,
          password: password,
          share: share,
          root: root,
        ));
        if (rsp.success) {
          print("set drive smb success");
          settingModel.setRemoteStorageSetted(true);
        } else {
          settingModel.setRemoteStorageSetted(false);
          assetModel.remoteLastError = rsp.message;
        }
      }
      break;
    case Drive.webDav:
      final url = prefs.getString('webdav_url');
      final username = prefs.getString('webdav_username');
      final password = prefs.getString('webdav_password');
      final root = prefs.getString('webdav_root_path');
      if (url != null && root != null) {
        final rsp = await storage.cli.setDriveWebdav(SetDriveWebdavRequest(
          addr: url,
          username: username,
          password: password,
          root: root,
        ));
        if (rsp.success) {
          logger.i("set drive webdav success");
          settingModel.setRemoteStorageSetted(true);
          // refreshUnsynchronizedPhotos();
        } else {
          settingModel.setRemoteStorageSetted(false);
          assetModel.remoteLastError = rsp.message;
        }
      }
      break;
    case Drive.nfs:
      final addr = prefs.getString('nfs_url');
      final root = prefs.getString('nfs_root_path');
      if (addr != null && root != null) {
        final rsp = await storage.cli.setDriveNFS(SetDriveNFSRequest(
          addr: addr,
          root: root,
        ));
        if (rsp.success) {
          logger.i("set drive nfs success");
          settingModel.setRemoteStorageSetted(true);
          // refreshUnsynchronizedPhotos();
        } else {
          settingModel.setRemoteStorageSetted(false);
          assetModel.remoteLastError = rsp.message;
        }
      }
      break;
    case Drive.baiduNetdisk:
      final refreshToken = prefs.getString("baidu_refresh_token");
      final accessToken = prefs.getString("baidu_access_token");
      final expiresAt = prefs.getInt("baidu_expires_at");
      if (refreshToken == null || refreshToken == "") {
        break;
      }
      final temporaryDir = await getTemporaryDirectory();
      print("temp dir: ${temporaryDir.path}");
      final rsp =
          await storage.cli.setDriveBaiduNetDisk(SetDriveBaiduNetDiskRequest(
        refreshToken: refreshToken,
        accessToken: accessToken,
        tmpDir: temporaryDir.path,
      ));
      if (rsp.success) {
        logger.i("set drive baidu netdisk success");
        settingModel.setRemoteStorageSetted(true);
      } else {
        settingModel.setRemoteStorageSetted(false);
        assetModel.remoteLastError = rsp.message;
      }
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

late AppLocalizations l10n;

void initI18n(BuildContext context) {
  l10n = AppLocalizations.of(context);
}

Completer<bool>? requesttingPermission;
BuildContext? requestPermissionContext;
void initRequestPermission(BuildContext context) {
  requestPermissionContext = context;
}

Future<bool> requestPermission() async {
  bool result = false;
  if (requesttingPermission != null) {
    result = await requesttingPermission!.future;
    return result;
  }
  requesttingPermission = Completer<bool>();
  //权限申请
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  if (ps == PermissionState.authorized) {
    result = true;
  } else {
    result = false;
    if (requestPermissionContext != null) {
      showDialog(
          context: requestPermissionContext!,
          builder: (BuildContext context) => AlertDialog(
                title: Text(l10n.needPermision),
                content: Text(l10n.gotoSystemSetting),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      PhotoManager.openSetting();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.openSetting),
                  ),
                ],
              ));
    }
  }
  requesttingPermission?.complete(result);
  requesttingPermission = null;
  return result;
}

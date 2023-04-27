import 'package:img_syncer/setting_storage_route.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/run_server.dart';
import 'package:img_syncer/sync_timer.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/logger.dart';

class Global {
  static Future init() async {
    runServer().then((port) async {
      storage = RemoteStorage("127.0.0.1", port);
      // storage = RemoteStorage("192.168.100.235", 50051);
      final prefs = await SharedPreferences.getInstance();
      final localFolder = prefs.getString("localFolder");
      if (localFolder != null && localFolder.isNotEmpty) {
        settingModel.setLocalFolder(localFolder);
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
              username: username.toString(),
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
              }
            });
          }
      }
      reloadAutoSyncTimer();
    });
  }
}

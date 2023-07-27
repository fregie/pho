import 'package:flutter/material.dart';
import 'package:img_syncer/storageform/smbform.dart';
import 'package:img_syncer/storageform/webdavform.dart';
import 'package:img_syncer/storageform/nfsform.dart';
import 'package:img_syncer/storageform/baidu_netdisk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/global.dart';

class SettingStorageRoute extends StatefulWidget {
  const SettingStorageRoute({Key? key}) : super(key: key);

  @override
  SettingStorageRouteState createState() => SettingStorageRouteState();
}

Drive getDrive(String drive) {
  return driveName.entries
      .firstWhere((element) => element.value == drive,
          orElse: () => const MapEntry(Drive.smb, "SMB"))
      .key;
}

class SettingStorageRouteState extends State<SettingStorageRoute> {
  final GlobalKey _formKey = GlobalKey<FormState>();

  @protected
  Drive currentDrive = Drive.smb;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final drive = prefs.getString("drive");
      if (drive != null) {
        setState(() {
          currentDrive = getDrive(drive);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget form;
    switch (currentDrive) {
      case Drive.smb:
        form = const SMBForm();
        break;
      case Drive.webDav:
        form = const WebDavForm();
        break;
      case Drive.nfs:
        form = const NFSForm();
        break;
      case Drive.baiduNetdisk:
        form = const BaiduNetdiskForm();
        break;
      default:
        form = const Text('Not implemented');
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: Text(l10n.storageSetting,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: Center(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                readOnly: true,
                controller: TextEditingController(
                    text: driveName[currentDrive] == "BaiduNetdisk"
                        ? l10n.baiduNetdisk
                        : driveName[currentDrive]),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.remoteStorageType,
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      itemBuilder: (BuildContext context) {
                        return driveName.values
                            .map((String value) => PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value == "BaiduNetdisk"
                                      ? l10n.baiduNetdisk
                                      : value),
                                ))
                            .toList();
                      },
                      onSelected: (String value) => setState(() {
                        currentDrive = getDrive(value);
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString("drive", value);
                        });
                      }),
                    )),
              ),
            ),
            form,
          ],
        )));
  }
}

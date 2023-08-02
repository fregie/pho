import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class BaiduNetdiskForm extends StatefulWidget {
  const BaiduNetdiskForm({Key? key}) : super(key: key);
  @override
  BaiduNetdiskFormState createState() => BaiduNetdiskFormState();
}

class BaiduNetdiskFormState extends State<BaiduNetdiskForm> {
  bool loginSuccess = false;
  StartBaiduNetdiskLoginResponse? rsp;

  Widget saveButtun() {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: FilledButton(
        onPressed: loginSuccess
            ? () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString("baidu_refresh_token", rsp!.refreshToken);
                  prefs.setString("baidu_access_token", rsp!.accessToken);
                  prefs.setInt("baidu_expires_at", rsp!.exiresAt.toInt());
                  prefs.setString("drive", driveName[Drive.baiduNetdisk]!);
                });
                settingModel.setRemoteStorageSetted(true);
                assetModel.remoteLastError = null;
                eventBus.fire(RemoteRefreshEvent());
                Navigator.pop(context);
              }
            : null,
        child: Text(
          l10n.save,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          child: Text(
            l10n.baiduNetdiskLogin,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.0),
          ),
          onPressed: () async {
            final temporaryDir = await getTemporaryDirectory();
            storage.cli
                .startBaiduNetdiskLogin(StartBaiduNetdiskLoginRequest(
              tmpDir: temporaryDir.path,
            ))
                .then((StartBaiduNetdiskLoginResponse resp) {
              rsp = resp;
              if (rsp!.success) {
                SnackBarManager.showSnackBar(l10n.testSuccess);
                setState(() {
                  loginSuccess = true;
                });
              }
            });
            final Uri authUrl = Uri.parse(
                'http://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id=8wylQfdIzIpNFOGHZSnOOQ98QLDFvl1U&redirect_uri=http://localhost.pho.tools:$httpPort/baidu/callback&scope=basic,netdisk&device_id=34906909&display=mobile');
            LaunchMode mode = LaunchMode.externalApplication;
            if (Platform.isIOS) {
              mode = LaunchMode.inAppWebView;
            }
            final success = await launchUrl(authUrl, mode: mode);
            if (!success) {
              throw Exception('Could not launch $authUrl');
            }
          },
        ),
        saveButtun(),
      ],
    ));
  }
}

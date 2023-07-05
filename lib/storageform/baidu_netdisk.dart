import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/global.dart';
import 'package:url_launcher/url_launcher.dart';

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
          i18n.save,
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
          child: const Text(
            "百度网盘登录",
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.0),
          ),
          onPressed: () async {
            storage.cli
                .startBaiduNetdiskLogin(StartBaiduNetdiskLoginRequest())
                .then((StartBaiduNetdiskLoginResponse resp) {
              rsp = resp;
              if (rsp!.success) {
                SnackBarManager.showSnackBar("登陆成功, 可以点击保存了");
                setState(() {
                  loginSuccess = true;
                });
              }
            });
            final Uri authUrl = Uri.parse(
                'http://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id=8wylQfdIzIpNFOGHZSnOOQ98QLDFvl1U&redirect_uri=http://localhost.pho.tools:$httpPort/baidu/callback&scope=basic,netdisk&device_id=34906909&display=mobile');
            if (!await launchUrl(authUrl,
                mode: LaunchMode.externalApplication)) {
              throw Exception('Could not launch $authUrl');
            }
          },
        ),
        saveButtun(),
      ],
    ));
  }
}

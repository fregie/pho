// iOS 后台同步入口（headless FlutterEngine）。
//
// 由 AppDelegate 的 BGProcessingTask handle 创建 headless engine 后通过
// `@pragma('vm:entry-point')` 调起。复用与 UI 相同的 Dart 全局（setting /
// asset / state / storage 等），但仅做后台同步所需的最小初始化：
//   - 不调用顶层全局初始化流程（会触发 IAP / 周期定时器 / UI 副作用）
//   - 不跑自动同步定时器重载、退款检查、订阅状态检查、标题缓存加载
//   - 不调 stateModel.setSyncProgress（后台无 UI 监听）
//   - 不直接 invoke sendLocalNotification channel，用 LocalNotifier 封装
//   - 不调 keepScreenOn

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:img_syncer/asset.dart';
import 'package:img_syncer/global.dart';
import 'package:img_syncer/l10n/app_localizations_en.dart';
import 'package:img_syncer/l10n/app_localizations_zh.dart';
import 'package:img_syncer/logger/logger.dart';
import 'package:img_syncer/notifications/local_notifier.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/run_server.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:img_syncer/sync/background_runner.dart';
import 'package:img_syncer/sync/bg_task_scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void backgroundSyncEntrypoint() async {
  // Step 1: 初始化 Flutter binding（headless engine 必须）
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: 注册 backgroundSync MethodChannel 接收 native 端的 cancel 命令
  bool cancelFlag = false;
  const bgChannel = MethodChannel('com.example.img_syncer/backgroundSync');
  bgChannel.setMethodCallHandler((call) async {
    if (call.method == 'cancel') {
      cancelFlag = true;
    }
  });

  // Headless isolate 没有 BuildContext，无法走 initI18n(context)；
  // 直接构造 localization 实例供 LocalNotifier.sendSyncCompleteNotification 使用，
  // 否则全局 `late AppLocalizations l10n` 会抛 LateInitializationError。
  final localeName = Platform.localeName.toLowerCase();
  l10n = localeName.startsWith('zh')
      ? (localeName.endsWith('_tw')
          ? AppLocalizationsZhTw()
          : AppLocalizationsZh())
      : AppLocalizationsEn();

  // Step 3: 写 prefs 信号（entrypoint 跑过的可观测证据）
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_bg_sync_time', DateTime.now().toIso8601String());

  // Step 4: 启动 Go server + 重建 RemoteStorage
  final portsStr = await runServer();
  final ports = portsStr.split(',');
  if (ports.length != 2) {
    logger.addLog('bg sync: grpc server start failed');
    await bgChannel.invokeMethod('complete', false);
    return;
  }
  final grpcP = int.parse(ports[0]);
  final httpP = int.parse(ports[1]);
  httpBaseUrl = 'http://127.0.0.1:$httpP';
  storage = RemoteStorage('127.0.0.1', grpcP);

  // Step 5: 最小 init 序列 — 应用 prefs 到 settingModel（参考 global.dart 的 init 模式）
  final localFolder = prefs.getString('localFolder');
  if (localFolder != null && localFolder.isNotEmpty) {
    settingModel.setLocalFolder(localFolder);
  }

  final enableEncrypt = prefs.getBool('enable_encrypt');
  if (enableEncrypt != null) {
    settingModel.setEncryptSwitch(enableEncrypt);
  }
  final encryptionType = prefs.getInt('encryption_type');
  if (encryptionType != null) {
    settingModel.setEncryptionType(EncryptionType.values[encryptionType]);
  }
  final encPassword = prefs.getString('encryption_password');
  if (encPassword != null) {
    settingModel.setEncryptionPassword(encPassword);
  }

  // Step 6: 初始化 drive（依赖 Step 4 设置的 storage）
  await initDrive();

  // Step 7: 填充 assetModel.localAssets
  // 预置 titleCache（Asset 构造器会访问 assetModel.titleCache），后台不读持久化缓存
  assetModel.titleCache = {};
  final re = await requestPermission();
  if (re) {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.common);
    for (var path in paths) {
      if (path.name == settingModel.localFolder) {
        int assetOffset = 0;
        const int assetPageSize = 100;
        while (true) {
          final List<AssetEntity> entities = await path.getAssetListRange(
              start: assetOffset, end: assetOffset + assetPageSize,);
          if (entities.isEmpty) break;
          for (final entity in entities) {
            final asset = Asset(local: entity);
            assetModel.localAssets.add(asset);
          }
          assetOffset += assetPageSize;
        }
        break;
      }
    }
  }

  // Step 8: 刷新未同步照片（建立 uploadedIds 基线）
  await refreshUnsynchronizedPhotos();

  // Step 9: WiFi runtime check — 非 WiFi 时重新调度下次 BGProcessingTask 后退出
  final wifiOnly = prefs.getBool('backgroundSyncWifiOnly') ?? true;
  if (wifiOnly) {
    final connectivityResults = await Connectivity().checkConnectivity();
    if (!connectivityResults.contains(ConnectivityResult.wifi)) {
      logger.addLog('bg sync: wifi required but not connected, rescheduling');
      await scheduleBgTaskViaChannel();
      await bgChannel.invokeMethod('complete', true);
      return;
    }
  }

  // Step 10: 执行同步
  final Map<String, bool> uploadedIds = {};
  for (final id in stateModel.syncedIDs) {
    uploadedIds[id] = true;
  }
  final result = await runSyncOnce(
    storage: storageClient,
    assets: assetModel.localAssets,
    uploadedIds: uploadedIds,
    parallelCount: 1,
    shouldStop: () => cancelFlag,
    refreshUnSync: true,
  );

  // Step 11: 完成后处理
  await prefs.setInt('last_bg_sync_success_count', result.succeeded);
  await prefs.setInt('last_bg_sync_fail_count', result.failed);

  final docDir = await getApplicationDocumentsDirectory();
  final logFile = File('${docDir.path}/bg_sync.log');
  await logFile.writeAsString(
    '${DateTime.now().toIso8601String()} | succeeded: ${result.succeeded}, failed: ${result.failed}, duration: ${result.duration.inSeconds}s\n',
    mode: FileMode.append,
  );

  // 重新调度下一次 BGProcessingTask（Apple 官方模式）
  await scheduleBgTaskViaChannel();

  // 发送同步完成通知（封装在 LocalNotifier，succeeded == 0 时静默不发）
  await LocalNotifier.sendSyncCompleteNotification(
    succeeded: result.succeeded,
    failed: result.failed,
  );

  // 通知 native 完成
  await bgChannel.invokeMethod('complete', true);
}
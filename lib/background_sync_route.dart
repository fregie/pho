import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/sync_timer.dart';
import 'package:img_syncer/state_model.dart';

class BackgroundSyncSettingRoute extends StatefulWidget {
  const BackgroundSyncSettingRoute({Key? key}) : super(key: key);

  @override
  _BackgroundSyncSettingRouteState createState() =>
      _BackgroundSyncSettingRouteState();
}

class _BackgroundSyncSettingRouteState
    extends State<BackgroundSyncSettingRoute> {
  bool _backgroundSyncEnabled = false;
  bool _backgroundSyncWifiOnly = true;
  Duration _backgroundSyncInterval = const Duration(minutes: 60);
  List<AssetPathEntity> albums = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _backgroundSyncEnabled = prefs.getBool('backgroundSyncEnabled') ?? false;
      _backgroundSyncWifiOnly = prefs.getBool('backgroundSyncWifiOnly') ?? true;
      _backgroundSyncInterval =
          Duration(minutes: prefs.getInt('backgroundSyncInterval') ?? 60);
    });
    await requestPermission();
    albums = await PhotoManager.getAssetPathList();
    for (var path in albums) {
      if (path.name == 'Recent') {
        albums.remove(path);
        break;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        title: Text('Background sync',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Enable background sync'),
            trailing: Switch(
              value: _backgroundSyncEnabled,
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('backgroundSyncEnabled', value);
                setState(() {
                  _backgroundSyncEnabled = value;
                });
                reloadAutoSyncTimer();
              },
            ),
          ),
          ListTile(
            title: const Text('Sync only on Wi-Fi'),
            trailing: Switch(
              value: _backgroundSyncWifiOnly,
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('backgroundSyncWifiOnly', value);
                setState(() {
                  _backgroundSyncWifiOnly = value;
                });
                reloadAutoSyncTimer();
              },
            ),
          ),
          ListTile(
            title: const Text('Sync interval'),
            trailing: DropdownButton<Duration>(
              value: _backgroundSyncInterval,
              items: const [
                DropdownMenuItem(
                  value: Duration(minutes: 1),
                  child: Text('1 minute'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 1),
                  child: Text('1 hour'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 3),
                  child: Text('3 hours'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 6),
                  child: Text('6 hours'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 12),
                  child: Text('12 hours'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 1),
                  child: Text('1 day'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 3),
                  child: Text('3 days'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 7),
                  child: Text('1 week'),
                ),
              ],
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('backgroundSyncInterval', value!.inMinutes);
                setState(() {
                  _backgroundSyncInterval = value;
                });
                reloadAutoSyncTimer();
              },
            ),
          ),
        ],
      ),
    );
  }
}

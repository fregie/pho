import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/sync_timer.dart';
import 'package:img_syncer/state_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context).backgroundSync,
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).enableBackgroundSync),
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
            title: Text(AppLocalizations.of(context).syncOnlyOnWifi),
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
            title: Text(AppLocalizations.of(context).syncInterval),
            trailing: DropdownButton<Duration>(
              value: _backgroundSyncInterval,
              items: [
                // DropdownMenuItem(
                //   value: Duration(minutes: 1),
                //   child: Text('1 minute'),
                // ),
                DropdownMenuItem(
                  value: Duration(minutes: 10),
                  child: Text('10 ${AppLocalizations.of(context).minite}'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 1),
                  child: Text('1 ${AppLocalizations.of(context).hour}'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 3),
                  child: Text('3 ${AppLocalizations.of(context).hour}'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 6),
                  child: Text('6 ${AppLocalizations.of(context).hour}'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 12),
                  child: Text('12 ${AppLocalizations.of(context).hour}'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 1),
                  child: Text('1 ${AppLocalizations.of(context).day}'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 3),
                  child: Text('3 ${AppLocalizations.of(context).day}'),
                ),
                DropdownMenuItem(
                  value: Duration(days: 7),
                  child: Text('1 ${AppLocalizations.of(context).week}'),
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

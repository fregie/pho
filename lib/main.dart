import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:img_syncer/choose_album_route.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:photo_album_manager/photo_album_manager.dart';
import 'dart:io';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:img_syncer/gallery_viewer_route.dart';
import 'package:img_syncer/theme/theme.dart';
import 'package:img_syncer/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_syncer/asset.dart';
import 'component.dart';
import 'package:img_syncer/run_server.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:img_syncer/state_model.dart';
import 'gallery_body.dart';
import 'setting_body.dart';
import 'sync_body.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';

const seedThemeColor = Color.fromARGB(255, 18, 159, 135);

void main() {
  stateModel.addListener(() {
    assetModel.setAlbum(stateModel.localFolder);
  });
  runServer().then((port) async {
    storage = RemoteStorage("127.0.0.1", port);
    // storage = RemoteStorage("192.168.100.235", 50051);
    final prefs = await SharedPreferences.getInstance();
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
          stateModel.setRemoteStorageSetted(true);
        } else {
          stateModel.setRemoteStorageSetted(false);
        }
      });
    }
  });
  Global.init().then((e) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => stateModel),
            ChangeNotifierProvider(create: (context) => assetModel),
            ChangeNotifierProvider(create: (context) => selectionModeModel),
          ],
          child: const MyApp(),
        ),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Goo photo';
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        late ColorScheme lightColorScheme;
        late ColorScheme darkColorScheme;
        if (lightDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
        } else {
          print("lightDynamic is null");
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedThemeColor,
            brightness: Brightness.light,
          );
        }
        if (darkDynamic != null) {
          darkColorScheme = darkDynamic.harmonized();
        } else {
          print("darkDynamic is null");
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedThemeColor,
            brightness: Brightness.dark,
          );
        }

        return AdaptiveTheme(
            light: ThemeData.from(
                colorScheme: lightColorScheme, useMaterial3: true),
            dark: ThemeData.from(
                colorScheme: darkColorScheme, useMaterial3: true),
            initial: AdaptiveThemeMode.system,
            builder: (theme, darkTheme) {
              return MaterialApp(
                title: _title,
                debugShowCheckedModeBanner: false,
                home: const MyHomePage(title: _title),
                theme: theme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
              );
            });
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final localFolder = prefs.getString("localFolder");
      if (localFolder != null) {
        Provider.of<StateModel>(context, listen: false)
            .setLocalFolder(localFolder);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? floatingActionButton;
    PreferredSizeWidget? appBar;
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        floatingActionButton = FloatingActionButton(
          heroTag: "upload",
          onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? image =
                await _picker.pickImage(source: ImageSource.gallery);
            if (image == null) {
              return;
            } else {
              var rsp = await storage.uploadXFile(image);
              if (rsp.success) {}
            }
          },
          tooltip: 'Upload',
          child: const Icon(Icons.add),
        );
        break;
      case 2:
        break;
      case 3:
        appBar = AppBar(
          centerTitle: true,
          title: Text(
            'Setting',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
        break;
    }
    return Consumer<SelectionModeModel>(
      builder: (context, model, child) => Scaffold(
        appBar: appBar,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const GalleryBody(
              useLocal: true,
            ),
            const GalleryBody(useLocal: false),
            Consumer<StateModel>(
              builder: (context, model, child) {
                return SyncBody(
                  localFolder: model.localFolder,
                );
              },
            ),
            const SettingBody(),
          ],
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: model.isSelectionMode
            ? null
            : NavigationBar(
                onDestinationSelected: _onItemTapped,
                selectedIndex: _selectedIndex,
                destinations: <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.phone_android,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Local',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Cloud',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud_sync,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Sync',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings,
                        color: Theme.of(context).iconTheme.color),
                    label: 'Setting',
                  ),
                ],
              ),
      ),
    );
  }
}

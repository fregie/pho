import 'package:flutter/material.dart';
import 'package:img_syncer/global.dart';
import 'package:provider/provider.dart';
import 'package:img_syncer/state_model.dart';
import 'gallery_body.dart';
import 'setting_body.dart';
import 'sync_body.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:img_syncer/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const seedThemeColor = Color(0xFF02FED1);
const darkSeedThemeColor = Color(0xFF02FED1);

void main() {
  Global.init().then((e) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => settingModel),
            ChangeNotifierProvider(create: (context) => assetModel),
            ChangeNotifierProvider(create: (context) => stateModel),
          ],
          child: const MyApp(),
        ),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'PHO';
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 设置状态栏颜色为透明
      systemNavigationBarColor: Colors.transparent, // 设置导航栏颜色为透明
      systemNavigationBarDividerColor: Colors.transparent, // 设置导航栏分隔线颜色为透明
    ));
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        late ColorScheme lightColorScheme;
        late ColorScheme darkColorScheme;
        if (lightDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
        } else {
          logger.i("lightDynamic is null");
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedThemeColor,
            brightness: Brightness.light,
          );
        }
        if (darkDynamic != null) {
          darkColorScheme = darkDynamic.harmonized();
        } else {
          logger.i("darkDynamic is null");
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: darkSeedThemeColor,
            brightness: Brightness.dark,
          );
        }
        const textTheme = TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Ubuntu'),
          bodySmall: TextStyle(fontFamily: 'Ubuntu'),
          bodyLarge: TextStyle(fontFamily: 'Ubuntu'),
          bodyMedium: TextStyle(fontFamily: 'Ubuntu'),
          labelSmall: TextStyle(fontFamily: 'Ubuntu'),
          labelLarge: TextStyle(fontFamily: 'Ubuntu'),
          labelMedium: TextStyle(fontFamily: 'Ubuntu'),
        );
        const bottomNavigationBarTheme = BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontFamily: 'Ubuntu'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Ubuntu'),
        );
        var lightTheme = ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
          textTheme: textTheme,
          bottomNavigationBarTheme: bottomNavigationBarTheme,
        );
        var darkTheme = ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          textTheme: textTheme,
          bottomNavigationBarTheme: bottomNavigationBarTheme,
        );

        return AdaptiveTheme(
            light: lightTheme,
            dark: darkTheme,
            initial: AdaptiveThemeMode.system,
            builder: (theme, darkTheme) {
              return MaterialApp(
                title: _title,
                debugShowCheckedModeBanner: false,
                home: const MyHomePage(title: _title),
                theme: theme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
    }
    return Consumer<StateModel>(
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
            Consumer<SettingModel>(
              builder: (context, model, child) {
                return SyncBody(
                  localFolder: model.localFolder,
                );
              },
            ),
            const SettingBody(),
          ],
        ),
        bottomNavigationBar: model.isSelectionMode
            ? null
            : NavigationBar(
                onDestinationSelected: _onItemTapped,
                selectedIndex: _selectedIndex,
                destinations: <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.phone_android,
                        color: Theme.of(context).iconTheme.color),
                    label: AppLocalizations.of(context).local,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud,
                        color: Theme.of(context).iconTheme.color),
                    label: AppLocalizations.of(context).cloud,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud_sync,
                        color: Theme.of(context).iconTheme.color),
                    label: AppLocalizations.of(context).sync,
                  ),
                ],
              ),
      ),
    );
  }
}

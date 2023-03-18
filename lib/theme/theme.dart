import 'package:flutter/material.dart';

Color backgroundColor = const Color(0xFFf6f8fe);

ThemeData customLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  primaryColor: Colors.indigo,
  hintColor: Colors.indigo,
  fontFamily: 'WorkSans',
  scaffoldBackgroundColor: backgroundColor,
  snackBarTheme: const SnackBarThemeData(
    contentTextStyle: TextStyle(fontFamily: 'WorkSans'),
  ),
  appBarTheme: AppBarTheme(
    titleTextStyle: const TextStyle(
      fontFamily: 'WorkSans',
      color: Colors.indigo,
    ),
    backgroundColor: backgroundColor,
    foregroundColor: Colors.indigo,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: backgroundColor,
    selectedItemColor: Colors.indigo,
  ),
  cardTheme: const CardTheme(
    surfaceTintColor: Colors.transparent,
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: backgroundColor,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.indigo,
    ),
    displayMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    displaySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.indigo,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
    ),
  ),
  chipTheme: const ChipThemeData(
    side: BorderSide.none,
  ),
  popupMenuTheme: const PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    surfaceTintColor: Colors.transparent,
    color: Colors.white,
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: Colors.indigo.withOpacity(0.15),
    iconTheme: MaterialStatePropertyAll(
      IconThemeData(color: Colors.grey[700]),
    ),
    backgroundColor: backgroundColor,
    surfaceTintColor: Colors.transparent,
    labelTextStyle: MaterialStatePropertyAll(
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    ),
  ),
);

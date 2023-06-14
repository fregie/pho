import 'package:flutter/material.dart';

const textThemeLight = TextTheme(
  headlineMedium:
      TextStyle(fontFamily: 'Ubuntu', color: Color.fromARGB(255, 0, 44, 36)),
  bodySmall: TextStyle(fontFamily: 'Ubuntu'),
  bodyLarge: TextStyle(fontFamily: 'Ubuntu'),
  bodyMedium: TextStyle(fontFamily: 'Ubuntu'),
  labelSmall: TextStyle(fontFamily: 'Ubuntu'),
  labelLarge: TextStyle(fontFamily: 'Ubuntu'),
  labelMedium: TextStyle(fontFamily: 'Ubuntu'),
);

const textThemeDark = TextTheme(
  headlineMedium: TextStyle(
      fontFamily: 'Ubuntu', color: Color.fromARGB(255, 172, 196, 192)),
  bodySmall: TextStyle(fontFamily: 'Ubuntu'),
  bodyLarge: TextStyle(fontFamily: 'Ubuntu'),
  bodyMedium: TextStyle(fontFamily: 'Ubuntu'),
  labelSmall: TextStyle(fontFamily: 'Ubuntu'),
  labelLarge: TextStyle(fontFamily: 'Ubuntu'),
  labelMedium: TextStyle(fontFamily: 'Ubuntu'),
);

const navigationBarThemeLight = NavigationBarThemeData(
  height: 67,
  iconTheme: MaterialStatePropertyAll(
    IconThemeData(color: Color.fromARGB(255, 0, 44, 36)),
  ),
  labelTextStyle: MaterialStatePropertyAll(
    TextStyle(
      fontFamily: 'Ubuntu',
      fontSize: 16,
      color: Color.fromARGB(255, 0, 44, 36),
      height: 1,
    ),
  ),
);

const navigationBarThemeDark = NavigationBarThemeData(
  height: 67,
  iconTheme: MaterialStatePropertyAll(
    IconThemeData(color: Color.fromARGB(255, 172, 196, 192)),
  ),
  labelTextStyle: MaterialStatePropertyAll(
    TextStyle(
      fontFamily: 'Ubuntu',
      fontSize: 16,
      color: Color.fromARGB(255, 172, 196, 192),
      height: 1,
    ),
  ),
);

const iconThemeLight = IconThemeData(color: Color.fromARGB(255, 0, 44, 36));
const iconThemeDark = IconThemeData(color: Color.fromARGB(255, 172, 196, 192));

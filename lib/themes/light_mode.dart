import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color(0xFF1E1F47),
    primary: Color(0xFFFCFD07),
    secondary: Color(0xFF15549B),
    tertiary: Color(0xFFFDFEFD),
    inversePrimary: Color(0xFFE03D07),
  ),
  snackBarTheme: const SnackBarThemeData(
  actionTextColor: Color(0xFFFDFEFD),
  backgroundColor: Color(0xFF15549B),
  contentTextStyle: TextStyle(color: Color(0xFFFCFD07)),
  elevation: 20
  ),
);
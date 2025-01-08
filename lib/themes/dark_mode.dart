import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
  snackBarTheme: SnackBarThemeData(
  actionTextColor: Colors.grey.shade800,
  backgroundColor: Colors.grey.shade700,
  contentTextStyle: TextStyle(color: Colors.grey.shade400),
  elevation: 20
  ),
);
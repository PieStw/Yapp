import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.deepPurple,
    onPrimary: Colors.grey[50]!,
    secondary: Colors.deepPurple[400]!,
    onSecondary: Colors.grey[50]!,
    tertiary: Colors.deepPurple[200]!,
    onTertiary: Colors.grey[50]!,
    surface: Colors.grey[50]!,
    onSurface: Colors.black,

    error: Colors.red,
    onError: Colors.white,
    inversePrimary: Colors.deepPurple[700]!,
  ),
);
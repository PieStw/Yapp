import 'package:flutter/material.dart';
import 'package:yapp/themes/dark_mode.dart';
import 'package:yapp/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkTheme;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
  }

  void toggleTheme() {
    if (_themeData == darkTheme) {
      _themeData = lightTheme;
    } else {
      _themeData = darkTheme;
    }
    notifyListeners();
  }
}


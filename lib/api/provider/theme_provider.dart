import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  ThemeMode? themeMode;
  String? themeString;

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    themeString = prefs.getString('themeMode') ?? "";
    if (themeString == "") {
      themeMode = ThemeMode.system;
    }
    else if (themeString == "system") {
      themeMode = ThemeMode.system;
    }
    else if (themeString == "light") {
      themeMode = ThemeMode.light;
    }
    else if (themeString == "dark") {
      themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void enableSystemTheme() async {
    themeMode = ThemeMode.system;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "system");
    notifyListeners();
  }

  void enableLightTheme() async {
    themeMode = ThemeMode.light;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "light");
    notifyListeners();
  }

  void enableDarkTheme() async {
    themeMode = ThemeMode.dark;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "dark");
    notifyListeners();
  }
}
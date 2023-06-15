import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enumerate.dart';

enum MeasurementSetting{
  ///meters
  metricSystem,

  ///miles
  imperialSystem,
}

class SettingProvider with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  MeasurementSetting? currentMeasurementSetting;
  String? measurementString;

  ThemeMode? currentThemeMode;
  String? themeString;

  SheetList? currentSheetList;

  SettingProvider() {
    init();
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///Measurement
    measurementString = prefs.getString('measurement') ?? "";

    if (measurementString == "metricSystem") {
      currentMeasurementSetting = MeasurementSetting.metricSystem;
    }
    else if (measurementString == "imperialSystem") {
      currentMeasurementSetting = MeasurementSetting.imperialSystem;
    }else{
      currentMeasurementSetting = MeasurementSetting.metricSystem;
    }

    ///Theme
    themeString = prefs.getString('themeMode') ?? "";
    if (themeString == "system") {
      currentThemeMode = ThemeMode.system;
    }
    else if (themeString == "light") {
      currentThemeMode = ThemeMode.light;
    }
    else if (themeString == "dark") {
      currentThemeMode = ThemeMode.dark;
    }else{
      currentThemeMode = ThemeMode.system;
    }

    notifyListeners();
  }


  ///Measurement
  void changeMeasurement(MeasurementSetting measurementSetting) async {
    currentMeasurementSetting = measurementSetting;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('measurement', measurementSetting.toString().split('.').last);
    notifyListeners();
  }

  convertMeterToMiles(double? meterDate){
    double milesData = 0;
    milesData = (meterDate ?? 0)*0.000621371;

    return milesData;
  }

  convertMeterToMilesInString(double? meterDate){
    double milesData = 0;
    milesData = (meterDate ?? 0)*0.000621371;

    return milesData.toStringAsFixed(2);
  }



  ///Theme
  bool isDarkMode(context){
    var darkMode = MediaQuery.of(context).platformBrightness;
    if(darkMode == Brightness.dark){
      return true;
    }else if(darkMode == Brightness.light)
    {
      return false;
    }
    else {
      return false;
    }
  }

  void enableSystemTheme() async {
    currentThemeMode = ThemeMode.system;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "system");
    notifyListeners();
  }

  void enableLightTheme() async {
    currentThemeMode = ThemeMode.light;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "light");
    notifyListeners();
  }

  void enableDarkTheme() async {
    currentThemeMode = ThemeMode.dark;
    SharedPreferences prefs = await _prefs;
    await prefs.setString('themeMode', "dark");
    notifyListeners();
  }

  changeSheetElement(SheetList sheetList){
    currentSheetList = sheetList;
    notifyListeners();
  }

}
  import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/evie_double_button_dialog.dart';
import '../enumerate.dart';
import '../fonts.dart';
import '../function.dart';

class SettingProvider with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  MeasurementSetting? currentMeasurementSetting;
  String? measurementString;

  ThemeMode? currentThemeMode = ThemeMode.light;
  String? themeString;

  SheetList? currentSheetList;
  String? stringPassing;
  bool enableDragDismiss = true;

  PackageInfo? packageInfo;

  StreamSubscription? currentAppSubscription;
  String? minRequiredVersion;
  String? currentVersion;

  SettingProvider() {
    init();
  }

  Future<void> init() async {
    checkAppVersion();
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
    // themeString = prefs.getString('themeMode') ?? "";
    // if (themeString == "system") {
    //   currentThemeMode = ThemeMode.system;
    // }
    // else if (themeString == "light") {
    //   currentThemeMode = ThemeMode.light;
    // }
    // else if (themeString == "dark") {
    //   currentThemeMode = ThemeMode.dark;
    // }
    // else{
    //   currentThemeMode = ThemeMode.system;
    // }
    notifyListeners();
  }

  checkAppVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo?.version;
    await currentAppSubscription?.cancel();
    try {
      currentAppSubscription = FirebaseFirestore.instance
          .collection('releases')
          .doc('app')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.data() != null) {
          Map<String, dynamic>? obj = snapshot.data();
          if (obj != null) {
            if (Platform.isIOS) {
              minRequiredVersion = obj['iosMinVersion'];
            }
            else if (Platform.isAndroid) {
              minRequiredVersion = obj['andMinVersion'];
            }
            if (minRequiredVersion != null && currentVersion != null) {
              Version minVersion = Version.parse(minRequiredVersion!);
              Version curVersion = Version.parse(currentVersion!);
              int hello = curVersion.compareTo(minVersion);
              if (curVersion!.compareTo(minVersion) < 0) {
                // Show a dialog or take appropriate action for an update required
                SmartDialog.show(
                  widget: EvieTwoButtonDialog(
                      title: Text(obj['title'],
                        style:EvieTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      childContent: Text(obj['desc'],
                        textAlign: TextAlign.center,
                        style: EvieTextStyles.body18,),
                      svgpicture: SvgPicture.asset(
                        "assets/images/app_update.svg",
                      ),
                      upContent: obj['upContent'],
                      downContent: obj['downContent'],
                      customButtonDown: obj['isForce'] ? Container() : null,
                      //downContent: "Maybe Later",
                      onPressedUp: () async {
                        if (Platform.isAndroid) {
                          final url = obj['andLink'];
                          final Uri _url = Uri.parse(url);
                          launch(_url);
                        }
                        else if (Platform.isIOS) {
                          final url = obj['iosLink'];
                          final Uri _url = Uri.parse(url);
                          launch(_url);
                        }
                        //SmartDialog.dismiss();
                      },
                      onPressedDown: () {
                        SmartDialog.dismiss();
                      }),
                  backDismiss: !obj['isForce'],
                  clickBgDismissTemp: !obj['isForce'],
                  tag: 'app_update'
                );
              }
              else {
                int hello = curVersion.compareTo(minVersion);
                SmartDialog.dismiss(tag: 'app_update');
              }
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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

  convertKiloMeterToMilesInString(double? meterDate){
    double milesData = 0;
    milesData = (meterDate ?? 0) * 0.621371;

    return milesData.toStringAsFixed(2);
  }


  ///Theme
  bool isDarkMode(context){
    var darkMode = MediaQuery.of(context).platformBrightness;
    if(darkMode == Brightness.dark){
      return false;
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

  changeSheetElement(SheetList sheetList,  [String? stringPassing]){
    this.stringPassing = stringPassing;
    currentSheetList = sheetList;
    notifyListeners();
  }

  changeEnableDragAndDismiss(bool enabled){
    enableDragDismiss = enabled;
    notifyListeners();
  }

}
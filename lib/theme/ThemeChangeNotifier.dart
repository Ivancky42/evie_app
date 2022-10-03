import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeChangeNotifier with ChangeNotifier {

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
}
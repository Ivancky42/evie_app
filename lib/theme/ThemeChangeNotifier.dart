import 'package:evie_test/theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeChangeNotifier with ChangeNotifier {

  ThemeData? currentTheme;

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

  setSystemMode(){


    notifyListeners();
  }

  setLightMode(){

    notifyListeners();
  }

  setDarkMode(){

    notifyListeners();
  }


}
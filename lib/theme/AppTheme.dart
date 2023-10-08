import 'package:flutter/material.dart';

import '../api/colours.dart';

class AppTheme{

  AppTheme._();

  ///Light theme setting
  static final ThemeData lightTheme = ThemeData(
    //Default font setting for the application is Raleway
    //Font are store in assets/fonts
    fontFamily: 'Avenir',
    primaryColor: EvieColors.primaryColor,

    //Default font colour
    textTheme: const TextTheme(
      //This is for text field user input setting
      subtitle1: TextStyle(color: Colors.black),
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),

    //Hint text colour
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.black),
    ),


    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFFECEDEB),

    //suggest grey color: 0xFFc5c6d0

    //Default App bar theme setting
    appBarTheme: const AppBarTheme(
      backgroundColor: EvieColors.transparent, elevation: 0.0,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
    ),

    //Bottom app bar colours
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xffffffff),
    ),

    //Bottom navigation bar theme setting
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: EvieColors.transparent, elevation: 0.0,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
    ),

    //Bottom drawer
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: EvieColors.transparent,
    ),

      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xffF2F2F2).withOpacity(0.9),
      ),

  //  brightness: Brightness.dark,
  );





  ///Dark theme setting
  static final ThemeData darkTheme = ThemeData(
    //Default font setting for the application is Raleway
    //Font are store in assets/fonts
    fontFamily: 'Avenir',

    //Default font colour
    textTheme: const TextTheme(
      //This is for text field user input setting
      subtitle1: TextStyle(color: Colors.white),
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),

    //Hint text colour
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white),
    ),
    
    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFF252526),

    //Default App bar theme setting
    appBarTheme: const AppBarTheme(
      backgroundColor: EvieColors.transparent, elevation: 0.0,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    //Bottom app bar colours
    bottomAppBarTheme: const BottomAppBarTheme(
      color: EvieColors.transparent,
    ),

    //Bottom navigation bar theme setting
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: EvieColors.transparent, elevation: 0.0,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
    ),

    //Bottom drawer
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xff0F191D),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xff1E1E1E).withOpacity(0.85),
    ),

  //  brightness: Brightness.light,
  );

}
import 'package:flutter/material.dart';

class AppTheme{

  AppTheme._();

  ///Light theme setting
  static final ThemeData lightTheme = ThemeData(
    //Default font setting for the application is Raleway
    //Font are store in assets/fonts
    fontFamily: 'Raleway',

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

    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFFD7E9EF),

    //suggest grey color: 0xFFc5c6d0

    //Default App bar theme setting
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0.0,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
    ),

    //Bottom navigation bar theme setting
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent, elevation: 0.0,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
    ),

  );






  ///Dark theme setting
  static final ThemeData darkTheme = ThemeData(
    //Default font setting for the application is Raleway
    //Font are store in assets/fonts
    fontFamily: 'Raleway',

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
    
    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFF0F191D),

    //Default App bar theme setting
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0.0,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    //Bottom navigation bar theme setting
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent, elevation: 0.0,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
    ),

  );

}
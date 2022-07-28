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
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),

    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFFD7E9EF),
  );

  ///Dark theme setting
  static final ThemeData darkTheme = ThemeData(
    //Default font setting for the application is Raleway
    //Font are store in assets/fonts
    fontFamily: 'Raleway',

    //Default font colour
    textTheme: const TextTheme(
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    
    //Default background colour for application
    scaffoldBackgroundColor: const Color(0xFF0F191D),
  );

}
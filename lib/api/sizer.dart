import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

extension CustomSizer on num {

  double get ch => Platform.isAndroid ? this / 844 * 100.h : this / 928.4 * 100.h;

  ///Calculate for bottom navigation bar padding size.
  double get sh => Platform.isAndroid ? this / 844 * 100.h : this / 600 * 100.h;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.cw -> will take 20% of the screen's width
  double get cw => Platform.isAndroid ? this / 390 * 100.w : this / 429 * 100.w;

  // double get ch => this / 928.4 * 100.h;
  //
  // /// Calculates the width depending on the device's screen size
  // ///
  // /// Eg: 20.cw -> will take 20% of the screen's width
  // double get cw => this / 429 * 100.w;

  //double get sp => this * 100.h / 811.6;
  //double get sp => this * 100.h / 900.6;
  double get sp => this * 100.h / 855.8;

  ///double get mp => this * 100.h / 27000;

  //double get mp => (this / 110)  * 100.h / 100.w;
  double get mp => this * 7.66 /((300 / 928.4 * 100.h) + 100);

  double get width => this * 100.w;
  double get height => this * 100.h;
}

getScreenHeight(){
  return Platform.isAndroid ? 100.h / 844 * 100.h : 100.h / 928.4 * 100.h;
}

getScreenWidth(){
  return Platform.isAndroid ? 100.w / 390 * 100.w : 100.w / 429 * 100.w;
}
///MediaQuery.of(context).size.height,
///// Full screen width and height
// double width = MediaQuery.of(context).size.width;
// double height = MediaQuery.of(context).size.height;
//
// // Height (without SafeArea)
// var padding = MediaQuery.of(context).viewPadding;
// double height1 = height - padding.top - padding.bottom;
//
// // Height (without status bar)
// double height2 = height - padding.top;
//
// // Height (without status and toolbar)
// double height3 = height - padding.top - kToolbarHeight;

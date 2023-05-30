import 'dart:io' show Platform;

import 'package:sizer/sizer.dart';

extension Sizer on num {
  double get h => Platform.isAndroid ? this / 844 * SizerUtil.height : this / 928.4 * SizerUtil.height;

  ///Calculate for bottom navigation bar padding size.
  double get sh => Platform.isAndroid ? this / 844 * SizerUtil.height : this / 600 * SizerUtil.height;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => Platform.isAndroid ? this / 390 *  SizerUtil.width : this / 429 *  SizerUtil.width;

  // double get h => this / 928.4 * SizerUtil.height;
  //
  // /// Calculates the width depending on the device's screen size
  // ///
  // /// Eg: 20.w -> will take 20% of the screen's width
  // double get w => this / 429 *  SizerUtil.width;

  //double get sp => this * SizerUtil.height / 811.6;
  //double get sp => this * SizerUtil.height / 900.6;
  double get sp => this * SizerUtil.height / 855.8;
}



getScreenHeight(){
  return Platform.isAndroid ? SizerUtil.height / 844 * SizerUtil.height : SizerUtil.height / 928.4 * SizerUtil.height;
}

getScreenWidth(){
  return Platform.isAndroid ? SizerUtil.width / 390 *  SizerUtil.width : SizerUtil.width / 429 *  SizerUtil.width;
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

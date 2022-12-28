import 'dart:io' show Platform;

import 'package:sizer/sizer.dart';

extension Sizer on num {
  double get h => Platform.isAndroid ? this / 844 * SizerUtil.height : this / 928.4 * SizerUtil.height;

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
  double get sp => this * SizerUtil.height / 900;
}
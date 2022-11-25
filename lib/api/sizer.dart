import 'package:sizer/sizer.dart';

extension Sizer on num {
  double get h => this / 844 * SizerUtil.height;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => this / 390 *  SizerUtil.width;

  double get sp => this * SizerUtil.height / 811.6;
}
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

class EvieDivider extends StatelessWidget {
  final double? thickness;
  final double? height;
  final Color? color;

  const EvieDivider({super.key, this.thickness, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness ?? 0.1.h,
      color: color ?? EvieColors.darkWhite,
      height: height ?? 0,

    );
  }
}



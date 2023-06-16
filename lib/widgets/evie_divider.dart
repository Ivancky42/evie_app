import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

class EvieDivider extends StatelessWidget {
  final double? thickness;
  final double? height;
  final Color? color;

  const EvieDivider({Key? key, this.thickness, this.height, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness ?? 0.1.h,
      color: color ?? EvieColors.darkWhite,
      height: height ?? 0,
    );
  }
}



import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EvieDivider extends StatelessWidget {
  final double? thickness;
  final double? height;
  const EvieDivider({Key? key, this.thickness, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness ?? 0.1.h,
      color: const Color(0xff8E8E8E),
      height: height ?? 0,
    );
  }
}


import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

class EvieCard2 extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPress;
  final Color? color;
  final Decoration? decoration;

  const EvieCard2({
    super.key,
    this.child,
    this.onPress,
    this.color,
    this.decoration,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //color: Colors.yellow,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 0),
              child: Text(
                'EV-Secure',
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
              ),
            ),
            child!,
          ],
        ),
        // decoration: decoration ?? BoxDecoration(
        //   color: color ?? EvieColors.dividerWhite,
        //   borderRadius: BorderRadius.circular(10.w),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
        //       offset: Offset(0, 8), // X and Y offset
        //       blurRadius: 16, // Blur radius
        //       spreadRadius: 0, // Spread radius
        //     ),
        //   ],
        // ),
      ),
    );
  }
}



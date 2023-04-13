import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

class EvieCard extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final String? title;
  final VoidCallback? onPress;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;

  const EvieCard({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.title,
    this.onPress,
    this.color,
    this.decoration,
    this.padding,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPress,
      child: Container(
        width: width ?? 168.w,
        height: height ?? 168.h,

        child: title != null ?
        Padding(
          padding: padding ?? EdgeInsets.only(left: 16.w, top: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title!,
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
              child ?? Container(),
            ],
          ),
        ) :
        child,

        decoration: decoration ?? BoxDecoration(
          color: color ?? EvieColors.dividerWhite,
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0.2.w,
              blurRadius: 3.w,
            ),
          ],
        ),
      ),
    );
  }
}



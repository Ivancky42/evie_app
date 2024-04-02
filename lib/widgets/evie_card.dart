import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  final bool? showInfo;
  final VoidCallback? onInfoPress;

  const EvieCard({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.title,
    this.onPress,
    this.color,
    this.decoration,
    this.padding, this.showInfo, this.onInfoPress,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Container(
        width: width ?? 168.w,
        height: height ?? 168.h,
        child: title != null ?
        Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: showInfo != null ?
              GestureDetector(
                onTap: onInfoPress,
                child: Container(
                    //color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 16.h),
                      child: SvgPicture.asset("assets/buttons/info_grey.svg",),
                    )
                ),
              ) :
              Container(),
            ),
            Padding(
              padding: padding ?? EdgeInsets.only(left: 16.w, top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!,textScaleFactor: 1, style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                  child ?? Container(),
                ],
              ),
            )
          ],
        ) :
        child,
        decoration: decoration ?? BoxDecoration(
          color: color ?? EvieColors.dividerWhite,
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
              offset: Offset(0, 8), // X and Y offset
              blurRadius: 16, // Blur radius
              spreadRadius: 0, // Spread radius
            ),
          ],
        ),
      ),
    );
  }
}

class EvieCard3 extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final String? title;
  final VoidCallback? onPress;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final bool? showInfo;
  final VoidCallback? onInfoPress;

  const EvieCard3({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.title,
    this.onPress,
    this.color,
    this.decoration,
    this.padding, this.showInfo, this.onInfoPress,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Container(
        width: width ?? 168.w,
        height: height ?? 168.h,
        child: title != null ?
        Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: showInfo != null ?
              GestureDetector(
                onTap: onInfoPress,
                child: Container(
                  //color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 16.h),
                      child: SvgPicture.asset("assets/buttons/info_grey.svg",),
                    )
                ),
              ) :
              Container(),
            ),
            Padding(
              padding: padding ?? EdgeInsets.only(left: 16.w, top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!, style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                  child ?? Container(),
                ],
              ),
            )
          ],
        ) :
        child,
        decoration: decoration ?? BoxDecoration(
          color: Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(122, 122, 121, 0.45),
              offset: Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}



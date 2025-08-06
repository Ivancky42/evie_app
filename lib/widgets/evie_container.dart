import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class BikePageContainer extends StatelessWidget {
  final Widget? subtitle;
  final Widget? contents;
  final String? content;
  final VoidCallback onPress;
  final String trailingImage;

  const BikePageContainer({
    super.key,
    this.subtitle,
    this.contents,
    this.content,
    required this.onPress,
    required this.trailingImage,
  });

  @override
  Widget build(BuildContext context) {

    if(subtitle != null){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPress,
        child: SizedBox(
          height: 62.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    subtitle!,
                    content != null ? Text(
                      content!,
                      style: TextStyle(fontSize: 16.sp),
                    ) : contents ?? Container(),
                  ],
                ),
                SvgPicture.asset(
                  trailingImage,
                  height: 24.h,
                  width: 24.w,
                ),
              ],
            ),
          ),
        ),
      );
    }else{
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPress,
        child: SizedBox(
          height: 44.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                content != null ? Text(
                  content!,
                  style: TextStyle(fontSize: 16.sp),
                ) : contents ?? Container(),
                SvgPicture.asset(
                  trailingImage,
                  height: 24.h,
                  width: 24.w,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}


class PlanPageElementRow extends StatelessWidget {
  final String content;

  const PlanPageElementRow({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/tick.svg",
          height: 24.h,
          width: 24.w,
        ),

        SizedBox(width: 4.w,),
        Text(content, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Color(0xff383838)),)

      ],
    );
  }
}




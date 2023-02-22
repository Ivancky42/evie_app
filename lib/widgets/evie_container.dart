import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/ThemeChangeNotifier.dart';

class BikePageContainer extends StatelessWidget {
  final Widget? subtitle;
  final Widget? contents;
  final String? content;
  final VoidCallback onPress;
  final String trailingImage;

  const BikePageContainer({
    Key? key,
    this.subtitle,
    this.contents,
    this.content,
    required this.onPress,
    required this.trailingImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(subtitle != null){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPress,
        child: Container(
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
        child: Container(
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




import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../api/colours.dart';

class AccountPageContainer extends StatelessWidget {
  final String content;
  final VoidCallback onPress;
  final String trailingImage;

  const AccountPageContainer({
    super.key,
    required this.content,
    required this.onPress,
    required this.trailingImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPress,
      child: SizedBox(
        height: 54.h,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                content,
                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
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
  }
}

class AccountPageDivider extends StatelessWidget {
  final double? height;

  const AccountPageDivider({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Divider(
        thickness: 0.2.h,
        color: EvieColors.darkWhite,
        height: height ?? 0,
      ),
    );
  }
}



class EditProfileContainer extends StatelessWidget {
  final String subtitle;
  final String content;
  final VoidCallback? onPress;
  final String? trailingImage;

  const EditProfileContainer({
    super.key,
    required this.subtitle,
    required this.content,
    this.onPress,
    this.trailingImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 59.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Color(0xff5F6060)),
                ),
                // SizedBox(
                //   height: 2.h,
                // ),
                Text(
                  content,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
            if (trailingImage != null) ...{
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onPress,
                child: SvgPicture.asset(
                  trailingImage!,
                  height: 24.h,
                  width: 24.w,
                ),
              ),
            }
          ],
        ),
      ),
    );
  }
}



class ChangeImageContainer extends StatelessWidget {
  final VoidCallback onPress;
  final String image;
  final String content;

  const ChangeImageContainer({
    super.key,
    required this.onPress,
    required this.image,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.only(top: 0.h, bottom: 0.h, left: 16.h),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPress,
        child: SizedBox(
          height: 52.h,
          child:  Row(
            children: [
              SvgPicture.asset(image),
              SizedBox(width: 8.w,),
              Text(
                content,
                style: TextStyle(fontSize: 16.sp),
              )
            ],
          ),
        )
      ),
    );
  }
}
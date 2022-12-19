import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



///Double button dialog
class AccountPageContainer extends StatelessWidget {

  final String content;
  final VoidCallback onPress;
  final String trailingImage;

  const AccountPageContainer({
    Key? key,
    required this.content,
    required this.onPress,
    required this.trailingImage,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 44.h,
        child:Padding(
          padding:  EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(content, style: TextStyle(fontSize: 16.sp),),
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
    Key? key,

this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(thickness:0.1.h ,color: const Color(0xff8E8E8E),height: height ?? 0,);
  }
}
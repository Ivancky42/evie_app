import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';

import '../api/colours.dart';

///Cupertino switch widget
class EvieSwitch extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final String? title;
  final String? text;
  final bool value;
  final Color thumbColor;
  final Color? activeColor;
  final double? height;

  const EvieSwitch({
    super.key,
    required this.onChanged,
    this.title,
    this.text,
    required this.value,
    required this.thumbColor,
    this.activeColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: height ?? 54.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title != null && text != null ?
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontWeight: FontWeight.w400),
                ),

                Text(
                  text ?? "",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
              ],
            ),
          ) :
          title != null && text == null ?
          Text(
            title ?? "",
            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontWeight: FontWeight.w400),
          ) :
          Text(text ?? "", style: TextStyle(fontSize: 16.sp),),

          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: CupertinoSwitch(
              value: value,
              activeTrackColor:  activeColor ?? EvieColors.primaryColor,
              thumbColor: thumbColor,
              //trackColor: const Color(0xff6A51CA).withOpacity(0.5),
              inactiveTrackColor: EvieColors.lightGrayishCyan,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );

  }
}

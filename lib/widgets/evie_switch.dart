import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';
import 'evie_textform.dart';

///Cupertino switch widget
class EvieSwitch extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final String? title;
  final String text;
  final bool value;
  final Color thumbColor;
  final Color? activeColor;

  const EvieSwitch({
    Key? key,
    required this.onChanged,
    this.title,
    required this.text,
    required this.value,
    required this.thumbColor,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 54.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title != null
              ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontWeight: FontWeight.w400),
                ),

                Text(
                  text,
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
              ],
            ),
          )
              : Text(text, style: TextStyle(fontSize: 16.sp),),

          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: CupertinoSwitch(
              value: value,
              activeColor:  activeColor ?? EvieColors.primaryColor,
              thumbColor: thumbColor,
              trackColor: const Color(0xff6A51CA).withOpacity(0.5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );

  }
}

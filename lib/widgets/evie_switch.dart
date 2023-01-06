import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'evie_textform.dart';

///Cupertino switch widget
class EvieSwitch extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final String? title;
  final String text;
  final bool value;
  final Color thumbColor;

  const EvieSwitch({
    Key? key,
    required this.onChanged,
    this.title,
    required this.text,
    required this.value,
    required this.thumbColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        title != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? "",
              style: TextStyle(fontSize: 16.sp, color: Color(0xff252526)),
            ),
            Container(
              width: 290.w,
              child: Text(
                text,
                style: TextStyle(fontSize: 15.sp, color: Color(0xff5F6060)),
              ),
            ),
          ],
        )
        : Text(text, style: TextStyle(fontSize: 16.sp),),

    CupertinoSwitch(
    value: value,
    activeColor:  const Color(0xff6A51CA),
    thumbColor: thumbColor,
    trackColor: const Color(0xff6A51CA).withOpacity(0.5),
    onChanged: onChanged,
    ),
      ],
    );

  }
}

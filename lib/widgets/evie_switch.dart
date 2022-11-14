import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'evie_textform.dart';

///Cupertino switch widget
class EvieSwitch extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final String text;
  final bool value;
  final Color thumbColor;

  const EvieSwitch({
    Key? key,
    required this.onChanged,
    required this.text,
    required this.value,
    required this.thumbColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 12.sp),
        ),
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

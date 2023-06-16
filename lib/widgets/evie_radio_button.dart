import 'package:evie_bike/api/fonts.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/colours.dart';
import 'evie_textform.dart';

///Radio button
class EvieRadioButton extends StatelessWidget {
  final String? text;
  final int value;
  final int groupValue;
  final ValueChanged onChanged;


  const EvieRadioButton({
    Key? key,
    this.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text ?? "", style: EvieTextStyles.body18,),

        Radio(
        fillColor: MaterialStateColor.resolveWith(
        (states) => EvieColors.primaryColor),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        ),
      ],
    );


  }
}

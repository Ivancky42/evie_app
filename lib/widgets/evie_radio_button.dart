import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'evie_textform.dart';

///Radio button
class EvieRadioButton extends StatelessWidget {
  final String text;
  final bool value;
  final String groupValue;
  final ValueChanged onChanged;


  const EvieRadioButton({
    Key? key,
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Radio(
      fillColor: MaterialStateColor.resolveWith(
              (states) => Color(0xff00B6F1)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

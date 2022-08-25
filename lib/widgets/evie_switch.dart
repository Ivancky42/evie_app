import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return Stack(
      children: <Widget>[
        EvieButton_TextForm_Constant(
          width: 12,
          height: 12,
          hintText: text,
        ),
        Positioned(
          bottom: 10,
          right: 20,
          child: CupertinoSwitch(
            value: value,
            activeColor: Color(0xffffffff),
            thumbColor: thumbColor,
            trackColor: Color(0xffffffff),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

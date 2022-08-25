import 'package:flutter/material.dart';

///Cupertino switch widget
class EvieSlider extends StatelessWidget {
  final ValueChanged<double?> onChanged;
  final double value;
  final double max;
  final String label;


  const EvieSlider({
    Key? key,
    required this.onChanged,
    required this.value,
    required this.max,
    required this.label,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      max: 10,
      //divisions: 10,
      activeColor: Color(0xff00B6F1),
      inactiveColor: Color(0xffFFFFFF),
      thumbColor: Color(0xff00B6F1),
      label: label,
      onChanged: onChanged,
    );
  }


}
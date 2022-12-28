import 'package:flutter/material.dart';

import '../api/colours.dart';

///Cupertino switch widget
class EvieSlider extends StatelessWidget {
  final ValueChanged<double?> onChanged;
  final double value;
  final double max;
  final String label;
  final int? division;


  const EvieSlider({
    Key? key,
    required this.onChanged,
    required this.value,
    required this.max,
    required this.label,
    this.division,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(

      value: value,
      max: max,
      divisions: division,
      activeColor: EvieColors.PrimaryColor,
      inactiveColor: Color(0xffD4D4D4),
      thumbColor: Color(0xffFAFAFA),
      label: label,
      onChanged: onChanged,
    );
  }


}
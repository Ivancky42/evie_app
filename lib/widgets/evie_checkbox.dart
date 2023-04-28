import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';
import 'evie_textform.dart';

///Cupertino switch widget
class EvieCheckBox extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final bool value;

  const EvieCheckBox({
    Key? key,
    required this.onChanged,
    required this.value,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Checkbox(
      value: value,
      activeColor: EvieColors.primaryColor,
      fillColor:  MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return EvieColors.primaryColor; // color of the checkbox when it's checked
        } else {
          return Colors.green; // color of the checkbox when it's unchecked
        }
      },
      ),
      onChanged: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(width: 1.w, color:EvieColors.lightGrayishCyan),
      ),
    );


  }
}

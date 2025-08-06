import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

///Cupertino switch widget
class EvieCheckBox extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final bool value;

  const EvieCheckBox({
    super.key,
    required this.onChanged,
    required this.value,

  });


  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: Transform.scale(
        scale: 1.4,
        child: Checkbox(
          value: value,
          activeColor: EvieColors.primaryColor,
          fillColor:  WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return EvieColors.primaryColor; // color of the checkbox when it's checked
            } else {
              return EvieColors.lightGrayishCyan; // color of the checkbox when it's unchecked
            }
          },
          ),
          onChanged: onChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          side: WidgetStateBorderSide.resolveWith(
                (states) {
              if (states.contains(WidgetState.selected)) {
                return BorderSide(width: 1, color: EvieColors.primaryColor); // color of the checkbox when it's checked
              } else {
                return BorderSide(color: EvieColors.lightGrayishCyan); // color of the checkbox when it's unchecked
              }
            },
          ),
          visualDensity: VisualDensity.comfortable,
        ),
      ),
    );


  }
}

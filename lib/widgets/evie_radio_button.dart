import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
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
    return Container(
      height: 70.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text ?? "", style: EvieTextStyles.body18,),

          Transform.scale(
            scale: 1.4, // Adjust the scale factor as needed
            child: Radio(
              fillColor: MaterialStateColor.resolveWith(
                      (states) {
                    if (states.contains(MaterialState.selected)) {
                      return EvieColors.primaryColor; // color of the checkbox when it's checked
                    } else {
                      return EvieColors.lightGrayishCyan; // color of the checkbox when it's unchecked
                    }
                  }),
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              visualDensity: VisualDensity.compact,
            ),
          )
        ],
      ),
    );


  }
}

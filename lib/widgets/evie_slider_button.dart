import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:slider_button/slider_button.dart';

import '../api/colours.dart';
import 'evie_textform.dart';

class EvieSliderButton extends StatelessWidget {

  final Function action;
  final String text;
  final bool? dismissible;


  const EvieSliderButton({
    Key? key,

    required this.action,
    required this.text,
    this.dismissible,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderButton(

      dismissible: false,
      action: action,
      width: 300.w,
      label: Text(
        text,
        style: TextStyle(
            color: EvieColors.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp),
      ),
      alignLabel: Alignment(0.2.w,0),
      buttonColor: EvieColors.primaryColor,
      shimmer: false,
      icon:  SvgPicture.asset(
        "assets/buttons/arrow_slider.svg",
        height: 64.h,
        width: 64.w,
      ),


    );

  }
}

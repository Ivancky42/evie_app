// import 'package:evie_test/api/sizer.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:slider_button/slider_button.dart';
//
// import '../api/colours.dart';
// import 'evie_textform.dart';
//
// class EvieSliderButton extends StatelessWidget {
//
//   final Function action;
//   final String text;
//   final bool? dismissible;
//   final bool? disable;
//   final Color? backgroundColor;
//
//   const EvieSliderButton({
//     Key? key,
//
//     required this.action,
//     required this.text,
//     this.dismissible,
//     this.disable,
//     this.backgroundColor,
//
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SliderButton(
//       dismissible: dismissible ?? false,
//       disable: disable ?? false,
//       action: action,
//       width: double.infinity,
//       backgroundColor: backgroundColor ?? const Color(0xffe0e0e0),
//       label: Text(
//         text,
//         style: TextStyle(
//             color: EvieColors.primaryColor,
//             fontWeight: FontWeight.w700,
//             fontSize: 20.sp),
//       ),
//       alignLabel: Alignment(0.2.w,0),
//       buttonColor: EvieColors.primaryColor,
//       shimmer: true,
//       baseColor: EvieColors.primaryColor,
//       highlightedColor: Colors.white,
//       icon:  SvgPicture.asset(
//         "assets/buttons/arrow_slider.svg",
//         height: 64.h,
//         width: 64.w,
//       ),
//       dismissThresholds: 4,
//     );
//
//   }
// }

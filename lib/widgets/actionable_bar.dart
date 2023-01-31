import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';


import '../api/colours.dart';

///Button Widget
class EvieActionableBar extends StatelessWidget {

  final String title;
  final String text;
  final Widget buttonLeft;
  final Widget buttonRight;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieActionableBar({
    Key? key,
    required this.title,
    required this.text,
    required this.buttonLeft,
    required this.buttonRight,
    this.width,
    this.height,
    this.backgroundColor,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124.h,
            color: backgroundColor ?? EvieColors.grayishWhite,
            child: Padding(
              padding: EdgeInsets.only(left:16.w, right: 17.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.mediumLightBlack),),
                  Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: EvieColors.darkGrayishCyan),),
                     Row(
                       children: [
                         Expanded(
                           child: Container(
                               height: 36.h,
                               child: buttonLeft),
                         ),

                         SizedBox(width: 8.w,),

                         Expanded(
                           child: Container(
                               height: 36.h,
                               child: buttonRight),
                         ),
                            ],
                          ),
          ],
        ),
      ),
    );
    // return Padding(
    //   padding: EdgeInsets.only(left:16.w, right: 17.w),
    //   child: Container(
    //       width: width,
    //       height: height,
    //       color: backgroundColor ?? EvieColors.grayishWhite,
    //       child: Column(
    //         children: [
    //           Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.mediumLightBlack),),
    //           Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: EvieColors.darkGrayishCyan),),
    //           Expanded(
    //             child: Row(
    //               children: [
    //                 buttonLeft,
    //                 SizedBox(width: 19.5.w,),
    //                 buttonRight,
    //               ],
    //             ),
    //           ),
    //         ],
    //       )
    //   ),
    // );
  }
}

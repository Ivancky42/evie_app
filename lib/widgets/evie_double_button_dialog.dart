import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../api/fonts.dart';
import 'evie_button.dart';


///Double button dialog
class EvieDoubleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final Widget childContent;
  final String leftContent;
  final String rightContent;
  final VoidCallback onPressedLeft;
  final VoidCallback onPressedRight;

  const EvieDoubleButtonDialog({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.childContent,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

      return Dialog(
          insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0.0,
          backgroundColor: EvieColors.grayishWhite,
          child: Container(
            padding:  EdgeInsets.only(
              left: 17.w,
              right: 17.w,
              top: 16.w,
                bottom: 16.w
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Padding(
                  padding:  EdgeInsets.only(bottom: 8.h),
                  child: Text(title, style:EvieTextStyles.h2,),
                ),
                Padding(
                  padding:  EdgeInsets.only(bottom: 11.h),
                  child: Divider(
                    thickness: 0.5.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                ),

                SizedBox(height: 8.h,),

                childContent,

                Padding(
                  padding: EdgeInsets.only(top: 9.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:  Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: EvieButton_ReversedColor(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              leftContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                            ),
                            onPressed: onPressedLeft,
                          ),
                        ),
                      ),

                      Expanded(
                        child:
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            rightContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedRight
                        ),
                      ),
      ),
                    ],
                  ),
                )

              ],
            ),
          )
      );
    }
}




///Cupertino for system dialog usage only
///Double cupertino button dialog
class EvieDoubleButtonDialogCupertino extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String content;
  final Widget? image;
  final String leftContent;
  final String rightContent;
  final VoidCallback onPressedLeft;
  final VoidCallback onPressedRight;

  const EvieDoubleButtonDialogCupertino({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.content,
    this.image,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return  CupertinoAlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
        ),
      ),

      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          onPressed: onPressedLeft,
          child: Text(
            leftContent,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          onPressed: onPressedRight,
          child: Text(
            rightContent,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],


    );
  }
}


///Double button dialog
class EvieDoubleButtonDialogFilter extends StatelessWidget{
  // final String buttonNumber;
  final Widget title;
  final Widget childContent;
  final String leftContent;
  final String rightContent;
  final VoidCallback onPressedLeft;
  final VoidCallback onPressedRight;

  const EvieDoubleButtonDialogFilter({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.childContent,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dialog(
        insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite,
        child: Container(
          padding:  EdgeInsets.only(
              left: 17.w,
              right: 17.w,
              top: 16.w,
              bottom: 16.w
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding:  EdgeInsets.only(bottom: 8.h),
                child: title,
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 11.h),
                child: Divider(
                  thickness: 0.5.h,
                  color: EvieColors.darkWhite,
                  height: 0,
                ),
              ),

              SizedBox(height: 8.h,),

              childContent,

              Padding(
                padding: EdgeInsets.only(top: 9.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:  Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            leftContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
                          onPressed: onPressedLeft,
                        ),
                      ),
                    ),

                    Expanded(
                      child:
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: EvieButton(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              rightContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                            onPressed: onPressedRight
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        )
    );
  }
}

// ///Single button dialog
// ///V made it
// class EvieTwoButtonDialog extends StatelessWidget{
//   final String title;
//   final String? content;
//   final SvgPicture? svgpicture;
//   final Widget? widget;
//   final String middleContent;
//   final VoidCallback onPressedMiddle;
//
//   const EvieTwoButtonDialog({
//     Key? key,
//     required this.title,
//     this.content,
//     this.widget,
//     this.svgpicture,
//     required this.middleContent,
//     required this.onPressedMiddle
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//         insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         elevation: 0.0,
//         backgroundColor: EvieColors.grayishWhite,
//         child: Container(
//           padding:  EdgeInsets.only(
//               left: 17.w,
//               right: 17.w,
//               top: 16.w,
//               bottom: 16.w
//           ),
//
//           child: Column(
//             //crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               Padding(
//                 padding: EdgeInsets.only(top: 32.h),
//                 child: SvgPicture.asset(
//                   "assets/images/people_search.svg",
//                   height: 150.h,
//                   width: 239.w,),
//               ),
//
//               Container(
//                 width: 325.w,
//                 child: Padding(
//                   padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
//                   child: Text(title,
//                     style:EvieTextStyles.h2,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//
//               content != null? Container(
//                 width: 326.w,
//                 child: Text(
//                   content ?? "" ,
//                   textAlign: TextAlign.center,
//                   style: EvieTextStyles.body18,
//                 ),
//               ) : Container(),
//
//               widget != null ? widget! : SizedBox(),
//
//               Padding(
//                 padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child:
//                       EvieButton(
//                           width: double.infinity,
//                           height: 48.h,
//                           child: Text(
//                             middleContent,
//                             style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
//                           ),
//                           onPressed: onPressedMiddle
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         )
//     );
//
//   }
// }

///Double button dialog
///V MADE IT
class EvieTwoButtonDialog extends StatelessWidget{
  final Widget? title;
  final bool? havePic;
  final Widget childContent;
  final SvgPicture? svgpicture;
  final String? upContent;
  final String? downContent;
  final VoidCallback? onPressedDown;
  final VoidCallback? onPressedUp;
  final Widget? customButtonUp;
  final Widget? customButtonDown;


  const EvieTwoButtonDialog({
    Key? key,
    this.title,
    this.havePic,
    required this.childContent,
    this.svgpicture,
    this.upContent,
    this.downContent,
    this.onPressedDown,
    this.onPressedUp,
    this.customButtonUp,
    this.customButtonDown,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dialog(
        insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite2,
        child: Container(
          padding:  EdgeInsets.only(
              left: 17.w,
              right: 17.w,
              top: 16.w,
              bottom: 16.w
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: havePic == false ? Container() : svgpicture == null? Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child: SvgPicture.asset(
                      "assets/images/people_search.svg",
                      height: 173.h,
                      width: 239.w,
                    ),
                  ),
                ): Padding(
                  padding: EdgeInsets.only(top: 32.h),
                  child: svgpicture!,
                )
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                  child: title,
                ),
              ),

              Container(child: childContent),

              Padding(
                padding: EdgeInsets.only(top: 37.h),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(

                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: customButtonUp ?? EvieButton(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              upContent ?? '',
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                            onPressed: onPressedUp
                        ),
                      ),
                    ),


                    Flexible(
                      child:  Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: customButtonDown ?? EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            downContent ?? '',
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
                          onPressed: onPressedDown,
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        )
    );
  }
}


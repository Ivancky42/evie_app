import 'package:evie_test/api/colours.dart';
import 'package:sizer/sizer.dart';
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
    super.key,
    //required this.buttonNumber,
    required this.title,
    required this.childContent,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Padding(
                  padding:  EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Text(title, style:EvieTextStyles.h2,),
                ),
                Divider(
                  thickness: 0.5.h,
                  color: EvieColors.darkWhite,
                  height: 0,
                ),

                //SizedBox(height: 9.h,),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 10.h),
                  child: childContent,
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:  Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: EvieButton_ReversedColor(
                            width: double.infinity,
                            height: 48.h,
                            onPressed: onPressedLeft,
                            child: Text(
                              leftContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                            ),
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
                          onPressed: onPressedRight,
                          child: Text(
                            rightContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          )
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
    super.key,
    //required this.buttonNumber,
    required this.title,
    required this.content,
    this.image,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  });



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
    super.key,
    //required this.buttonNumber,
    required this.title,
    required this.childContent,
    required this.leftContent,
    required this.rightContent,
    required this.onPressedLeft,
    required this.onPressedRight
  });

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
              left: 18.w,
              right: 16.w,
              top: 12.h,
              bottom: 22.h
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding:  EdgeInsets.only(bottom: 6.h),
                child: title,
              ),
              Divider(
                thickness: 0.5.h,
                color: EvieColors.darkWhite,
                height: 0,
              ),

              childContent,

              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:  Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          onPressed: onPressedLeft,
                          child: Text(
                            leftContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
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
                            onPressed: onPressedRight,
                            child: Text(
                              rightContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            )
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

///Double button dialog
///V MADE IT
class EvieTwoButtonDialog extends StatelessWidget{
  final Widget? title;
  final bool? havePic;
  final Widget childContent;
  final SvgPicture? svgpicture;
  final Widget? lottie;
  final String? upContent;
  final String? downContent;
  final VoidCallback? onPressedDown;
  final VoidCallback? onPressedUp;
  final Widget? customButtonUp;
  final Widget? customButtonDown;


  const EvieTwoButtonDialog({
    super.key,
    this.title,
    this.havePic,
    required this.childContent,
    this.svgpicture,
    this.upContent,
    this.downContent,
    this.onPressedDown,
    this.onPressedUp,
    this.customButtonUp,
    this.customButtonDown, this.lottie,

  });

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

              lottie != null ?
              Center(
                  child: lottie,
              ) : Container(),

              SizedBox(
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
                            onPressed: onPressedUp,
                            child: Text(
                              upContent ?? '',
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            )
                        ),
                      ),
                    ),


                    Flexible(
                      child:  Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: customButtonDown ?? EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          onPressed: onPressedDown,
                          child: Text(
                            downContent ?? '',
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
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

class EvieConnectingDialog extends StatelessWidget{
  final Widget? title;
  final bool? havePic;
  final Widget childContent;
  final SvgPicture? svgpicture;
  final Widget? lottie;
  final String? upContent;
  final String? downContent;
  final VoidCallback? onPressedDown;
  final VoidCallback? onPressedUp;
  final Widget? customButtonUp;
  final Widget? customButtonDown;


  const EvieConnectingDialog({
    super.key,
    this.title,
    this.havePic,
    required this.childContent,
    this.svgpicture,
    this.upContent,
    this.downContent,
    this.onPressedDown,
    this.onPressedUp,
    this.customButtonUp,
    this.customButtonDown, this.lottie,

  });

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
              // top: 16.w,
              bottom: 16.w
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  lottie != null ?
                  Center(
                    child: lottie,
                  ) : Container(),

                  Padding(
                    padding: EdgeInsets.only(top: 250.h),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 325.w,
                          child: Padding(
                            padding:  EdgeInsets.only(bottom: 16.h),
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
                                      onPressed: onPressedUp,
                                      child: Text(
                                        upContent ?? '',
                                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                                      )
                                  ),
                                ),
                              ),


                              Flexible(
                                child:  Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: customButtonDown ?? EvieButton_ReversedColor(
                                    width: double.infinity,
                                    height: 48.h,
                                    onPressed: onPressedDown,
                                    child: Text(
                                      downContent ?? '',
                                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}


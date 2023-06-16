import 'package:evie_bike/api/colours.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

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


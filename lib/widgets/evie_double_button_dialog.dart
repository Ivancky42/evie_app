import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import 'evie_button.dart';


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
          backgroundColor: Color(0xffECEDEB),
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
                  child: Text(title, style: TextStyle(fontSize: 24.sp),),
                ),
                Padding(
                  padding:  EdgeInsets.only(bottom: 11.h),
                  child: Divider(
                    thickness: 0.5.h,
                    color: const Color(0xff8E8E8E),
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
                        child: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            leftContent,
                            style: TextStyle(
                                color: EvieColors.PrimaryColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          onPressed: onPressedLeft,
                        ),
                      ),

                      Expanded(
                        child:
                      EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          rightContent,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        onPressed: onPressedRight
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
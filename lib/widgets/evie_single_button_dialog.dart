import 'package:evie_test/api/fonts.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/sizer.dart';

import '../api/colours.dart';
import 'package:flutter/cupertino.dart';

import 'evie_button.dart';


///Single button dialog
class EvieSingleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String? content;
  final Widget? widget;
  final String rightContent;
  final VoidCallback onPressedRight;

  const EvieSingleButtonDialog({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    this.content,
    this.widget,
    required this.rightContent,
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

              content != null? Text(
                content ?? "" ,
                textAlign: TextAlign.start,
                style: EvieTextStyles.body18,
              ) : Container(),

              widget != null ? widget! : SizedBox(),

              Padding(
                padding: EdgeInsets.only(top: 9.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            rightContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
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



///Single button dialog
class EvieSingleButtonDialogCupertino extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String content;
  final Widget? image;
  final String rightContent;
  final VoidCallback onPressedRight;

  const EvieSingleButtonDialogCupertino({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.content,
    this.image,
    required this.rightContent,
    required this.onPressedRight
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return CupertinoAlertDialog(
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


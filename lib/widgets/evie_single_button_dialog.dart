import 'package:flutter/material.dart';
import 'package:evie_test/api/sizer.dart';

import '../api/colours.dart';
import 'package:flutter/cupertino.dart';

import 'evie_button.dart';

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


///Single button dialog
class EvieSingleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String content;
  final Widget? image;
  final String rightContent;
  final VoidCallback onPressedRight;

  const EvieSingleButtonDialog({
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
                child: Text(title, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 11.h),
                child: Divider(
                  thickness: 0.5.h,
                  color: const Color(0xff8E8E8E),
                  height: 0,
                ),
              ),

              image != null ? image! : SizedBox(),

              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                ),
              ),

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
      return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.0,
          backgroundColor: Color(0xffECEDEB),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                image != null ? image! : SizedBox(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16,16,16,0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,16,16,0),
                  child: Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(
                  height:30.0,
                ),

                Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        SizedBox(width: 2.w,),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: onPressedRight,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  backgroundColor: EvieColors.primaryColor),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 0),
                                child: Text(
                                  rightContent,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            //width: double.infinity, height: 40,
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(top: 45),
          )
      );

  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';


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
    return Sizer(builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
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
    },);
  }
}


///Double button dialog
class EvieDoubleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String content;
  final Widget? image;
  final String? leftContent;
  final String rightContent;
  final VoidCallback? onPressedLeft;
  final VoidCallback onPressedRight;

  const EvieDoubleButtonDialog({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.content,
    this.image,
    this.leftContent,
    required this.rightContent,
    this.onPressedLeft,
    required this.onPressedRight
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
      return  Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.0,
          //backgroundColor: Colors.transparent,
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
                        Expanded(
                          child: ElevatedButton(
                              onPressed: onPressedLeft,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  ///Set to transparent
                                  elevation: 0.0,
                                  backgroundColor: Color(0xff00B6F1).withOpacity(0)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 0),
                                child: Text(
                                  leftContent!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            //width: double.infinity, height: 40,
                          ),
                        ),
                        SizedBox(width: 2.w,),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: onPressedRight,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  backgroundColor: const Color(0xff00B6F1)),
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
    },);
  }
}
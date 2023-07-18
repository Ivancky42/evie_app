import 'package:evie_test/api/fonts.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

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

///Single button dialog
///V made it
class EvieOneButtonDialog extends StatelessWidget{
   final String title;
  final String? content;
  final SvgPicture? svgpicture;
  final Widget? widget;
  final String middleContent;
  final VoidCallback onPressedMiddle;

  const EvieOneButtonDialog({
    Key? key,
    required this.title,
    this.content,
    this.widget,
    this.svgpicture,
    required this.middleContent,
    required this.onPressedMiddle
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
            mainAxisSize: MainAxisSize.min,
            children: [

              svgpicture == null?
            Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: SvgPicture.asset(
                  "assets/images/people_search.svg",
                  height: 150.h,
                  width: 239.w,),
              ) : Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: SvgPicture.asset(
                  "assets/images/bike_champion.svg",
                  height: 157.h,
                  width: 164.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                  child: Text(title,
                    style:EvieTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              content != null? Container(
                width: 326.w,
                child: Text(
                  content ?? "" ,
                  textAlign: TextAlign.center,
                  style: EvieTextStyles.body18,
                ),
              ) : Container(),

              widget != null ? widget! : SizedBox(),

              Padding(
                padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
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

class Evie2IconOneButtonDialog extends StatelessWidget{
  final String title;
  final String miniTitle1;
  final String miniTitle2;
  final String content1;
  final String content2;
  final SvgPicture? svgpicture;
  final String middleContent;
  final VoidCallback onPressedMiddle;

  const Evie2IconOneButtonDialog({
    Key? key,
    required this.title,
    required this.miniTitle1,
    required this.miniTitle2,
    required this.content1,
    required this.content2,
    this.svgpicture,
    required this.middleContent,
    required this.onPressedMiddle
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
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

             Row(
               mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: Container(
                        width: 25.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: EvieColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: Container(
                        width: 25.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: EvieColors.progressBarGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

              Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: SvgPicture.asset(
                  "assets/images/people_search.svg",
                  height: 150.h,
                  width: 239.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
                  child: Text(title,
                    style:EvieTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                width: 326.w,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/bluetooth_connected.svg",
                        height: 36.h,
                        width: 36.w,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              miniTitle1,
                              style: EvieTextStyles.miniTitle,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Text(
                                content1,
                                textAlign: TextAlign.left,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                width: 326.w,

                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/lock_safe.svg",
                        height: 36.h,
                        width: 36.w,
                      ),

                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              miniTitle2,
                              style: EvieTextStyles.miniTitle,
                            ),

                            Text(
                              content2,
                              textAlign: TextAlign.left,
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 140.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
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

class Evie3IconOneButtonDialog extends StatelessWidget{
  final String title;
  final String miniTitle1;
  final String miniTitle2;
  final String miniTitle3;
  final String content1;
  final String content2;
  final String content3;
  final SvgPicture? svgpicture;
  final String middleContent;
  final VoidCallback onPressedMiddle;

  const Evie3IconOneButtonDialog({
    Key? key,
    required this.title,
    required this.miniTitle1,
    required this.miniTitle2,
    required this.miniTitle3,
    required this.content1,
    required this.content2,
    required this.content3,
    this.svgpicture,
    required this.middleContent,
    required this.onPressedMiddle
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
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: Container(
                      width: 25.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: EvieColors.progressBarGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: Container(
                      width: 25.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: EvieColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: SvgPicture.asset(
                  "assets/images/people_search.svg",
                  height: 150.h,
                  width: 239.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
                  child: Text(title,
                    style:EvieTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                width: 326.w,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/setting.svg",
                      height: 36.h,
                      width: 36.w,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            miniTitle1,
                            style: EvieTextStyles.miniTitle,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Text(
                              content1,
                              textAlign: TextAlign.left,
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              // maxLines: 3,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 326.w,

                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/battery_half.svg",
                      height: 36.h,
                      width: 36.w,
                      color: EvieColors.primaryColor,
                    ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            miniTitle2,
                            style: EvieTextStyles.miniTitle,
                          ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Text(
                              content2,
                              textAlign: TextAlign.left,
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 326.w,

                child: Row(
                  children: [
                    SvgPicture.asset(
                      //"assets/icons/purple_user.svg",
                      "assets/icons/battery_half.svg",
                      height: 36.h,
                      width: 36.w,
                    ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            miniTitle3,
                            style: EvieTextStyles.miniTitle,
                          ),

                          Text(
                            content3,
                            textAlign: TextAlign.left,
                            style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 30.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
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

class EvieOneDialog extends StatelessWidget{
  final String title;
  final String? content1;
  final String? content2;
  final String? email;
  final SvgPicture? svgpicture;
  final Widget? widget;
  final String middleContent;
  final VoidCallback onPressedMiddle;

  const EvieOneDialog({
    Key? key,
    required this.title,
    this.content1,
    this.content2,
    this.email,
    this.widget,
    this.svgpicture,
    required this.middleContent,
    required this.onPressedMiddle
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
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: SvgPicture.asset(
                  "assets/images/people_search.svg",
                  height: 150.h,
                  width: 239.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                  child: Text(title,
                    style:EvieTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                width: 326.w,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: content1 ?? "",
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumBlack),
                      ),

                      TextSpan(text: email,
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor),
                      ),

                      TextSpan(text: content2,
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumBlack),
                      ),
                    ],
                  ),
                ),
              ),

              widget != null ? widget! : SizedBox(),

              Padding(
                padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
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

class Evie2IconBatchOneButtonDialog extends StatelessWidget{
  final String title;
  final String miniTitle1;
  final String miniTitle2;
  final String content1;
  final String content2;
  final SvgPicture? svgpicture;
  final String middleContent;
  final VoidCallback onPressedMiddle;

  const Evie2IconBatchOneButtonDialog({
    Key? key,
    required this.title,
    required this.miniTitle1,
    required this.miniTitle2,
    required this.content1,
    required this.content2,
    this.svgpicture,
    required this.middleContent,
    required this.onPressedMiddle
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
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [


              Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: SvgPicture.asset(
                  "assets/images/people_search.svg",
                  height: 150.h,
                  width: 239.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
                  child: Text(title,
                    style:EvieTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                width: 326.w,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 0.w),
                      child: SvgPicture.asset(
                        "assets/icons/antitheft.svg",
                        height: 36.h,
                        width: 36.w,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:EdgeInsets.only(right: 4.w),
                                child: Text(
                                  miniTitle1,
                                  style: EvieTextStyles.miniTitle,
                                ),
                              ),

                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Text(
                              content1,
                              textAlign: TextAlign.left,
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 326.w,

                child: Row(
                  children: [
                    Padding(
                      padding:EdgeInsets.only(right: 0.w),
                      child: SvgPicture.asset(
                        "assets/icons/vector.svg",
                        height: 36.h,
                        width: 36.w,
                        color: EvieColors.primaryColor,
                      ),
                    ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Text(
                                  miniTitle2,
                                  style: EvieTextStyles.miniTitle,
                                ),
                              ),

                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),

                          Text(
                            content2,
                            textAlign: TextAlign.left,
                            style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 84.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
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




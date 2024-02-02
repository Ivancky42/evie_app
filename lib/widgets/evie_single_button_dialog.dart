import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/colours.dart';
import 'package:flutter/cupertino.dart';

import '../api/dialog.dart';
import '../api/provider/bike_provider.dart';
import 'evie_button.dart';


///Single button dialog
class EvieSingleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String? content;
  final Widget? widget;
  final String rightContent;
  final VoidCallback onPressedRight;
  final bool? isReversed;
  final bool? havePic;
  final SvgPicture? svgpicture;
  final Widget? customButton;
  final String? middleContent;
  final VoidCallback? onPressedMiddle;
  final Widget? lottie;

  const EvieSingleButtonDialog({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    this.content,
    this.widget,
    required this.rightContent,
    required this.onPressedRight, this.isReversed, this.havePic, this.svgpicture, this.customButton, this.middleContent, this.onPressedMiddle, this.lottie,
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
              //top: 16.w,
              bottom: 16.w
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              Stack(
                children: [
                  Center(
                    child: Container(
                      //color: Colors.red,
                      //width: 300.w,
                      child: Transform.translate(
                        offset: Offset(0.0, -45.0), // Move the Lottie animation up by 50.0 units
                        child: Lottie.asset(
                          'assets/images/error-animate.json',
                          repeat: false,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 240.h),
                    child: Column(
                      children: [
                        Container(
                          width: 325.w,
                          child: Padding(
                            padding:  EdgeInsets.only(bottom: 16.h),
                            child: Text(title!,
                              style:EvieTextStyles.h2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        content != null ? Container(
                          width: 326.w,
                          child: Text(
                            content ?? "" ,
                            textAlign: TextAlign.center,
                            style: EvieTextStyles.body18,
                          ),
                        ) : const SizedBox.shrink(),

                        widget != null ? widget! : const SizedBox.shrink(),

                        Padding(
                          padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child:
                                customButton ?? EvieButton(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: Text(
                                      middleContent ?? "Ok",
                                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                                    ),
                                    onPressed: onPressedRight
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        )
    );
      Dialog(
        insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite,
        child: Container(
          // padding:  EdgeInsets.only(
          //     left: 17.w,
          //     right: 17.w,
          //     top: 16.w,
          //     bottom: 16.w
          // ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding:  EdgeInsets.only(bottom: 8.h, left: 17.w, right: 17.w, top: 16.w),
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

              Padding(
                padding:  EdgeInsets.only(left: 17.w, right: 17.w),
                child: content != null? Text(
                  content ?? "" ,
                  textAlign: TextAlign.start,
                  style: EvieTextStyles.body18,
                ) : Container(),
              ),

              Padding(
                padding: EdgeInsets.only(left: 17.w, right: 17.w),
                child: widget != null ? widget! : SizedBox(),
              ),

              Padding(
                padding: EdgeInsets.only(top: 9.h, bottom: 16.h, left: 17.w, right: 17.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                     isReversed == null ?
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            rightContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedRight
                      ) :
                      EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            rightContent,
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
                          onPressed: onPressedRight
                      )
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

class EvieSingleButtonDialogOld extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String? content;
  final Widget? widget;
  final String rightContent;
  final VoidCallback onPressedRight;
  final bool? isReversed;
  final bool? havePic;
  final SvgPicture? svgpicture;
  final Widget? customButton;
  final String? middleContent;
  final VoidCallback? onPressedMiddle;
  final Widget? lottie;

  const EvieSingleButtonDialogOld({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    this.content,
    this.widget,
    required this.rightContent,
    required this.onPressedRight, this.isReversed, this.havePic, this.svgpicture, this.customButton, this.middleContent, this.onPressedMiddle, this.lottie,
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
          // padding:  EdgeInsets.only(
          //     left: 17.w,
          //     right: 17.w,
          //     top: 16.w,
          //     bottom: 16.w
          // ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding:  EdgeInsets.only(bottom: 8.h, left: 17.w, right: 17.w, top: 16.w),
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

              Padding(
                padding:  EdgeInsets.only(left: 17.w, right: 17.w),
                child: content != null? Text(
                  content ?? "" ,
                  textAlign: TextAlign.start,
                  style: EvieTextStyles.body18,
                ) : Container(),
              ),

              Padding(
                padding: EdgeInsets.only(left: 17.w, right: 17.w),
                child: widget != null ? widget! : SizedBox(),
              ),

              Padding(
                padding: EdgeInsets.only(top: 9.h, bottom: 16.h, left: 17.w, right: 17.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child:
                        isReversed == null ?
                        EvieButton(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              rightContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                            onPressed: onPressedRight
                        ) :
                        EvieButton_ReversedColor(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              rightContent,
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                            ),
                            onPressed: onPressedRight
                        )
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
   final String? title;
  final String? content;
  final bool? havePic;
  final SvgPicture? svgpicture;
  final Widget? widget;
  final String? middleContent;
  final VoidCallback? onPressedMiddle;
  final Widget? customButton;

  const EvieOneButtonDialog({
    Key? key,
    this.title,
    this.content,
    this.widget,
    this.svgpicture,
    this.havePic,
    this.middleContent,
    this.onPressedMiddle,
    this.customButton,
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
                      height: 150.h,
                      width: 239.w,
                    ),
                  ),
                ): Padding(
                  padding: EdgeInsets.only(top: 32.h),
                  child: svgpicture!,
                ),
              ),

              title != null ?  Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                  child: Text(title!,
                    style:EvieTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : SizedBox.shrink(),

              content != null ? Container(
                width: 326.w,
                child: Text(
                  content ?? "" ,
                  textAlign: TextAlign.center,
                  style: EvieTextStyles.body18,
                ),
              ) : const SizedBox.shrink(),

              widget != null ? widget! : const SizedBox.shrink(),

             Padding(
                padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      customButton ?? EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            middleContent ?? "Ok",
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: onPressedMiddle
                      ),
                    ),
                  ],
                ),
             ),
            ],
          ),
        )
    );
  }
}

class EvieClubDialog extends StatefulWidget {
  const EvieClubDialog({Key? key, }) : super(key: key);

  @override
  State<EvieClubDialog> createState() => _EvieClubDialogState();
}

class _EvieClubDialogState extends State<EvieClubDialog> {

  int screenIndex = 0;
  PermissionStatus? permissionStatus;

  Widget buildWidget() {
    return screenIndex == 0 ?
      Column(
      children: [
        Center(
            child: Container(
              height: 150.h,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: SvgPicture.asset(
                  "assets/images/ev_club.svg",
                  height: 150.h,
                  width: 239.w,
                ),
              ),
            )
        ),

        Container(
          width: 325.w,
          child: Padding(
            padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
            child: Text('Welcome to the EV+ \nClub!',
              style:EvieTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        Container(
          width: 326.w,
          child: Text(
            "Your experience is about to get a whole lot richer! Brace yourself for an immersive experience filled with exclusive features with EV-Secure. \n\n Thank you for choosing to join us at the EV-Secure. We’re honored to have you with us!" ,
            textAlign: TextAlign.center,
            style: EvieTextStyles.body18,
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: EvieButton(
                      height: 48.h,
                      child: Text(
                        "Let's Go!",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () {
                        setState(() {
                          screenIndex = 1;
                        });
                      }
                  ),
              )
            ],
          ),
        ),
      ],
    ) :
      screenIndex == 1 ?
      Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 28.h),
              child: SvgPicture.asset(
                "assets/images/sync.svg",),
            ),

            Container(
              width: 325.w,
              child: Padding(
                padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
                child: Text('Sync. Ride. Thrive.',
                  style:EvieTextStyles.target_reference_h1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/bluetooth_connected.svg",
                    height: 36.h,
                    width: 36.w,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Connected',
                        style: EvieTextStyles.target_reference_body,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          'Seamlessly sync your bike and stay in control with Bluetooth connectivity.',
                          textAlign: TextAlign.left,
                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/lock_safe.svg",
                    height: 36.h,
                    width: 36.w,
                  ),
                ),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One-Tap Unlock',
                        style: EvieTextStyles.target_reference_body,
                      ),

                      Text(
                        'Security has never been this convenient with EVIE\'s built-in locking system.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h,),

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/bar_chart.svg",
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
                          Text(
                            'Ride History',
                            style: EvieTextStyles.target_reference_body,
                          ),

                          SvgPicture.asset(
                            "assets/icons/batch_tick.svg",
                            width: 24.w,
                            height: 24.w,
                          ),
                        ],
                      ),

                      Text(
                        'Security has never been this convenient with EVIE\'s built-in locking system.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),

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
                          getButtonText(),
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          if (screenIndex == 1) {
                            if (Platform.isAndroid) {
                              await Permission.bluetoothConnect.request();
                              await Permission.bluetoothScan.request();
                              setState(() {
                                screenIndex = 2;
                              });
                            }
                            else {
                              //openAppSettings();
                              setState(() {
                                screenIndex = 2;
                              });
                              //OpenSettings.openBluetoothSetting();
                            }
                          }
                          else {
                            SmartDialog.dismiss();
                          }
                        }
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ) :
      Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 28.h),
              child: SvgPicture.asset(
                "assets/images/master_your_ride.svg",),
            ),

            Container(
              width: 325.w,
              child: Padding(
                padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
                child: Text('Master Your Ride',
                  style:EvieTextStyles.target_reference_h1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/setting.svg",
                    height: 36.h,
                    width: 36.w,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bike Settings',
                        style: EvieTextStyles.target_reference_body,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          'Tailor your ride to perfection, fine-tune your preferences, optimize performance, and create your ultimate cycling experience.',
                          textAlign: TextAlign.left,
                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/battery.svg",
                    height: 36.h,
                    width: 36.w,
                  ),
                ),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery Life',
                        style: EvieTextStyles.target_reference_body,
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child:  Text(
                          'Check your bike’s battery life before it needs its next charge.',
                          textAlign: TextAlign.left,
                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: SvgPicture.asset(
                    "assets/icons/bike_outline.svg",
                    height: 36.h,
                    width: 36.w,
                  ),
                ),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multiple Bikes',
                        style: EvieTextStyles.target_reference_body,
                      ),

                      Text(
                        'See all your bikes’ details and switch seamlessly between them.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),

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
                          getButtonText(),
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          if (screenIndex == 1) {
                            if (Platform.isAndroid) {
                              await Permission.bluetoothConnect.request();
                              await Permission.bluetoothScan.request();
                              setState(() {
                                screenIndex = 2;
                              });
                            }
                            else {
                              //openAppSettings();
                              setState(() {
                                screenIndex = 2;
                              });
                              //OpenSettings.openBluetoothSetting();
                            }
                          }
                          else {
                            SmartDialog.dismiss();
                          }
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    PermissionStatus status = await Permission.bluetoothConnect.status;
    if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
      setState(() {
        permissionStatus = status;
      });
    }
    else {
      PermissionStatus status = await Permission.bluetoothScan.status;
      if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
        setState(() {
          permissionStatus = status;
        });
      }
    }
  }

  String getButtonText() {
    if (Platform.isAndroid) {
      if (screenIndex == 1) {
        if (permissionStatus == PermissionStatus.denied ||
            permissionStatus == PermissionStatus.permanentlyDenied) {
          return 'Allow Bluetooth';
        }
        else {
          return 'Next';
        }
      }
      else {
        return 'Done';
      }
    }
    else {
      if (screenIndex == 1) {
        return 'Next';
      }
      else {
        return 'Done';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            color: screenIndex == 0 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
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
                            color: screenIndex == 1 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
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
                            color: screenIndex == 2 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildWidget(),
                ],
              ),
            )
        ),

        Lottie.asset(
          'assets/animations/confetti.json',
          repeat: false,
        ),
      ],
    );
  }
}


class WelcomeJoinTeam extends StatefulWidget {
  final String palName;
  final String teamName;
  const WelcomeJoinTeam({Key? key, required this.palName, required this.teamName, }) : super(key: key);

  @override
  State<WelcomeJoinTeam> createState() => _WelcomeJoinTeamState();
}

class _WelcomeJoinTeamState extends State<WelcomeJoinTeam> {

  int screenIndex = 0;
  PermissionStatus? permissionStatus;

  Widget buildWidget() {
    return screenIndex == 0 ?
    Column(
      children: [
        Center(
            child: Container(
              height: 150.h,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: SvgPicture.asset(
                  "assets/images/ev_club.svg",
                  height: 150.h,
                  width: 239.w,
                ),
              ),
            )
        ),

        Container(
          width: 325.w,
          child: Padding(
            padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
            child: Text('Welcome ' + widget.palName + ', to ' + widget.teamName  ,
              style:EvieTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        Container(
          width: 326.w,
          child: Text(
            "Are you ready for an adventure? Perks of being a PedalPal include having access to exclusive features such as GPS Tracking, Security Alerts, Ride History and more!" ,
            textAlign: TextAlign.center,
            style: EvieTextStyles.body18,
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 37.h, bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: EvieButton(
                    height: 48.h,
                    child: Text(
                      "Let's Go!",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                    ),
                    onPressed: () {
                      setState(() {
                        screenIndex = 1;
                      });
                    }
                ),
              )
            ],
          ),
        ),
      ],
    ) :
    screenIndex == 1 ?
    Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: SvgPicture.asset(
              "assets/images/sync.svg",),
          ),

          Container(
            width: 325.w,
            child: Padding(
              padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
              child: Text('Sync. Ride. Thrive.',
                style:EvieTextStyles.target_reference_h1,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/bluetooth_connected.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Connected',
                      style: EvieTextStyles.target_reference_body,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Seamlessly sync your bike and stay in control with Bluetooth connectivity.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/lock_safe.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One-Tap Unlock',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Text(
                      'Security has never been this convenient with EVIE\'s built-in locking system.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h,),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/bar_chart.svg",
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
                        Text(
                          'Ride History',
                          style: EvieTextStyles.target_reference_body,
                        ),

                        SvgPicture.asset(
                          "assets/icons/batch_tick.svg",
                          width: 24.w,
                          height: 24.w,
                        ),
                      ],
                    ),

                    Text(
                      'Security has never been this convenient with EVIE\'s built-in locking system.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),

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
                        getButtonText(),
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () async {
                        if (screenIndex == 1) {
                          if (Platform.isAndroid) {
                            await Permission.bluetoothConnect.request();
                            await Permission.bluetoothScan.request();
                            setState(() {
                              screenIndex = 2;
                            });
                          }
                          else {
                            //openAppSettings();
                            setState(() {
                              screenIndex = 2;
                            });
                            //OpenSettings.openBluetoothSetting();
                          }
                        }
                        else {
                          SmartDialog.dismiss();
                        }
                      }
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    ) :
    Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: SvgPicture.asset(
              "assets/images/master_your_ride.svg",),
          ),

          Container(
            width: 325.w,
            child: Padding(
              padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
              child: Text('Master Your Ride',
                style:EvieTextStyles.target_reference_h1,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/setting.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bike Settings',
                      style: EvieTextStyles.target_reference_body,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Tailor your ride to perfection, fine-tune your preferences, optimize performance, and create your ultimate cycling experience.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/battery.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battery Life',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child:  Text(
                        'Check your bike’s battery life before it needs its next charge.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/bike_outline.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiple Bikes',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Text(
                      'See all your bikes’ details and switch seamlessly between them.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),

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
                        getButtonText(),
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () async {
                        if (screenIndex == 1) {
                          if (Platform.isAndroid) {
                            await Permission.bluetoothConnect.request();
                            await Permission.bluetoothScan.request();
                            setState(() {
                              screenIndex = 2;
                            });
                          }
                          else {
                            //openAppSettings();
                            setState(() {
                              screenIndex = 2;
                            });
                            //OpenSettings.openBluetoothSetting();
                          }
                        }
                        else {
                          SmartDialog.dismiss();
                        }
                      }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    PermissionStatus status = await Permission.bluetoothConnect.status;
    if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
      setState(() {
        permissionStatus = status;
      });
    }
    else {
      PermissionStatus status = await Permission.bluetoothScan.status;
      if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
        setState(() {
          permissionStatus = status;
        });
      }
    }
  }

  String getButtonText() {
    if (Platform.isAndroid) {
      if (screenIndex == 1) {
        if (permissionStatus == PermissionStatus.denied ||
            permissionStatus == PermissionStatus.permanentlyDenied) {
          return 'Allow Bluetooth';
        }
        else {
          return 'Next';
        }
      }
      else {
        return 'Done';
      }
    }
    else {
      if (screenIndex == 1) {
        return 'Next';
      }
      else {
        return 'Done';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            color: screenIndex == 0 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
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
                            color: screenIndex == 1 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
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
                            color: screenIndex == 2 ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildWidget(),
                ],
              ),
            )
        ),

        Lottie.asset(
          'assets/animations/confetti.json',
          repeat: false,
        ),
      ],
    );
  }
}

class Evie4OneButtonDialog extends StatefulWidget {
  const Evie4OneButtonDialog({Key? key}) : super(key: key);

  @override
  State<Evie4OneButtonDialog> createState() => _Evie4OneButtonDialogState();
}

class _Evie4OneButtonDialogState extends State<Evie4OneButtonDialog> {

  bool isFirst = true;
  PermissionStatus? permissionStatus;

  Widget buildWidget() {
    return
    isFirst ?
    Padding(
      padding: EdgeInsets.only(bottom: 140.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: SvgPicture.asset(
              "assets/images/sync.svg",),
          ),

          Container(
            width: 325.w,
            child: Padding(
              padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
              child: Text('Sync. Ride. Thrive.',
                style:EvieTextStyles.target_reference_h1,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/bluetooth_connected.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Connected',
                      style: EvieTextStyles.target_reference_body,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Seamlessly sync your bike and stay in control with Bluetooth connectivity.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/lock_safe.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One-Tap Unlock',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Text(
                      'Security has never been this convenient with EVIE\'s built-in locking system.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ):
    Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: SvgPicture.asset(
              "assets/images/master_your_ride.svg",),
          ),

          Container(
            width: 325.w,
            child: Padding(
              padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
              child: Text('Master Your Ride',
                style:EvieTextStyles.target_reference_h1,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/setting.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bike Settings',
                      style: EvieTextStyles.target_reference_body,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Tailor your ride to perfection, fine-tune your preferences, optimize performance, and create your ultimate cycling experience.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/battery.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battery Life',
                      style: EvieTextStyles.target_reference_body,
                    ),

                   Padding(
                     padding: EdgeInsets.only(bottom: 16.h),
                     child:  Text(
                       'Check your bike’s battery life before it needs its next charge.',
                       textAlign: TextAlign.left,
                       style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                     ),
                   ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/bike_outline.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiple Bikes',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Text(
                      'See all your bikes’ details and switch seamlessly between them.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    PermissionStatus status = await Permission.bluetoothConnect.status;
    if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
      setState(() {
        permissionStatus = status;
      });
    }
    else {
      PermissionStatus status = await Permission.bluetoothScan.status;
      if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
        setState(() {
          permissionStatus = status;
        });
      }
    }
  }

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
              top: 16.h,
              bottom: 16.h
          ),

          child: Column(
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
                        color: isFirst ? EvieColors.primaryColor : EvieColors.progressBarGrey,
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
                        color: isFirst ? EvieColors.progressBarGrey : EvieColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              buildWidget(),

              Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                      EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                              getButtonText(),
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: () async {
                            if (isFirst) {
                              if (Platform.isAndroid) {
                                await Permission.bluetoothConnect.request();
                                await Permission.bluetoothScan.request();
                                setState(() {
                                  isFirst = false;
                                });
                              }
                              else {
                                //openAppSettings();
                                setState(() {
                                  isFirst = false;
                                });
                                //OpenSettings.openBluetoothSetting();
                              }
                            }
                            else {
                              SmartDialog.dismiss();
                            }
                          }
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

  String getButtonText() {
    if (Platform.isAndroid) {
      if (isFirst) {
        if (permissionStatus == PermissionStatus.denied ||
            permissionStatus == PermissionStatus.permanentlyDenied) {
          return 'Allow Bluetooth';
        }
        else {
          return 'Next';
        }
      }
      else {
        return 'Done';
      }
    }
    else {
      if (isFirst) {
        return 'Next';
      }
      else {
        return 'Done';
      }
    }
  }
}


class FeedFirstDialog extends StatefulWidget {
  const FeedFirstDialog({Key? key}) : super(key: key);

  @override
  State<FeedFirstDialog> createState() => _FeedFirstDialogState();
}

class _FeedFirstDialogState extends State<FeedFirstDialog> {

  PermissionStatus? permissionStatus;

  Widget buildWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: 26.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: SvgPicture.asset(
              "assets/images/feed.svg",),
          ),

          Container(
            width: 325.w,
            child: Padding(
              padding:  EdgeInsets.only(bottom: 24.h, top: 31.76.h),
              child: Text('Always Be Informed.',
                style:EvieTextStyles.target_reference_h1,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/notification.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Updated',
                      style: EvieTextStyles.target_reference_body,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Stay informed on all your e-bike’s activities, from your bike’s battery life to the latest app updates.',
                        textAlign: TextAlign.left,
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                child: SvgPicture.asset(
                  "assets/icons/list.svg",
                  height: 36.h,
                  width: 36.w,
                ),
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Deals',
                      style: EvieTextStyles.target_reference_body,
                    ),

                    Text(
                      'Receive all of EVIE’S latest offers. Be the first to know when there are exclusive deals coming up.',
                      textAlign: TextAlign.left,
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> checkPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
      setState(() {
        permissionStatus = status;
      });
    }
    else {
      setState(() {
        permissionStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPermission();
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
              top: 16.h,
              bottom: 16.h
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildWidget(),

              Padding(
                padding: EdgeInsets.only(bottom: 15.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          getButtonText(),
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied) {
                            SmartDialog.dismiss();
                            if (Platform.isAndroid) {
                              AppSettings.openAppSettings(type: AppSettingsType.notification);
                            }
                            else {
                              AppSettings.openAppSettings(type: AppSettingsType.notification);
                            }
                          }
                          else {
                            SmartDialog.dismiss();
                          }
                        }
                    ),
                    SizedBox(height: 11.h,),
                    permissionStatus == PermissionStatus.denied ||
                        permissionStatus == PermissionStatus.permanentlyDenied ?
                    GestureDetector (
                      child: Text(
                        "Not Now",
                        softWrap: false,
                        style: EvieTextStyles.body18_underline,
                      ),
                      onTap: () {
                        SmartDialog.dismiss();
                      },
                    ) : Container(),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  String getButtonText() {
    if (Platform.isAndroid) {
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.permanentlyDenied) {
        return 'Allow Push Notifications';
      }
      else {
        return 'Confirm';
      }
    }
    else {
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.permanentlyDenied) {
        return 'Allow Push Notifications';
      }
      else {
        return 'Confirm';
      }
    }
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
        insetPadding: EdgeInsets.only(left: 10, right: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite,
        child: Container(
          padding:  EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 32.h,
              bottom: 16.h
          ),

          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              svgpicture ?? Container(),
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
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir', height: EvieTextStyles.lineHeight),
                      ),

                      TextSpan(text: email,
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontFamily: 'Avenir', height: EvieTextStyles.lineHeight),
                      ),

                      TextSpan(text: content2,
                        style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir', height: EvieTextStyles.lineHeight),
                      ),
                    ],
                  ),
                ),
              ),

              widget != null ? widget! : SizedBox(),

              Padding(
                padding: EdgeInsets.only(top: 37.h),
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
              top: 16.h,
              bottom: 16.h
          ),

          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: SvgPicture.asset(
                  "assets/images/worry_free.svg",
                  height: 150.h,
                  width: 239.w,),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 8.h, top: 31.76.h),
                  child: Text(title,
                    style:EvieTextStyles.title.copyWith(height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(0, 16.h, 0, 17.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                      child: SvgPicture.asset(
                        "assets/icons/antitheft_2.svg",
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
                                  style: EvieTextStyles.miniTitle.copyWith(color: Color(0xff3f3f3f)),
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
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 50.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      child: SvgPicture.asset(
                        "assets/icons/vector.svg",
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
              Row(
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
            ],
          ),
        )
    );

  }
}




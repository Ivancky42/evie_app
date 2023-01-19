
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';




class FirmwareUpdateFailed extends StatefulWidget{
  const FirmwareUpdateFailed({ Key? key }) : super(key: key);
  @override
  _FirmwareUpdateFailedState createState() => _FirmwareUpdateFailedState();
}

class _FirmwareUpdateFailedState extends State<FirmwareUpdateFailed> {

  @override
  Widget build(BuildContext context) {


    return WillPopScope(
        onWillPop: () async {
          return false;
        },

        child: Scaffold(
          body: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,76.h,16.w,4.h),
                        child: Text(
                          "Oops! Firmware update fail.",
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                        child: Container(
                          child: Text(
                            "Looks like something went wrong. Please try again.",
                            style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                          ),
                        ),
                      ),


                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(75.w,98.h,75.w,127.84.h),
                          child: SvgPicture.asset(
                            "assets/images/allow_location.svg",
                          ),
                        ),
                      ),


                    ]),


                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Try again",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () {
                        changeToNavigatePlanScreen(context);
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(150.w,25.h,150.w,EvieLength.buttonWord_WordBottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        child: Text(
                          "Remind me later",
                          softWrap: false,
                          style: TextStyle(fontSize: 12.sp,color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                        ),
                        onPressed: () {
                          changeToNavigatePlanScreen(context);
                        },
                      ),
                    ),
                  ),
                ),

              ]),
        ));
  }
}
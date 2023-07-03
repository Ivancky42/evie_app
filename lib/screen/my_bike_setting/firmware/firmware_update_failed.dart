
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/sheet_2.dart';




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
                            "We're sorry, but your EVIE firmware upgrade was not successful. "
                                "Please check if your Evie bike is still functioning properly and if not, reach out to our support team for assistance. "
                                    "We'll help you troubleshoot the issue and find a solution. THank you for trying to upgrade your device!",
                            style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                          ),
                        ),
                      ),


                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w,98.h,16.w,127.84.h),
                          child: SvgPicture.asset(
                            "assets/images/bike_broken.svg",
                          ),
                        ),
                      ),


                    ]),


                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () {
                        showBikeSettingSheet(context);
                      },
                    ),
                  ),
                ),


              ]),
        ));
  }
}
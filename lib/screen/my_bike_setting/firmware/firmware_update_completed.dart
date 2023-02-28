import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/length.dart';
import '../../../api/navigator.dart';



class FirmwareUpdateCompleted extends StatefulWidget{
  const FirmwareUpdateCompleted({ Key? key }) : super(key: key);
  @override
  _FirmwareUpdateCompletedState createState() => _FirmwareUpdateCompletedState();
}

class _FirmwareUpdateCompletedState extends State<FirmwareUpdateCompleted> {

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
                          "Update Completed",
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                        child: Container(
                          child: Text(
                            "Hooray! EVIE firmware have been updated successfully.",
                            style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                          ),
                        ),
                      ),


                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(75.w,98.h,75.w,127.84.h),
                          child: SvgPicture.asset(
                            "assets/images/beer_celebration.svg",
                          ),
                        ),
                      ),
                    ]),


                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                       changeToBikeSetting(context);
                      },
                    ),
                  ),
                ),
              ]),
        ));
  }

}
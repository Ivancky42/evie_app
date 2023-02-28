import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';



class ResetBike extends StatefulWidget{
  const ResetBike({ Key? key }) : super(key: key);
  @override
  _ResetBikeState createState() => _ResetBikeState();
}

class _ResetBikeState extends State<ResetBike> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Reset Bike',
          onPressed: () {
            changeToNavigatePlanScreen(context);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: Text(
                    "Reset bike to original state",
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 106.h),
                  child: Text(
                    "Getting your bike back to square one. In development stage "
                        "this function is use to clear bike user to empty list. Press reset to continue.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Reset Bike",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    showResetBike(context, _bikeProvider);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }

}
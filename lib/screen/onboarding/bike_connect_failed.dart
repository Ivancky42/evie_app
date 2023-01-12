import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_button.dart';

class BikeConnectFailed extends StatefulWidget {
  const BikeConnectFailed({Key? key}) : super(key: key);

  @override
  _BikeConnectFailedState createState() => _BikeConnectFailedState();
}

class _BikeConnectFailedState extends State<BikeConnectFailed> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          body: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(70.w, 66.h, 70.w, 50.h),
              child: const StepProgressIndicator(
                totalSteps: 10,
                currentStep: 4,
                selectedColor: Color(0xffCECFCF),
                selectedSize: 4,
                unselectedColor: Color(0xffDFE0E0),
                unselectedSize: 3,
                padding: 0.0,
                roundedEdges: Radius.circular(16),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 4.h),
              child: Text(
                "Bike registration failed",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 63.h),
              child: Text(
                "Oops! Look like ${_bikeProvider.scanQRCodeResult.toString()} happen.",
                style: TextStyle(fontSize: 16.sp, height: 1.5.h),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32.w, 0.h, 32.w, 4.h),
                child: Text(
                  "Bike Serial Number",
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32.w, 4.h, 32.w, 32.h),
                child: Text(
                  "Not Registered",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(19.w, 336.h, 19.w, 288.h),
          child: Container(
            height: 220.h,
            width: 352.18.w,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Image(
                  fit: BoxFit.fitWidth,
                  image:
                      AssetImage("assets/images/bike_HPStatus/bike_normal.png"),
                ),
                IconButton(
                  iconSize: 100.h,
                  icon: Image.asset("assets/icons/connect_failed.png"),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Scan QR Code",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  onPressed: () {
                    changeToQRScanningScreen(context);
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
                      "Maybe Later",
                      softWrap: false,
                      style: TextStyle(fontSize: 12.sp,color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      changeToTurnOnNotificationsScreen(context);
                    },
                  ),
                ),
              ),
            ),


          ])),
    );
  }
}

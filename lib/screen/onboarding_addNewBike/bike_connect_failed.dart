import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/evie_progress_indicator.dart';

class BikeConnectFailed extends StatefulWidget {
  const BikeConnectFailed({Key? key}) : super(key: key);

  @override
  _BikeConnectFailedState createState() => _BikeConnectFailedState();
}

class _BikeConnectFailedState extends State<BikeConnectFailed> {

  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

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

            const EvieProgressIndicator(currentPageNumber: 4, totalSteps: 8,),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 4.h),
              child: Text(
                "Bike registration failed",
                style: EvieTextStyles.h2,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 63.h),
              child: Text(
                "Oops! Look like ${_bikeProvider.scanQRCodeResult.toString()} happen.",
                style: EvieTextStyles.body18,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32.w, 0.h, 32.w, 4.h),
                child: Text(
                  "Evie Bike",
                  style:
                  EvieTextStyles.body20,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32.w, 4.h, 32.w, 32.h),
                child: Text(
                  "Bike Serial Number",
                  style:
                      EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(19.w, 356.h, 19.w, 288.h),
          child: Container(
            height: 220.h,
            width: 352.18.w,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/bike_fall.svg",
                ),

                // IconButton(
                //   iconSize: 100.h,
                //   icon: Image.asset("assets/icons/connect_failed.png"),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
        ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom+60.h),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Try Again",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {
                    changeToQRScanningScreen(context);
                  },
                ),
              ),
            ),

          Align(
              alignment: Alignment.bottomCenter,
            child:Padding(
                padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonbutton_buttonBottom+60.h),
                child: EvieButton_ReversedColor(
                    width: double.infinity,
                    onPressed: (){

                    },
                    child: Text("Get Help", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)))
            ),
          ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Skip register bike process",
                      softWrap: false,
                      style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      _authProvider.setIsFirstLogin(false);

                      if(_bikeProvider.isAddBike == true){
                        _authProvider.setIsFirstLogin(false);
                        _bikeProvider.setIsAddBike(false);
                       changeToUserHomePageScreen(context);
                      }else{
                        changeToTurnOnNotificationsScreen(context);
                      }
                    },
                  ),
                ),
              ),
            ),


          ])),
    );
  }
}

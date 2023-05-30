import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/auth_provider.dart';

class BeforeYouStart extends StatefulWidget {
  const BeforeYouStart({Key? key}) : super(key: key);

  @override
  _BeforeYouStartState createState() => _BeforeYouStartState();
}

class _BeforeYouStartState extends State<BeforeYouStart> {
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

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
                child:  Text(
                  "Things you'll need before you start",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,0.h),
                child: Container(
                  child:   Text(
                    "1. Assemble your buke fully.",
                    style: EvieTextStyles.body18,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(26.w,0.h,16.w,0.h),
                  child: TextButton(
                      onPressed: (){
                        Uri.http("www.google.com");
                      },
                      child: Row(
                        children: [
                          Text("How to assemble my bike?",
                            style: EvieTextStyles.body18.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                    ),
                          SvgPicture.asset(
                            "assets/buttons/external_link_purple.svg",
                          ),
                        ],
                      ),
                  ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w,0.h,16.w,98.h),
                child: Container(
                  child:   Text(
                    "2. Get ownership card ready.",
                    style: EvieTextStyles.body18,
                  ),
                ),
              ),],
          ),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(78.w,152.h,78.w,127.84.h),
                child: SvgPicture.asset(
                  "assets/images/ride_bike_see_phone.svg",
                ),
              ),
        ),

           Align(
           alignment: Alignment.bottomCenter,
            child: Padding(
             padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
             child: SizedBox(
               height: 48.h,
                width: double.infinity,
                child: EvieButton(
                  width: double.infinity,
                   child:Text(
                     "I'm ready",
                     style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                   ),
                   onPressed: () async {
                  // var locationStatus = await Permission.location.status;
                  //
                  // if (_bluetoothProvider.bleStatus == BleStatus.unauthorized && locationStatus == PermissionStatus.granted) {
                  //   changeToTurnOnBluetoothScreen(context);
                  // }
                  // else if (locationStatus == PermissionStatus.granted && _bluetoothProvider.bleStatus != BleStatus.unauthorized) {

                    changeToTurnOnQRScannerScreen(context);

                  //}
                  // else {
                  //   changeToTurnOnLocationScreen(context);
                  // }

                },
              ),
            ),
          ),
        ),



           ///Button for on boarding and add bike respectively
           _bikeProvider.isAddBike ? Align(
             alignment: Alignment.bottomCenter,
             child: Padding(
               padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonbutton_buttonBottom),
               child: EvieButton_ReversedColor(
                 width: double.infinity,
                   onPressed: (){
                   _bikeProvider.setIsAddBike(false);
                   changeToUserHomePageScreen(context);
                   },
                   child: Text("Cancel", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)))
             ),
           ) : Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                        child: Text(
                          "I'm not ready",
                          softWrap: false,
                          style: EvieTextStyles.body18.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                        ),
                        onPressed: () {
                          _authProvider.setIsFirstLogin(false);
                        changeToUserHomePageScreen(context);
                        },
                      ),
                ),
              ),
            ),
      ])),
    );
  }
}

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/onboarding/turn_on_bluetooth.dart';
import 'package:evie_test/screen/onboarding/turn_on_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/location_provider.dart';

class LetsGo extends StatefulWidget {
  const LetsGo({Key? key}) : super(key: key);

  @override
  _LetsGoState createState() => _LetsGoState();
}

class _LetsGoState extends State<LetsGo> {
  late CurrentUserProvider _currentUserProvider;
  late LocationProvider _locationProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    var currentName = _currentUserProvider.currentUserModel?.name;

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
                  //  "Hi ${_currentUserProvider.currentUserModel!.name}, thanks for choosing EVIE!",
                  "Stay closeby with your bike",
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                child: Container(
                  child: Text(
                    "Assemble your bike fully and keep your bike closely with you for the following steps.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(11.w,4.h,16.w,98.h),

                  child: TextButton(
                      onPressed: (){

                      },
                      child: Text("How to assemble my bike?",
                        style: TextStyle( fontSize: 16.sp, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),)),
              )
            ],
          ),

            Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.fromLTRB(75.w,98.h,75.w,127.84.h),
            child: SvgPicture.asset(
              "assets/images/setup_account.svg",
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
                child: Text(
                  "I'm Ready",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                      fontWeight: FontWeight.w700
                  ),
                ),
                onPressed: () async {
                  //changeToTurnOnLocationScreen(context);
                  var locationStatus = await Permission.location.status;

                  if (_bluetoothProvider.bleStatus == BleStatus.unauthorized && locationStatus == PermissionStatus.granted) {
                    changeToTurnOnBluetoothScreen(context);
                  }
                  else if (locationStatus == PermissionStatus.granted && _bluetoothProvider.bleStatus != BleStatus.unauthorized) {
                    changeToTurnOnQRScannerScreen(context);
                  }
                  else {
                    changeToTurnOnLocationScreen(context);
                  }

                },
              ),
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
                          changeToNotificationsControlScreen(context);
                        },
                      ),
                ),
              ),
            ),
      ])),
    );
  }
}

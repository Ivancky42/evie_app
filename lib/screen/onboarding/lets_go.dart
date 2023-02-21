import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
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
                child:  Text(
                  "Stay close with your bike",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                child: Container(
                  child:   Text(
                    "Assemble your bike fully. Keep your device close to your bike for the following steps. Please note that registering your bike may take up to 5 minutes.",
                    style: EvieTextStyles.body18,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(11.w,4.h,16.w,98.h),

                  child: TextButton(
                      onPressed: (){
                        Uri.http("www.google.com");
                      },
                      child: Text("How to assemble my bike?",
                        style: TextStyle( fontSize: 18.sp, fontWeight:FontWeight.w900, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),)),
              )
            ],
          ),

            Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.fromLTRB(75.w,98.h,75.w,127.84.h),
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
                          "I'm not ready",
                          softWrap: false,
                          style: TextStyle(fontSize: 14.sp, fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                        ),
                        onPressed: () {
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

import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
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
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_progress_indicator.dart';


class TurnOnBluetooth extends StatefulWidget {
  const TurnOnBluetooth({Key? key}) : super(key: key);

  @override
  _TurnOnBluetoothState createState() => _TurnOnBluetoothState();
}

class _TurnOnBluetoothState extends State<TurnOnBluetooth> {

  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {

    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const EvieProgressIndicator(currentPageNumber: 1),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                      child: Text(
                        "Allow Bluetooth",
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 113.h),
                      child: Text(
                        "Bluetooth is required to connect your device with your bike. "
                            "This allows EVIE app provide you with real-time information, such as speed, distance, and more.",
                        style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,221.h),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/bike_gointo_phone.svg",

                        ),
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Allow Bluetooth",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {

                        StreamSubscription? subscription;
                        PermissionStatus status = await _bluetoothProvider.handlePermission();
                        if (status == PermissionStatus.granted) {
                          subscription = _bluetoothProvider.checkBLEStatus().listen((bleStatus) {
                            if (bleStatus == BleStatus.ready) {
                              changeToTurnOnQRScannerScreen(context);
                              subscription?.cancel();
                            }
                            else if (bleStatus == BleStatus.poweredOff){
                              OpenSettings.openBluetoothSetting();
                            }
                          });
                        }
                        else if (status == PermissionStatus.denied) {
                          await _bluetoothProvider.handlePermission();
                        }
                        else if (status == PermissionStatus.permanentlyDenied) {
                          OpenSettings.openBluetoothSetting();
                        }
                      },
                    ),
                  ),
                ),
              ]
          )
      ),
    );
  }
}

import 'dart:async';

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';


import '../../../../../api/colours.dart';
import '../../../../../api/provider/bike_provider.dart';
import '../../../../../api/provider/bluetooth_provider.dart';
import '../../../../../api/provider/current_user_provider.dart';
import '../../../../../api/provider/location_provider.dart';
import '../../../../../bluetooth/modelResult.dart';
import '../../../../../widgets/evie_single_button_dialog.dart';
import '../../../../../widgets/evie_slider_button.dart';
import '../../../paid_plan/bottom_sheet_widget.dart';
import '../../../home_page_widget.dart';

class CrashAlert extends StatefulWidget {
  final SvgPicture? connectImage;
  final String? distanceBetween;
  final bool? isDeviceConnected;


  const CrashAlert({
    Key? key,

    required this.connectImage,
    required this.distanceBetween,
    required this.isDeviceConnected,
  }) : super(key: key);

  @override
  State<CrashAlert> createState() => _CrashAlertState();
}

class _CrashAlertState extends State<CrashAlert> {

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
  CableLockResult? cableLockState;


  @override
  Widget build(BuildContext context) {

    CurrentUserProvider _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    LocationProvider _locationProvider = Provider.of<LocationProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
    cableLockState = _bluetoothProvider.cableLockState;


      return Container(
          height: 636.h,
          decoration: BoxDecoration(
            color: const Color(0xFFECEDEB),
            borderRadius:
            BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 11.h),
                      child: Image.asset(
                        "assets/buttons/home_indicator.png",
                        width: 40.w,
                        height: 4.h,
                      ),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(
                          16.w, 9.h, 0, 0),
                      child: Bike_Name_Row(
                          bikeName: _bikeProvider
                              .currentBikeModel
                              ?.deviceName ??
                              "",
                          distanceBetween:
                          widget.distanceBetween ??
                              "-",
                          currentBikeStatusImage: "assets/images/bike_HPStatus/bike_danger.png",
                          isDeviceConnected: widget.isDeviceConnected!
                      ),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(
                          16.w,
                          17.15.h,
                          0,
                          0),
                      child: IntrinsicHeight(
                        child: Bike_Status_Row(
                          currentSecurityIcon:
                          "assets/buttons/bike_security_danger.svg",
                          batteryImage: getBatteryImage(
                              _bikeProvider
                                  .currentBikeModel
                                  ?.batteryPercent ??
                                  0),
                          batteryPercentage:
                          _bikeProvider
                              .currentBikeModel
                              ?.batteryPercent ??
                              0,
                          child: Text(
                            "CRASH ALERT",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 31.h),
                      child: Column(
                        children: [

                          Padding(
                            padding:  EdgeInsets.only(top:41.h,bottom:29.h),
                            child: EvieSliderButton(action: (){SmartDialog.showLoading();}, text: "I am OK",),
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ));
    }
  }


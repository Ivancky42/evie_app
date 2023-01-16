import 'dart:async';

import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../api/colours.dart';
import '../../../../../api/provider/bike_provider.dart';
import '../../../../../api/provider/bluetooth_provider.dart';
import '../../../../../api/provider/current_user_provider.dart';
import '../../../../../api/provider/location_provider.dart';
import '../../../../../bluetooth/modelResult.dart';
import '../../../../user_home_page/home_page_function.dart';
import '../../../../../widgets/evie_single_button_dialog.dart';
import '../../../paid_plan/bottom_sheet_widget.dart';
import '../../../home_page_widget.dart';

class BikeSafe extends StatefulWidget {

  final SvgPicture? connectImage;
  final String? distanceBetween;
  final bool? isDeviceConnected;


  const BikeSafe({
    Key? key,
    required this.connectImage,
  required this.distanceBetween,
    required this.isDeviceConnected,
  }) : super(key: key);

  @override
  State<BikeSafe> createState() => _BikeSafeState();
}

class _BikeSafeState extends State<BikeSafe> {

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  StreamController? connectStream;

  @override
  Widget build(BuildContext context) {

    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

      return Stack(
        children: [
          Container(
              height: 636.h,
              decoration: BoxDecoration(
                color: EvieColors.grayishWhite,
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
                            distanceBetween: widget.distanceBetween ??
                                "-",
                            currentBikeStatusImage:
                            "assets/images/bike_HPStatus/bike_safe.png",
                            isDeviceConnected: widget.isDeviceConnected!,
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
                              currentSecurityIcon: getSecurityImageWidget(_bikeProvider.currentBikeModel!.isLocked!),
                              child: getSecurityTextWidget(_bikeProvider.currentBikeModel!.isLocked!),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 31.h),
                          child: Column(
                            children: [

                              if(widget.isDeviceConnected!)...{

                              SizedBox(
                                height: 96.h,
                                width: 96.w,
                                child:
                                FloatingActionButton(
                                  elevation: 0,
                                  backgroundColor: cableLockState?.lockState == LockState.lock
                                      ?  EvieColors.primaryColor : EvieColors.softPurple,
                                  onPressed: cableLockState
                                      ?.lockState == LockState.lock
                                      ? () {
                                    ///Check is connected

                                    SmartDialog.showLoading(
                                        msg: "Unlocking");
                                    StreamSubscription?
                                    subscription;
                                    subscription = _bluetoothProvider
                                        .cableUnlock()
                                        .listen(
                                            (unlockResult) {
                                          SmartDialog.dismiss(
                                              status:
                                              SmartStatus.loading);
                                          subscription
                                              ?.cancel();
                                          if (unlockResult.result ==
                                              CommandResult.success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Bike is unlocked. To lock bike, pull the lock handle on the bike.',
                                                  style: TextStyle(fontSize: 16.sp),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            SmartDialog.dismiss(
                                                status: SmartStatus.loading);
                                            subscription
                                                ?.cancel();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                width: 358.w,
                                                behavior: SnackBarBehavior.floating,
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                content: Container(
                                                  height: 80.h,
                                                  child: Text(
                                                    'Bike is unlocked. To lock bike, pull the lock handle on the bike.',
                                                    style: TextStyle(fontSize: 16.sp),
                                                  ),
                                                ),
                                                duration: const Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        }, onError: (error) {
                                      SmartDialog.dismiss(
                                          status:
                                          SmartStatus.loading);
                                      subscription
                                          ?.cancel();
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialogCupertino(
                                              title: "Error",
                                              content: "Cannot unlock bike, please place the phone near the bike and try again.",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    });
                                  }
                                      : null,
                                  //icon inside button
                                  child: widget.connectImage,
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                Text(
                                  "Connecting bike",
                                  style: TextStyle(
                                      fontSize:
                                      12.sp,
                                      fontWeight:
                                      FontWeight
                                          .w400,
                                      color: EvieColors.darkGray),
                                ),
                              } else if (deviceConnectResult == DeviceConnectResult.connected) ...{
                                Text(
                                  "Tap to unlock bike",
                                  style: TextStyle(
                                      fontSize:
                                      12.sp,
                                      fontWeight:
                                      FontWeight
                                          .w400,
                                      color: EvieColors.darkGray),
                                ),
                              } else ...{
                                Text(
                                  "",
                                  style: TextStyle(
                                      fontSize:
                                      12.sp,
                                      fontWeight:
                                      FontWeight
                                          .w400,
                                      color: EvieColors.darkGray),
                                ),
                              },

                                ///If device is not connected
                              }   else...{

                                SizedBox(
                                    height: 96.h,
                                    width: 96.w,
                                    child:
                                    FloatingActionButton(
                                      elevation: 0,
                                      backgroundColor:
                                      EvieColors.primaryColor,
                                      onPressed: () {
                                        checkBleStatusAndConnectDevice(_bluetoothProvider);
                                      },
                                      //icon inside button
                                      child:
                                      widget.connectImage,
                                    )),
                                SizedBox(
                                  height: 12.h,
                                ),
                                if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                  Text(
                                    "Connecting bike",
                                    style: TextStyle(
                                        fontSize:
                                        12.sp,
                                        fontWeight:
                                        FontWeight
                                            .w400,
                                        color: EvieColors.darkGray),
                                  ),
                                } else ...{
                                  Text(
                                    "Tap to connect bike",
                                    style: TextStyle(
                                        fontSize:
                                        12.sp,
                                        fontWeight:
                                        FontWeight
                                            .w400,
                                        color: EvieColors.darkGray),
                                  ),
                                },

                              }

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),

        ],
      );

  }
}


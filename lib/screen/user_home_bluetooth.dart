import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_single_button_dialog.dart';

class UserHomeBluetooth extends StatefulWidget {
  const UserHomeBluetooth({Key? key}) : super(key: key);

  @override
  _UserHomeBluetoothState createState() => _UserHomeBluetoothState();
}

class _UserHomeBluetoothState extends State<UserHomeBluetooth> {
  late BluetoothProvider bluetoothProvider = context.watch<BluetoothProvider>();
  late BikeProvider bikeProvider = context.watch<BikeProvider>();

  Timer? countdownTimer;
  bool isCountDownOver = false;

  Duration myDuration = const Duration(seconds: 30);

  @override
  initState() {
    super.initState();
    startCountDownTimer();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    bluetoothProvider.stopScan();
    super.dispose();
  }

  void startCountDownTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(seconds: 30));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        setState(() {
          isCountDownOver = true;
          bluetoothProvider.stopScan();
        });
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (bluetoothProvider.bleStatus == BleStatus.ready) {
        SmartDialog.dismiss(tag: "bluetoothOff");
        if (bluetoothProvider.scanSubscription == null) {
          bluetoothProvider.startScan();
        }
      } else if (bluetoothProvider.bleStatus == BleStatus.poweredOff) {
        SmartDialog.show(
            keepSingle: true,
            //     tag: "bluetoothOff",
            widget: EvieDoubleButtonDialogCupertino(
                title: " \"EVIE\" Would Like to Use Bluetooth",
                content:
                "EVIE will use Bluetooth to stay connect with your EVIE bike.",
                leftContent: "Don't Allow",
                rightContent: "Setting",
                image: Image.asset(
                  "assets/icons/bluetooth_logo.png",
                  width: 36,
                  height: 36,
                ),
                onPressedLeft: () {
                  SmartDialog.dismiss();
                },
                onPressedRight: () {
                  OpenSettings.openBluetoothSetting();
                }));
      }
    });

    if (bluetoothProvider.isPaired == true) {
      bluetoothProvider.setIsPairedResult(false);
      if (bluetoothProvider.deviceID != null) {
        bikeProvider
            .uploadToFireStore(bluetoothProvider.deviceID)
            .then((result) {
          if (result == true) {
            SmartDialog.dismiss(status: SmartStatus.loading);
            SmartDialog.show(
                tag: "ConnectSuccess",
                widget: EvieSingleButtonDialogCupertino(
                    title: "Success",
                    content: "Connected",
                    rightContent: "OK",
                    onPressedRight: () {
                      SmartDialog.dismiss(tag: "ConnectSuccess");

                      ///Change to connect success page
                      changeToNameBikeScreen(context);
                      //changeToUserHomePageScreen(context);
                    }));
          } else {
            SmartDialog.show(
                widget: EvieSingleButtonDialogCupertino(
                    title: "Error",
                    content: "Error connect bike, try again",
                    rightContent: "OK",
                    onPressedRight: () {
                      SmartDialog.dismiss();
                    }));
          }
        });
      }
    }

    return Scaffold(
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5.h,
                ),

                SizedBox(
                  height: 3.h,
                ),
                bluetoothProvider.discoverDeviceList.isEmpty
                    ? Text(
                  "Scanning your Bike",
                  style: TextStyle(fontSize: 18.sp),
                )
                    : Text(
                  "Bluetooth found...",
                  style: TextStyle(fontSize: 18.sp),
                ),
                SizedBox(
                  height: 1.h,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: bluetoothProvider.discoverDeviceList.isEmpty
                ? Container(
              color: Colors.grey,
              height: 60.h,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const RipplePulseAnimation(),
                  const Image(
                    fit: BoxFit.fitWidth,
                    image:
                    AssetImage("assets/images/evie_bike_shadow_half.png"),
                  ),
                  IconButton(
                    iconSize: 12.h,
                    icon: Image.asset("assets/icons/bluetooth_logo.png"),
                    tooltip: 'Bluetooth',
                    onPressed: () {},
                  ),
                ],
              ),
            )
                : Container(
              height: 60.h,
              child: ListView.separated(
                itemCount: bluetoothProvider.discoverDeviceList.length,
                itemBuilder: (context, index) {
                  String key = bluetoothProvider.discoverDeviceList.keys
                      .elementAt(index);
                  return listItem(bluetoothProvider.discoverDeviceList[key]);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16,
                  bottom: EvieLength.buttonWord_ButtonBottom),
              child: EvieButton_ReversedColor(
                width: double.infinity,
                child: !isCountDownOver
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 2.h,
                      width: 4.w,
                      child: const CircularProgressIndicator(
                        color: EvieColors.PrimaryColor,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Scanning",
                      style: TextStyle(
                        color: EvieColors.PrimaryColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "Scan Again",
                  style: TextStyle(
                    color: EvieColors.PrimaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: !isCountDownOver
                    ? null
                    : () {
                  bluetoothProvider.stopScan();
                  isCountDownOver = false;
                  resetTimer();
                  startCountDownTimer();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16, right: 16, bottom: EvieLength.buttonWord_WordBottom),
              child: SizedBox(
                height: 4.h,
                width: 30.w,
                child: TextButton(
                  child: Text(
                    "Stop Scanning",
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: EvieColors.PrimaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: () {
                    bluetoothProvider.stopScan();
                    changeToUserHomePageScreen(context);
                  },
                ),
              ),
            ),
          ),
        ]));
  }

  Widget deviceMacAddress(String deviceId) {
    return Text(deviceId);
  }

  Widget deviceSignal(int rssi) {
    ///rssi strength Parameter
    if (rssi >= -70) {
      return Text(
        "Strong",
        style: TextStyle(
            fontSize: 11.8.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xff05A454)),
      );
    } else if (rssi >= -100 && rssi < -70) {
      return Text(
        "Medium",
        style: TextStyle(
            fontSize: 11.8.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xffE59200)),
      );
    } else if (rssi < -100) {
      return Text(
        "Weak",
        style: TextStyle(
            fontSize: 11.8.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xffF42525)),
      );
    } else {
      return Text(
        "N/A",
        style: TextStyle(
            fontSize: 11.8.sp, fontWeight: FontWeight.w400, color: Colors.grey),
      );
    }
  }

  Widget leading() {
    return const CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }

  ///Return container with self align item
  Widget listItem(DiscoveredDevice? discoveredDevice) {
    if (discoveredDevice != null) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Container(
                  height: 35.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 26.h,
                          decoration: const BoxDecoration(
                            color: Color(0xffDFE0E0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  discoveredDevice.name,
                                  style: TextStyle(
                                      fontSize: 14.8.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 0.8.h),
                                Text(
                                  "Ready to connect",
                                  style: TextStyle(
                                      fontSize: 11.8.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5F6060)),
                                ),
                                SizedBox(height: 0.8.h),
                                Row(
                                  children: [
                                    Container(
                                      height: 2.5.h,
                                      child: const Image(
                                        image: AssetImage(
                                            "assets/icons/bluetooth_small.png"),
                                      ),
                                    ),
                                    Text(
                                      "Strength",
                                      style: TextStyle(
                                          fontSize: 11.8.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff5F6060)),
                                    ),
                                    Spacer(),
                                    deviceSignal(discoveredDevice.rssi)
                                  ],
                                ),
                                SizedBox(height: 0.8.h),
                                EvieButton(
                                  width: double.infinity,
                                  child: Text(
                                    "Connect",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  onPressed: () {
                                    SmartDialog.show(
                                        backDismiss: false,
                                        tag: "ConnectBike",
                                        widget: EvieDoubleButtonDialogCupertino(
                                          //buttonNumber: "2",
                                            title: "Connect Bike",
                                            content: "Connect to this bike?",
                                            leftContent: "Cancel",
                                            rightContent: "Connect",
                                            image: Image.asset(
                                              "assets/evieBike.png",
                                              width: 36,
                                              height: 36,
                                            ),
                                            onPressedLeft: () {
                                              SmartDialog.dismiss(
                                                  tag: "ConnectBike");
                                            },
                                            onPressedRight: () {
                                              SmartDialog.dismiss(
                                                  tag: "ConnectBike");
                                              bluetoothProvider.stopScan();
                                              Navigator.pop(context);
                                              SmartDialog.showLoading(
                                                  backDismiss: false);
                                              try {
                                                bluetoothProvider.connectDevice(
                                                    discoveredDevice.id, "REw40n21");
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            }));
                                  },
                                ),
                                SizedBox(height: 1.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
              ),
            ),
            ]
          ),
        );
    }
    else {
      return Container();
    }
  }
}

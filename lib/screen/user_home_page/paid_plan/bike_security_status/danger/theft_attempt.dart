import 'dart:async';

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../../api/colours.dart';
import '../../../../../api/dialog.dart';
import '../../../../../api/fonts.dart';
import '../../../../../api/function.dart';
import '../../../../../api/provider/bike_provider.dart';
import '../../../../../api/provider/bluetooth_provider.dart';
import '../../../../../api/provider/current_user_provider.dart';
import '../../../../../api/provider/location_provider.dart';
import '../../../../../api/provider/setting_provider.dart';
import '../../../../../api/snackbar.dart';
import '../../../../../bluetooth/modelResult.dart';
import '../../../../../widgets/evie_single_button_dialog.dart';
import '../../../../../widgets/evie_slider_button.dart';
import '../../../paid_plan/bottom_sheet_widget.dart';
import '../../../home_page_widget.dart';

class BikeDanger extends StatefulWidget {

  final Widget? connectImage;
  final String? distanceBetween;
  final bool? isDeviceConnected;

  const BikeDanger({
    Key? key,
    required this.connectImage,
    required this.distanceBetween,
    required this.isDeviceConnected,
  }) : super(key: key);

  @override
  State<BikeDanger> createState() => _BikeDangerState();
}

class _BikeDangerState extends State<BikeDanger> {

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
  CableLockResult? cableLockState;
  DeviceConnectResult? deviceConnectResult;

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  bool dismissed = false;
  bool isWithinDistance = false;
  bool isLoaded = false;
  double percent = 0.0;

  bool isScanning = false;
  StreamSubscription? bleScanSub;

  @override
  void initState() {
    super.initState();
  }

  ///The data has finished loading, call your function here
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    if(isLoaded == false){
      if (_bluetoothProvider.currentBikeModel != null) {
        isLoaded = true;
        bleScanSub = _bluetoothProvider.startScanRSSI();
      }
    }

  }

  // didUpdateWidget(Widget oldWidget): If the parent widget changes and has to rebuild this widget (because it needs to give it different data),
  // but it's being rebuilt with the same runtimeType, then this method is called. '
  // 'This is because Flutter is re-using the state, which is long lived. In this case, you may want to initialize some data again, as you would in.

  @override
  void dispose() {
    bleScanSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
    cableLockState = _bluetoothProvider.cableLockState;
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    percent = _bluetoothProvider.deviceRssiProgress;

    Future.delayed(Duration.zero, () {
      if(
      //deviceConnectResult == null ||
      deviceConnectResult == DeviceConnectResult.disconnected
          || deviceConnectResult == DeviceConnectResult.scanTimeout
          || deviceConnectResult == DeviceConnectResult.connectError
          || deviceConnectResult == DeviceConnectResult.scanError){

        isScanning = false;
      }else if(
      deviceConnectResult == DeviceConnectResult.connected
          || deviceConnectResult == DeviceConnectResult.connecting
          || deviceConnectResult == DeviceConnectResult.scanning
      ){
        isScanning = true;
      }
    });


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
                    child: Image.asset("assets/buttons/home_indicator.png",
                      width: 40.w,
                      height: 4.h,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
                    child: Bike_Name_Row(
                        bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
                        distanceBetween: widget.distanceBetween ?? "-",
                        currentBikeStatusImage: "assets/images/bike_HPStatus/bike_danger.png",
                        settingProvider: _settingProvider,
                        isDeviceConnected: widget.isDeviceConnected! && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
                    child: IntrinsicHeight(
                      child: Bike_Status_Row(
                        currentSecurityIcon:
                        "assets/buttons/bike_security_danger.svg",
                        batteryImage: getBatteryImage(_bikeProvider.currentBikeModel?.batteryPercent ?? 0),
                        batteryPercentage: _bikeProvider.currentBikeModel?.batteryPercent ?? 0,
                        settingProvider: _settingProvider,
                        child: Text(
                          "Theft Attempt",
                          style: EvieTextStyles.headlineB,
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
                            padding:  EdgeInsets.only(top:0.h,left: 16.w, right: 16.w, bottom: 20.h),
                            child:   Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/bluetooth_small.svg",
                                ),
                                Text("Signal Strength", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                                Expanded(
                                  child: LinearPercentIndicator(
                                    padding: EdgeInsets.only(left: 29.w,right: 8.w),
                                    animation: true,
                                    lineHeight: 4.h,
                                    animationDuration: 500,
                                    percent: percent,
                                    progressColor: _getProgressColor(percent),
                                    backgroundColor: EvieColors.lightGray,
                                    animateFromLastPercent: true,
                                    barRadius: Radius.circular(10),
                                  ),
                                ),
                              ],
                            )
                        ),

                        Visibility(
                          // visible: deviceConnectResult == null
                          //     || deviceConnectResult == DeviceConnectResult.disconnected
                          //     || deviceConnectResult == DeviceConnectResult.scanTimeout
                          //     || deviceConnectResult == DeviceConnectResult.connectError
                          //     || deviceConnectResult == DeviceConnectResult.scanError,
                          visible: isScanning == false,
                          child:  Padding(
                            padding:  EdgeInsets.only(top:0.h,bottom:29.h),
                            child: EvieSliderButton(
                              dismissible: false,
                              action: () async {
                                print("action");

                                checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);

                                setState(() {
                                  isScanning = true;
                                });


                              }, text: "I'm with my bike",),
                          ),
                        ),

                        Visibility(
                          // visible:   deviceConnectResult == DeviceConnectResult.connected
                          //     || deviceConnectResult == DeviceConnectResult.connecting
                          //     || deviceConnectResult == DeviceConnectResult.scanning,
                          visible:   isScanning == true,
                          child:  SizedBox(
                              height: 96.h,
                              width: 96.w,
                              child:
                              FloatingActionButton(
                                elevation: 0,
                                backgroundColor:
                                EvieColors.primaryColor,
                                onPressed: deviceConnectResult == DeviceConnectResult.connected ? () {
                                  ///Check is connected

                                  _bluetoothProvider.setIsUnlocking(true);
                                  showUnlockingToast(context);

                                  StreamSubscription? subscription;
                                  subscription = _bluetoothProvider.cableUnlock().listen((unlockResult) {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();
                                    if (unlockResult.result == CommandResult.success) {
                                      //        showToLockBikeInstructionToast(context);
                                    } else {
                                      SmartDialog.dismiss(status: SmartStatus.loading);
                                      subscription?.cancel();
                                      //        showToLockBikeInstructionToast(context);
                                    }
                                  }, onError: (error) {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();
                                    showCannotUnlockBike();
                                  });
                                } : ()async{
                                  checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
                                },
                                //icon inside button
                                child:widget.connectImage,
                              )),
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
  Color _getProgressColor(double percent) {
    if (percent < 0.3) {
      return EvieColors.lightRed;
    } else if (percent < 0.7) {
      return EvieColors.lightOrange;
    } else {
      return EvieColors.successGreen;
    }
  }

}



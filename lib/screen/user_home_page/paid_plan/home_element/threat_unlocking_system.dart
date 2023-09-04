import 'dart:async';

import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/snackbar.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_single_button_dialog.dart';

import 'package:lottie/lottie.dart' as lottie;

class ThreatUnlockingSystem extends StatefulWidget {
  String page;
  ThreatUnlockingSystem({
    required this.page,
    Key? key
  }) : super(key: key);

  @override
  State<ThreatUnlockingSystem> createState() => _ThreatUnlockingSystemState();
}

class _ThreatUnlockingSystemState extends State<ThreatUnlockingSystem> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;

  Widget? buttonImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

    return EvieCard(
      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right:8.w, top: 8.h),
              child: SvgPicture.asset(
                "assets/buttons/info_grey.svg",

              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                      height: 96.h,
                      width: 96.w,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor:
                        EvieColors.primaryColor,
                        onPressed: () {
                          if(widget.page == "home"){

                            changeToThreatMap(context);

                            Future.delayed(const Duration(seconds: 1), () {
                              _bluetoothProvider.checkBLEStatus().listen((event) {
                                if(event == BleStatus.ready){
                                  showThreatConnectBikeDialog(context, setState, _bluetoothProvider,_bikeProvider);

                                  StreamSubscription? stream;
                                  stream = _bluetoothProvider.startScanRSSI().listen((bLEScanResult) {

                                    // if(bLEScanResult == BLEScanResult.scanTimeout){
                                    //   SmartDialog.dismiss();
                                    //   SmartDialog.dismiss();
                                    //
                                    //   stream?.cancel();
                                    // }
                                  });
                                }else if(event == BleStatus.poweredOff || event == BleStatus.unauthorized){
                                  showBluetoothNotTurnOn();
                                }
                              });
                            });

                          }else{
                            _bluetoothProvider.checkBLEStatus().listen((event) {
                              if(event == BleStatus.ready){
                                showThreatConnectBikeDialog(context, setState, _bluetoothProvider,_bikeProvider);

                                StreamSubscription? stream;
                                stream = _bluetoothProvider.startScanRSSI().listen((bLEScanResult) {

                                  // if(bLEScanResult == BLEScanResult.scanTimeout){
                                  //   SmartDialog.dismiss();
                                  //   SmartDialog.dismiss();
                                  //
                                  //   stream?.cancel();
                                  // }
                                });
                              }else if(event == BleStatus.poweredOff || event == BleStatus.unauthorized){
                                showBluetoothNotTurnOn();
                              }
                            });
                          }

                        },
                        //icon inside button
                        child: SvgPicture.asset(
                          "assets/buttons/scan_bike_button.svg",
                        ),
                      )),
                  SizedBox(
                    height: 12.h,
                  ),
                  Text(
                    "Tap to scan for bike",
                    style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                  ),
                ],
              ),
            ],
          )

        ],
      ),
    );
  }

  runBLEConnect(){
      _bluetoothProvider.checkBLEStatus().listen((event) {
        if(event == BleStatus.ready){
          showThreatConnectBikeDialog(context, setState, _bluetoothProvider,_bikeProvider);

          StreamSubscription? stream;
          stream = _bluetoothProvider.startScanRSSI().listen((bLEScanResult) {

            // if(bLEScanResult == BLEScanResult.scanTimeout){
            //   SmartDialog.dismiss();
            //   SmartDialog.dismiss();
            //
            //   stream?.cancel();
            // }
          });
        }else if(event == BleStatus.poweredOff || event == BleStatus.unauthorized){
          showBluetoothNotTurnOn();
        }
      });
  }
}



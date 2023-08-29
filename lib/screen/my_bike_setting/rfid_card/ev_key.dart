import 'dart:io';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';



class EVKey extends StatefulWidget {
  const EVKey({Key? key}) : super(key: key);

  @override
  _EVKeyState createState() => _EVKeyState();
}

class _EVKeyState extends State<EVKey> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  DeviceConnectResult? deviceConnectResult;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'EV-Key',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 32.5.h, 16.w,2.h),
                  child: Text(
                    "Unlock bike with EV-Key",
                    style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 0.h),
                  child: Text(
                    "Unlocking your bike has never been easier with the EV-Key! This convenient and secure method lets you access your bike with just a simple tap.\n\n "
                        "A maximum number of 5 EV-Key can be register.",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                  ),
                ),


                Expanded(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Container(
                        width: 200.w,
                        height: 228.84.h,
                        child: Lottie.asset(
                          'assets/animations/RFIDCardRegister.json',
                          // delegates: LottieDelegates(
                          //   text: (initialText) => '**$initialText**',
                          //   values: [
                          //     ValueDelegate.color(
                          //       const ['Rectangle Path 1', 'Rectangle 1', 'Path 1','Group 1',],
                          //       value: Colors.red,
                          //     ),
                          //   ],
                          // ),
                      ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 122.h),
                  child: Center(
                    child: Text(
                      "You don't have EV-Key registered yet.",
                      style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: SizedBox(
                  height: 48.h,
                  width: double.infinity,
                  child: EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Add EV-Key",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                    ),

                    onPressed: () async {
                        if (deviceConnectResult == null
                            || deviceConnectResult == DeviceConnectResult.disconnected
                            || deviceConnectResult == DeviceConnectResult.scanTimeout
                            || deviceConnectResult == DeviceConnectResult.connectError
                            || deviceConnectResult == DeviceConnectResult.scanError
                            || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                            ) {
                            _settingProvider.changeSheetElement(SheetList.registerEvKey);
                            showConnectDialog(_bluetoothProvider, _bikeProvider);
                              }
                              else if (deviceConnectResult == DeviceConnectResult.connected) {
                          _settingProvider.changeSheetElement(SheetList.registerEvKey);
                              }
                            },
                  ),
                ),
              ),
            ),
          ],
        ),),
    );
  }
}

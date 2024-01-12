import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';

class TroubleshootScreen extends StatefulWidget {
  const TroubleshootScreen({Key? key}) : super(key: key);

  @override
  State<TroubleshootScreen> createState() => _TroubleshootScreenState();
}

class _TroubleshootScreenState extends State<TroubleshootScreen> {
  late SettingProvider _settingProvider;
  late BluetoothProvider _bluetoothProvider;
  late BikeProvider _bikeProvider;

  DeviceConnectResult? deviceConnectResult;

  @override
  Widget build(BuildContext context) {
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: PageAppbar(
            title: 'Troubleshoot',
            onPressed: () {
              _settingProvider.changeSheetElement(SheetList.bikeSetting);
            },
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(0, 25.h, 0, 16.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w),
                    child: Text(
                      "Encountering problems with your bike? Explore our Troubleshoot Center to identify and troubleshoot common bike issues. Let's get you rolling smoothly!",
                      style: EvieTextStyles.body18,
                    ),
                  ),
                  SizedBox(height: 25.h,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bike Lock",
                              style: EvieTextStyles.body18,
                            ),
                            SizedBox(height: 4.h,),
                            Text(
                              "Your bike is currently locked, and you're unable to unlock it on the home page.",
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: EvieButton(
                                width: 120.w,
                                height: 36.h,
                                onPressed: () async {
                                  if (deviceConnectResult == null
                                      || deviceConnectResult == DeviceConnectResult.disconnected
                                      || deviceConnectResult == DeviceConnectResult.scanTimeout
                                      || deviceConnectResult == DeviceConnectResult.connectError
                                      || deviceConnectResult == DeviceConnectResult.scanError
                                      || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                                  ) {
                                    showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                                  }
                                  else if (deviceConnectResult == DeviceConnectResult.connected) {
                                    //SmartDialog.showLoading(msg: 'Entering Recovery Mode....');
                                    showCustomLightLoading('Restoring bike lock...');
                                    _bluetoothProvider.cableUnlock();
                                    await Future.delayed(Duration(seconds: 2));
                                    showRecoveringModeToast(context);
                                    SmartDialog.dismiss();
                                  }
                                },
                                child: Text(
                                  'Restore',
                                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h,),
                          ],
                        ),
                      ),
                      Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                            child: Divider(
                              thickness: 0.2.h,
                              color: EvieColors.darkWhite,
                              height: 0,
                            ),
                          )
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      const url = 'https://support.eviebikes.com/en-US';
                      final Uri _url = Uri.parse(url);
                      launch(_url);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          SizedBox(height: 12.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16.w, right: 16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "FAQ",
                                      style: EvieTextStyles.body18,
                                    ),
                                    SizedBox(height: 4.h,),
                                    Text(
                                      "Unable to locate the solution you're seeking? \nExplore our FAQ site.",
                                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 16.w),
                                child: SvgPicture.asset(
                                  "assets/buttons/external_link.svg",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h,),
                          Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                                child: Divider(
                                  thickness: 0.2.h,
                                  color: EvieColors.darkWhite,
                                  height: 0,
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ),
                ]
            ),
          )
        ),
    );
  }
}

import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/sheet.dart';

import '../../../../widgets/evie_card.dart';
import '../../home_page_widget.dart';


class Battery extends StatefulWidget {
  final bool isShow;
  const Battery({
    super.key, required this.isShow
  });

  @override
  State<Battery> createState() => _BatteryState();
}

class _BatteryState extends State<Battery> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    int batteryPercentage = _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected
        ? int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0")
        : _bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0;

    String estimatedDistance = getEstDistance(batteryPercentage, _settingProvider);

    return EvieCard(
      showInfo: widget.isShow ? true : null,
      onInfoPress: () {
        showBatteryInfoDialog(context);
      },
      onPress: (){
        showBatteryDetailsSheet(context);
      },
      title: "Battery",
      child: Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
              Row(
                 crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h, right: 8.w),
                    child: SvgPicture.asset(
                      getBatteryImage(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?
                      int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0")
                          : _bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0),
                      width: 30.w,
                      height: 60.h,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                              Padding(
                                padding:EdgeInsets.only(left: 0.w),
                                child: Text(
                                  "${_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?
                                  int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0") :
                                  _bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0}",
                                  style: EvieTextStyles.batteryPercent.copyWith(height: 0.7),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(right: 15.w),
                              child: Text(
                                " %",
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGray),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10.h),
                      Padding(
                          padding: EdgeInsets.only(left: 0.w, right: 15.w),
                          child: Text(
                            estimatedDistance,
                            style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h, top: 12.h),
              child: Text(
                calculateTimeAgo(_bikeProvider.currentBikeModel?.batteryModel?.lastUpdated?.toDate() ?? DateTime.now()),
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),),
           ],
        ),
      ),
    );
  }
}



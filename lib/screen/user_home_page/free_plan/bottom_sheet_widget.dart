import 'dart:io';

import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/provider/trip_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/switch_bike.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../bluetooth/modelResult.dart';

class Bike_Name_Row extends StatelessWidget {
  String bikeName;
  String distanceBetween;
  String currentBikeStatusImage;
  bool? isDeviceConnected;

  Bike_Name_Row({
    Key? key,
    required this.bikeName,
    required this.distanceBetween,
    required this.currentBikeStatusImage,
    required this.isDeviceConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  bikeName,
                    style:EvieTextStyles.h3,
                ),
                Visibility(
                  visible: isDeviceConnected!,
                  child: SvgPicture.asset(
                    "assets/icons/bluetooth_small.svg",
                    width: 20.w,
                    height: 20.h,
                  ),
                )
              ],
            ),

            SizedBox(
              height: 4.h,
            ),

            Text(
              isDeviceConnected! ? "With You" : "Bike is not connected",
              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
            ),
          ],
        ),

        GestureDetector(
          onTap: (){
            SmartDialog.dismiss(status: SmartStatus.allToast);
            showMaterialModalBottomSheet(
                expand: false,
                context: context,
                builder: (context) {
                  return SwitchBike();
                });
          },

          child: Padding(
            padding:  EdgeInsets.only(right: 16.w),
            child: Stack(
              children: [
                Image(
                  image: AssetImage(currentBikeStatusImage),
                  height: 59.h,
                  width: 86.w,
                ),
                Positioned(
                  top: -3,
                  right: 2,
                  child: SvgPicture.asset(
                    "assets/buttons/switch_button.svg",
                    width: 20.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Bike_Status_Row extends StatelessWidget {
  String currentSecurityIcon;
  LockState isLocked;
  String currentBatteryIcon;
  Widget child;
  String batteryPercentage;
  SettingProvider settingProvider;

  Bike_Status_Row({
    Key? key,
    required this.currentSecurityIcon,
    required this.isLocked,
    required this.currentBatteryIcon,
    required this.child,
    required this.batteryPercentage,
    required this.settingProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset(
        currentSecurityIcon,
        height:36.h,
        width: 36.w,
      ),
      SizedBox(width: 4.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Platform.isAndroid ? 135.w : 150.w,
            child: child,
          )
        ],
      ),
      const VerticalDivider(
        thickness: 1,
      ),
      SvgPicture.asset(
        currentBatteryIcon,
        width: 36.w,
        height: 36.h,
      ),
      SizedBox(
        width: 10.w,
      ),
      if (batteryPercentage == "-") ...{
        Text(
          "${batteryPercentage} %",
          style: EvieTextStyles.headlineB,
        ),
      } else ...{
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "${batteryPercentage} %",
            style: EvieTextStyles.headlineB,
          ),
          Text(
            ///Calculate based on battery percentage
            settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ? "Est 0km" : "Est 0miles",
            style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
          )
        ])
      }
    ]);
  }
}

import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/switch_bike.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
                  "ADD NEW BIKE",
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            SizedBox(
              height: 4.h,
            ),

            Text(
              isDeviceConnected! ? "With You" : "Bike is not connected",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),

        GestureDetector(
          onTap: () {

          },
          child: Image(
            image: AssetImage("assets/images/bike_HPStatus/bike_not_available.png"),
            height: 60.h,
            width: 87.w,
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
  String connectText;
  Widget child;
  String estKm;

  Bike_Status_Row({
    Key? key,
    required this.currentSecurityIcon,
    required this.isLocked,
    required this.currentBatteryIcon,
    required this.connectText,
    required this.child,
    required this.estKm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (isLocked == LockState.lock) ...{
        SvgPicture.asset(
          "assets/buttons/bike_security_lock_and_secure.svg",
          height: 36.h,
          width: 36.w,
        ),
      } else if (isLocked == LockState.unlock) ...{
        SvgPicture.asset(
          "assets/buttons/bike_security_unlock.svg",
          height: 36.h,
          width: 36.w,
        ),
      } else ...{
        SvgPicture.asset(
          "assets/icons/battery_not_available.svg",
          height: 36.h,
          width: 36.w,
        ),
      },
      SizedBox(width: 4.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 135.w,
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
      if (estKm == "") ...{
        Text(
          "${connectText} %",
          style: TextStyle(fontSize: 20.sp),
        ),
      } else ...{
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "${connectText} %",
            style: TextStyle(fontSize: 20.sp),
          ),
          Text(
            estKm,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          )
        ])
      }
    ]);
  }
}

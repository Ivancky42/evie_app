import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Bike_Name_Row extends StatelessWidget {
  String bikeName;
  String distanceBetween;
  String currentBikeStatusImage;

  Bike_Name_Row({
    Key? key,
    required this.bikeName,
    required this.distanceBetween,
    required this.currentBikeStatusImage,
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
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
                SvgPicture.asset(
                  "assets/icons/batch_tick.svg",
                  width: 20.w,
                  height: 20.h,
                ),
                SvgPicture.asset(
                  "assets/icons/connection.svg",
                  width: 20.w,
                  height: 20.h,
                ),
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              "Est. ${distanceBetween}m",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Image(
          image: AssetImage(currentBikeStatusImage),
          height: 60.h,
          width: 87.w,
        ),
      ],
    );
  }
}

class Bike_Status_Row extends StatelessWidget {
  String currentSecurityIcon;
  Widget child;
  String batteryImage;
  int batteryPercentage;

  Bike_Status_Row({
    Key? key,
    required this.currentSecurityIcon,
    required this.child,
    required this.batteryImage,
    required this.batteryPercentage,
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
            width: 135.w,
            child: child,
          )
        ],
      ),
      const VerticalDivider(
        thickness: 1,
      ),
      SvgPicture.asset(
        batteryImage,
        width: 36.w,
        height: 36.h,
      ),
      SizedBox(
        width: 10.w,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${batteryPercentage} %",
          style: TextStyle(fontSize: 20.sp),
        ),
        Text(
          "Est 0km",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        )
      ])
    ]);
  }
}

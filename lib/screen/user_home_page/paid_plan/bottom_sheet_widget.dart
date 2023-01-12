import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/switch_bike.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';


import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';

class Bike_Name_Row extends StatelessWidget {
  String bikeName;
  String distanceBetween;
  String currentBikeStatusImage;
  bool isDeviceConnected;

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
            Text(
              "Est. ${distanceBetween}m",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
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
          child: Image(
            image: AssetImage(currentBikeStatusImage),
            height: 59.h,
            width: 86.w,
          ),
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

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      children: [
        Column(
          mainAxisAlignment:
          MainAxisAlignment
              .start,
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [

            Row(
              children: [
                Text(
                  bikeName,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight:
                      FontWeight
                          .w700),
                ),

                Visibility(
                    visible: isDeviceConnected!,

                    child:   const Image(
                      image: AssetImage(
                          "assets/icons/bluetooth_small.png"),

                    ),
                )
              ],

            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              distanceBetween,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight:
                  FontWeight
                      .w400),
            ),
          ],
        ),
        Image(
          image: AssetImage(
              currentBikeStatusImage),
          height: 60.h,
          width: 87.w,
        ),
      ],
    );
  }
}


class Bike_Status_Row extends StatelessWidget {

  String currentSecurityIcon;
  String currentBatteryIcon;
  String connectText;
  Widget child;
  String estKm;

  Bike_Status_Row({
    Key? key,
    required this.currentSecurityIcon,
    required this.currentBatteryIcon,
    required this.connectText,
    required this.child,
    required this.estKm,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Container(
            width: 21.w,
            height: 24.h,
            child: Image(
              image: AssetImage(
                  currentSecurityIcon),
              height: 35.h,
              width: 35.w,
            ),
          ),
          SizedBox(width: 11.5.w),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
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
          Image(
            image: AssetImage(
                currentBatteryIcon),
            height: 24.h,
            width: 24.w,
            //height: 1.h,
          ),
          SizedBox(
            width: 10.w,
          ),

          if(estKm == "")...{
            Text(
              "${connectText} %",
              style: TextStyle(
                  fontSize: 20.sp
              ),
            ),

          }else...{
            Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children:[
                  Text(
                    "${connectText} %",
                    style: TextStyle(
                        fontSize: 20.sp
                    ),
                  ),
                  Text(estKm,style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),)
                ])
          }

        ]);
  }
}



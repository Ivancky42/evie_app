import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/model/bike_plan_model.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/model/user_bike_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';


class MyGarage extends StatefulWidget {
  const MyGarage({Key? key}) : super(key: key);

  @override
  _MyGarageState createState() => _MyGarageState();
}

class _MyGarageState extends State<MyGarage> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);


    return WillPopScope(
      onWillPop: () async {

        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'My Garage',
          onPressed: () {
            changeToMyAccount(context);
          },
        ),
        body: Stack(
          children: [
            _bikeProvider.userBikeList.isEmpty ?

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w,76.h,16.w,4.h),
                  child: Text(
                    "Add New Bike",
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                  child: Container(
                    child: Text(
                      "To start riding and using the app, you'll need to connect and setup your bike with your account.",
                      style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                    ),
                  ),
                ),


                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(75.w,98.h,75.w,127.84.h),
                    child: SvgPicture.asset(
                      "assets/images/riding_bike.svg",
                    ),
                  ),
                ),
              ],
            )
                :
            Padding(
              padding: EdgeInsets.only(bottom:100.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _bikeProvider.userBikeList.length,
                itemBuilder: (context, index) {
                  return listItem(
                      _bikeProvider.userBikeList.values.elementAt(index),
                      _bikeProvider.userBikeDetails.values.elementAt(index),
                    _bikeProvider.userBikePlans.values.elementAt(index),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
              ),
            ),



            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(_bikeProvider.userBikeList.isEmpty ? "Add New Bike" : "Add More Bike",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  onPressed: () {
                   changeToTurnOnQRScannerScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }

  Widget listItem(UserBikeModel userBikeList, BikeModel userBikeDetails, BikePlanModel? userBikePlan) {

    bool isPlanSubscript;
    final result = _bikeProvider.calculateDateDifference(userBikePlan!.periodEnd!.toDate());
    if(result < 0){
      isPlanSubscript = false;
    }else{
      isPlanSubscript = true;
    }

      return Padding(
          padding:EdgeInsets.only(left:16.w, right: 16.w, top:28.h),
          child: Stack(
            children: [
              SizedBox(
                  height: 340.h,
                  child: Stack(
                      children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 270.h,
                        decoration: const BoxDecoration(
                          color: EvieColors.lightGrayishCyan,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Padding(
                          padding:EdgeInsets.only(left:16.w, right: 16.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Center(
                              child: Text(
                              userBikeDetails.deviceName!,
                              style: TextStyle(
                                  fontSize: 14.8.sp,
                                  fontWeight: FontWeight.w500),
                              ),
                            ),

                              SizedBox(height: 14.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Plan",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400),
                                  ),

                                  Text(
                                    isPlanSubscript ? "Pro Plan" : "Free Plan",
                                    style: TextStyle(
                                        fontSize: 14.8.sp,
                                        color: EvieColors.darkGrayishCyan,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Plan Expiry",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                      userBikePlan.periodEnd?.toDate().toString() ?? "Free Forever",
                                    style: TextStyle(
                                        fontSize: 14.8.sp,
                                        color: EvieColors.darkGrayishCyan,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),

                              SizedBox(height: 0.8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Model",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "EVIE S series",
                                    style: TextStyle(
                                        fontSize: 14.8.sp,
                                        color: EvieColors.darkGrayishCyan,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Owner",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "owner",
                                    style: TextStyle(
                                        fontSize: 14.8.sp,
                                        color: EvieColors.darkGrayishCyan,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                        SizedBox(height: 15.h,),
                        Container(
                            height: 48.h,
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  SvgPicture.asset(
                                    "assets/icons/setting.svg",
                                    height:24.h,
                                    color: EvieColors.primaryColor,
                                  ),
                                  Text(
                                    "Bike Setting",
                                    style: TextStyle(
                                      color: EvieColors.primaryColor,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                              width: 1.5,
                              color: EvieColors.primaryColor,
                              ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.w)
                                ),
                                elevation: 0.0,
                                backgroundColor: const Color(0xffDFE0E0),
                              ),
                              onPressed: () async {
                                await _bikeProvider.changeBikeUsingIMEI(userBikeList.deviceIMEI);
                                changeToNavigatePlanScreen(context);
                              }
                            )
                        ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Image(
                        height: 86.71.h,
                        image: const AssetImage(
                            "assets/images/bike_HPStatus/bike_normal.png"),
                      ),
                    )
                  ])),
            ],
          ));
  }
}

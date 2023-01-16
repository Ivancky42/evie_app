import 'dart:async';
import 'dart:collection';
import 'dart:io';
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

import '../../../api/length.dart';
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
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w),
              child: _bikeProvider.userBikeList.isEmpty ?

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
              ListView.separated(
                itemCount: _bikeProvider.userBikeList.length,
                itemBuilder: (context, index) {
                //  String key = bluetoothProvider.discoverDeviceList.keys.elementAt(index);
                  return Container(
                    //  _bikeProvider.userBikeList[index]
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
                    changeToLetsGoScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }


}

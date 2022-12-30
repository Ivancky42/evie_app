import 'dart:async';
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

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_switch.dart';
import '../../widgets/evie_textform.dart';
import '../my_bike/my_bike_widget.dart';


class CurrentPlan extends StatefulWidget {
  const CurrentPlan({Key? key}) : super(key: key);

  @override
  _CurrentPlanState createState() => _CurrentPlanState();
}

class _CurrentPlanState extends State<CurrentPlan> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Subscription',
          onPressed: () {
            changeToNavigatePlanScreen(context);
          },
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Padding(
                    padding: EdgeInsets.only(top:28.h),
                    child: Text("Current Plan", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500, color: Color(0xff171617)),),
                  ),
                  Text(_bikeProvider.isPlanSubscript == false ? "Essential Plan" : "Pro Plan",style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Color(0xff252526)),),
                  Text(_bikeProvider.isPlanSubscript == false ?"Forever" : "${_bikeProvider.currentBikePlanModel!.periodStart?.toDate().toString()} - ${_bikeProvider.currentBikePlanModel!.periodEnd?.toDate().toString()}",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Color(0xff5F6060)),),
                  Padding(
                    padding: EdgeInsets.only(top:19.h),
                    child: Text("Status",style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Color(0xff5F6060)),),
                  ),
                  ///Active Color (0xff05A454)    Expired Color (0xffF42525)
                  Text("Active",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Color(0xff05A454)),),
                  BikePageDivider(),


                  Visibility(
                    visible: _bikeProvider.currentBikePlanModel != null && _bikeProvider.isPlanSubscript == false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:28.h),
                          child: Text("Expired Plan", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500, color: Color(0xff171617)),),
                        ),
                        Text("Pro Plan",style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Color(0xff252526)),),
                        Text("${_bikeProvider.currentBikePlanModel!.periodStart?.toDate().toString()} - ${_bikeProvider.currentBikePlanModel!.periodEnd?.toDate().toString()}",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Color(0xff5F6060)),),
                        Padding(
                          padding: EdgeInsets.only(top:19.h),
                          child: Text("Status",style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Color(0xff5F6060)),),
                        ),

                        ///Active Color (0xff05A454)    Expired Color (0xffF42525)
                        Text("Expired",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Color(0xffF42525)),),
                        BikePageDivider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(_bikeProvider.isPlanSubscript == false ? "Upgrade Plan" : "See Plan Detail",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  onPressed: () {
                    changeToManagePlanScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }
}

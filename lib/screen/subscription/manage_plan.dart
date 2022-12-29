import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/screen/subscription/essential_plan/essential_plan.dart';
import 'package:evie_test/screen/subscription/pro_plan/pro_plan.dart';
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

class ManagePlan extends StatefulWidget {
  const ManagePlan({Key? key}) : super(key: key);

  @override
  _ManagePlanState createState() => _ManagePlanState();
}

class _ManagePlanState extends State<ManagePlan> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToCurrentPlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Manage Plan',
          onPressed: () {
            changeToCurrentPlanScreen(context);
          },
        ),
        body: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 16.w, right: 16.w, bottom: 30.h),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffDFE0E0),
                          border: Border.all(
                            color: Color(0xffDFE0E0),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Container(
                        height: 40.h,
                        child: TabBar(
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // Creates border
                              color: Color(0xfff4f4f4)),
                          tabs: [
                            Text(
                              "Essential",
                              style: TextStyle(
                                  fontSize: 16.sp, color: Color(0xff383838)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Pro ",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Color(0xff383838)),
                                ),
                                Container(
                                  height: 23.h,
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                      color: EvieColors.PrimaryColor,
                                      border: Border.all(
                                        color: EvieColors.PrimaryColor,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(5))),
                                  child: Center(
                                    child: Text(
                                      "Best Value",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xffECEDEB)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Expanded(
                    child: TabBarView(children: [
                       EssentialPlan(),
                       ProPlan(),
                    ]),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

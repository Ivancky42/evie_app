import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/pro_plan/pro_plan.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';


import '../../../api/colours.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import 'essential_plan/essential_plan.dart';



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
        Navigator.of(context).pop();
        showCurrentPlanSheet(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Manage Plan',
          onPressed: () {
            Navigator.of(context).pop();
            showCurrentPlanSheet(context);
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
                          color: EvieColors.lightGrayishCyan,
                          border: Border.all(
                            color: EvieColors.lightGrayishCyan,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(30))),
                      child: Container(
                        height: 40.h,
                        child: TabBar(

                          /// Defined Tab Text Colour
                          labelColor: EvieColors.primaryColor,
                          unselectedLabelColor: EvieColors.lightBlack,

                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // Creates border
                              color: EvieColors.dividerWhite),
                          tabs: [

                            Text(
                              "Starter",
                              style: EvieTextStyles.ctaSmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Premium ",
                                  style: EvieTextStyles.ctaSmall,
                                ),
                                SvgPicture.asset(
                                  "assets/icons/batch_tick.svg",
                                  height: 16.h,
                                ),

                                // Container(
                                //   height: 23.h,
                                //   width: 70.w,
                                //   decoration: BoxDecoration(
                                //       color: EvieColors.primaryColor,
                                //       border: Border.all(
                                //         color: EvieColors.primaryColor,
                                //       ),
                                //       borderRadius: const BorderRadius.all(Radius.circular(5))),
                                //   child: Center(
                                //     child: Text(
                                //       "Best Value",
                                //       style: TextStyle(
                                //           fontSize: 12.sp,
                                //           color: Color(0xffECEDEB)),
                                //     ),
                                //   ),
                                // )

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                 const Expanded(
                    child: TabBarView(
                        children: [
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

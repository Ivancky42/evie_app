import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/trip_history/trip_history_data.dart';
import 'package:evie_test/screen/trip_history/week.dart';
import 'package:evie_test/screen/trip_history/year.dart';
import 'package:flutter/material.dart';

import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../widgets/evie_appbar.dart';
import 'day.dart';
import 'month.dart';

enum TotalData{
  mileage,
  noOfRide,
  carbonFootprint,
}

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
            padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 22.h),
            child: Container(
              child: Text(
                "Trip History",
                style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
              ),
            ),
          ),


            ///Detect is have bike
            ///Detect if plan subscript

            Expanded(
              child: DefaultTabController(
                  length: 4,
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

                                labelColor: EvieColors.primaryColor,
                                unselectedLabelColor: EvieColors.lightBlack,

                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: EvieColors.dividerWhite),

                                tabs: [
                                  Text(
                                    "Day",
                                    style: EvieTextStyles.ctaSmall,
                                  ),
                                  Text(
                                    "Week",
                                    style: EvieTextStyles.ctaSmall,
                                  ),
                                  Text(
                                    "Month",
                                    style: EvieTextStyles.ctaSmall,
                                  ),
                                  Text(
                                    "Year",
                                    style: EvieTextStyles.ctaSmall,
                                  ),
                                ],

                                ///Bold text when selected
                                //labelStyle: TextStyle(fontWeight: FontWeight.bold),

                              ),
                            ),
                          ),
                        ),

                        const Expanded(
                          child: TabBarView(
                              children: [
                                // TripDay(),
                                // TripWeek(),
                                // TripMonth(),
                                // TripYear(),

                               TripHistoryData("day"),
                               TripHistoryData("week"),
                               TripHistoryData("month"),
                               TripHistoryData("year"),
                              ]),
                        ),

                      ],
                    ),
                  )),
            ),

            // Stack(
            //   children: [
            //     Divider(
            //       thickness: 34.h,
            //       color: EvieColors.dividerWhite,
            //     ),
            //
            //     ///Recent activity / 2022 Stats
            //     Padding(
            //       padding: EdgeInsets.only(left: 16.w),
            //       child: Text("Recent Activity", style: EvieTextStyles.h4),
            //     ),
            //   ],
            // ),

            //Listview.separated / pagination
          ],
        ),
      ),
    );
  }
}


import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/trip_history/week.dart';
import 'package:evie_test/screen/trip_history/year.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../widgets/evie_appbar.dart';
import 'day.dart';
import 'month.dart';

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
                                    "Day",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Color(0xff383838)),
                                  ),
                                  Text(
                                    "Week",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Color(0xff383838)),
                                  ),
                                  Text(
                                    "Month",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Color(0xff383838)),
                                  ),
                                  Text(
                                    "Year",
                                    style: TextStyle(
                                        fontSize: 16.sp, color: Color(0xff383838)),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),

                         const Expanded(
                          child: TabBarView(
                              children: [
                                TripDay(),
                                TripWeek(),
                                TripMonth(),
                                TripYear(),
                              ]),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}


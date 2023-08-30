import 'dart:ui';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/ride_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/ride/ride_history_data.dart';
import 'package:evie_test/screen/ride/ride_history_data2.dart';
import 'package:flutter/material.dart';
import '../../api/fonts.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
              child: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0.h, 0.w, 22.h),
                          child: Container(
                            child: Text(
                              "Ride History",
                              style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 30.h),
                          child: Container(
                            decoration: BoxDecoration(
                                color: EvieColors.lightGrayishCyan,
                                border: Border.all(
                                  color: EvieColors.lightGrayishCyan,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(30)
                                )
                            ),
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
                              ),
                            ),
                          ),
                        ),

                        const Expanded(
                          child: TabBarView(
                              children: [
                                RideHistoryData2(RideFormat.day),
                                RideHistoryData2(RideFormat.week),
                                RideHistoryData2(RideFormat.month),
                                RideHistoryData2(RideFormat.year),
                              ]),
                        ),
                      ],
                    ),
                  ))
            ),
      ),
    );
  }
}


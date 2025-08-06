import 'package:evie_test/api/colours.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/trip_history/trip_history_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/fonts.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/trip_provider.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {

  late BikeProvider _bikeProvider;
  late TripProvider _tripProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // bool? exitApp = await showQuitApp() as bool?;
        // return exitApp ?? false;
        return false;
      },
      child: Scaffold(
        body: Container(
              ///Detect if user have bike
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
                              style: EvieTextStyles.target_reference_h1,
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
                                borderRadius: const BorderRadius.all(Radius.circular(30))),
                            child: SizedBox(
                              height: 40.h,
                              child: TabBar(

                                labelColor: EvieColors.primaryColor,
                                unselectedLabelColor: EvieColors.lightBlack,

                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: EvieColors.dividerWhite),

                                tabs: [
                                  Container(
                                    height: double.infinity,
                                    color: Colors.red,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Text(
                                            "Days",
                                            style: EvieTextStyles.ctaSmall,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Week",
                                            style: EvieTextStyles.ctaSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Month",
                                            style: EvieTextStyles.ctaSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Year",
                                            style: EvieTextStyles.ctaSmall,
                                          ),
                                        ],
                                      ),
                                    ),
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
                                TripHistoryData(TripFormat.day),
                                TripHistoryData(TripFormat.week),
                                TripHistoryData(TripFormat.month),
                                TripHistoryData(TripFormat.year),
                              ]),
                        ),
                      ],
                    ),
                  )),
            )
      ),
    );
  }
}


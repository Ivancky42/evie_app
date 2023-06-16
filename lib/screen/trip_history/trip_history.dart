import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_bike/api/backend/sim_api_caller.dart';
import 'package:evie_bike/api/colours.dart';
import 'package:evie_bike/api/provider/plan_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/bluetooth/modelResult.dart';
import 'package:evie_bike/screen/trip_history/trip_history_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/trip_provider.dart';
import '../../widgets/evie_appbar.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // bool? exitApp = await showQuitApp() as bool?;
        // return exitApp ?? false;
        return false;
      },
      child: Scaffold(
        body:
            Container(
              ///Detect if user have bike
              child: _bikeProvider.userBikeList.isNotEmpty ?
              ///Detect if premium plan subscript
                  _bikeProvider.isPlanSubscript == true ?
              DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 0.w, 22.h),
                          child: Container(
                            child: Text(
                              "Rides",
                              style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                            ),
                          ),
                        ),

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
                               TripHistoryData(TripFormat.day),
                               TripHistoryData(TripFormat.week),
                               TripHistoryData(TripFormat.month),
                               TripHistoryData(TripFormat.year),
                              ]),
                        ),
                      ],
                    ),
                  ))
                      :
                  Column(
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
                      Column(
                        children: [
                          Center(child: Text("You do not have plan subscript")),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 120.h),
                              child: Lottie.asset('assets/animations/add-bike.json'),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                  :
              Column(
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
                      Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(left:15.w, right:15.w),
                              child: SvgPicture.asset(
                                        "assets/images/bike_register_required.svg",
                                        height:608.h,
                              ),
                            ),
                          ),

                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 120.h),
                              child: Lottie.asset('assets/animations/add-bike.json'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            ),
      ),
    );
  }
}


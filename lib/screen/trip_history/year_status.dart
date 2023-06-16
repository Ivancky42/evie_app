import 'dart:math';

import 'package:evie_bike/api/colours.dart';
import 'package:evie_bike/api/provider/bike_provider.dart';
import 'package:evie_bike/api/provider/trip_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter_svg/svg.dart';

import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/provider/setting_provider.dart';

class YearStatus extends StatefulWidget{
  final DateTime pickedData;
  const YearStatus(this.pickedData,{ Key? key }) : super(key: key);
  @override
  _YearStatusState createState() => _YearStatusState();
}

class _YearStatusState extends State<YearStatus> {

  late SettingProvider _settingProvider;
  late TripProvider _tripProvider;

  double carbonFootPrint = 0;
  double totalMileage = 0;
  double noOfRide = 0;
  double averageSpeed = 0;
  double averageDuration = 0;

  @override
  Widget build(BuildContext context) {
    _settingProvider = Provider.of<SettingProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);

    getYearStatusData();


    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          color: EvieColors.dividerWhite,
          width: double.infinity,
          child: Padding(
            padding:  EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
            child: Text("${widget.pickedData.year} Status", style: EvieTextStyles.h4),
          ),
        ),

        Container(
          height: 77.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Carbon Footprint",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
                Text(
                  ///Carbon footprint per month = total carbon footprint / 12
                  "${((_tripProvider.currentTripHistoryLists.values.fold<double>(0, (prev, element) => prev + element.carbonPrint!))/12).toStringAsFixed(0)}g/month",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                )
              ],
            ),
          ),
        ),

        const EvieDivider(),

        Container(
          height: 77.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Mileage",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
                Text(
                  _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                  "${(totalMileage/1000).toStringAsFixed(2)}km/ride" :
                  "${_settingProvider.convertMeterToMilesInString(totalMileage)}miles/ride",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                )
              ],
            ),
          ),
        ),

        const EvieDivider(),

        Container(
          height: 77.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No of Ride",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
                Text(
                  "${noOfRide.toInt()}ride/month",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                )
              ],
            ),
          ),
        ),

        const EvieDivider(),

        // Average Speed per Ride = Total Distance / Total Time per Ride
        // Total Time = End Time - Start Time
        Container(
          height: 77.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Average Speed",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
                Text(
                  _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                  "${averageSpeed.toStringAsFixed(2)}kmh/ride":
                  "${(averageSpeed*0.621371).toStringAsFixed(2)}mph/ride",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                )
              ],
            ),
          ),
        ),

        const EvieDivider(),

        // Average Duration = Total Time / Number of Rides
        // Total Time = End Time - Start Time
        Container(
          height: 77.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Duration",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                ),
                Text(
                  "${formatTotalDuration(averageDuration)}/ride",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                )
              ],
            ),
          ),
        ),

        const EvieDivider(),

        Padding(
          padding:
          const EdgeInsets.all(6),
          child:  Padding(
            padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
            child: Container(
              height: 45.h,
              width: double.infinity,
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Show All Data",
                      style:  EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                    ),
                    SvgPicture.asset(
                      "assets/buttons/external_link.svg",
                    ),
                  ],
                ),
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,

                ),
              ),
            ),
          ),
        ),

      ],);
  }

  getYearStatusData(){
      List<double> returnData = _tripProvider.getYearStatusData(widget.pickedData);
      totalMileage = returnData.elementAt(0);
      noOfRide = returnData.elementAt(1);
      averageSpeed = returnData.elementAt(2);
      averageDuration = returnData.elementAt(3);

  }
}



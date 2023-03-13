import 'dart:math';

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/trip_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/evie_oval.dart';


class RecentActivity extends StatefulWidget{
  final TripFormat format;
  const RecentActivity(this.format,{ Key? key }) : super(key: key);
  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {

  List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
  late String currentData;
  late List<TripHistoryModel> currentTripHistoryListDay = [];

  late List<ChartData> chartData = [];
  late TooltipBehavior _tooltip;
  late NumericAxis xNumericAxis;

  DateTime? pickedDate = DateTime.now();

  late BikeProvider _bikeProvider;
  late TripProvider _tripProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);


    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [


        Container(
          color: EvieColors.dividerWhite,
          width: double.infinity,
          child: Padding(
            padding:  EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
            child: Text("Recent Activity", style: EvieTextStyles.h4),
          ),
        ),

        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return Divider(height: 1.h);
          },
          itemCount: _tripProvider.currentTripHistoryLists.length,
          itemBuilder: (context, index) {
            return  ListTile(
              title: Text(_tripProvider.currentTripHistoryLists.values.elementAt(index).startTime.toDate().toString()),
              subtitle: Text(_tripProvider.currentTripHistoryLists.values.elementAt(index).distance.toString()),

            );
          },
        ),

        //Listview.separated / pagination

      ],);
  }

}


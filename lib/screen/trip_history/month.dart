import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';


class TripMonth extends StatefulWidget{
  const TripMonth({ Key? key }) : super(key: key);
  @override
  _TripMonthState createState() => _TripMonthState();
}

class _TripMonthState extends State<TripMonth> {
  late List<_ChartData> data = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);

    _bikeProvider.currentTripHistoryLists.forEach((key, value) {
      data.add(_ChartData(value.startTime.toDate(), value.distance.toDouble()));
    });


    return   Padding(
        padding: EdgeInsets.only(left: 32.w, right: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text("TOTAL"),
            Row(
              children: [
                Text("1234g"),
                SizedBox(width: 4.w,),
                Text('Carbon Footprint')
              ],
            ),
            Text('Thursday, 1234567'),

            SfCartesianChart(
                primaryXAxis: CategoryAxis(),

                ///maximum, data.duration highest
                primaryYAxis: NumericAxis(
                  //minimum: 0, maximum: 2500, interval: 300,
                  opposedPosition: true,
                ),

                tooltipBehavior: _tooltip,
                series: <ChartSeries<_ChartData, dynamic>>[
                  ColumnSeries<_ChartData, dynamic>(
                      dataSource: data,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      name: data.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(5),
                        topLeft: Radius.circular(5),
                      )
                  )
                ])

          ],)
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
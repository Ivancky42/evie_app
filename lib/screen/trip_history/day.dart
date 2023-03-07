import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';


class TripDay extends StatefulWidget{

  const TripDay({Key? key,}) : super(key: key);

  @override
  State<TripDay> createState() => _TripDayState();
}

class _TripDayState extends State<TripDay> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      _ChartData('12.00', 1623),
      _ChartData('13.00', 2100),
      _ChartData('12.00', 899),
      _ChartData('14.00', 767),
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            primaryYAxis: NumericAxis(minimum: 0, maximum: 2500, interval: 300,
              opposedPosition: true,
            ),

            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  color: EvieColors.primaryColor,)
            ])

      ],)
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
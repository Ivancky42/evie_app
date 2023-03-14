import 'dart:math';

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/trip_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/trip_history/recent_activity.dart';
import 'package:evie_test/screen/trip_history/year_status.dart';
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


class TripHistoryData extends StatefulWidget{
  final TripFormat format;
  const TripHistoryData(this.format,{ Key? key }) : super(key: key);
  @override
  _TripHistoryDataState createState() => _TripHistoryDataState();
}

class _TripHistoryDataState extends State<TripHistoryData> {

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
  void initState() {
    _tooltip = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series,
            int pointIndex, int seriesIndex) {
          return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Distance: ${data.y.toStringAsFixed(0) ?? "0"}',
                  style: EvieTextStyles.body16.copyWith(color: EvieColors.white),
                ),
              )
          );
        });

    getChartAxis();

    currentData = totalData.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);

    getData(_bikeProvider, _tripProvider);
    getChartAxis();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Text("TOTAL", style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Row(
              children: [

                if(currentData == totalData.elementAt(0))...{
                  Text((currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2), style: EvieTextStyles.display,),
                  Text(" km", style: EvieTextStyles.body18,),
                }else if(currentData == totalData.elementAt(1))...{
                  // Text(_bikeProvider.currentTripHistoryLists.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                  Text(currentTripHistoryListDay.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                  Text("rides", style: EvieTextStyles.body18,),
                }else if(currentData == totalData.elementAt(2))...{
                  Text(" 0", style: EvieTextStyles.display,),
                  Text(" g", style: EvieTextStyles.body18,),
                },

                SizedBox(width: 4.w,),
                EvieOvalGray(
                  buttonText: currentData,
                  onPressed: (){
                    if(currentData == totalData.first){
                      setState(() {
                        currentData = totalData.elementAt(1);
                      });
                    }else if(currentData == totalData.elementAt(1)){
                      setState(() {
                        currentData = totalData.last;
                      });
                    }else if(currentData == totalData.last){
                      setState(() {
                        currentData = totalData.first;
                      });
                    }
                  },)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Row(
              children: [
                Text(
                  widget.format == TripFormat.week ?
                  "${monthsInYear[pickedDate!.month]} ${pickedDate!.day}-${pickedDate!.add(Duration(days: 6)).day} ${pickedDate!.year}" :
                  "${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}",
                  style: const TextStyle(color: EvieColors.darkGrayishCyan),),

                Expanded(
                  child:  EvieButton_PickDate(
                    showColour: false,
                    width: 155.w,
                    onPressed: () async {
                    //  pickedDate
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate ?? DateTime.now(),
                        firstDate:  DateTime(DateTime.now().year-2),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: EvieColors.primaryColor,
                            ), ), child: child!);
                        },
                      );

                        if(picked == null){
                          setState(() {
                            pickedDate == DateTime.now();
                          });
                        }else{
                          setState(() {
                            pickedDate = picked;
                          });
                        }
                    },
                    child: SvgPicture.asset(
                      "assets/buttons/calendar.svg",
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (DragEndDetails details){
                double velocity = details.velocity.pixelsPerSecond.dx;
                if(velocity > 0){
                  ///Swipe right, go to previous date
                  setState(() {
                    pickedDate = pickedDate?.subtract(Duration(days: 1));
                  });
                }else{
                  ///Swipe left, go to next date

                  //If picked date less than today
                  if(calculateDateDifferenceFromNow(pickedDate!) < 0){
                    setState(() {
                      pickedDate = pickedDate?.add(Duration(days: 1));
                    });
                  }
                }
              },
              child:
              SfCartesianChart(
                primaryXAxis: widget.format == TripFormat.day || widget.format == TripFormat.week
                    ? CategoryAxis(
                    isVisible: true,
                  )
                    :
                xNumericAxis,

                ///maximum, data.duration highest
                primaryYAxis: NumericAxis(
                  //minimum: 0, maximum: 2500, interval: 300,
                  opposedPosition: true,
                ),

                tooltipBehavior: _tooltip,
                series: <ColumnSeries<ChartData, dynamic>>[
                  ColumnSeries<ChartData, dynamic>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) =>
                    widget.format == TripFormat.day ? "${data.x.hour.toString().padLeft(2,'0')}:${data.x.minute.toString().padLeft(2,'0')}" :
                    widget.format == TripFormat.week ? weekdayName[data.x.weekday] :
                  //  widget.format == TripFormat.year ? monthName[data.x] :
                    data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    ///width of the column
                    width: 0.8,
                    ///Spacing between the column
                    spacing: 0.2,
                    name: chartData.toString(),
                    color: EvieColors.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight:  Radius.circular(5),
                      topLeft: Radius.circular(5),
                    ),
                  ),

                ],
                enableAxisAnimation: true,
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: false,
                  enablePinching: false,
                ),

              ),
            ),
          ),


          if(widget.format == TripFormat.year)...{
            YearStatus(pickedDate!),
          }else...{
            RecentActivity(widget.format),
          }

        ],),
    );
  }


  getChartAxis(){
    switch(widget.format){
      case TripFormat.day:
        xNumericAxis = NumericAxis(
          isVisible: true,
        );
        break;
      case TripFormat.week:
        xNumericAxis = NumericAxis(
          minimum: pickedDate!.day.toDouble(),
          maximum: pickedDate!.add(const Duration(days: 6)).day.toDouble(),
          interval: 1,
          isVisible: true,
        );
        break;
      case TripFormat.month:
        xNumericAxis = NumericAxis(
          minimum: 1,
          maximum: daysInMonth(pickedDate!.year,  pickedDate!.month).toDouble(),
          interval: 4,
          isVisible: true,
        );
        break;
      case TripFormat.year:
        xNumericAxis = NumericAxis(
          minimum: 1,
          maximum: 12,
          interval: 1,
          isVisible: true,
        );
        break;
    }
  }

  getData(BikeProvider bikeProvider, TripProvider tripProvider){

    switch(widget.format){
      case TripFormat.day:
        chartData.clear();
        currentTripHistoryListDay.clear();

        tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
            chartData.add(ChartData(value.startTime.toDate(), value.distance.toDouble()));
            currentTripHistoryListDay.add(value);
          }
        });
        return;
      case TripFormat.week:
        chartData.clear();
        currentTripHistoryListDay.clear();
        // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

        // for(int i = pickedDate!.add(const Duration(days: 0)).day; i < pickedDate!.add(const Duration(days: 6)).day; i ++){
        //   chartData.add((ChartData(i, 0)));
        // }

        chartData.add((ChartData(pickedDate!.add(const Duration(days: 0)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 1)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 2)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 3)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 4)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 5)), 0)));
        chartData.add((ChartData(pickedDate!.add(const Duration(days: 6)), 0)));

        tripProvider.currentTripHistoryLists.forEach((key, value) {
          if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 7)))){
            ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
            newData.y = newData.y + value.distance.toDouble();
            currentTripHistoryListDay.add(value);
          }
        });
        return;
      case TripFormat.month:
        chartData.clear();
        currentTripHistoryListDay.clear();

        final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);

        tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){

            double totalDistance = 0;

            for (int day = 1; day <= totalDaysInMonth; day++) {
              if(value.startTime.toDate().day == day){
                totalDistance += value.distance;
                chartData.add(ChartData(value.startTime.toDate().day, totalDistance));
              }
            }
              currentTripHistoryListDay.add(value);
          }
        });

        return;
      case TripFormat.year:
        chartData.clear();
        currentTripHistoryListDay.clear();

        tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().year == pickedDate!.year){

            double totalDistance = 0;

            for (int month = 1; month <= 12; month++) {
              if(value.startTime.toDate().month == month){
                totalDistance += value.distance;
                chartData.add(ChartData(value.startTime.toDate().month, totalDistance));
              }
            }
            currentTripHistoryListDay.add(value);
          }
        });
        return;
    }
  }
}


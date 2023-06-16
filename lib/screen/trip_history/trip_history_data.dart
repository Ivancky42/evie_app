import 'dart:math';

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
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


  late List<TripHistoryModel> currentTripHistoryListDay = [];

  late List<ChartData> chartData = [];
  late TooltipBehavior _tooltip;


  DateTime now = DateTime.now();
  DateTime? pickedDate;

  late BikeProvider _bikeProvider;
  late TripProvider _tripProvider;
  late SettingProvider _settingProvider;

  bool isFirst = true;
  late String selectedDate;

  @override
  void initState() {
    pickedDate = DateTime(now.year, now.month, now.day);

    selectedDate = widget.format ==
        TripFormat.week ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}" :
        widget.format == TripFormat.month ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}";

    _tooltip = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series,
            int pointIndex, int seriesIndex) {
          return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                Text(
                  "Distance: ${(data.y/1000).toStringAsFixed(0) ?? "0"}km",
                  style: EvieTextStyles.body16.copyWith(color: EvieColors.white),
                ):
                Text(
                  "Distance: ${_settingProvider.convertMeterToMilesInString(data.y) ?? "0"}miles",
                  style: EvieTextStyles.body16.copyWith(color: EvieColors.white),
                ),
              )
          );
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    getData(_bikeProvider, _tripProvider);

    return SingleChildScrollView(
      physics:const BouncingScrollPhysics(),
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

                if(_tripProvider.currentData == _tripProvider.dataType.elementAt(0))...{
                  _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
                  Row(
                    children: [
                      Text((currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2), style: EvieTextStyles.display,),
                      Text(" km", style: EvieTextStyles.body18,),
                    ],
                  ):
                  Row(
                    children: [
                      Text(_settingProvider.convertMeterToMilesInString(currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())), style: EvieTextStyles.display,),
                      Text(" miles", style: EvieTextStyles.body18,),
                    ],
                  ),

                }else if(_tripProvider.currentData == _tripProvider.dataType.elementAt(1))...{
                  // Text(_bikeProvider.currentTripHistoryLists.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                  Text(currentTripHistoryListDay.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                  Text("rides", style: EvieTextStyles.body18,),
                }else if(_tripProvider.currentData == _tripProvider.dataType.elementAt(2))...{
                  Text("${(currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.carbonPrint!.toDouble())).toStringAsFixed(0)}", style: EvieTextStyles.display,),
                  Text(" g", style: EvieTextStyles.body18,),
                },

                SizedBox(width: 4.w,),
                EvieOvalGray(
                  buttonText: _tripProvider.currentData,
                  onPressed: (){
                    if(_tripProvider.currentData == _tripProvider.dataType.first){
                      _tripProvider.setCurrentData(_tripProvider.dataType.elementAt(1));
                    }else if(_tripProvider.currentData == _tripProvider.dataType.elementAt(1)){
                      _tripProvider.setCurrentData(_tripProvider.dataType.last);
                    }else if(_tripProvider.currentData == _tripProvider.dataType.last){
                      _tripProvider.setCurrentData(_tripProvider.dataType.first);
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
                  selectedDate,
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
                          if(picked.day == DateTime.now().day && picked.month == DateTime.now().month && picked.year == DateTime.now().year){
                            setState(() {
                              pickedDate = picked;
                              isFirst = true;
                              selectedDate = "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}";
                            });
                          }else{
                            setState(() {
                              pickedDate = picked;
                              isFirst = false;
                              selectedDate = "${monthsInYear[pickedDate!.month]} ${pickedDate!.day}-${pickedDate!.add(Duration(days: 6)).day} ${pickedDate!.year}";
                            });
                          }
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
                if(widget.format == TripFormat.month){
                  if(velocity > 0){
                    ///Swipe right, go to previous date
                    setState(() {
                      pickedDate = pickedDate?.subtract(Duration(days: 30));
                    });
                  }else{
                    ///Swipe left, go to next date

                    //If picked date less than today
                    if(calculateDateDifferenceFromNow(pickedDate!) < 0){
                      setState(() {
                        pickedDate = pickedDate?.add(Duration(days: 30));
                      });
                    }
                  }
                }else if(widget.format == TripFormat.year){
                  if(velocity > 0){
                    ///Swipe right, go to previous date
                    setState(() {
                      pickedDate = pickedDate?.subtract(Duration(days: 365));
                    });
                  }else{
                    ///Swipe left, go to next date

                    //If picked date less than today
                    if(calculateDateDifferenceFromNow(pickedDate!) < 0){
                      setState(() {
                        pickedDate = pickedDate?.add(Duration(days: 365));
                      });
                    }
                  }
                }else{
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
                }

              },
              child:
              SfCartesianChart(
                primaryXAxis: CategoryAxis(
                    isVisible: true,
                  ),

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
                      widget.format == TripFormat.month ? data.x.day :
                      widget.format == TripFormat.year ? monthNameHalf[data.x.month] :
                      data.x,

                    yValueMapper: (ChartData data, _) =>
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                      (data.y/1000):
                      _settingProvider.convertMeterToMiles(data.y.toDouble()),

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

        if (isFirst) {
          chartData.clear();
          currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for(int i = 0; i < 7; i ++){
            chartData.add((ChartData(pickedDate!.subtract(Duration(days: i)), 0)));
          }

          chartData = chartData.reversed.toList();

          tripProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 1))) && value.startTime.toDate().isAfter(pickedDate!.subtract(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
              newData.y = newData.y + value.distance.toDouble();
              currentTripHistoryListDay.add(value);
            }
          });
        }
        else {
          chartData.clear();
          currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for (int i = 0; i < 7; i ++) {
            chartData.add((ChartData(pickedDate!.add(Duration(days: i)), 0)));
          }

          chartData = chartData.reversed.toList();

          tripProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) =>
              data.x.day == value.startTime
                  .toDate()
                  .day);
              newData.y = newData.y + value.distance.toDouble();
              currentTripHistoryListDay.add(value);
            }
          });
        }

        return;
      case TripFormat.month:
        chartData.clear();
        currentTripHistoryListDay.clear();

        final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);

        for(int i = 1; i <= totalDaysInMonth; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, i), 0)));
        }
        tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
            newData.y = newData.y + value.distance.toDouble();
            currentTripHistoryListDay.add(value);
          }
        });

        return;
      case TripFormat.year:
        chartData.clear();
        currentTripHistoryListDay.clear();

        for(int i = 1; i <= 12; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, i, 1), 0)));
        }

        tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.month == value.startTime.toDate().month);
            newData.y = newData.y + value.distance.toDouble();
            currentTripHistoryListDay.add(value);

          }
        });
        return;
    }
  }
}


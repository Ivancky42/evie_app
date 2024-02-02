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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../api/enumerate.dart';
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

  late List<ChartData> chartData = [];
  late TooltipBehavior _tooltip;


  DateTime now = DateTime.now();
  DateTime? pickedDate;

  late BikeProvider _bikeProvider;
  late TripProvider _tripProvider;
  late SettingProvider _settingProvider;

  bool isFirst = true;
  late String selectedDate;

  late SelectionBehavior _selectionBehavior;

  double? selectedMileageTemp;
  DateTime? selectedDateTemp;
  String? selectedMileage;
  ///Selected carbon footprint
  String? selectedCF;
  String? selectedRides;


  bool isFirstLoad = true;
  bool isDataEmpty = true;

  TrackballBehavior? _trackballBehavior;

  @override
  void initState() {

    pickedDate = DateTime(now.year, now.month, now.day);

    selectedDate = widget.format == TripFormat.day ?
        "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"    :
        widget.format == TripFormat.week ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day}, ${pickedDate!.year}" :
        widget.format == TripFormat.month ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
        "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";

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

     //  _selectionBehavior = SelectionBehavior(
     //    enable: true,
     //    selectedColor: EvieColors.primaryColor,
     //    unselectedColor: EvieColors.lightPrimaryColor,
     // );

    _trackballBehavior = TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(format: 'point.x : point.y'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    if(isFirstLoad){
      _tripProvider.changeSelectedIndex(-1, TripFormat.day);
      getData();
      checkIsDataEmpty();
      isFirstLoad = false;
    }

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
                      Text(
                        ///Selected km
                        selectedMileage != null ? emptyFormatting(((stringToDouble(selectedMileage!))/1000).toStringAsFixed(2)) :
                        emptyFormatting((_tripProvider.currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2)), style: EvieTextStyles.display,),
                      Text(" km", style: EvieTextStyles.body18,),
                    ],
                  ):
                  Row(
                    children: [
                      Text(
                        selectedMileage != null ? emptyFormatting(_settingProvider.convertMeterToMilesInString(((stringToDouble(selectedMileage!))/1000).toStringAsFixed(2))) :
                         emptyFormatting(_settingProvider.convertMeterToMilesInString(_tripProvider.currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()))), style: EvieTextStyles.display,),
                      Text(" miles", style: EvieTextStyles.body18,),
                    ],
                  ),
                }
                else if(_tripProvider.currentData == _tripProvider.dataType.elementAt(1))...{
                  // Text(_bikeProvider.currentTripHistoryLists.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                  Text(selectedRides != null ? emptyFormatting(thousandFormatting(stringToDouble(selectedRides!))) :
                  emptyFormatting(_tripProvider.currentTripHistoryListDay.length.toStringAsFixed(0)), style: EvieTextStyles.display,),
                  Text(" rides", style: EvieTextStyles.body18,),
                }else if(_tripProvider.currentData == _tripProvider.dataType.elementAt(2))...{
                  Text(
                    selectedCF != null ? emptyFormatting(thousandFormatting(stringToDouble(selectedCF!))) :
                     emptyFormatting(thousandFormatting((_tripProvider.currentTripHistoryListDay.fold<int>(0, (prev, element) => prev + element.carbonPrint!)))), style: EvieTextStyles.display,),
                  Text(" g", style: EvieTextStyles.body18,),
                },

                SizedBox(width: 4.w,),
                EvieOvalGray(
                  buttonText: _tripProvider.currentData == "Carbon Footprint" ? "CO₂ Saved" : _tripProvider.currentData == "No of Ride" ? "No. of Rides"  : _tripProvider.currentData == "Distance" ? "Distance" :_tripProvider.currentData,
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
                  selectedDateTemp != null ?
                  widget.format == TripFormat.day?
                  "${selectedDateTemp!.hour.toString().padLeft(2,'0')}:${selectedDateTemp!.minute.toString().padLeft(2,'0')} ${weekdayNameFull[selectedDateTemp!.weekday]}, ${monthsInYear[selectedDateTemp!.month]} ${selectedDateTemp!.day} ${selectedDateTemp!.year}"  :
                  widget.format == TripFormat.week ?
                  "${weekdayNameFull[selectedDateTemp!.weekday]}, ${monthsInYear[selectedDateTemp!.month]} ${selectedDateTemp!.day} ${selectedDateTemp!.year}" :
                  widget.format == TripFormat.month ?
                  "${weekdayNameFull[selectedDateTemp!.weekday]}, ${monthsInYear[selectedDateTemp!.month]} ${selectedDateTemp!.day} ${selectedDateTemp!.year}" :
                  "${monthNameHalf[selectedDateTemp!.month]} ${selectedDateTemp!.year}" :
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

                              selectedDate = widget.format == TripFormat.day ?
                              "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
                              widget.format == TripFormat.week ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}" :
                              widget.format == TripFormat.month ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
                              "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";
                            });
                          }else{
                            setState(() {
                              pickedDate = picked;
                              isFirst = false;

                              selectedDate = widget.format == TripFormat.day ?
                              "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
                              widget.format == TripFormat.week ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.day}-${pickedDate!.add(Duration(days: 6)).day} ${pickedDate!.year}" :
                              widget.format == TripFormat.month ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
                              "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";

                            });
                          }
                        }
                      getData();
                      checkIsDataEmpty();
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
                getData();
                checkIsDataEmpty();
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

              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfCartesianChart(
                    onSelectionChanged: (SelectionArgs args) {
                      var tappedData = args.pointIndex < chartData.length
                          ? chartData[args.pointIndex]
                          : null;
                      if (tappedData != null) {
                       // _tripProvider.changeSelectedIndex(tappedData.y);

                        selectedMileageTemp = tappedData.y;
                        selectedDateTemp = tappedData.x;

                        ///Press selected index
                        if(widget.format == _tripProvider.tripFormat && args.pointIndex == _tripProvider.selectedIndex){
                          _tripProvider.changeSelectedIndex(-1, TripFormat.day);
                          setState(() {
                            selectedMileage = null;
                            selectedCF = null;
                            selectedRides = null;
                            selectedDateTemp = null;
                          });
                        }else{
                          ///Press selected index
                          _tripProvider.changeSelectedIndex(args.pointIndex, widget.format);
                        }

                        getData();
                        checkIsDataEmpty();

                      }
                    },
                    // onSelectionChanged: (index){
                    //   print(index.pointIndex);
                    // },
                    primaryXAxis: CategoryAxis(
                        isVisible: true,
                        // plotBands: <PlotBand>[
                        //
                        //   PlotBand(
                        //       start: ,
                        //       end: ,
                        //       borderColor: EvieColors.primaryColor,
                        //       borderWidth: 0.5.w,
                        //       dashArray: const <double>[1,1]),
                        // ]
                      ),
                    ///maximum, data.duration highest
                    primaryYAxis: NumericAxis(
                      //minimum: 0, maximum: 2500, interval: 300,
                      opposedPosition: true,
                    ),

                    ///ToolTip
                    //tooltipBehavior: _tooltip,
                    series: <ColumnSeries<ChartData, dynamic>>[
                      ColumnSeries<ChartData, dynamic>(

                        //selectionBehavior: _selectionBehavior,

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
                    trackballBehavior: _trackballBehavior,
                  ),

                  Visibility(
                      visible: isDataEmpty,
                      child: Container(
                        width: 75.w,
                          color: EvieColors.grayishWhite,
                          child: Center(
                              child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),))),
                  ),
                ],
              ),
            ),
          ),

          if(widget.format == TripFormat.year)...{
            YearStatus(pickedDate!),
          }else...{
            RecentActivity(widget.format, isDataEmpty),
          }

        ],),
    );
  }

  getData(){

    selectedDate = widget.format == TripFormat.day ?
    "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
    widget.format == TripFormat.week ?
    "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}" :
    widget.format == TripFormat.month ?
    "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
    "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";

    switch(widget.format){
      case TripFormat.day:
        chartData.clear();
        _tripProvider.currentTripHistoryListDay.clear();

        _tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
            chartData.add(ChartData(value.startTime.toDate(), value.distance.toDouble()));
            _tripProvider.currentTripHistoryListDay.add(value);
          }else{
          }
        });

        if(chartData.isEmpty){
          for(int i = 1; i <= 7; i ++){
            switch(i){
              case 1: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 08, 0), 0))); break;
              case 2: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 10, 0), 0))); break;
              case 3: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 12, 0), 0))); break;
              case 4: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 14, 0, i), 0))); break;
              case 5: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 16, 0), 0))); break;
              case 6: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 18, 0), 0))); break;
              case 7: chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 20, 0), 0))); break;
            }
           // chartData.add((ChartData(DateTime(pickedDate!.month, pickedDate!.day, i), 0)));
          }
        }

        if(_tripProvider.selectedIndex != -1 && _tripProvider.tripFormat == TripFormat.day){
          setState(() {
            selectedMileage = _tripProvider.currentTripHistoryListDay.elementAt(_tripProvider.selectedIndex).distance.toString();
            selectedCF = _tripProvider.currentTripHistoryListDay.elementAt(_tripProvider.selectedIndex).carbonPrint.toString();
            selectedRides = 1.toString();
          });
        }

        return;
      case TripFormat.week:

        if (isFirst) {
          chartData.clear();
          _tripProvider.currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for(int i = 0; i < 7; i ++){
            chartData.add((ChartData(pickedDate!.subtract(Duration(days: i)), 0)));
          }

          chartData = chartData.reversed.toList();

          _tripProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 1))) && value.startTime.toDate().isAfter(pickedDate!.subtract(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
              newData.y = newData.y + value.distance.toDouble();
              _tripProvider.currentTripHistoryListDay.add(value);
            }
          });
        }
        else {
          chartData.clear();
          _tripProvider.currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for (int i = 0; i < 7; i ++) {
            chartData.add((ChartData(pickedDate!.add(Duration(days: i)), 0)));
          }

          _tripProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) =>
              data.x.day == value.startTime
                  .toDate()
                  .day);
              newData.y = newData.y + value.distance.toDouble();
              _tripProvider.currentTripHistoryListDay.add(value);
            }
          });
        }

        if(_tripProvider.selectedIndex != -1 && _tripProvider.tripFormat == TripFormat.week){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _tripProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month &&
                selectedDateTemp?.day == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().day){
              tempMileage += _tripProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _tripProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
              tempRides += 1;
            }
          }

          setState(() {
            if(tempMileage != 0){
              selectedMileage = tempMileage.toString();
            }
            if(selectedMileageTemp != 0){
              selectedCF = tempCF.toString();
            }

             selectedRides = tempRides.toString();

          });

        }

        return;
      case TripFormat.month:
        chartData.clear();
        _tripProvider.currentTripHistoryListDay.clear();

        final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);

        for(int i = 1; i <= totalDaysInMonth; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, i), 0)));
        }
        _tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
            newData.y = newData.y + value.distance.toDouble();
            _tripProvider.currentTripHistoryListDay.add(value);
          }
        });

        if(_tripProvider.selectedIndex != -1 && _tripProvider.tripFormat == TripFormat.month){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _tripProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month &&
                selectedDateTemp?.day == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().day){
              tempMileage += _tripProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _tripProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
              tempRides += 1;
            }
          }

          setState(() {
            if(tempMileage != 0){
              selectedMileage = tempMileage.toString();
            }
            if(selectedMileageTemp != 0){
              selectedCF = tempCF.toString();
            }
            selectedRides = tempRides.toString();
          });

        }


        return;
      case TripFormat.year:
        chartData.clear();
        _tripProvider.currentTripHistoryListDay.clear();

        for(int i = 1; i <= 12; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, i, 1), 0)));
        }

        _tripProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().year == pickedDate!.year){
            ChartData newData = chartData.firstWhere((data) => data.x.month == value.startTime.toDate().month);
            newData.y = newData.y + value.distance.toDouble();
            _tripProvider.currentTripHistoryListDay.add(value);
          }
        });

        if(_tripProvider.selectedIndex != -1 && _tripProvider.tripFormat == TripFormat.year){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _tripProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _tripProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month){
              tempMileage += _tripProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _tripProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
              tempRides += 1;
            }
          }

          setState(() {
            if(tempMileage != 0){
              selectedMileage = tempMileage.toString();
            }
            if(selectedMileageTemp != 0){
              selectedCF = tempCF.toString();
            }
            selectedRides = tempRides.toString();
          });

       }
        return;
    }
  }

  checkIsDataEmpty(){
    isDataEmpty = true;
    for (var i = 0; i < _tripProvider.currentTripHistoryLists.length; i++) {
      if (_tripProvider.isFilterData(
          _tripProvider.currentTripHistoryListDay,
          _tripProvider.currentTripHistoryLists.values.elementAt(i))) {

        isDataEmpty = false;

      }
    }
  }

}


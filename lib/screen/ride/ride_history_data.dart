import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/ride/recent_activity.dart';
import 'package:evie_test/screen/trip_history/year_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../api/enumerate.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/provider/ride_provider.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/evie_oval.dart';


class RideHistoryData extends StatefulWidget{
  final RideFormat format;
  const RideHistoryData(this.format,{ Key? key }) : super(key: key);
  @override
  _RideHistoryDataState createState() => _RideHistoryDataState();
}

class _RideHistoryDataState extends State<RideHistoryData> {

  late List<ChartData> chartData = [];
  DateTime now = DateTime.now();
  DateTime? pickedDate;
  late RideProvider _rideProvider;
  late SettingProvider _settingProvider;
  bool isFirst = true;
  late String selectedDate;
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

    selectedDate = widget.format == RideFormat.day ?
        "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"    :
        widget.format == RideFormat.week ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day}, ${pickedDate!.year}" :
        widget.format == RideFormat.month ?
        "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
        "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";

    _trackballBehavior = TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(format: 'point.x : point.y'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _rideProvider = Provider.of<RideProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

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
                Row(
                  children: [
                    Text(_rideProvider.rideDataString, style: EvieTextStyles.display,),
                    Text(_rideProvider.rideDataUnit, style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray,)),
                  ],
                ),

                SizedBox(width: 4.w,),

                EvieOvalGray(
                  buttonText: _rideProvider.rideDataTypeString,
                  onPressed: (){
                    // if(_rideProvider.rideDataType == RideDataType.mileage){
                    //   _rideProvider.setRideData(RideDataType.noOfRide, RideFormat.week);
                    // }
                    // else if(_rideProvider.rideDataType == RideDataType.noOfRide){
                    //   _rideProvider.setRideData(RideDataType.carbonFootprint, RideFormat.week);
                    // }
                    // else if(_rideProvider.rideDataType == RideDataType.carbonFootprint){
                    //   _rideProvider.setRideData(RideDataType.mileage, RideFormat.week);
                    // }
                  },
                )
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Row(
              children: [
                Text(
                  selectedDateTemp != null ?
                  widget.format == RideFormat.day?
                  "${selectedDateTemp!.hour.toString().padLeft(2,'0')}:${selectedDateTemp!.minute.toString().padLeft(2,'0')} ${weekdayNameFull[selectedDateTemp!.weekday]}, ${monthsInYear[selectedDateTemp!.month]} ${selectedDateTemp!.day} ${selectedDateTemp!.year}"  :
                  widget.format == RideFormat.week ?
                  "${weekdayNameFull[selectedDateTemp!.weekday]}, ${monthsInYear[selectedDateTemp!.month]} ${selectedDateTemp!.day} ${selectedDateTemp!.year}" :
                  widget.format == RideFormat.month ?
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

                              selectedDate = widget.format == RideFormat.day ?
                              "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
                              widget.format == RideFormat.week ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}" :
                              widget.format == RideFormat.month ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
                              "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";
                            });
                          }else{
                            setState(() {
                              pickedDate = picked;
                              isFirst = false;

                              selectedDate = widget.format == RideFormat.day ?
                              "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
                              widget.format == RideFormat.week ?
                              "${monthsInYear[pickedDate!.month]} ${pickedDate!.day}-${pickedDate!.add(Duration(days: 6)).day} ${pickedDate!.year}" :
                              widget.format == RideFormat.month ?
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
                if(widget.format == RideFormat.month){
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
                }
                else if(widget.format == RideFormat.year){
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
                }
                else{
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
                        if(widget.format == _rideProvider.rideFormat && args.pointIndex == _rideProvider.selectedIndex){
                          _rideProvider.changeSelectedIndex(-1, RideFormat.day);
                          setState(() {
                            selectedMileage = null;
                            selectedCF = null;
                            selectedRides = null;
                            selectedDateTemp = null;
                          });
                        }else{
                          ///Press selected index
                          _rideProvider.changeSelectedIndex(args.pointIndex, widget.format);
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
                          widget.format == RideFormat.day ? "${data.x.hour.toString().padLeft(2,'0')}:${data.x.minute.toString().padLeft(2,'0')}" :
                          widget.format == RideFormat.week ? weekdayName[data.x.weekday] :
                          widget.format == RideFormat.month ? data.x.day :
                          widget.format == RideFormat.year ? monthNameHalf[data.x.month] :
                          data.x,

                        yValueMapper: (ChartData data, _) =>
                          _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                          (data.y/1000) :
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

          if(widget.format == RideFormat.year)...{
            YearStatus(pickedDate!),
          }else...{
            RecentActivity(widget.format, isDataEmpty),
          }

        ],),
    );
  }

  getData(){

    selectedDate = widget.format == RideFormat.day ?
    "${weekdayNameFull[pickedDate!.weekday]}, ${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}"  :
    widget.format == RideFormat.week ?
    "${monthsInYear[pickedDate!.month]} ${pickedDate!.subtract(Duration(days: 6)).day}-${pickedDate!.day} ${pickedDate!.year}" :
    widget.format == RideFormat.month ?
    "${monthsInYear[pickedDate!.month]} ${pickedDate!.year}" :
    "Jan ${pickedDate!.year} - Dec ${pickedDate!.year}";

    switch(widget.format){
      case RideFormat.day:
        chartData.clear();
        _rideProvider.currentTripHistoryListDay.clear();

        _rideProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
            chartData.add(ChartData(value.startTime.toDate(), value.distance.toDouble()));
            _rideProvider.currentTripHistoryListDay.add(value);
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

        if(_rideProvider.selectedIndex != -1 && _rideProvider.rideFormat == RideFormat.day){
          setState(() {
            selectedMileage = _rideProvider.currentTripHistoryListDay.elementAt(_rideProvider.selectedIndex).distance.toString();
            selectedCF = _rideProvider.currentTripHistoryListDay.elementAt(_rideProvider.selectedIndex).carbonPrint.toString();
            selectedRides = 1.toString();
          });
        }

        return;
      case RideFormat.week:

        if (isFirst) {
          chartData.clear();
          _rideProvider.currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for(int i = 0; i < 7; i ++){
            chartData.add((ChartData(pickedDate!.subtract(Duration(days: i)), 0)));
          }

          chartData = chartData.reversed.toList();

          _rideProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 1))) && value.startTime.toDate().isAfter(pickedDate!.subtract(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
              newData.y = newData.y + value.distance.toDouble();
              _rideProvider.currentTripHistoryListDay.add(value);
            }
          });
        }
        else {
          chartData.clear();
          _rideProvider.currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for (int i = 0; i < 7; i ++) {
            chartData.add((ChartData(pickedDate!.add(Duration(days: i)), 0)));
          }

          _rideProvider.currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) =>
              data.x.day == value.startTime
                  .toDate()
                  .day);
              newData.y = newData.y + value.distance.toDouble();
              _rideProvider.currentTripHistoryListDay.add(value);
            }
          });
        }

        if(_rideProvider.selectedIndex != -1 && _rideProvider.rideFormat == RideFormat.week){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _rideProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month &&
                selectedDateTemp?.day == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().day){
              tempMileage += _rideProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _rideProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
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
      case RideFormat.month:
        chartData.clear();
        _rideProvider.currentTripHistoryListDay.clear();

        final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);

        for(int i = 1; i <= totalDaysInMonth; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, i), 0)));
        }
        _rideProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
            newData.y = newData.y + value.distance.toDouble();
            _rideProvider.currentTripHistoryListDay.add(value);
          }
        });

        if(_rideProvider.selectedIndex != -1 && _rideProvider.rideFormat == RideFormat.month){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _rideProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month &&
                selectedDateTemp?.day == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().day){
              tempMileage += _rideProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _rideProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
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
      case RideFormat.year:
        chartData.clear();
        _rideProvider.currentTripHistoryListDay.clear();

        for(int i = 1; i <= 12; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, i, 1), 0)));
        }

        _rideProvider.currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().year == pickedDate!.year){
            ChartData newData = chartData.firstWhere((data) => data.x.month == value.startTime.toDate().month);
            newData.y = newData.y + value.distance.toDouble();
            _rideProvider.currentTripHistoryListDay.add(value);
          }
        });

        if(_rideProvider.selectedIndex != -1 && _rideProvider.rideFormat == RideFormat.year){

          double tempMileage = 0;
          double tempCF = 0;
          double tempRides = 0;

          for (var i = 0; i< _rideProvider.currentTripHistoryListDay.length; i++) {
            if(selectedDateTemp?.year == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().year &&
                selectedDateTemp?.month == _rideProvider.currentTripHistoryListDay.elementAt(i).startTime!.toDate().month){
              tempMileage += _rideProvider.currentTripHistoryListDay.elementAt(i).distance!;
              tempCF += _rideProvider.currentTripHistoryListDay.elementAt(i).carbonPrint!;
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
    for (var i = 0; i < _rideProvider.currentTripHistoryLists.length; i++) {
      if (_rideProvider.isFilterData(
          _rideProvider.currentTripHistoryListDay,
          _rideProvider.currentTripHistoryLists.values.elementAt(i))) {
        isDataEmpty = false;
      }
    }
  }

}


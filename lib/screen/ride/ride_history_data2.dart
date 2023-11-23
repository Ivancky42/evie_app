import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/ride/recent_activity.dart';
import 'package:evie_test/screen/ride/year_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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


class RideHistoryData2 extends StatefulWidget{
  final RideFormat format;
  const RideHistoryData2(this.format,{ Key? key }) : super(key: key);
  @override
  _RideHistoryData2State createState() => _RideHistoryData2State();
}

class _RideHistoryData2State extends State<RideHistoryData2> {

  DateTime now = DateTime.now();
  late RideProvider _rideProvider;
  late SettingProvider _settingProvider;
  bool isFirst = true;
  double? selectedMileageTemp;
  DateTime? selectedDateTemp;
  String? selectedMileage;
  ///Selected carbon footprint
  String? selectedCF;
  String? selectedRides;
  bool isFirstLoad = true;
  bool isDataEmpty = true;

  late String selectedDate;
  DateTime? pickedDate;
  bool _isLoading = true; // Add a loading indicator state


  final List<String> xLabels = List.generate(12, (index) {
    // Generate labels for 24 hours
    return '${index.toString().padLeft(2, '0')}:00';
  });

  @override
  void initState() {
    super.initState();
    _rideProvider = context.read<RideProvider>();
    Future.delayed(Duration.zero).then((value) => _loadTripHistory());
  }

  // Define an async function to load trip history
  Future<void> _loadTripHistory() async {
    try {
      pickedDate = DateTime.now();
      filterDateByRideFormat(pickedDate!);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (widget.format == RideFormat.day) {
          await _rideProvider.getDayRideHistory(DateTime.now());
          await _rideProvider.setRideData(RideDataType.mileage, widget.format, pickedDate!);
        }
        else if (widget.format == RideFormat.week) {
          await _rideProvider.getWeekRideHistory(DateTime.now());
          await _rideProvider.setRideData(RideDataType.mileage, widget.format, pickedDate!);
        }
        else if (widget.format == RideFormat.month) {
          await _rideProvider.getMonthRideHistory(DateTime.now());
          await _rideProvider.setRideData(RideDataType.mileage, widget.format, pickedDate!);
        }
        else if (widget.format == RideFormat.year) {
          await _rideProvider.getYearRideHistory(DateTime.now().year);
          await _rideProvider.setRideData(RideDataType.mileage, widget.format, pickedDate!);
        }
      });
      await _rideProvider.getChartData(widget.format, pickedDate!);
      setState(() {
        _isLoading = false; // Set loading state to false when done
      });
    } catch (error) {
      // Handle error if needed
      print('Error loading trip history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    _rideProvider = Provider.of<RideProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return _isLoading ?
            Center(child: CircularProgressIndicator(color: EvieColors.primaryColor,),) :
            SingleChildScrollView(
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
                    Text(
                      widget.format == RideFormat.day ?
                      _rideProvider.rideDataDayString :
                      widget.format == RideFormat.week ?
                      _rideProvider.rideDataWeekString :
                      widget.format == RideFormat.month ?
                      _rideProvider.rideDataMonthString :
                      widget.format == RideFormat.year ?
                      _rideProvider.rideDataYearString :
                      _rideProvider.rideDataString,
                      style: EvieTextStyles.measurement,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(_rideProvider.rideDataUnit, style: EvieTextStyles.unit),
                    )
                  ],
                ),

                SizedBox(width: 4.w,),

                EvieOvalGray(
                  buttonText: _rideProvider.rideDataTypeString,
                  onPressed: (){
                    if(_rideProvider.rideDataType == RideDataType.mileage){
                      _rideProvider.setRideData(RideDataType.noOfRide, widget.format, pickedDate!);
                    }
                    else if(_rideProvider.rideDataType == RideDataType.noOfRide){
                      _rideProvider.setRideData(RideDataType.carbonFootprint, widget.format, pickedDate!);
                    }
                    else if(_rideProvider.rideDataType == RideDataType.carbonFootprint){
                      _rideProvider.setRideData(RideDataType.mileage, widget.format, pickedDate!);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Row(
              children: [
                Container(
                  //color: Colors.yellow,
                  child: Text(
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
                ),

                Container(
                  //color: Colors.green,
                  child: EvieButton_PickDate(
                    width: 50.w,
                    showColour: false,
                    onPressed: () async {
                      if (widget.format == RideFormat.day) {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: pickedDate!,
                          firstDate: DateTime(pickedDate!.year - 2),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: EvieColors.primaryColor,
                              ),), child: child!);
                          },
                        );
                        filterDateByRideFormat(picked ?? pickedDate!);
                        //_rideProvider.getChartData(widget.format, pickedDate!);
                        await _rideProvider.getDayRideHistory(pickedDate!);
                        _rideProvider.setRideData(_rideProvider.rideDataType, widget.format, pickedDate!);
                      }
                      else if (widget.format == RideFormat.week) {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: pickedDate!,
                          firstDate: DateTime(pickedDate!.year - 2),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: EvieColors.primaryColor,
                              ),), child: child!);
                          },
                        );
                        filterDateByRideFormat(picked ?? pickedDate!);
                        //_rideProvider.getChartData(widget.format, pickedDate!);
                        await _rideProvider.getWeekRideHistory(pickedDate!);
                        _rideProvider.setRideData(_rideProvider.rideDataType, widget.format, pickedDate!);
                      }
                      else if (widget.format == RideFormat.month) {
                        DateTime? picked = await showMonthPicker(
                            context: context,
                            initialDate: pickedDate!,
                            selectedMonthBackgroundColor: EvieColors.primaryColor,
                            headerColor: EvieColors.primaryColor,
                            unselectedMonthTextColor: EvieColors.primaryColor,
                            yearFirst: false,
                            selectYearOnly: false,
                            confirmWidget: Text(
                              'OK',
                              style: TextStyle(
                                  color: EvieColors.primaryColor
                              ),
                            ),
                            cancelWidget: Text(
                              'Cancel',
                              style: TextStyle(
                                color: EvieColors.primaryColor,
                              ),
                            )
                        );
                        filterDateByRideFormat(picked ?? pickedDate!);
                        //_rideProvider.getChartData(widget.format, pickedDate!);
                        await _rideProvider.getMonthRideHistory(pickedDate!);
                        _rideProvider.setRideData(_rideProvider.rideDataType, widget.format, pickedDate!);
                      }
                      else if (widget.format == RideFormat.year) {
                        DateTime? picked = await showMonthPicker(
                            context: context,
                            initialDate: pickedDate!,
                            selectedMonthBackgroundColor: EvieColors.primaryColor,
                            headerColor: EvieColors.primaryColor,
                            unselectedMonthTextColor: EvieColors.primaryColor,
                            yearFirst: true,
                            selectYearOnly: true,
                            confirmWidget: Text(
                              'OK',
                              style: TextStyle(
                                  color: EvieColors.primaryColor
                              ),
                            ),
                            cancelWidget: Text(
                              'Cancel',
                              style: TextStyle(
                                color: EvieColors.primaryColor,
                              ),
                            )
                        );

                        filterDateByRideFormat(picked ?? pickedDate!);
                        //_rideProvider.getChartData(widget.format, pickedDate!);
                        await _rideProvider.getYearRideHistory(pickedDate!.year);
                        _rideProvider.setRideData(_rideProvider.rideDataType, widget.format, pickedDate!);
                      }
                    },
                    child: SvgPicture.asset(
                      "assets/buttons/calendar.svg",
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    isVisible: true,
                    // RideFormat.day == widget.format ?
                    // _rideProvider.dayRideHistoryList.isEmpty ? false :
                    // RideFormat.month == widget.format ?
                    // _rideProvider.monthRideHistoryList.isEmpty ? false :
                    // RideFormat.year == widget.format ?
                    // _rideProvider.yearTimeChartData.isEmpty ? false :
                    // RideFormat.week == widget.format ?
                    // _rideProvider.weekRideHistoryList.isEmpty ? false :
                    //     true : true : true : true : true,
                  ),
                  ///maximum, data.duration highest
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: getMaxValue(widget.format),
                    //interval: 2,
                    numberFormat: NumberFormat('#,##0'),
                    opposedPosition: true,
                    isVisible: true,
                    // RideFormat.day == widget.format ?
                    // _rideProvider.dayRideHistoryList.isEmpty ? false :
                    // RideFormat.month == widget.format ?
                    // _rideProvider.monthRideHistoryList.isEmpty ? false :
                    // RideFormat.year == widget.format ?
                    // _rideProvider.yearTimeChartData.isEmpty ? false :
                    // RideFormat.week == widget.format ?
                    // _rideProvider.weekRideHistoryList.isEmpty ? false :
                    // true : true : true : true : true,
                  ),
                  series: RideFormat.day == widget.format ?
                  <ColumnSeries<DayTimeChartData, dynamic>>[
                    ColumnSeries<DayTimeChartData, dynamic>(
                      //borderRadius: BorderRadius.circular(10),
                      dataSource: _rideProvider.dayTimeChartData,
                      xValueMapper: (DayTimeChartData data, _) => dayTimeName[DateFormat('h a').format(data.x)],
                      yValueMapper: (DayTimeChartData data, _) {

                        if (_settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem) {
                          return (data.y/1000);
                        }
                        else {
                          return _settingProvider.convertMeterToMiles(data.y.toDouble());
                        }
                      },
                      ///width of the column
                      width: 0.8,
                      ///Spacing between the column
                      spacing: 0.2,
                      name: _rideProvider.dayTimeChartData.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                  ] :
                  RideFormat.week == widget.format ?
                  <ColumnSeries<ChartData, dynamic>>[
                    ColumnSeries<ChartData, dynamic>(
                      dataSource: _rideProvider.weekTimeChartData,
                      xValueMapper: (ChartData data, _) => weekdayName[data.x.weekday],
                      yValueMapper: (ChartData data, _) => _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                      (data.y/1000):
                      _settingProvider.convertMeterToMiles(data.y.toDouble()),
                      ///width of the column
                      width: 0.8,
                      ///Spacing between the column
                      spacing: 0.2,
                      name: _rideProvider.weekTimeChartData.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                  ] :
                  RideFormat.month == widget.format ?
                  <ColumnSeries<ChartData, dynamic>>[
                    ColumnSeries<ChartData, dynamic>(
                      dataSource: _rideProvider.monthTimeChartData,
                      xValueMapper: (ChartData data, _) => data.x.day,
                      yValueMapper: (ChartData data, _) =>
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                      (data.y/1000):
                      _settingProvider.convertMeterToMiles(data.y.toDouble()),
                      ///width of the column
                      width: 0.8,
                      ///Spacing between the column
                      spacing: 0.2,
                      name: _rideProvider.monthTimeChartData.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                  ] :
                  RideFormat.year == widget.format ?
                  <ColumnSeries<ChartData, dynamic>>[
                    ColumnSeries<ChartData, dynamic>(
                      dataSource: _rideProvider.yearTimeChartData,
                      xValueMapper: (ChartData data, _) => monthNameHalf[data.x.month],
                      yValueMapper: (ChartData data, _) =>
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                      (data.y/1000):
                      _settingProvider.convertMeterToMiles(data.y.toDouble()),

                      ///width of the column
                      width: 0.8,
                      ///Spacing between the column
                      spacing: 0.2,
                      name: _rideProvider.yearTimeChartData.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                  ] :
                  <ColumnSeries<ChartData, dynamic>>[
                    ColumnSeries<ChartData, dynamic>(
                      dataSource: _rideProvider.chartData,
                      xValueMapper: (ChartData data, _) =>
                      //widget.format == RideFormat.day ? "${data.x.hour.toString().padLeft(2,'0')}:${data.x.minute.toString().padLeft(2,'0')}" :
                      widget.format == RideFormat.day ? dayTimeName[DateFormat('h a').format(data.x)] :
                      widget.format == RideFormat.week ? weekdayName[data.x.weekday] :
                      widget.format == RideFormat.month ? data.x.day :
                      widget.format == RideFormat.year ? monthNameHalf[data.x.month] :
                      data.x,
                      yValueMapper: (ChartData data, _) =>
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                      (data.y/1000):
                      _settingProvider.convertMeterToMiles(data.y.toDouble()),

                      ///width of the column
                      width: 0.8,
                      ///Spacing between the column
                      spacing: 0.2,
                      name: _rideProvider.chartData.toString(),
                      color: EvieColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight:  Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                  ],
                  enableAxisAnimation: true,
                  trackballBehavior:
                  RideFormat.day == widget.format ?
                  TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    shouldAlwaysShow: true,
                    tooltipSettings: InteractiveTooltip(
                      // color: Colors.black87,
                      // connectorLineColor: Colors.black87,
                      // borderColor: Colors.black87,
                      decimalPlaces: 2,
                      canShowMarker: false,
                      format: 'point.x : point.y' + _rideProvider.rideDataUnit,
                    ),
                  ) :
                  TrackballBehavior(
                    shouldAlwaysShow: true,
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: InteractiveTooltip(
                      format: 'point.x : point.y' + _rideProvider.rideDataUnit,
                      decimalPlaces: 2,
                      canShowMarker: false,
                    ),
                  ),
                ),

                RideFormat.day == widget.format ?
                Visibility(
                  visible: _rideProvider.dayRideHistoryList.isEmpty ? true : false,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      width: 75.w,
                      color: EvieColors.grayishWhite,
                      //color: EvieColors.red,
                      child: Center(
                          child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan, fontWeight: FontWeight.w400),))),
                ) :
                RideFormat.week == widget.format ?
                Visibility(
                  visible: _rideProvider.weekRideHistoryList.isEmpty ? true : false,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      width: 75.w,
                      color: EvieColors.grayishWhite,
                      //color: EvieColors.red,
                      child: Center(
                          child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan, fontWeight: FontWeight.w400),))),
                ) :
                RideFormat.month == widget.format ?
                Visibility(
                  visible: _rideProvider.monthRideHistoryList.isEmpty ? true : false,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      width: 75.w,
                      color: EvieColors.grayishWhite,
                      //color: EvieColors.red,
                      child: Center(
                          child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan, fontWeight: FontWeight.w400),))),
                ) :
                RideFormat.year == widget.format ?
                Visibility(
                  visible: _rideProvider.yearRideHistoryList.isEmpty ? true : false,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      width: 75.w,
                      color: EvieColors.grayishWhite,
                      //color: EvieColors.red,
                      child: Center(
                          child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan, fontWeight: FontWeight.w400),))),
                ) :
                Visibility(
                  visible: _rideProvider.chartData.isEmpty ? true : false,
                  child: Container(
                      width: 75.w,
                      color: EvieColors.grayishWhite,
                      child: Center(
                          child: Text("No Data",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),))),
                ),
              ],
            ),
          ),

          if(widget.format == RideFormat.year)...{
            YearStatus(pickedDate!),
          }
          else...{
            RideFormat.day == widget.format ?
            /// ΣY = 0
            RecentActivity(widget.format, _rideProvider.dayTimeChartData.fold<double>(0, (prev, element) => prev + element.y!.toDouble()) == 0 ? true : false) :
            RideFormat.week == widget.format ?
            RecentActivity(widget.format,_rideProvider.weekTimeChartData.fold<double>(0, (prev, element) => prev + element.y!.toDouble()) == 0 ? true : false ) :
            RideFormat.month == widget.format ?
            RecentActivity(widget.format,_rideProvider.monthTimeChartData.fold<double>(0, (prev, element) => prev + element.y!.toDouble()) == 0 ? true : false ) :
            RecentActivity(widget.format,_rideProvider.chartData.fold<double>(0, (prev, element) => prev + element.y!.toDouble()) == 0 ? true : false )
          }
        ],
      ),
    );
  }

  void filterDateByRideFormat(DateTime picked) {
    setState(() {
      pickedDate = picked;
      selectedDate = widget.format == RideFormat.day ?
      formatDay(picked) :
      widget.format == RideFormat.week ?
      formatWeek(picked):
      widget.format == RideFormat.month ?
      "${monthsInYear[picked.month]} ${picked.year}" :
      "Jan ${picked.year} - Dec ${picked.year}";
    });
  }

  String formatDay(DateTime date) {
    return "${weekdayNameFull[date!.weekday]}, ${monthsInYear[date!.month]} ${date!.day} ${date!.year}";
  }

  String formatWeek(DateTime date) {
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    DateTime sunday = date.add(Duration(days: DateTime.daysPerWeek - date.weekday));

    String formattedWeek = DateFormat('MMM d').format(monday) +
        '-' +
        DateFormat('MMM d, yyyy').format(sunday);

    return formattedWeek;
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


  double? getMaxValue(RideFormat rideFormat) {
    if (rideFormat == RideFormat.day) {
      var data = _rideProvider.dayTimeChartData;
      if (data.isEmpty) {
        return 5; // Set a default value if the list is empty
      }

      var maximunValue = data.map((entry) => entry.y).reduce((max, value) => max > value ? max : value).toDouble();

      if (_settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem) {
        maximunValue = (maximunValue/1000);
      }
      else {
        maximunValue = _settingProvider.convertMeterToMiles(maximunValue.toDouble());
      }

      if (maximunValue <= 5) {
        return 5;
      }
      else {
        return maximunValue;
      }
    }
    else if (rideFormat == RideFormat.week) {
      var data = _rideProvider.weekTimeChartData;
      if (data.isEmpty) {
        return 5; // Set a default value if the list is empty
      }

      var maximunValue = data.map((entry) => entry.y).reduce((max, value) => max > value ? max : value).toDouble();
      if (_settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem) {
        maximunValue = (maximunValue/1000);
      }
      else {
        maximunValue = _settingProvider.convertMeterToMiles(maximunValue.toDouble());
      }

      if (maximunValue <= 5) {
        return 5;
      }
      else {
        return maximunValue;
      }
    }
    else if (rideFormat == RideFormat.month) {
      var data = _rideProvider.monthTimeChartData;
      if (data.isEmpty) {
        return 5; // Set a default value if the list is empty
      }

      var maximunValue = data.map((entry) => entry.y).reduce((max, value) => max > value ? max : value).toDouble();
      if (_settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem) {
        maximunValue = (maximunValue/1000);
      }
      else {
        maximunValue = _settingProvider.convertMeterToMiles(maximunValue.toDouble());
      }

      if (maximunValue <= 5) {
        return 5;
      }
      else {
        return maximunValue;
      }
    }
    else if (rideFormat == RideFormat.year) {
      var data = _rideProvider.yearTimeChartData;
      if (data.isEmpty) {
        return 5; // Set a default value if the list is empty
      }

      var maximunValue = data.map((entry) => entry.y).reduce((max, value) => max > value ? max : value).toDouble();
      if (_settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem) {
        maximunValue = (maximunValue/1000);
      }
      else {
        maximunValue = _settingProvider.convertMeterToMiles(maximunValue.toDouble());
      }

      if (maximunValue <= 5) {
        return 5;
      }
      else {
        return maximunValue;
      }
    }
  }

}


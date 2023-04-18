import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/model/trip_history_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../api/provider/trip_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_oval.dart';

class Rides extends StatefulWidget {

  Rides({

    Key? key
  }) : super(key: key);

  @override
  State<Rides> createState() => _RidesState();
}

class _RidesState extends State<Rides> {

  late BikeProvider _bikeProvider;
  late TripProvider _tripProvider;
  late SettingProvider _settingProvider;

  List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
  late String currentData;
  late List<TripHistoryModel> currentTripHistoryListDay = [];
  late List<ChartData> chartData = [];
  DateTime now = DateTime.now();
  DateTime? pickedDate;

  @override
  void initState() {
    super.initState();

    currentData = totalData.first;
    pickedDate = DateTime(now.year, now.month, now.day);
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    getTripHistoryData(_bikeProvider, _tripProvider);

    return EvieCard(
      title: "Rides",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            EvieOvalGray(
              buttonText: currentData == "Carbon Footprint" ? "CO2" : currentData,
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
              },),


            if(currentData == totalData.elementAt(0))...{
              _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
              Row(
                children: [
                  Text("${(currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2)}", style: EvieTextStyles.display,),
                  Text(" km", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray,)),
                ],
              ) :
              Row(
                children: [
                  Text("${_settingProvider.convertMeterToMilesInString(currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()))}", style: EvieTextStyles.display,),
                  Text(" miles", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                ],
              ),
            }else if(currentData == totalData.elementAt(1))...{
              Row(
                children: [
                  Text("${currentTripHistoryListDay.length.toStringAsFixed(0)}", style: EvieTextStyles.display,),
                  Text(" rides ", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                ],
              ),
            }else if(currentData == totalData.elementAt(2))...{
              Row(
                children: [
                  Text("0", style: EvieTextStyles.display,),
                  Text(" g", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                ],
              ),
            },

            Text("ridden this week", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray,height: 1.2),),
            SizedBox(height: 16.h,),
          ],
        ),
      ),
      onPress: (){
        showTripHistorySheet(context);
      },
    );
  }

  getTripHistoryData(BikeProvider bikeProvider, TripProvider tripProvider){

    chartData.clear();
    currentTripHistoryListDay.clear();
    // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

    for(int i = 0; i < 7; i ++){
      chartData.add((ChartData(pickedDate!.add(Duration(days: i)), 0)));
    }

    tripProvider.currentTripHistoryLists.forEach((key, value) {
      if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 6)))){
        ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
        newData.y = newData.y + value.distance.toDouble();
        currentTripHistoryListDay.add(value);
      }
    });

  }
}



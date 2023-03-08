import 'dart:math';

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/evie_oval.dart';


class TripDay extends StatefulWidget{
  const TripDay({ Key? key }) : super(key: key);
  @override
  _TripDayState createState() => _TripDayState();
}

class _TripDayState extends State<TripDay> {
  List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
  late String currentData;

  late List<_ChartData> data = [];
  late TooltipBehavior _tooltip;
  double totalMileage = 0;
  DateTime? pickedDate = DateTime.now();

  late BikeProvider _bikeProvider;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    currentData = totalData.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   _bikeProvider = Provider.of<BikeProvider>(context);

      getData(_bikeProvider);

    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.only(left: 32.w, right: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text("TOTAL", style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),),
              Row(
                children: [
                  if(currentData == totalData.elementAt(0))...{
                    Text((totalMileage/1000).toStringAsFixed(2), style: EvieTextStyles.display,),
                    Text("km", style: EvieTextStyles.body18,),
                  }else if(currentData == totalData.elementAt(1))...{
                    Text(_bikeProvider.currentTripHistoryLists.length.toStringAsFixed(0), style: EvieTextStyles.display,),
                    Text("rides", style: EvieTextStyles.body18,),
                  }else if(currentData == totalData.elementAt(2))...{
                    Text("12345", style: EvieTextStyles.display,),
                    Text("g", style: EvieTextStyles.body18,),
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
              Row(
                children: [
                  Text(pickedDate != null ? "${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}": "${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}",
                    style: const TextStyle(color: EvieColors.darkGrayishCyan),),

                  Expanded(
                    child:  EvieButton_PickDate(
                      showColour: false,
                      width: 155.w,
                      onPressed: () async {

                          pickedDate = await showDatePicker(
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

                          // if(pickedDate == null){
                          //   setState(() {
                          //     pickedDate == DateTime.now();
                          //   });
                          // }

                          setState(() {});
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

              GestureDetector(
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
                    setState(() {
                      pickedDate = pickedDate?.add(Duration(days: 1));
                    });
                  }
                },
                child: SfCartesianChart(
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
                          ///width of the column
                          width: 0.8,
                          ///Spacing between the column
                          spacing: 0.2,
                          name: data.toString(),
                          color: EvieColors.primaryColor,
                          borderRadius: const BorderRadius.only(
                            topRight:  Radius.circular(5),
                            topLeft: Radius.circular(5),
                          )
                      )
                    ]),
              )

            ],)
      ),
    );
  }

  getData(BikeProvider bikeProvider){

    totalMileage = 0;
    data.clear();

    bikeProvider.currentTripHistoryLists.forEach((key, value) {
      ///Filter date
      if(bikeProvider.calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
        data.add(_ChartData(value.startTime.toDate(), value.distance.toDouble()));
        totalMileage += value.distance!;
      }
    });
  }
}



class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
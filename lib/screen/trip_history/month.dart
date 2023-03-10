// import 'dart:math';
//
// import 'package:evie_test/api/colours.dart';
// import 'package:evie_test/api/model/trip_history_model.dart';
// import 'package:evie_test/api/navigator.dart';
// import 'package:evie_test/api/provider/bike_provider.dart';
// import 'package:evie_test/api/provider/trip_provider.dart';
// import 'package:evie_test/api/sizer.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../api/fonts.dart';
// import '../../api/function.dart';
// import '../../widgets/evie_button.dart';
// import '../../widgets/evie_oval.dart';
//
//
// class TripMonth extends StatefulWidget{
//   const TripMonth({ Key? key }) : super(key: key);
//   @override
//   _TripMonthState createState() => _TripMonthState();
// }
//
// class _TripMonthState extends State<TripMonth> {
//   List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
//   late String currentData;
//   late List<TripHistoryModel> currentTripHistoryListDay = [];
//
//   late List<_ChartData> chartData = [];
//   late TooltipBehavior _tooltip;
//   DateTime? pickedDate = DateTime.now();
//
//   late BikeProvider _bikeProvider;
//   late TripProvider _tripProvider;
//
//   @override
//   void initState() {
//     _tooltip = TooltipBehavior(
//         enable: true,
//         builder: (dynamic data, dynamic point, dynamic series,
//             int pointIndex, int seriesIndex) {
//           return Container(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Distance: ${data.y.toStringAsFixed(0) ?? "0"}',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//           );
//         });
//     currentData = totalData.first;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _tripProvider = Provider.of<TripProvider>(context);
//
//     getData(_bikeProvider, _tripProvider);
//
//     return Padding(
//         padding: EdgeInsets.only(left: 32.w, right: 32.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//
//           children: [
//
//             Text("TOTAL", style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),),
//             Row(
//               children: [
//
//                 if(currentData == totalData.elementAt(0))...{
//                   Text((currentTripHistoryListDay.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2), style: EvieTextStyles.display,),
//                   Text("km", style: EvieTextStyles.body18,),
//                 }else if(currentData == totalData.elementAt(1))...{
//                   // Text(_bikeProvider.currentTripHistoryLists.length.toStringAsFixed(0), style: EvieTextStyles.display,),
//                   Text(currentTripHistoryListDay.length.toStringAsFixed(0), style: EvieTextStyles.display,),
//                   Text("rides", style: EvieTextStyles.body18,),
//                 }else if(currentData == totalData.elementAt(2))...{
//                   Text("12345", style: EvieTextStyles.display,),
//                   Text("g", style: EvieTextStyles.body18,),
//                 },
//
//                 SizedBox(width: 4.w,),
//                 EvieOvalGray(
//                   buttonText: currentData,
//                   onPressed: (){
//                     if(currentData == totalData.first){
//                       setState(() {
//                         currentData = totalData.elementAt(1);
//                       });
//                     }else if(currentData == totalData.elementAt(1)){
//                       setState(() {
//                         currentData = totalData.last;
//                       });
//                     }else if(currentData == totalData.last){
//                       setState(() {
//                         currentData = totalData.first;
//                       });
//                     }
//                   },)
//               ],
//             ),
//
//             Row(
//               children: [
//                 Text("${monthsInYear[pickedDate!.month]} ${pickedDate!.day} ${pickedDate!.year}",
//                   style: const TextStyle(color: EvieColors.darkGrayishCyan),),
//
//                 Expanded(
//                   child:  EvieButton_PickDate(
//                     showColour: false,
//                     width: 155.w,
//                     onPressed: () async {
//
//                       pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: pickedDate ?? DateTime.now(),
//                         firstDate:  DateTime(DateTime.now().year-2),
//                         lastDate: DateTime.now(),
//                         builder: (context, child) {
//                           return Theme(data: Theme.of(context).copyWith(
//                             colorScheme: const ColorScheme.light(
//                               primary: EvieColors.primaryColor,
//                             ), ), child: child!);
//                         },
//                       );
//
//                       // if(pickedDate == null){
//                       //   setState(() {
//                       //     pickedDate == DateTime.now();
//                       //   });
//                       // }
//
//                       setState(() {});
//                     },
//                     child: SvgPicture.asset(
//                       "assets/buttons/calendar.svg",
//                       height: 24.h,
//                       width: 24.w,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onHorizontalDragEnd: (DragEndDetails details){
//                 double velocity = details.velocity.pixelsPerSecond.dx;
//                 if(velocity > 0){
//                   ///Swipe right, go to previous date
//                   setState(() {
//                     pickedDate = pickedDate?.subtract(Duration(days: 1));
//                   });
//                 }else{
//                   ///Swipe left, go to next date
//
//                   //If picked date less than today
//                   if(calculateDateDifferenceFromNow(pickedDate!) < 0){
//                     setState(() {
//                       pickedDate = pickedDate?.add(Duration(days: 1));
//                     });
//                   }
//                 }
//               },
//               child:
//               SfCartesianChart(
//                 primaryXAxis: NumericAxis(
//                   minimum: 1,
//                   maximum: daysInMonth(pickedDate!.year,  pickedDate!.month).toDouble(),
//                   interval: 4,
//                   isVisible: true,
//                 ),
//
//                 ///maximum, data.duration highest
//                 primaryYAxis: NumericAxis(
//                   //minimum: 0, maximum: 2500, interval: 300,
//                   opposedPosition: true,
//                 ),
//
//                 tooltipBehavior: _tooltip,
//                 series: <ColumnSeries<_ChartData, dynamic>>[
//                   ColumnSeries<_ChartData, dynamic>(
//                       dataSource: chartData,
//                       xValueMapper: (_ChartData data, _) => data.x,
//                       yValueMapper: (_ChartData data, _) => data.y,
//                       ///width of the column
//                       width: 0.8,
//                       ///Spacing between the column
//                       spacing: 0.2,
//                       name: chartData.toString(),
//                       color: EvieColors.primaryColor,
//                       borderRadius: const BorderRadius.only(
//                         topRight:  Radius.circular(5),
//                         topLeft: Radius.circular(5),
//                       )
//                   ),
//
//                 ],
//                 enableAxisAnimation: true,
//                 zoomPanBehavior: ZoomPanBehavior(
//                   enablePanning: false,
//                   enablePinching: false,
//                 ),
//
//               ),
//             )
//
//           ],)
//     );
//   }
//
//   getData(BikeProvider bikeProvider, TripProvider tripProvider){
//     chartData.clear();
//     currentTripHistoryListDay.clear();
//
//     final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);
//
//     tripProvider.currentTripHistoryLists.forEach((key, value) {
//       ///Filter date
//       if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){
//
//         double totalDistance = 0;
//
//         for (int day = 1; day <= totalDaysInMonth; day++) {
//           if(value.startTime.toDate().day == day){
//             totalDistance += value.distance;
//             chartData.add(_ChartData(value.startTime.toDate().day, totalDistance));
//           }
//         }
//
//         currentTripHistoryListDay.add(value);
//       }
//     });
//
//   }
// }
//
// class _ChartData {
//   _ChartData(this.x, this.y);
//
//   final dynamic x;
//   final dynamic y;
// }
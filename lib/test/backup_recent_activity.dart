// import 'dart:math';
//
// import 'package:evie_test/api/colours.dart';
// import 'package:evie_test/api/model/trip_history_model.dart';
// import 'package:evie_test/api/navigator.dart';
// import 'package:evie_test/api/provider/bike_provider.dart';
// import 'package:evie_test/api/provider/setting_provider.dart';
// import 'package:evie_test/api/provider/trip_provider.dart';
// import 'package:evie_test/api/sheet.dart';
// import 'package:evie_test/api/sizer.dart';
// import 'package:evie_test/widgets/evie_divider.dart';
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
// class RecentActivity extends StatefulWidget{
//   final TripFormat format;
//   const RecentActivity(this.format,{ Key? key }) : super(key: key);
//   @override
//   _RecentActivityState createState() => _RecentActivityState();
// }
//
// class _RecentActivityState extends State<RecentActivity> {
//
//   List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
//   late String currentData;
//   late List<TripHistoryModel> currentTripHistoryListDay = [];
//
//   late List<ChartData> chartData = [];
//   late TooltipBehavior _tooltip;
//   late NumericAxis xNumericAxis;
//
//   DateTime? pickedDate = DateTime.now();
//
//   late BikeProvider _bikeProvider;
//   late TripProvider _tripProvider;
//   late SettingProvider _settingProvider;
//
//   @override
//   Widget build(BuildContext context) {
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _tripProvider = Provider.of<TripProvider>(context);
//     _settingProvider = Provider.of<SettingProvider>(context);
//
//     return  Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//
//       children: [
//
//         Container(
//           color: EvieColors.dividerWhite,
//           width: double.infinity,
//           child: Padding(
//             padding:  EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
//             child: Text("Trips", style: EvieTextStyles.h4),
//           ),
//         ),
//
//         ListView.separated(
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           padding: EdgeInsets.zero,
//           separatorBuilder: (context, index) {
//             return Divider(height: 1.h);
//           },
//           itemCount: _tripProvider.currentTripHistoryLists.length,
//           itemBuilder: (context, index) {
//
//             return  Column(
//               children: [
//                 GestureDetector(
//                   behavior: HitTestBehavior.translucent,
//                   onTap: () {
//                     //Navigator.pop(context);
//                     showRideHistorySheet(context, _tripProvider.currentTripHistoryLists.keys.elementAt(index), _tripProvider.currentTripHistoryLists.values.elementAt(index));
//
//                   },
//                   child: Container(
//                     height: 77.h,
//                     child: Padding(
//                       padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 calculateDateAgo(_tripProvider.currentTripHistoryLists.values.elementAt(index).startTime.toDate(), _tripProvider.currentTripHistoryLists.values.elementAt(index).endTime.toDate()),
//
//                                 style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
//                               ),
//                               SvgPicture.asset(
//                                 "assets/buttons/next.svg",
//                                 height: 24.h,
//                                 width: 24.w,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
//                               Text(
//                                 "${(_tripProvider.currentTripHistoryLists.values.elementAt(index).distance.toDouble()/1000).toStringAsFixed(2)} km",
//                                 style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
//                               ):
//                               Text(
//                                 "${_settingProvider.convertMeterToMilesInString((_tripProvider.currentTripHistoryLists.values.elementAt(index).distance.toDouble()))}miles",
//                                 style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
//                               ),
//                               Text(
//                                 "${thousandFormatting(_tripProvider.currentTripHistoryLists.values.elementAt(index).carbonPrint)}g CO2 Saved",
//                                 style: EvieTextStyles.body14,
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const EvieDivider(),
//
//               ],
//             );
//
//           },
//         ),
//
//         Padding(
//           padding:
//           const EdgeInsets.all(6),
//           child:  Padding(
//             padding: EdgeInsets.only(
//                 left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
//             child: Container(
//               height: 45.h,
//               width: double.infinity,
//               child: ElevatedButton(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Show All Data",
//                       style:  EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
//                     ),
//                     SvgPicture.asset(
//                       "assets/buttons/external_link.svg",
//                     ),
//                   ],
//                 ),
//                 onPressed: () {
//                   ///Go to external link
//                 },
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                       side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
//                   elevation: 0.0,
//                   backgroundColor: EvieColors.transparent,
//
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         ///Hide
//         // Center(
//         //   child: Text(
//         //     "Currently all trip history data are from bike 862205055084620, 4487",
//         //     style:  EvieTextStyles.body12,
//         //   ),
//         // ),
//       ],);
//   }
//
// }
//

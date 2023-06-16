// import 'package:evie_bike/api/sizer.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
//
//
//
//
//
//
//
// class Bike_Name_Row extends StatelessWidget {
//
//   String bikeName;
//   String distanceBetween;
//   String currentBikeStatusImage;
//
//
//   Bike_Name_Row({
//     Key? key,
//     required this.bikeName,
//    required this.distanceBetween,
//     required this.currentBikeStatusImage,
//
//
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment:
//       MainAxisAlignment
//           .spaceBetween,
//       children: [
//         Column(
//           mainAxisAlignment:
//           MainAxisAlignment
//               .start,
//           crossAxisAlignment:
//           CrossAxisAlignment
//               .start,
//           children: [
//
//             Row(
//               children: [
//                 Text(
//                   bikeName,
//                   style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight:
//                       FontWeight
//                           .w700),
//                 ),
//
//                 Image(
//                   width: 20.w,
//                   height: 20.h,
//                   image: AssetImage(
//                       "assets/icons/batch_tick.png"),
//
//                 ),
//
//                 Image(
//                   image: AssetImage(
//                       "assets/icons/connection.png"),
//
//                 ),
//
//               ],
//
//             ),
//
//             SizedBox(
//               height: 4.h,
//             ),
//             Text(
//               "Est. ${distanceBetween}m",
//               style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight:
//                   FontWeight
//                       .w400),
//             ),
//           ],
//         ),
//         Image(
//           image: AssetImage(
//               currentBikeStatusImage),
//           height: 60.h,
//           width: 87.w,
//         ),
//       ],
//     );
//   }
// }
//
//
// class Bike_Status_Row extends StatelessWidget {
//
//   String currentSecurityIcon;
//   Widget child;
//   String batteryImage;
//   int batteryPercentage;
//
//   Bike_Status_Row({
//     Key? key,
//     required this.currentSecurityIcon,
//     required this. child,
//     required this.batteryImage,
//     required this.batteryPercentage,
//
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//         children: [
//           Container(
//             width: 21.w,
//             height: 24.h,
//             child: Image(
//               image: AssetImage(
//                   currentSecurityIcon),
//             ),
//           ),
//           SizedBox(width: 11.5.w),
//           Column(
//             crossAxisAlignment:
//             CrossAxisAlignment
//                 .start,
//             children: [
//               Container(
//                 width: 135.w,
//                 child: child,
//               )
//             ],
//           ),
//           const VerticalDivider(
//             thickness: 1,
//           ),
//           Image(
//             image: AssetImage(
//                 batteryImage),
//             //height: 1.h,
//           ),
//           SizedBox(
//             width: 10.w,
//           ),
//           Column(
//               crossAxisAlignment:
//               CrossAxisAlignment
//                   .start,
//               children: [
//                 Text(
//                   "${batteryPercentage} %",
//                   style: TextStyle(
//                     fontSize: 20.sp
//                       ),
//                 ),
//                 Text("Est 0km", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),)
//               ])
//         ]);
//   }
// }
//
//

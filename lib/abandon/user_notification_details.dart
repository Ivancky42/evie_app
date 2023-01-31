// import 'dart:async';
// import 'dart:collection';
// import 'dart:io';
// import 'package:evie_test/api/provider/auth_provider.dart';
// import 'package:evie_test/api/provider/notification_provider.dart';
// import 'package:evie_test/widgets/evie_appbar.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:provider/provider.dart';
// import 'package:evie_test/api/provider/current_user_provider.dart';
// import 'package:evie_test/widgets/evie_button.dart';
// import 'package:sizer/sizer.dart';
//
// import '../api/model/bike_user_model.dart';
// import '../api/model/notification_model.dart';
// import '../api/navigator.dart';
// import '../api/provider/bike_provider.dart';
// import '../widgets/evie_single_button_dialog.dart';
//
// ///User profile page with user account information
//
// class UserNotificationDetails extends StatefulWidget {
//   final String notificationKeys;
//   final NotificationModel notificationValues;
//
//   const UserNotificationDetails(this.notificationKeys, this.notificationValues,
//       {Key? key})
//       : super(key: key);
//
//   @override
//   _UserNotificationDetailsState createState() =>
//       _UserNotificationDetailsState();
// }
//
// class _UserNotificationDetailsState extends State<UserNotificationDetails> {
//   late NotificationProvider _notificationProvider;
//   late BikeProvider _bikeProvider;
//   late CurrentUserProvider _currentUserProvider;
//
//   String? conditionType;
//
//   ///Pass data from user notification page / notification click to this page
//
//   @override
//   Widget build(BuildContext context) {
//     _notificationProvider = Provider.of<NotificationProvider>(context);
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _currentUserProvider = Provider.of<CurrentUserProvider>(context);
//
//     return WillPopScope(
//       onWillPop: () async {
//      changeToFeedsScreen(context);
//         return true;
//       },
//
//       child:Scaffold(
//           appBar: AppBar(
//             centerTitle: false,
//             title: Row(
//               children: const <Widget>[
//                 /*
//                 IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       changeToUserHomePageScreen(context);
//                     }),
//                  */
//                 Text('Notification'),
//               ],
//             ),
//           ),
//           body: Scaffold(
//               body: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   //    child: Center(
//                   child: SingleChildScrollView(
//                       child: Column(
//
//                           //  mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                         if (widget.notificationValues.type == "shareBike") ...[
//                           SizedBox(
//                             height: 20.h,
//                           ),
//                           Center(
//                             child:
//                                 Text(widget.notificationValues.title ?? "error",
//                                     style: TextStyle(
//                                       fontFamily: 'Raleway',
//                                       fontSize: 17.sp,
//                                       fontWeight: FontWeight.w600,
//                                     )),
//                           ),
//                           SizedBox(
//                             height: 5.h,
//                           ),
//                           Container(
//                             child: Center(
//                               child: Text(
//                                 widget.notificationValues.body ?? "error",
//                                 style: TextStyle(
//                                   fontFamily: 'Raleway',
//                                   fontSize: 15.sp,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 10.h,
//                           ),
//                           Visibility(
//                             visible: widget.notificationValues.status == "pending",
//
//                             ///Another button for declined
//                             child: EvieButton(
//                               width: 200,
//                               height: 20,
//                               onPressed: () {
//
//                                 StreamSubscription? currentSubscription;
//                                 currentSubscription = _bikeProvider.acceptSharedBike(widget.notificationValues.deviceIMEI!, _currentUserProvider.currentUserModel!.uid)
//                                     .listen((uploadStatus) async {
//
//                                   if(uploadStatus == UploadFirestoreResult.success){
//                                     SmartDialog.dismiss();
//                                     _notificationProvider.updateUserNotificationSharedBikeStatus(widget.notificationValues.deviceIMEI!);
//                                     ScaffoldMessenger.of(context)
//                                         .showSnackBar(
//                                       const SnackBar(
//                                         content: Text('Bike added successfully!'),
//                                         duration: Duration(
//                                             seconds: 3),),
//                                     );
//
//                                     changeToUserHomePageScreen(context);
//                                     for (var element in _bikeProvider.userBikeNotificationList) {
//                                       await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}$element");
//                                     }
//
//                                     currentSubscription?.cancel();
//                                   } else if(uploadStatus == UploadFirestoreResult.failed) {
//                                     SmartDialog.dismiss();
//                                     SmartDialog.show(
//                                         backDismiss: false,
//                                         widget: EvieSingleButtonDialogCupertino(
//                                             title: "Error",
//                                             content: "Try again",
//                                             rightContent: "OK",
//                                             onPressedRight: () async {
//                                               SmartDialog.dismiss();
//                                             }));
//                                   }
//                                 },
//                                 );
//
//
//
//                               },
//                               child: const Text(
//                                 "Accept",
//                                 style: TextStyle(
//                                   fontSize: 15.0,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ] else if (widget.notificationValues.type ==
//                             "removeBike") ...[
//                           SizedBox(
//                             height: 20.h,
//                           ),
//                           Center(
//                             child: Text(
//                               widget.notificationValues.title ?? "error",
//                               style: TextStyle(
//                                 fontFamily: 'Raleway',
//                                 fontSize: 17.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 5.h,
//                           ),
//                           Container(
//                             child: Center(
//                               child: Text(
//                                 widget.notificationValues.body ?? "error",
//                                 style: TextStyle(
//                                   fontFamily: 'Raleway',
//                                   fontSize: 15.sp,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ]
//                       ]))
//                   //     )
//                   ))),
//     );
//   }
// }

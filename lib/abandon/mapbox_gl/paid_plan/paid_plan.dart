// import 'dart:async';
// import 'dart:math';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:evie_test/api/navigator.dart';
// import 'package:evie_test/api/provider/auth_provider.dart';
// import 'package:evie_test/api/provider/bluetooth_provider.dart';
// import 'package:evie_test/api/sizer.dart';
// import 'package:evie_test/screen/user_home_page/paid_plan/mapbox_widget.dart';
// import 'package:evie_test/widgets/page_widget/home_page_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:evie_test/api/provider/current_user_provider.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:map_launcher/map_launcher.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:provider/provider.dart';
// import '../../../api/model/location_model.dart';
// import '../../../api/provider/bike_provider.dart';
// import '../../../api/provider/location_provider.dart';
// import '../../../bluetooth/modelResult.dart';
// import '../../../widgets/evie_double_button_dialog.dart';
// import '../../../widgets/evie_single_button_dialog.dart';
// import '../free_plan/free_plan.dart';
// import 'bottom_sheet_widget.dart';
//
// class PaidPlan extends StatefulWidget {
//   const PaidPlan({Key? key}) : super(key: key);
//
//   @override
//   _PaidPlanState createState() => _PaidPlanState();
// }
//
// class _PaidPlanState extends State<PaidPlan> {
//   late CurrentUserProvider _currentUserProvider;
//   late BikeProvider _bikeProvider;
//   late BluetoothProvider _bluetoothProvider;
//
//   Color lockColour = const Color(0xff6A51CA);
//
//   ///When get data from _bluetoothProvider.cableLockState is not equal to unknown
//   ///Need either lock/unlock
//   bool? isDeviceConnected;
//
//   final CarouselController _pageController = CarouselController();
//
//   String carbonFootprint = "D";
//   String mileage = "D";
//
//   DeviceConnectionState? connectionState;
//   ConnectionStateUpdate? connectionStateUpdate;
//   CableLockResult? cableLockState;
//
//   Image connectImage = Image(
//     image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
//     width: 52.w,
//     height: 50.h,
//   );
//
//   Image lockImage = Image(
//     width: 52.w,
//     height: 50.h,
//     image: const AssetImage("assets/buttons/lock_lock.png"),
//   );
//
//   List<String> imgList = [
//     'assets/images/bike_HPStatus/bike_normal.png',
//   ];
//
//   final List<String> dangerStatus = ['safe', 'warning', 'danger'];
//   String currentDangerStatus = 'safe';
//   String currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
//   String currentSecurityIcon =
//       "assets/buttons/bike_security_lock_and_secure.png";
//
//   late LocationProvider _locationProvider;
//   late LatLngBounds latLngBounds;
//
//   MapboxMapController? mapController;
//   double currentScroll = 0.40;
//
//   Symbol? locationSymbol;
//   String? distanceBetween;
//   UserLocation? userLocation;
//
//   StreamSubscription? locationSubscription;
//
//   static const double initialRatio = 374 / 710;
//   static const double minRatio = 170 / 710;
//   static const double maxRatio = 1.0;
//   bool isBottomSheetExpanded = false;
//   bool isMapListShowing = false;
//   List<AvailableMap>? availableMaps;
//
//   @override
//   void initState() {
//     _locationProvider = Provider.of<LocationProvider>(context, listen: false);
//     _locationProvider.addListener(locationListener);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _locationProvider.removeListener(locationListener);
//     mapController?.dispose();
//     super.dispose();
//   }
//
//
//   void loadImage(String dangerStatus) {
//     switch (dangerStatus) {
//       case 'safe':
//         {
//           currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
//           currentSecurityIcon =
//           "assets/buttons/bike_security_lock_and_secure.png";
//         }
//         break;
//       case 'warning':
//         {
//           currentBikeStatusImage =
//           "assets/images/bike_HPStatus/bike_warning.png";
//           currentSecurityIcon = "assets/buttons/bike_security_warning.png";
//         }
//         break;
//       case 'danger':
//         {
//           currentBikeStatusImage =
//           "assets/images/bike_HPStatus/bike_danger.png";
//           currentSecurityIcon = "assets/buttons/bike_security_danger.png";
//         }
//         break;
//       default:
//         {
//           currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
//           currentSecurityIcon =
//           "assets/buttons/bike_security_lock_and_secure.png";
//         }
//     }
//   }
//
//
//   ///Change icon according to dangerous level
//   addSymbol() async {
//
//     var markerImage = await loadMarkerImage(currentDangerStatus);
//     mapController?.addImage('marker', markerImage);
//
//     locationSymbol = (await mapController?.addSymbol(
//       SymbolOptions(
//         iconImage: 'marker',
//         iconSize: 2,
//         geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
//             _locationProvider.locationModel!.geopoint.longitude),
//       ),
//     ));
//   }
//
//   void getPlace() {
//     _locationProvider.getPlaceMarks(
//         _locationProvider.locationModel!.geopoint.latitude,
//         _locationProvider.locationModel!.geopoint.longitude);
//
//     try {
//       mapController?.onSymbolTapped.add((argument) async {
//       });
//     } catch (e, s) {
//       print(s);
//     }
//   }
//
//   void _onMapCreated(MapboxMapController mapController) async {
//     setState(() {
//       this.mapController = mapController;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _currentUserProvider = Provider.of<CurrentUserProvider>(context);
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _bluetoothProvider = Provider.of<BluetoothProvider>(context);
//     _locationProvider = Provider.of<LocationProvider>(context);
//
//     connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
//     connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
//     cableLockState = _bluetoothProvider.cableLockState;
//
//     ///Handle all data if bool isDeviceConnected is true
//     if (connectionState == DeviceConnectionState.connected &&
//         cableLockState?.lockState == LockState.lock ||
//         cableLockState?.lockState == LockState.unlock) {
//       setState(() {
//         isDeviceConnected = true;
//       });
//     } else {
//       setState(() {
//         isDeviceConnected = false;
//       });
//
//     }
//
//     Future.delayed(Duration.zero, () {
//       if (_bluetoothProvider.connectionStateUpdate?.failure != null) {
//         _bluetoothProvider.disconnectDevice(connectionStateUpdate!.deviceId);
//         SmartDialog.show(
//             keepSingle: true,
//             widget: EvieSingleButtonDialogCupertino(
//                 title: "Cannot connect bike",
//                 content: "Move your device near the bike and try again",
//                 rightContent: "OK",
//                 onPressedRight: () {
//                   SmartDialog.dismiss();
//                 }));
//       }
//     });
//
//     setConnectImage();
//     setLockImage();
//     setBikeImage();
//
//     // final TextEditingController _bikeNameController = TextEditingController();
//     // final FocusNode _textFocus = FocusNode();
//
//
//     return WillPopScope(
//       onWillPop: () async {
//         bool? exitApp = await SmartDialog.show(
//             widget: EvieDoubleButtonDialogCupertino(
//                 title: "Close this app?",
//                 content: "Are you sure you want to close this App?",
//                 leftContent: "No",
//                 rightContent: "Yes",
//                 onPressedLeft: () {
//                   SmartDialog.dismiss();
//                 },
//                 onPressedRight: () {
//                   SystemNavigator.pop();
//                 })) as bool?;
//         return exitApp ?? false;
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topCenter,
//               child: Column(
//                 //mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 34.h,
//                   ),
//                   FutureBuilder(
//                       future: _currentUserProvider.fetchCurrentUserModel,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return GestureDetector(
//                               onTap: (){
//                                 changeToLetsGoScreen(context);
//                               },
//                               child:HomePageWidget_Status(
//                                   currentDangerState: currentDangerStatus,
//                                   location: _locationProvider.currentPlaceMark)
//                           );
//                         } else {
//                           return const Center(
//                             child: Text("Good Morning"),
//                           );
//                         }
//                       }),
//                   FutureBuilder(
//                       future: getLocationModel(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return SizedBox(
//                             width: double.infinity,
//                             height: 636.h,
//                             child: Stack(
//                               children: [
//
//                                 Mapbox_Widget(
//                                     accessToken: _locationProvider.defPublicAccessToken,
//                                     onMapCreated: _onMapCreated,
//                                     onStyleLoadedCallback:  () {
//                                       loadImage(currentDangerStatus);
//                                       getPlace();
//                                     },
//                                     onUserLocationUpdate: (userLocation) {
//                                       if (this.userLocation != null) {
//                                         this.userLocation = userLocation;
//                                         getDistanceBetween();
//                                       }
//                                       else {
//                                         this.userLocation = userLocation;
//                                         getDistanceBetween();
//                                         runSymbol();
//                                       }
//                                     },
//                                     latitude: _locationProvider
//                                         .locationModel!.geopoint.latitude,
//                                     longitude:_locationProvider
//                                         .locationModel!.geopoint.longitude,
//                                     )
//                               ],
//                             ),
//                           );
//                         } else {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                       }),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: NotificationListener<DraggableScrollableNotification>(
//                   onNotification: (notification) {
//
//
//                     if (notification.extent > 0.8) {
//                       setState(() {
//                         currentScroll = notification.extent;
//                         isBottomSheetExpanded = true;
//                       });
//                     }
//                     else {
//                       setState(() {
//                         currentScroll = notification.extent;
//                         isBottomSheetExpanded = false;
//                       });
//                     }
//
//                     return false;
//                   },
//                   child: DraggableScrollableSheet(
//                       initialChildSize: initialRatio,
//                       minChildSize: minRatio,
//                       maxChildSize: maxRatio,
//                       snap: true,
//                       snapSizes: const [minRatio, initialRatio, maxRatio],
//                       expand: true,
//                       builder: (BuildContext context, ScrollController _scrollController) {
//
//                         animateBounce();
//
//                         return ListView(
//                           controller: _scrollController,
//                           children: [
//                             mapLauncher(),
//                             currentScroll <= 0.8 ?
//                             Stack(
//                                 children: [
//                                   ///Bike Connected
//                                   if (isDeviceConnected == true) ...{
//                                     Container(
//                                         height: 636.h,
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFECEDEB),
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                                 children: <Widget>[
//                                                   Padding(
//                                                     padding: EdgeInsets.only(top: 11.h),
//                                                     child: Image.asset("assets/buttons/home_indicator.png",
//                                                       width: 40.w, height: 4.h,),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                     EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
//                                                     child: Bike_Name_Row(
//                                                       bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
//                                                       distanceBetween: distanceBetween ?? "-",
//                                                       currentBikeStatusImage: currentBikeStatusImage,),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
//                                                     child: IntrinsicHeight(
//                                                       child: Bike_Status_Row(
//                                                         batteryImage: getBatteryImage(_bikeProvider.currentBikeModel?.batteryPercent ?? 0),
//                                                         batteryPercentage: _bikeProvider.currentBikeModel?.batteryPercent ?? 0,
//                                                         currentSecurityIcon: currentSecurityIcon,
//                                                         child: getSecurityTextWidget(
//                                                             _bluetoothProvider.cableLockState?.lockState ?? LockState.unknown,
//                                                             _bikeProvider.currentBikeModel?.location!.status ?? ""),),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding: EdgeInsets.only(top: 31.h),
//                                                     child: Column(
//                                                       children: [
//                                                         SizedBox(
//                                                           height: 96.h,
//                                                           width: 96.w,
//                                                           child:FloatingActionButton(
//                                                             elevation: 0,
//                                                             backgroundColor:
//                                                             cableLockState
//                                                                 ?.lockState ==
//                                                                 LockState
//                                                                     .lock
//                                                                 ? lockColour
//                                                                 : const Color(
//                                                                 0xffC1B7E8),
//                                                             onPressed: cableLockState
//                                                                 ?.lockState ==
//                                                                 LockState.lock
//                                                                 ? () {
//                                                               ///Check is connected
//
//                                                               SmartDialog
//                                                                   .showLoading(
//                                                                   msg:
//                                                                   "Unlocking");
//                                                               StreamSubscription?
//                                                               subscription;
//                                                               subscription =
//                                                                   _bluetoothProvider
//                                                                       .cableUnlock()
//                                                                       .listen(
//                                                                           (unlockResult) {
//                                                                         SmartDialog.dismiss(
//                                                                             status: SmartStatus
//                                                                                 .loading);
//                                                                         subscription
//                                                                             ?.cancel();
//                                                                         if (unlockResult
//                                                                             .result ==
//                                                                             CommandResult
//                                                                                 .success) {
//                                                                           ScaffoldMessenger.of(
//                                                                               context)
//                                                                               .showSnackBar(
//                                                                             SnackBar(
//                                                                               content:
//                                                                               Text('Bike is unlocked. To lock bike, pull the lock handle on the bike.',style: TextStyle(fontSize: 16.sp),),
//                                                                               duration:
//                                                                               Duration(seconds: 2),
//                                                                             ),
//                                                                           );
//                                                                         } else {
//                                                                           SmartDialog.dismiss(
//                                                                               status:
//                                                                               SmartStatus.loading);
//                                                                           subscription
//                                                                               ?.cancel();
//                                                                           ScaffoldMessenger.of(
//                                                                               context)
//                                                                               .showSnackBar(
//                                                                             SnackBar(
//                                                                               width:
//                                                                               358.w,
//                                                                               behavior:
//                                                                               SnackBarBehavior.floating,
//                                                                               shape: const RoundedRectangleBorder(
//                                                                                   borderRadius:
//                                                                                   BorderRadius.all(Radius.circular(10))),
//                                                                               content:
//                                                                               Container(
//                                                                                 height:
//                                                                                 80.h,
//                                                                                 child:
//                                                                                 Text('Bike is unlocked. To lock bike, pull the lock handle on the bike.',style: TextStyle(fontSize: 16.sp),),
//                                                                               ),
//                                                                               duration:
//                                                                               const Duration(seconds: 4),
//                                                                             ),
//                                                                           );
//                                                                         }
//                                                                       }, onError: (error) {
//                                                                     SmartDialog.dismiss(
//                                                                         status: SmartStatus
//                                                                             .loading);
//                                                                     subscription
//                                                                         ?.cancel();
//                                                                     SmartDialog.show(
//                                                                         widget: EvieSingleButtonDialogCupertino(
//                                                                             title: "Error",
//                                                                             content: "Cannot unlock bike, please place the phone near the bike and try again.",
//                                                                             rightContent: "OK",
//                                                                             onPressedRight: () {
//                                                                               SmartDialog.dismiss();
//                                                                             }));
//                                                                   });
//                                                             }
//                                                                 : null,
//                                                             //icon inside button
//                                                             child: lockImage,
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 12.h,
//                                                         ),
//                                                         if (connectionState?.name ==
//                                                             "connecting") ...{
//                                                       Text(
//                                                             "Connecting bike",
//                                                             style: TextStyle(
//                                                                 fontSize: 12.sp,
//                                                                 fontWeight:
//                                                                 FontWeight.w400,
//                                                                 color: Color(
//                                                                     0xff3F3F3F)),
//                                                           ),
//                                                         } else if(connectionState?.name ==
//                                                             "connected")...{
//                                                            Text(
//                                                             "Tap to unlock bike",
//                                                             style: TextStyle(
//                                                                 fontSize: 12.sp,
//                                                                 fontWeight:
//                                                                 FontWeight.w400,
//                                                                 color: Color(
//                                                                     0xff3F3F3F)),
//                                                           ),
//                                                         }else ...{
//                                                       Text(
//                                                             "Tap to connect bike",
//                                                             style: TextStyle(
//                                                                 fontSize: 12.sp,
//                                                                 fontWeight:
//                                                                 FontWeight.w400,
//                                                                 color: Color(
//                                                                     0xff3F3F3F)),
//                                                           ),
//                                                         },
//                                                         // SizedBox(
//                                                         //   height: 11.h,
//                                                         // ),
//                                                         Image(
//                                                           image: AssetImage(
//                                                               "assets/buttons/up.png"),
//                                                           width: 24.w,
//                                                           height: 24.h,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         )),
//                                   }
//                                   ///Bike Not Connected
//                                   else ...{
//                                     Container(
//                                         height: 636.h,
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFECEDEB),
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                                 children: <Widget>[
//                                                   Padding(
//                                                     padding: EdgeInsets.only(top: 11.h),
//                                                     child: Image.asset("assets/buttons/home_indicator.png",
//                                                       width: 40.w, height: 4.h,),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                     EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
//                                                     child: Bike_Name_Row(
//                                                       bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
//                                                       distanceBetween: distanceBetween ?? "-",
//                                                       currentBikeStatusImage: currentBikeStatusImage,),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
//                                                     child: IntrinsicHeight(
//                                                       child: Bike_Status_Row(
//                                                         currentSecurityIcon: currentSecurityIcon,
//                                                         batteryImage: getBatteryImage(_bikeProvider.currentBikeModel?.batteryPercent ?? 0),
//                                                         batteryPercentage: _bikeProvider.currentBikeModel?.batteryPercent ?? 0,
//                                                         child: getFirestoreSecurityTextWidget(
//                                                            _bikeProvider.currentBikeModel?.isLocked,
//                                                             _bikeProvider.currentBikeModel?.location!.status ?? ""),),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding: EdgeInsets.only(top: 31.h),
//                                                     child: Column(
//                                                       children: [
//                                                         SizedBox(
//                                                           height: 96.h,
//                                                           width: 96.w,
//                                                           child: FloatingActionButton(
//                                                             elevation: 0,
//                                                             backgroundColor:
//                                                             lockColour,
//                                                             onPressed: () {
//                                                               ///Check bluetooth status
//
//                                                               var bleStatus =
//                                                                   _bluetoothProvider
//                                                                       .bleStatus;
//                                                               switch (bleStatus) {
//                                                                 case BleStatus
//                                                                     .poweredOff:
//                                                                   SmartDialog.show(
//                                                                       keepSingle:
//                                                                       true,
//                                                                       widget: EvieSingleButtonDialogCupertino(
//                                                                           title: "Error",
//                                                                           content: "Bluetooth is off, please turn on your bluetooth",
//                                                                           rightContent: "OK",
//                                                                           onPressedRight: () {
//                                                                             SmartDialog
//                                                                                 .dismiss();
//                                                                           }));
//                                                                   break;
//                                                                 case BleStatus
//                                                                     .unknown:
//                                                                 // TODO: Handle this case.
//                                                                   break;
//                                                                 case BleStatus
//                                                                     .unsupported:
//                                                                   SmartDialog.show(
//                                                                       keepSingle:
//                                                                       true,
//                                                                       widget: EvieSingleButtonDialogCupertino(
//                                                                           title: "Error",
//                                                                           content: "Bluetooth unsupported",
//                                                                           rightContent: "OK",
//                                                                           onPressedRight: () {
//                                                                             SmartDialog
//                                                                                 .dismiss();
//                                                                           }));
//                                                                   break;
//                                                                 case BleStatus
//                                                                     .unauthorized:
//                                                                 // TODO: Handle this case.
//                                                                   break;
//                                                                 case BleStatus
//                                                                     .locationServicesDisabled:
//                                                                   SmartDialog.show(
//                                                                       keepSingle:
//                                                                       true,
//                                                                       widget: EvieSingleButtonDialogCupertino(
//                                                                           title: "Error",
//                                                                           content: "Location service disabled",
//                                                                           rightContent: "OK",
//                                                                           onPressedRight: () {
//                                                                             SmartDialog
//                                                                                 .dismiss();
//                                                                           }));
//                                                                   break;
//                                                                 case BleStatus
//                                                                     .ready:
//                                                                   if (connectionState ==
//                                                                       null ||
//                                                                       connectionState ==
//                                                                           DeviceConnectionState
//                                                                               .disconnected) {
//                                                                     _bluetoothProvider
//                                                                         .connectDevice();
//
//                                                                     // if(connectionStateUpdate != null){
//                                                                     //   if(connectionStateUpdate?.failure.toString() != null){
//                                                                     //     SmartDialog.show(
//                                                                     //         keepSingle: true,
//                                                                     //         widget: EvieSingleButtonDialogCupertino(
//                                                                     //             title: "Error",
//                                                                     //             content: "Cannot connect bike, please place the phone near the bike and try again.",
//                                                                     //             rightContent: "OK",
//                                                                     //             onPressedRight: (){SmartDialog.dismiss();})
//                                                                     //     );
//                                                                     //   }
//                                                                     // }
//
//                                                                   } else {
//
//                                                                   }
//                                                                   break;
//                                                                 default:
//                                                                   break;
//                                                               }
//                                                             },
//                                                             //icon inside button
//                                                             child: connectImage,
//                                                           )
//                                                         ),
//                                                         SizedBox(
//                                                           height: 12.h,
//                                                         ),
//                                                         if (connectionState?.name ==
//                                                             "connecting") ...{
//                                                           Text(
//                                                             "Connecting bike",
//                                                             style: TextStyle(
//                                                                 fontSize: 12.sp,
//                                                                 fontWeight:
//                                                                 FontWeight.w400,
//                                                                 color: Color(
//                                                                     0xff3F3F3F)),
//                                                           ),
//                                                         } else ...{
//                                                            Text(
//                                                             "Tap to connect bike",
//                                                             style: TextStyle(
//                                                                 fontSize: 12.sp,
//                                                                 fontWeight:
//                                                                 FontWeight.w400,
//                                                                 color: Color(
//                                                                     0xff3F3F3F)),
//                                                           ),
//                                                         },
//                                                         SizedBox(
//                                                           height: 11.h,
//                                                         ),
//                                                         const Image(
//                                                           image: AssetImage(
//                                                               "assets/buttons/up.png"),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         )),
//                                   }
//                                 ]) :
//                             Container (
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFECEDEB),
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: [
//
//                                     SizedBox(
//                                       height: 28.h,
//                                     ),
//
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.only(left:17.w),
//                                           child: Text("Threat History",style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),),
//                                         ),
//                                         IconButton(
//                                             onPressed: (){
//                                               _bikeProvider.controlBikeList("next");
//
//                                             },
//                                             icon: const Image(
//                                               image: AssetImage("assets/buttons/filter.png"),
//                                             )),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 11.h,
//                                     ),
//                                     const Divider(thickness: 2,),
//
//                                     Align(
//                                       alignment: Alignment.bottomCenter,
//                                       child: Column(
//                                         children: [
//
//                                            Text("scroll to load more",style:TextStyle(color: Color(0xff7A7A79), fontSize: 12.sp),),
//                                           SizedBox(height: 1.h),
//                                           Padding(
//                                             padding: const EdgeInsets.all(6),
//                                             child: Container(
//
//                                               child: ElevatedButton(
//                                               child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Show All Data",
//                       style:  EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
//                     ),
//                     SvgPicture.asset(
//                      "assets/buttons/external_link.svg",
//                     ),
//                   ],
//                 ),
//                                                   style: TextStyle(
//                                                     fontSize: 11.sp,
//                                                     color:
//                                                     Color(0xff7A7A79),
//                                                   ),
//                                                 ),
//                                                 onPressed: () {},
//                                                 style: ElevatedButton
//                                                     .styleFrom(
//                                                   shape: RoundedRectangleBorder(
//                                                       borderRadius:
//                                                       BorderRadius
//                                                           .circular(
//                                                           14.0),
//                                                       side: const BorderSide(
//                                                           color: Color(
//                                                               0xff7A7A79))),
//                                                   elevation: 0.0,
//                                                   backgroundColor:
//                                                   EvieColors.transparent,
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 120,
//                                                       vertical: 20),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//
//                                   ],
//                                 ),
//                               height: 720.h,
//                             ),
//                           ],
//                         );
//
//
//                       }),
//                 ),
//               ),
//             )
//           ],
//         ),
//         //        ),
//         //   )
//       ),
//     );
//   }
//
//   Widget mapLauncher() {
//     if (isBottomSheetExpanded) {
//       return const SizedBox();
//     }
//     else {
//       return Align(
//         alignment: Alignment.bottomRight,
//         child: GestureDetector(
//           onTap: () async {
//             List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
//             if (isMapListShowing) {
//               setState(() {
//                 this.availableMaps = null;
//                 isMapListShowing = false;
//               });
//             }
//             else {
//               setState(() {
//                 this.availableMaps = availableMaps;
//                 isMapListShowing = true;
//               });
//             }
//           },
//           child: Container(
//               height: 50.h,
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     availableMaps != null ?
//                     ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         return GestureDetector(
//                           onTap: () {
//                             MapLauncher.showDirections(
//                                 mapType: availableMaps![index].mapType,
//                                 destination: Coords(_bikeProvider.currentBikeModel!.location!.geopoint.latitude,
//                                     _bikeProvider.currentBikeModel!.location!.geopoint.longitude
//                                 )
//                             );
//                           },
//                           child: SvgPicture.asset(
//                             availableMaps![index].icon,
//                             width: 36.w,
//                             height: 36.h,
//                           ),
//                         );
//                       },
//                       itemCount: availableMaps?.length,
//                     ) : SizedBox(),
//                     Padding(
//                       padding: EdgeInsets.only(right: 8.h),
//                       child: SvgPicture.asset(
//                         "assets/icons/direction.svg",
//                         width: 50.w,
//                         height: 50.h,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//           ),
//         ),
//       );
//     }
//   }
//
//
//   void setConnectImage() {
//     if (connectionState?.name == "connected") {
//       setState(() {
//         connectImage = Image(
//           image: const AssetImage("assets/buttons/lock_lock.png"),
//           width: 52.w,
//           height: 50.h,
//         );
//         lockColour = const Color(0xff6A51CA);
//       });
//     } else if (connectionState?.name == "connecting") {
//       setState(() {
//         connectImage = Image(
//           image: const AssetImage("assets/buttons/loading.png"),
//           width: 52.w,
//           height: 50.h,
//         );
//         lockColour = const Color(0xff6A51CA);
//       });
//     } else if (connectionState?.name == "disconnected") {
//       setState(() {
//         connectImage = Image(
//           image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
//           width: 52.w,
//           height: 50.h,
//         );
//       });
//     }
//   }
//
//   void setLockImage() {
//     if (cableLockState?.lockState == LockState.lock) {
//       setState(() {
//         lockImage = Image(
//           width: 52.w,
//           height: 50.h,
//           image: const AssetImage("assets/buttons/lock_lock.png"),
//         );
//         lockColour = const Color(0xff6A51CA);
//       });
//     } else if (cableLockState?.lockState == LockState.unlock) {
//       setState(() {
//         lockImage = Image(
//           width: 52.w,
//           height: 50.h,
//           image: const AssetImage("assets/buttons/lock_unlock.png"),
//         );
//         lockColour = const Color(0xff6A51CA);
//       });
//     }
//   }
//
//   void setBikeImage() {
//     if (isDeviceConnected == true) {
//       switch (_bikeProvider.currentBikeModel!.location!.status) {
//         case "safe":
//           setState(() {
//             imgList = [
//               'assets/images/bike_HPStatus/bike_safe.png',
//             ];
//           });
//           break;
//         case "warning":
//           setState(() {
//             imgList = [
//               'assets/images/bike_HPStatus/bike_warning.png',
//             ];
//           });
//           break;
//         case "danger":
//           setState(() {
//             imgList = [
//               'assets/images/bike_HPStatus/bike_danger.png',
//             ];
//           });
//           break;
//         default:
//           setState(() {
//             imgList = [
//               'assets/images/bike_HPStatus/bike_normal.png',
//             ];
//           });
//       }
//     } else {
//       setState(() {
//         imgList = [
//           'assets/images/bike_HPStatus/bike_normal.png',
//         ];
//       });
//     }
//   }
//
//   Future<LocationModel?> getLocationModel() async {
//     return _locationProvider.locationModel;
//   }
//
//   void getDistanceBetween() {
//     if (userLocation != null) {
//       if (userLocation != null && distanceBetween == "-") {
//         setState(() {
//           distanceBetween = Geolocator.distanceBetween(
//               userLocation!.position.latitude,
//               userLocation!.position.longitude,
//               _locationProvider.locationModel!.geopoint.latitude,
//               _locationProvider.locationModel!.geopoint.longitude)
//               .toStringAsFixed(0);
//         });
//       }
//       else {
//         distanceBetween = Geolocator.distanceBetween(
//             userLocation!.position.latitude,
//             userLocation!.position.longitude,
//             _locationProvider.locationModel!.geopoint.latitude,
//             _locationProvider.locationModel!.geopoint.longitude)
//             .toStringAsFixed(0);
//         print(distanceBetween);
//       }
//     }
//     else {
//       distanceBetween = "-";
//     }
//   }
//
//   void animateBounce() {
//     if(_locationProvider.locationModel != null && userLocation?.position != null){
//       final LatLng southwest = LatLng(
//         min(_locationProvider.locationModel!.geopoint.latitude,
//             userLocation!.position.latitude),
//         min(_locationProvider.locationModel!.geopoint.longitude,
//             userLocation!.position.longitude),
//       );
//
//       final LatLng northeast = LatLng(
//         max(_locationProvider.locationModel!.geopoint.latitude,
//             userLocation!.position.latitude),
//         max(_locationProvider.locationModel!.geopoint.longitude,
//             userLocation!.position.longitude),
//       );
//
//       latLngBounds = LatLngBounds(southwest: southwest, northeast: northeast);
//
//       if(currentScroll <= (initialRatio) && currentScroll > minRatio + 0.01){
//         if (mapController != null) {
//           if (!mapController!.isCameraMoving) {
//             mapController?.animateCamera(CameraUpdate.newLatLngBounds(
//               latLngBounds,
//               left: 170.w,
//               right: 170.w,
//               top: 100.h,
//               bottom: 324.h,
//             ));
//           }
//         }
//
//       }else if(currentScroll == minRatio){
//         mapController?.animateCamera(CameraUpdate.newLatLngBounds(
//           latLngBounds,
//           left: 80.w,
//           right: 80.w,
//           top: 80.h,
//           bottom: 120.h,
//         ));
//       }
//     }
//   }
//
//   void locationListener() {
//     currentDangerStatus = _bikeProvider.currentBikeModel!.location!.status;
//     //currentBikeLatitude = _locationProvider.locationModel!.geopoint.latitude;
//     //currentBikeLongitude =  _locationProvider.locationModel!.geopoint.longitude;
//
//     getDistanceBetween();
//     loadImage(currentDangerStatus);
//     if (mapController != null) {
//       runSymbol();
//     }
//   }
//
//   runSymbol() async {
//     if (mapController?.symbols != null  && locationSymbol != null) {
//
//       var markerImage = await loadMarkerImage(currentDangerStatus);
//       mapController?.addImage('marker', markerImage);
//
//       mapController?.updateSymbol(
//         locationSymbol!,
//         SymbolOptions(
//           iconImage: 'marker',
//           iconSize: 2,
//           geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
//               _locationProvider.locationModel!.geopoint.longitude),
//         ),
//       );
//       animateBounce();
//     } else {
//       if(mapController != null){
//         await addSymbol();
//         animateBounce();
//       }
//     }
//     //  getPlace();
//   }
// }

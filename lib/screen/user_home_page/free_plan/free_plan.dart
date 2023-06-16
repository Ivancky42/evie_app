import 'dart:async';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/free_plan/mapbox_widget.dart';
import 'package:evie_test/widgets/evie_card.dart';

import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/function.dart';
import '../../../api/model/location_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../api/toast.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../home_page_widget.dart';
import '../paid_plan/paid_plan.dart';
import '../switch_bike.dart';
import 'bottom_sheet_widget.dart';

class FreePlan extends StatefulWidget {
  const FreePlan({Key? key}) : super(key: key);

  @override
  _FreePlanState createState() => _FreePlanState();
}

class _FreePlanState extends State<FreePlan> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late NotificationProvider _notificationProvider;
  late SettingProvider _settingProvider;

  Color lockColour = const Color(0xff6A51CA);


  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;

  Widget? buttonImage;

  List<String> imgList = [
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  final List<String> dangerStatus = ['safe', 'warning', 'danger'];
  String currentDangerStatus = 'safe';
  String currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
  String currentSecurityIcon = "assets/buttons/bike_security_not_available.svg";

  late LocationProvider _locationProvider;

  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;

  StreamSubscription? locationSubscription;
  bool myLocationEnabled = false;
  bool isFirstLoadUserLocation = true;

  LocationData? userLocation;
  late final MapController mapController;
  final Location _locationService = Location();

  StreamSubscription? userLocationSubscription;
  StreamSubscription<DeviceConnectResult>? connectionStream;

  static const double initialRatio = 374 / 700;
  static const double minRatio = 136 / 700;
  static const double maxRatio = 1.0;
  bool isBottomSheetExpanded = false;
  bool isFirstTimeConnected = false;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    mapController = MapController();
    initLocationService();
  }

  void initLocationService() async {

    // ///If 5 seconds are passed AND if the phone is moved at least 1 meters, listen the location
    // await _locationService.changeSettings(interval: 5000, distanceFilter: 1);
    //
    // ///For user live location
    // userLocationSubscription = _locationService.onLocationChanged.listen((LocationData result) async {
    //       if (mounted) {
    //         setState(() {
    //           userLocation = result;
    //           if(isFirstLoadUserLocation == true){
    //             Future.delayed(const Duration(milliseconds: 50), () {
    //               animateBounce();
    //             });
    //             isFirstLoadUserLocation = false;
    //           }
    //        //   animateBounce();
    //         });
    //       }
    //     });
    //
    // locationListener();
    // // if(userLocation != null){
    // //   locationListener();
    // // }
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    mapController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
     _notificationProvider = Provider.of<NotificationProvider>(context);
     _settingProvider = Provider.of<SettingProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

    setButtonImage();

    LatLng currentLatLngFree;

    if (userLocation != null) {
      currentLatLngFree = LatLng(userLocation!.latitude!, userLocation!.longitude!);
    } else {
      currentLatLngFree = LatLng(0, 0);
    }

    final markers = <Marker>[
      Marker(
        width: 42.w,
        height: 56.h,
        point: currentLatLngFree,
        builder: (ctx) {
          return _buildCompass();
        },
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
          backgroundColor: EvieColors.lightBlack,
          body: SafeArea(
            child: Container(
              color: EvieColors.grayishWhite,
              child: Stack(
                children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color:  EvieColors.lightBlack,
                        child: FutureBuilder(
                            future: _currentUserProvider.fetchCurrentUserModel,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                  onTap: (){},
                                  child:Padding(
                                    padding: EdgeInsets.fromLTRB(0.w, 0, 0.w, 0),
                                    child: Container(
                                        height: 73.33.h,
                                        color:  EvieColors.lightBlack,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: SingleChildScrollView(
                                            physics: NeverScrollableScrollPhysics(),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/bike_round.png'),
                                                  ),
                                                  Padding(
                                                    padding:  EdgeInsets.only(left: 12.w),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        Row(
                                                          children: [
                                                            Text(
                                                              _bikeProvider.currentBikeModel?.deviceName ?? "loading",
                                                              style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite),
                                                            ),
                                                            // Text(
                                                            //   "icons",
                                                            //   style: EvieTextStyles.h3.copyWith(color: EvieColors.grayishWhite),
                                                            // ),
                                                          ],
                                                        ),

                                                        deviceConnectResult == DeviceConnectResult.connected ?
                                                        Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/icons/bluetooth_connected.svg",
                                                            ),
                                                            Text(
                                                              "Connected",
                                                              style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
                                                            ),
                                                          ],
                                                        ) :
                                                        Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/icons/bluetooth_disconnected.svg",
                                                            ),
                                                            Text(
                                                              "Disconnected",
                                                              style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],),
                                                Padding(
                                                  padding: EdgeInsets.only(right: 22.5.w),
                                                  child: IconButton(
                                                      onPressed: (){
                                                        showMaterialModalBottomSheet(
                                                            expand: false,
                                                            context: context,
                                                            builder: (context) {
                                                              return SwitchBike();
                                                            });
                                                  },
                                                      icon: SvgPicture.asset("assets/buttons/down_white.svg",)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "Loading",
                                    style: EvieTextStyles.h3,
                                  ),
                                );
                              }
                            }),
                      ),
                     Expanded(
                       child: SingleChildScrollView(
                         physics: const BouncingScrollPhysics(),
                         child: Padding(
                           padding: EdgeInsets.all(5),
                           child: Column(
                             children: [

                               // Visibility(
                               //   visible: _bikeProvider.rfidList.length == 0,
                               //   child: Padding(
                               //     padding: EdgeInsets.all(10.w),
                               //     child: EvieCard(
                               //       height: 96.h,
                               //       width: double.infinity,
                               //       color: EvieColors.primaryColor,
                               //       child: Row(
                               //         children: [
                               //
                               //       ],),
                               //     ),
                               //   ),
                               // ),

                               Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Expanded(
                                     child: Padding(

                                         padding: EdgeInsets.all(8),
                                         child: EvieCard(
                                           title: "Orbital Anti-theft",
                                           child: Expanded(
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.end,
                                               children: [
                                                 SvgPicture.asset(
                                                   "assets/buttons/bike_security_not_available.svg",
                                                 ),
                                                 Text("Not Available", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                             ],
                                             ),
                                           ),

                                         )
                                     ),
                                   ),
                                   Expanded(
                                     child: Padding(
                                         padding: EdgeInsets.all(8),
                                         child: EvieCard(
                                           ///Listen to bluetooth provider data
                                           title: "Battery",
                                           child: Expanded(
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.end,
                                               children: [
                                                 SvgPicture.asset(
                                                   getBatteryImage(int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0")),
                                                   width: 36.w,
                                                   height: 36.h,
                                                 ),
                                                 Text("${int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0")} %", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                                 Text("Est 0km", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                 ),
                                                 SizedBox(height: 16.h,),
                                               ],
                                             ),
                                           ),

                                         )
                                     ),
                                   ),
                                 ],
                               ),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Expanded(
                                     child: Padding(
                                         padding: EdgeInsets.all(8),
                                         child: EvieCard(
                                           title: "Rides",
                                           child: Expanded(
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.end,
                                               children: [
                                                 SvgPicture.asset(
                                                   "assets/icons/bar_chart.svg",
                                                 ),
                                                 Text("- km", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                                 Text("ridden this week", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         )
                                     ),
                                   ),
                                   Expanded(
                                     child: Padding(
                                         padding: EdgeInsets.all(8),
                                         child: EvieCard(
                                           onPress: (){
                                             showBikeSettingSheet(context);
                                           },
                                           title: "Setting",
                                           child: Expanded(
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.end,
                                               children: [
                                                 SvgPicture.asset(
                                                   "assets/icons/setting_black.svg",
                                                 ),
                                                 Text("Bike Setting", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                               ],
                                             ),
                                           ),
                                         )
                                     ),
                                   ),
                                 ],
                               ),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Expanded(
                                     child: Padding(
                                         padding: EdgeInsets.all(8),
                                         child:Container()
                                     ),
                                   ),

                                   Expanded(
                                     child: Padding(
                                         padding: EdgeInsets.all(8),
                                         child: EvieCard(
                                           child: Column(
                                             mainAxisAlignment: MainAxisAlignment.center,
                                             crossAxisAlignment: CrossAxisAlignment.center,
                                             children: [
                                               if(deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr)...{

                                                 SizedBox(
                                                   height: 96.h,
                                                   width: 96.w,
                                                   child:
                                                   FloatingActionButton(
                                                     elevation: 0,
                                                     backgroundColor: cableLockState?.lockState == LockState.lock
                                                         ?  EvieColors.primaryColor : EvieColors.softPurple,
                                                     onPressed: cableLockState
                                                         ?.lockState == LockState.lock
                                                         ? () {
                                                       ///Check is connected

                                                       _bluetoothProvider.setIsUnlocking(true);
                                                       showUnlockingToast(context);

                                                       StreamSubscription?
                                                       subscription;
                                                       subscription = _bluetoothProvider
                                                           .cableUnlock()
                                                           .listen(
                                                               (unlockResult) {
                                                             SmartDialog.dismiss(
                                                                 status:
                                                                 SmartStatus.loading);
                                                             subscription
                                                                 ?.cancel();
                                                             if (unlockResult.result ==
                                                                 CommandResult.success) {

                                                               //  showToLockBikeInstructionToast(context);

                                                             } else {
                                                               SmartDialog.dismiss(
                                                                   status: SmartStatus.loading);
                                                               subscription?.cancel();
                                                               //  showToLockBikeInstructionToast(context);
                                                             }
                                                           }, onError: (error) {
                                                         SmartDialog.dismiss(
                                                             status:
                                                             SmartStatus.loading);
                                                         subscription
                                                             ?.cancel();
                                                         SmartDialog.show(
                                                             widget: EvieSingleButtonDialog(
                                                                 title: "Error",
                                                                 content: "Cannot unlock bike, please place the phone near the bike and try again.",
                                                                 rightContent: "OK",
                                                                 onPressedRight: () {
                                                                   SmartDialog.dismiss();
                                                                 }));
                                                       });
                                                     }
                                                         : (){
                                                       showToLockBikeInstructionToast(context);
                                                     },
                                                     //icon inside button
                                                     child: buttonImage,
                                                   ),
                                                 ),
                                                 SizedBox(
                                                   height: 12.h,
                                                 ),
                                                 if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                                   Text(
                                                     "Connecting bike",
                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                   ),
                                                 } else if (deviceConnectResult == DeviceConnectResult.connected) ...{
                                                   Text(
                                                     "Tap to unlock bike",
                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                   ),
                                                 } else ...{
                                                   Text(
                                                     "",
                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                   ),
                                                 },

                                                 ///If device is not connected
                                               }
                                               else...{
                                                 SizedBox(
                                                     height: 96.h,
                                                     width: 96.w,
                                                     child:
                                                     FloatingActionButton(
                                                       elevation: 0,
                                                       backgroundColor:
                                                       EvieColors.primaryColor,
                                                       onPressed: () {
                                                         checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
                                                       },
                                                       //icon inside button
                                                       child: buttonImage,
                                                     )),
                                                 SizedBox(
                                                   height: 12.h,
                                                 ),
                                                 if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                                   Text(
                                                     "Connecting bike",
                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                   ),
                                                 }
                                                 else ...{
                                                   Text(
                                                     "Tap to connect bike",
                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                   ),
                                                 },

                                               }

                                             ],),
                                         )
                                     ),
                                   ),
                                 ],
                               ),

                             ],
                           ),
                         ),
                       ),
                     ),

                    ],
                  ),
                ),
              ],),
            )
            // Stack(
            //   children: [
            //     Align(
            //       alignment: Alignment.topCenter,
            //       child: Column(
            //         //mainAxisAlignment: MainAxisAlignment.center,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //
            //           FutureBuilder(
            //               future: _currentUserProvider.fetchCurrentUserModel,
            //               builder: (context, snapshot) {
            //                 if (snapshot.hasData) {
            //                   return GestureDetector(
            //                     onTap: (){},
            //                     child:Padding(
            //                       padding: EdgeInsets.fromLTRB(0.w, 0, 0.w, 0),
            //                       child: Container(
            //                           height: 73.33.h,
            //                           color:  EvieColors.lightBlack,
            //                           child: Container(
            //                             alignment: Alignment.centerLeft,
            //                             child: Row(
            //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                               children: [
            //                                 Row(children: [
            //                                   Text("EvieBikePic", style: TextStyle(color: EvieColors.grayishWhite),),
            //                                   Column(
            //                                     mainAxisAlignment: MainAxisAlignment.center,
            //                                     children: [
            //                                       Row(
            //                                         children: [
            //                                           Text(
            //                                             "name",
            //                                             style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite),
            //                                           ),
            //                                           Text(
            //                                             "  icons",
            //                                             style: EvieTextStyles.h3.copyWith(color: EvieColors.grayishWhite),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                       Text(
            //                                         "status",
            //                                         style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
            //                                       ),
            //                                     ],
            //                                   ),
            //                                 ],),
            //                                 Text("button",style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite))
            //                               ],
            //                             ),
            //                           )
            //                       ),
            //                     ),
            //                   );
            //                 } else {
            //                   return Center(
            //                    child: Text(
            //                      "hello",
            //                       style: EvieTextStyles.h3,
            //                     ),
            //                   );
            //                 }
            //               }),
            //
            //           FutureBuilder(
            //               future: getLocationModel(),
            //               builder: (context, snapshot) {
            //                 if (snapshot.hasData) {
            //                   return SizedBox(
            //                     width: double.infinity,
            //                     height: 600.h,
            //                     child: Stack(
            //                       children: [
            //                         Mapbox_Widget(
            //                           accessToken: _locationProvider.defPublicAccessToken,
            //                           //onMapCreated: _onMapCreated,
            //
            //                           mapController: mapController,
            //                           markers: markers,
            //                           // onUserLocationUpdate: (userLocation) {
            //                           //   if (this.userLocation != null) {
            //                           //     this.userLocation = userLocation;
            //                           //     getDistanceBetween();
            //                           //   }
            //                           //   else {
            //                           //     this.userLocation = userLocation;
            //                           //     getDistanceBetween();
            //                           //     runSymbol();
            //                           //   }
            //                           // },
            //                           latitude: _locationProvider.locationModel!.geopoint.latitude,
            //                           longitude: _locationProvider.locationModel!.geopoint.longitude,
            //                         ),
            //                       ],
            //                     ),
            //                   );
            //                 } else {
            //                   return const Center(
            //                     child: CircularProgressIndicator(),
            //                   );
            //                 }
            //               }),
            //         ],
            //       ),
            //     ),
            //
            //     stackActionableBar(context, _bikeProvider, _notificationProvider),
            //
            //     Align(
            //       alignment: Alignment.bottomCenter,
            //       child: Container(
            //         height: double.infinity,
            //         width: double.infinity,
            //         child: NotificationListener<DraggableScrollableNotification>(
            //           onNotification: (notification) {
            //             if (notification.extent > 0.8) {
            //               setState(() {
            //                 currentScroll = notification.extent;
            //                 isBottomSheetExpanded = true;
            //               });
            //             } else {
            //               setState(() {
            //                 currentScroll = notification.extent;
            //                 isBottomSheetExpanded = false;
            //               });
            //             }
            //
            //             return false;
            //           },
            //           child: DraggableScrollableSheet(
            //               initialChildSize: initialRatio,
            //               minChildSize: minRatio,
            //               maxChildSize: maxRatio,
            //               snap: true,
            //               snapSizes: const [minRatio, initialRatio, maxRatio],
            //               expand: true,
            //               builder: (BuildContext context, ScrollController _scrollController) {
            //
            //                 return ListView(
            //                   controller: _scrollController,
            //                   physics: const BouncingScrollPhysics(),
            //                   children: [
            //                     navigateButton(),
            //                     currentScroll <= 0.8 ?
            //                     Stack(
            //                         children: [
            //                           ///Bike Connected
            //                           if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) ...{
            //                             Container(
            //                                 height: 636.h,
            //                                 decoration: BoxDecoration(
            //                                   color: const Color(0xFFECEDEB),
            //                                   borderRadius: BorderRadius.circular(16),
            //                                 ),
            //                                 child: Column(
            //                                   children: [
            //                                     Center(
            //                                       child: Column(
            //                                         mainAxisAlignment:
            //                                         MainAxisAlignment.start,
            //                                         children: <Widget>[
            //                                           Padding(
            //                                             padding: EdgeInsets.only(top: 11.h),
            //                                             child: Image.asset(
            //                                               "assets/buttons/home_indicator.png",
            //                                               width: 40.w,
            //                                               height: 4.h,),
            //                                           ),
            //                                           Padding(
            //                                             padding:
            //                                             EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
            //                                             child: Bike_Name_Row(
            //                                               isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,
            //                                               bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
            //                                               distanceBetween: "Est. ${distanceBetween}m",
            //                                               currentBikeStatusImage: currentBikeStatusImage,),
            //                                           ),
            //
            //                                           Padding(
            //                                             padding:
            //                                             EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
            //                                             child: IntrinsicHeight(
            //                                               child: Bike_Status_Row(
            //                                                 batteryPercentage: _bluetoothProvider.bikeInfoResult!.batteryLevel!,
            //                                                 currentBatteryIcon: getBatteryImageFromBLE(_bluetoothProvider.bikeInfoResult!.batteryLevel!),
            //                                                 currentSecurityIcon: currentSecurityIcon,
            //                                                 isLocked: cableLockState?.lockState ?? LockState.unknown,
            //                                                 settingProvider: _settingProvider,
            //                                                 child: Text( cableLockState!.lockState == LockState.lock ?
            //                                                 "Locked & Secured" : "Unlocked",
            //                                                   style: EvieTextStyles.headlineB,
            //                                                 ),),
            //                                             ),
            //                                           ),
            //
            //                                           Padding(
            //                                             padding: EdgeInsets.only(top: 31.h),
            //                                             child: Column(
            //                                               children: [
            //                                                 SizedBox(
            //                                                   height: 96.h,
            //                                                   width: 96.w,
            //                                                   child:FloatingActionButton(
            //                                                     elevation: 0,
            //                                                     backgroundColor:
            //                                                     cableLockState?.lockState == LockState.lock ? lockColour : const Color(0xffC1B7E8),
            //                                                     onPressed: cableLockState?.lockState == LockState.lock ? () {
            //                                                       ///Check is connected
            //
            //                                                    ///   SmartDialog.showLoading(msg: "Unlocking");
            //                                                       showUnlockingToast(context);
            //
            //                                                       StreamSubscription?
            //                                                       subscription;
            //                                                       subscription = _bluetoothProvider.cableUnlock().listen((unlockResult) {
            //                                                                 SmartDialog.dismiss(status: SmartStatus.loading);
            //                                                                 subscription?.cancel();
            //                                                                 if (unlockResult.result == CommandResult.success) {
            //                                                     //              showToLockBikeInstructionToast(context);
            //                                                                 } else {
            //                                                                   SmartDialog.dismiss(status: SmartStatus.loading);
            //                                                                   subscription?.cancel();
            //                                                      //             showToLockBikeInstructionToast(context);
            //                                                                 }
            //                                                               }, onError: (error) {
            //                                                             SmartDialog.dismiss(status: SmartStatus.loading);
            //                                                             subscription?.cancel();
            //                                                             showCannotUnlockBike();
            //                                                           });
            //                                                     }
            //                                                         : (){
            //                                                       showToLockBikeInstructionToast(context);
            //                                                     },
            //                                                     //icon inside button
            //                                                     child: lockImage,
            //                                                   ),
            //                                                 ),
            //                                                 SizedBox(
            //                                                   height: 12.h,
            //                                                 ),
            //                                                 if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
            //                                                   Text(
            //                                                     "Connecting bike",
            //                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            //                                                   ),
            //                                                 } else if(deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr)...{
            //                                                   Text(
            //                                                     "Tap to unlock bike",
            //                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            //                                                   ),
            //                                                 }else ...{
            //                                                   Text(
            //                                                     "Tap to connect bike",
            //                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            //                                                   ),
            //                                                 },
            //
            //                                               ],
            //                                             ),
            //                                           )
            //                                         ],
            //                                       ),
            //                                     ),
            //                                   ],
            //                                 )),
            //                           }
            //                           ///Bike Not Connected
            //                           else ...{
            //                             Container(
            //                                 height: 636.h,
            //                                 decoration: BoxDecoration(
            //                                   color: const Color(0xFFECEDEB),
            //                                   borderRadius: BorderRadius.circular(16),
            //                                 ),
            //                                 child: Column(
            //                                   children: [
            //                                     Center(
            //                                       child: Column(
            //                                         mainAxisAlignment:
            //                                         MainAxisAlignment.start,
            //                                         children: <Widget>[
            //                                           Padding(
            //                                             padding: EdgeInsets.only(top: 11.h),
            //                                             child: Image.asset("assets/buttons/home_indicator.png",
            //                                               width: 40.w, height: 4.h,),
            //                                           ),
            //                                           Padding(
            //                                             padding:
            //                                             EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
            //                                             child: Bike_Name_Row(
            //                                               bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
            //                                               distanceBetween: "Bike is not connected",
            //                                               currentBikeStatusImage: "assets/images/bike_HPStatus/bike_normal.png",
            //                                               isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr),
            //                                           ),
            //
            //                                           Padding(
            //                                             padding:
            //                                             EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
            //                                             child: IntrinsicHeight(
            //                                               child: Bike_Status_Row(
            //                                                 batteryPercentage: "-",
            //                                                 currentSecurityIcon:"assets/buttons/bike_security_not_available.svg",
            //                                                 currentBatteryIcon: "assets/icons/battery_not_available.svg",
            //                                                 isLocked: cableLockState?.lockState ?? LockState.unknown,
            //                                                 settingProvider: _settingProvider,
            //                                                 child:Text(
            //                                                   "Not Available",
            //                                                   style: EvieTextStyles.headlineB,
            //                                                 ),),
            //                                             ),
            //                                           ),
            //
            //                                           Padding(
            //                                             padding: EdgeInsets.only(top: 31.h),
            //                                             child: Column(
            //                                               children: [
            //                                                 SizedBox(
            //                                                   height: 96.h,
            //                                                   width: 96.w,
            //                                                   child: FloatingActionButton(
            //                                                     elevation: 0,
            //                                                     backgroundColor:
            //                                                     lockColour,
            //                                                     onPressed: () async {
            //                                                       checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
            //                                                     },
            //                                                     //icon inside button
            //                                                     child: connectImage,
            //                                                   ),
            //                                                 ),
            //                                                 SizedBox(
            //                                                   height: 12.h,
            //                                                 ),
            //                                                 if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
            //                                                   Text(
            //                                                     "Connecting bike",
            //                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            //                                                   ),
            //                                                 } else ...{
            //                                                   Text(
            //                                                     "Tap to connect bike",
            //                                                     style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            //                                                   ),
            //                                                 },
            //
            //                                               ],
            //                                             ),
            //                                           )
            //                                         ],
            //                                       ),
            //                                     ),
            //                                   ],
            //                                 )),
            //                           }
            //                         ]) :
            //                     Container (
            //                       decoration: BoxDecoration(
            //                         color: const Color(0xFFECEDEB),
            //                         borderRadius: BorderRadius.circular(16),
            //                       ),
            //                       child: Column(
            //                         mainAxisSize: MainAxisSize.max,
            //                         children: [
            //                           SizedBox(
            //                             height: 28.h,
            //                           ),
            //
            //                           Row(
            //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                             children: [
            //                               Padding(
            //                                 padding: EdgeInsets.only(left:17.w),
            //                                 child: Text("Threat History",style: EvieTextStyles.h1,),
            //                               ),
            //                               IconButton(
            //                                 onPressed: (){
            //                                   _bikeProvider.controlBikeList("next");
            //                                   _bluetoothProvider.disconnectDevice();
            //                                 },
            //                                 icon: SvgPicture.asset(
            //                                   "assets/buttons/filter.svg",
            //                                 ),
            //                               ),
            //                             ],
            //                           ),
            //                           SizedBox(
            //                             height: 11.h,
            //                           ),
            //                           const Divider(thickness: 2,),
            //
            //                           Align(
            //                             alignment: Alignment.bottomCenter,
            //                             child: Column(
            //                               children: [
            //
            //                                 Padding(
            //                                   padding: EdgeInsets.only(left:15.w, right:15.w),
            //                                   child: SvgPicture.asset(
            //                                     "assets/images/free_plan_threat.svg",
            //                                     height:608.h,
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //
            //                         ],
            //                       ),
            //                       height: 720.h,
            //                     ),
            //                   ],
            //                 );
            //               }),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          )
        //        ),
        //   )
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          color: Colors.transparent,
          child: Container(
            child: Transform.rotate(
              //   angle: (direction * (math.pi / 180) * -1),
              angle: (direction * (math.pi / 180) * 1),
              child: Image.asset('assets/icons/user_location_icon.png'),
            ),
          ),
        );
      },
    );
  }

  Widget navigateButton() {
    if (isBottomSheetExpanded) {
      return const SizedBox();
    } else {
      return Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () async {
            animateBounce();
          },
          child: Container(
              height: 50.h,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.h),
                  child: SvgPicture.asset(
                    "assets/buttons/location.svg",
                    width: 50.w,
                    height: 50.h,
                  ),
                ),
              )),
        ),
      );
    }
  }


  void setButtonImage() {
    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      if (cableLockState?.lockState == LockState.unlock) {
        if(_bluetoothProvider.isUnlocking == true){
          Future.delayed(Duration.zero, () {
            _bluetoothProvider.setIsUnlocking(false);
          });
        }
        buttonImage = SvgPicture.asset(
          "assets/buttons/lock_unlock.svg",
          width: 52.w,
          height: 50.h,
        );
      }else if(_bluetoothProvider.isUnlocking){
        buttonImage =  lottie.Lottie.asset('assets/animations/unlock_button.json', repeat: false);
      } else if (cableLockState?.lockState == LockState.lock) {

        buttonImage = SvgPicture.asset(
          "assets/buttons/lock_lock.svg",
          width: 52.w,
          height: 50.h,);
      }
    }
    else if (cableLockState?.lockState == LockState.unknown) {

      buttonImage =  lottie.Lottie.asset('assets/animations/loading_button.json');
    }
    else if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning || deviceConnectResult == DeviceConnectResult.partialConnected) {

      buttonImage =  lottie.Lottie.asset('assets/animations/loading_button.json');
    }
    else if (deviceConnectResult == DeviceConnectResult.disconnected) {
      buttonImage = SvgPicture.asset(
        "assets/buttons/bluetooth_not_connected.svg",
        width: 52.w,
        height: 50.h,
      );
    }
    else {
      buttonImage = SvgPicture.asset(
        "assets/buttons/bluetooth_not_connected.svg",
        width: 52.w,
        height: 50.h,
      );
    }
  }



  void setBikeImage() {
    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      switch (_bikeProvider.currentBikeModel!.location!.status) {
        case "safe":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_safe.png',
            ];
          });
          break;
        case "warning":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_warning.png',
            ];
          });
          break;
        case "danger":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_danger.png',
            ];
          });
          break;
        default:
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_normal.png',
            ];
          });
      }
    } else {
      setState(() {
        imgList = [
          'assets/images/bike_HPStatus/bike_normal.png',
        ];
      });
    }
  }

  Future<LocationModel?> getLocationModel() async {
    return _locationProvider.locationModel;
  }

  void animateBounce(){
    // if(userLocation != null){
    //   mapController.move(LatLng(userLocation!.latitude!, userLocation!.longitude!), 14);
    // }
  }


  // void animateBounce() {
  //   if(_locationProvider.locationModel != null && userLocation?.position != null){
  //     final LatLng southwest = LatLng(
  //       min(_locationProvider.locationModel!.geopoint.latitude!,
  //           userLocation!.position.latitude),
  //       min(_locationProvider.locationModel!.geopoint.longitude!,
  //           userLocation!.position.longitude),
  //     );
  //
  //     final LatLng northeast = LatLng(
  //       max(_locationProvider.locationModel!.geopoint.latitude!,
  //           userLocation!.position.latitude),
  //       max(_locationProvider.locationModel!.geopoint.longitude!,
  //           userLocation!.position.longitude),
  //     );
  //
  //     latLngBounds = LatLngBounds(southwest: southwest, northeast: northeast);
  //
  //     if(currentScroll == (324 / 710)){
  //       mapController?.animateCamera(CameraUpdate.newLatLngBounds(
  //         latLngBounds,
  //         left: 170,
  //         right: 170,
  //         top: 100,
  //         bottom: 300,
  //       ));
  //
  //     }else if(currentScroll == (120 / 710)){
  //       mapController?.animateCamera(CameraUpdate.newLatLngBounds(
  //         latLngBounds,
  //         left: 80,
  //         right: 80,
  //         top: 80,
  //         bottom: 80,
  //       ));
  //     }
  //   }
  // }

  void locationListener() {
    //currentDangerStatus = _bikeProvider.currentBikeModel!.location!.status;
    //loadImage(currentDangerStatus);

    setButtonImage();
    setBikeImage();
  }


}

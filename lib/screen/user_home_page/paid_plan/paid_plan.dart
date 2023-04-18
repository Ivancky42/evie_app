import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/orbital_anti_theft.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/mapbox_widget.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat_history.dart';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/function.dart';
import '../../../api/model/location_model.dart';
import '../../../api/model/trip_history_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/provider/trip_provider.dart';
import '../../../api/snackbar.dart';
import '../../../api/toast.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/actionable_bar.dart';
import '../../../widgets/evie_card.dart';
import '../../../widgets/evie_oval.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../home_page_widget.dart';
import '../switch_bike.dart';
import 'bike_security_status/connection_lost/connection_lost.dart';
import 'bike_security_status/crash/crash_alert.dart';
import 'bike_security_status/danger/theft_attempt.dart';
import 'bike_security_status/fall/fall_detected.dart';
import 'bike_security_status/safe/bike_safe.dart';
import 'bike_security_status/warning/movement_detected.dart';
import 'bottom_sheet_widget.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'home_element/battery.dart';
import 'home_element/rides.dart';
import 'home_element/setting.dart';

class PaidPlan extends StatefulWidget  {
  const PaidPlan({Key? key}) : super(key: key);

  @override
  _PaidPlanState createState() => _PaidPlanState();
}

class _PaidPlanState extends State<PaidPlan> with WidgetsBindingObserver{
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late NotificationProvider _notificationProvider;

  bool isActionBarAppear = false;

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;


  late LatLngBounds latLngBounds;

  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;

  //StreamSubscription? locationSubscription;
  //StreamSubscription? userLocationSubscription;

  
  /// +100 , +100
  static const double initialRatio = 424 / 700;
  static const double minRatio = 186 / 700;

  static const double maxRatio = 1.0;
  bool isBottomSheetExpanded = false;
  bool isMapListShowing = false;
  bool isFirstLoadUserLocation = true;
  List<map_launcher.AvailableMap>? availableMaps;

  LocationData? userLocation;
  //MapController? mapController;
  final Location _locationService = Location();

  bool isScanned = false;
  bool isFirstTimeConnected = false;
  //var markers = <Marker>[];

  //GeoPoint? selectedGeopoint;


  @override
  void initState() {
    super.initState();
    //_locationProvider = Provider.of<LocationProvider>(context, listen: false);
    //_locationProvider.addListener(locationListener);
    //mapController = MapController();

    //initLocationService();
    WidgetsBinding.instance.addObserver(this);

    //selectedGeopoint  = _locationProvider.locationModel?.geopoint;
  }

  // void initLocationService() async {
  //
  //   ///If 5 seconds are passed AND if the phone is moved at least 1 meters, listen the location
  //   await _locationService.changeSettings(interval: 5000, distanceFilter: 1);
  //
  //   ///For user live location
  //   // userLocationSubscription = _locationService.onLocationChanged.listen((LocationData result) async {
  //   //       if (mounted) {
  //   //         setState(() {
  //   //           userLocation = result;
  //   //
  //   //           if(userLocation != null && _locationProvider.locationModel?.status != null) {
  //   //             getDistanceBetween();
  //   //
  //   //             if(isFirstLoadUserLocation == true){
  //   //               // Future.delayed(const Duration(milliseconds: 50), () {
  //   //               //   animateBounce();
  //   //               // });
  //   //               isFirstLoadUserLocation = false;
  //   //             }
  //   //
  //   //             ///User location update will bounce every once, causing almost infinity bounce if open comment
  //   //             //       animateBounce();
  //   //
  //   //           }
  //   //         });
  //   //       }
  //   //     });
  //
  //   //locationListener();
  //   // if(userLocation != null && _locationProvider.locationModel?.status != null){
  //   //   locationListener();
  //   // }
  // }

  @override
  void dispose() {
    //_locationProvider.removeListener(locationListener);
    //mapController?.dispose();
    //userLocationSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
     // _bluetoothProvider.startScanAndConnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    // deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    // cableLockState = _bluetoothProvider.cableLockState;
    //
    // setButtonImage();
    //
    // LatLng currentLatLng;
    // if (userLocation != null) {
    //   currentLatLng = LatLng(userLocation!.latitude!, userLocation!.longitude!);
    // } else {
    //   currentLatLng = LatLng(0, 0);
    // }
    //
    //
    // Color statusBarColor = Colors.transparent;
    //
    // if(_bikeProvider.rfidList.length == 0 && _notificationProvider.isTimeArrive){
    //     statusBarColor = Colors.transparent;
    // }else{
    //   if (_locationProvider.locationModel?.isConnected == false) {
    //     statusBarColor = EvieColors.orange;
    //   } else {
    //     if (_locationProvider.locationModel?.status == "safe") {
    //       statusBarColor = Colors.transparent;
    //     } else if (_locationProvider.locationModel?.status == "warning" ||
    //         _locationProvider.locationModel?.status == "fall") {
    //       statusBarColor = EvieColors.orange;
    //     } else if (_locationProvider.locationModel?.status == "danger" ||
    //         _locationProvider.locationModel?.status == "crash") {
    //       statusBarColor = EvieColors.darkRed;
    //     } else {
    //       statusBarColor = Colors.transparent;
    //     }
    //   }
    // }

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
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Container(
                                            height: 73.33.h,
                                            color:  EvieColors.lightBlack,
                                            child: Container(
                                              alignment: Alignment.centerLeft,
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

                                                                  //context.watch<BikeProvider>().currentBikeModel?.deviceName ?? "loading"
                                                                  // Selector<MyState, int>(
                                                                  //  selector: (context, myState) => myState.myValue,
                                                                  //  builder: (context, myValue, child) {
                                                                  //    return Text('My Value: $myValue');
                                                                  //    },
                                                                  //  );
                                                                  // }

                                                                  _bikeProvider.currentBikeModel?.deviceName ?? "loading",
                                                                  style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite),
                                                                ),
                                                                SvgPicture.asset(
                                                                  "assets/icons/batch_tick.svg",
                                                                  height: 25.h,
                                                                )
                                                              ],
                                                            ),

                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    _bikeProvider.currentBikeModel?.location?.isConnected == true ?
                                                                    Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          "assets/icons/wifi_connected.svg",
                                                                        ),
                                                                        Text(
                                                                          "Online",
                                                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
                                                                        ),
                                                                      ],
                                                                    ) :
                                                                    Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          "assets/icons/wifi_offline.svg",
                                                                        ),
                                                                        Text(
                                                                          "Offline",
                                                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: 9.w, right: 5.w, bottom: 2.h),
                                                                  child: SvgPicture.asset(
                                                                    "assets/icons/break_line.svg",
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
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
                                                                )
                                                            ],)
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
                                physics: isActionBarAppear == true ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: SizedBox(
                                    height: isActionBarAppear == true ? double.infinity : 1000.h,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: OrbitalAntiTheft(),
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
                                                  child: Battery(),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Rides(),
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
                                                  child: Setting(),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: UnlockingSystem(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],),
              )
          )
        //        ),
        //   )
      ),
    );
  }

  // Widget _buildCompass() {
  //   return StreamBuilder<CompassEvent>(
  //     stream: FlutterCompass.events,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Text('Error reading heading: ${snapshot.error}');
  //       }
  //
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       }
  //       double? direction = snapshot.data!.heading;
  //
  //       if (direction == null) {
  //         return const Center(
  //           child: Text("Device does not have sensors !"),
  //         );
  //       }
  //
  //       return Material(
  //         shape: CircleBorder(),
  //         clipBehavior: Clip.antiAlias,
  //         elevation: 0.0,
  //         color: Colors.transparent,
  //         child: Container(
  //           child: Transform.rotate(
  //             //   angle: (direction * (math.pi / 180) * -1),
  //             angle: (direction * (math.pi / 180) * 1),
  //             child: Image.asset('assets/icons/user_location_icon.png'),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget mapLauncher() {
  //   if (isBottomSheetExpanded) {
  //     return const SizedBox();
  //   } else {
  //     return Align(
  //       alignment: Alignment.bottomRight,
  //       child: GestureDetector(
  //         onTap: () async {
  //           List<map_launcher.AvailableMap> availableMaps =
  //               await map_launcher.MapLauncher.installedMaps;
  //           if (isMapListShowing) {
  //             setState(() {
  //               this.availableMaps = null;
  //               isMapListShowing = false;
  //             });
  //           } else {
  //             setState(() {
  //               this.availableMaps = availableMaps;
  //               isMapListShowing = true;
  //             });
  //           }
  //         },
  //         child: Container(
  //             height: 50.h,
  //             child: Align(
  //               alignment: Alignment.bottomRight,
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   availableMaps != null
  //                       ? ListView.builder(
  //                           scrollDirection: Axis.horizontal,
  //                           shrinkWrap: true,
  //                           itemBuilder: (context, index) {
  //                             return GestureDetector(
  //                               onTap: () {
  //                                 if(selectedGeopoint != null){
  //                                   map_launcher.MapLauncher.showDirections(
  //                                       mapType: availableMaps![index].mapType,
  //                                       destination: map_launcher.Coords(
  //                                           selectedGeopoint!.latitude,
  //                                           selectedGeopoint!.longitude));
  //                                 }else{
  //                                   map_launcher.MapLauncher.showDirections(
  //                                       mapType: availableMaps![index].mapType,
  //                                       destination: map_launcher.Coords(
  //                                           _bikeProvider.currentBikeModel!.location!.geopoint.latitude,
  //                                           _bikeProvider.currentBikeModel!.location!.geopoint.longitude));
  //                                 }
  //
  //                               },
  //                               child: SvgPicture.asset(
  //                                 availableMaps![index].icon,
  //                                 width: 36.w,
  //                                 height: 36.h,
  //                               ),
  //                             );
  //                           },
  //                           itemCount: availableMaps?.length,
  //                         )
  //                       : SizedBox(),
  //                   Padding(
  //                     padding: EdgeInsets.only(right: 8.h),
  //                     child: SvgPicture.asset(
  //                       "assets/buttons/direction.svg",
  //                       width: 50.w,
  //                       height: 50.h,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //       ),
  //     );
  //   }
  // }

  // Widget navigateButton() {
  //   if (isBottomSheetExpanded) {
  //     return const SizedBox();
  //   } else {
  //     return Align(
  //       alignment: Alignment.bottomRight,
  //       child: GestureDetector(
  //         onTap: () async {
  //
  //           animateBounce();
  //         },
  //         child: Container(
  //             height: 50.h,
  //             child: Align(
  //               alignment: Alignment.bottomRight,
  //               child: Padding(
  //                 padding: EdgeInsets.only(right: 8.h),
  //                 child: SvgPicture.asset(
  //                   "assets/buttons/location.svg",
  //                   width: 50.w,
  //                   height: 50.h,
  //                 ),
  //               ),
  //             )),
  //       ),
  //     );
  //   }
  // }

  // void getDistanceBetween() {
  //   if (userLocation != null) {
  //     if (userLocation != null && distanceBetween == "-") {
  //       setState(() {
  //         distanceBetween = Geolocator.distanceBetween(
  //                 userLocation!.latitude!,
  //                 userLocation!.longitude!,
  //                 _locationProvider.locationModel!.geopoint.latitude,
  //                 _locationProvider.locationModel!.geopoint.longitude)
  //             .toStringAsFixed(0);
  //       });
  //     } else {
  //       distanceBetween = Geolocator.distanceBetween(
  //               userLocation!.latitude!,
  //               userLocation!.longitude!,
  //               _locationProvider.locationModel!.geopoint.latitude,
  //               _locationProvider.locationModel!.geopoint.longitude)
  //           .toStringAsFixed(0);
  //     }
  //   } else {
  //     distanceBetween = "-";
  //   }
  //   Future.delayed(Duration.zero, () {
  //     _bikeProvider.saveDistanceBetween(distanceBetween);
  //   });
  // }
  //
  // void locationListener() {
  //   //setButtonImage();
  //   //getDistanceBetween();
  //   //animateBounce();
  //   // loadImage(currentDangerStatus);
  // }

  // switchBikeStatusBar(String status) {
  //   if(_locationProvider.locationModel?.isConnected == false){
  //     return HomePageWidget_StatusBar(currentDangerState: 'warning',location: _locationProvider.currentPlaceMark);
  //   }else{
  //     return HomePageWidget_StatusBar(currentDangerState: status,location: _locationProvider.currentPlaceMark, selectedGeopoint: selectedGeopoint, locationProvider: _locationProvider,);
  //   }
  // }

  // switchBikeStatusBottom(String status) {
  //   if(_locationProvider.locationModel?.isConnected == false){
  //     return ConnectionLost( connectImage:buttonImage,distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected);
  //   }
  //   else{
  //     switch(status) {
  //       case "safe":
  //         return BikeSafe(connectImage:buttonImage,distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
  //       case "warning":
  //         return BikeWarning(connectImage:buttonImage, distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
  //       case "danger":
  //         return BikeDanger(connectImage:buttonImage, distanceBetween: distanceBetween,  isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
  //       case "fall":
  //         return FallDetected(connectImage:buttonImage, distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
  //       case "crash":
  //         return CrashAlert(connectImage:buttonImage,distanceBetween: distanceBetween,  isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
  //       default:
  //         return const CircularProgressIndicator();
  //     }
  //   }
  // }

}

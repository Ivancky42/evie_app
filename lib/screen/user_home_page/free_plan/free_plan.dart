import 'dart:async';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/free_plan/mapbox_widget.dart';

import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../api/model/location_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../home_page_widget.dart';
import '../paid_plan/paid_plan.dart';
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

  Color lockColour = const Color(0xff6A51CA);


  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;

  SvgPicture? connectImage;
  SvgPicture? lockImage;

  List<String> imgList = [
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  final List<String> dangerStatus = ['safe', 'warning', 'danger'];
  String currentDangerStatus = 'safe';
  String currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
  String currentSecurityIcon =
      "assets/buttons/bike_security_not_available.svg";

  late LocationProvider _locationProvider;

  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;

  StreamSubscription? locationSubscription;
  bool myLocationEnabled = false;

  LocationData? userLocation;
  late final MapController mapController;
  final Location _locationService = Location();

  StreamSubscription? userLocationSubscription;
  StreamSubscription<DeviceConnectResult>? connectionStream;

  static const double initialRatio = 374 / 700;
  static const double minRatio = 136 / 700;
  static const double maxRatio = 1.0;
  bool isBottomSheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    mapController = MapController();
    initLocationService();
  }

  void initLocationService() async {
    LocationData? location;
    locationListener();

    ///For user live location
    location = await _locationService.getLocation();
    userLocation = location;
    userLocationSubscription =
        _locationService.onLocationChanged.listen((LocationData result) async {
          if (mounted) {
            setState(() {
              userLocation = result;
              animateBounce();
            });
          }
        });
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

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

    setConnectImage();
    setLockImage();

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

    // final TextEditingController _bikeNameController = TextEditingController();
    // final FocusNode _textFocus = FocusNode();



    ///Bike Container pop page to here cannot cannot listen to deviceConnectionResult as this page button on Press,
    ///this function works
    ///but this function will let dialog pop up twice
    print(_bluetoothProvider.deviceConnectResult.toString());
    Future.delayed(Duration.zero, () {
      if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanError ) {
        SmartDialog.show(
            keepSingle: true,
            widget: EvieSingleButtonDialogCupertino(
                title: "Cannot connect bike",
                content: "Move your device near the bike and try again",
                rightContent: "OK",
                onPressedRight: () {
                  SmartDialog.dismiss();
                }));
      } else if(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout){
        SmartDialog.show(
            tag: "SCAN_TIMEOUT",
            widget: EvieSingleButtonDialogCupertino(
                title: "Cannot connect bike",
                content: "Scan timeout",
                rightContent: "OK",
                onPressedRight: () {
                  SmartDialog.dismiss();
                }),);
      }else if(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connectError){
        SmartDialog.show(
            keepSingle: true,
            widget: EvieSingleButtonDialogCupertino(
                title: "Cannot connect bike",
                content: "Connection Error",
                rightContent: "OK",
                onPressedRight: () {
                  SmartDialog.dismiss();
                }));
      }
    });

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await SmartDialog.show(
            widget: EvieDoubleButtonDialogCupertino(
                title: "Close this app?",
                content: "Are you sure you want to close this App?",
                leftContent: "No",
                rightContent: "Yes",
                onPressedLeft: () {
                  SmartDialog.dismiss();
                },
                onPressedRight: () {
                  SystemNavigator.pop();
                })) as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: _currentUserProvider.fetchCurrentUserModel,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: (){},
                                child:Padding(
                                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 28.h),
                                  child: Container(
                                      height: 24.h,
                                      child: Text(
                                        "Good Morning ${_currentUserProvider.currentUserModel!.name}",
                                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                                      )
                                  ),
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text("Good Morning"),
                              );
                            }
                          }),
                      FutureBuilder(
                          future: getLocationModel(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                width: double.infinity,
                                height: 600.h,
                                child: Stack(
                                  children: [
                                    Mapbox_Widget(
                                      accessToken:
                                      _locationProvider.defPublicAccessToken,
                                      //onMapCreated: _onMapCreated,

                                      mapController: mapController,
                                      markers: markers,
                                      // onUserLocationUpdate: (userLocation) {
                                      //   if (this.userLocation != null) {
                                      //     this.userLocation = userLocation;
                                      //     getDistanceBetween();
                                      //   }
                                      //   else {
                                      //     this.userLocation = userLocation;
                                      //     getDistanceBetween();
                                      //     runSymbol();
                                      //   }
                                      // },
                                      latitude: _locationProvider
                                          .locationModel!.geopoint.latitude,
                                      longitude: _locationProvider
                                          .locationModel!.geopoint.longitude,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: NotificationListener<DraggableScrollableNotification>(
                      onNotification: (notification) {
                        if (notification.extent > 0.8) {
                          setState(() {
                            currentScroll = notification.extent;
                            isBottomSheetExpanded = true;
                          });
                        } else {
                          setState(() {
                            currentScroll = notification.extent;
                            isBottomSheetExpanded = false;
                          });
                        }

                        return false;
                      },
                      child: DraggableScrollableSheet(
                          initialChildSize: initialRatio,
                          minChildSize: minRatio,
                          maxChildSize: maxRatio,
                          snap: true,
                          snapSizes: const [minRatio, initialRatio, maxRatio],
                          expand: true,
                          builder: (BuildContext context, ScrollController _scrollController) {


                            return ListView(
                              controller: _scrollController,
                              children: [
                                navigateButton(),
                                currentScroll <= 0.8 ?
                                Stack(
                                    children: [
                                      ///Bike Connected
                                      if (deviceConnectResult == DeviceConnectResult.connected) ...{
                                        Container(
                                            height: 636.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECEDEB),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 11.h),
                                                        child: Image.asset("assets/buttons/home_indicator.png",
                                                          width: 40.w, height: 4.h,),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
                                                        child: Bike_Name_Row(
                                                          isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,
                                                          bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
                                                          distanceBetween: "Est. ${distanceBetween}m",
                                                          currentBikeStatusImage: currentBikeStatusImage,),
                                                      ),

                                                      Padding(
                                                        padding:
                                                        EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
                                                        child: IntrinsicHeight(
                                                          child: Bike_Status_Row(
                                                            estKm:"",
                                                            currentBatteryIcon: getBatteryImageFromBLE(_bluetoothProvider.bikeInfoResult!.batteryLevel!),
                                                            connectText: _bluetoothProvider.bikeInfoResult!.batteryLevel!,
                                                            currentSecurityIcon: currentSecurityIcon,
                                                            isLocked: cableLockState?.lockState ?? LockState.unknown,
                                                            child: Text( cableLockState!.lockState == LockState.lock ?
                                                            "LOCK & SECURED" : "UNLOCKED",
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                                                            ),),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding: EdgeInsets.only(top: 31.h),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 96.h,
                                                              width: 96.w,
                                                              child:FloatingActionButton(
                                                                elevation: 0,
                                                                backgroundColor:
                                                                cableLockState
                                                                    ?.lockState ==
                                                                    LockState
                                                                        .lock
                                                                    ? lockColour
                                                                    : const Color(
                                                                    0xffC1B7E8),
                                                                onPressed: cableLockState
                                                                    ?.lockState ==
                                                                    LockState.lock
                                                                    ? () {
                                                                  ///Check is connected

                                                                  SmartDialog
                                                                      .showLoading(
                                                                      msg:
                                                                      "Unlocking");
                                                                  StreamSubscription?
                                                                  subscription;
                                                                  subscription =
                                                                      _bluetoothProvider
                                                                          .cableUnlock()
                                                                          .listen(
                                                                              (unlockResult) {
                                                                            SmartDialog.dismiss(
                                                                                status: SmartStatus
                                                                                    .loading);
                                                                            subscription
                                                                                ?.cancel();
                                                                            if (unlockResult
                                                                                .result ==
                                                                                CommandResult
                                                                                    .success) {
                                                                              ScaffoldMessenger.of(
                                                                                  context)
                                                                                  .showSnackBar(
                                                                                SnackBar(
                                                                                  content:
                                                                                  Text('Bike is unlocked. To lock bike, pull the lock handle on the bike.',style: TextStyle(fontSize: 16.sp),),
                                                                                  duration:
                                                                                  Duration(seconds: 2),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              SmartDialog.dismiss(status: SmartStatus.loading);
                                                                              subscription
                                                                                  ?.cancel();
                                                                              ScaffoldMessenger.of(
                                                                                  context)
                                                                                  .showSnackBar(
                                                                                SnackBar(
                                                                                  width:
                                                                                  358.w,
                                                                                  behavior:
                                                                                  SnackBarBehavior.floating,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius:
                                                                                      BorderRadius.all(Radius.circular(10))),
                                                                                  content:
                                                                                  Container(
                                                                                    height:
                                                                                    80.h,
                                                                                    child:
                                                                                    Text('Bike is unlocked. To lock bike, pull the lock handle on the bike.',style: TextStyle(fontSize: 16.sp),),
                                                                                  ),
                                                                                  duration: const Duration(seconds: 4),
                                                                                ),
                                                                              );
                                                                            }
                                                                          }, onError: (error) {
                                                                        SmartDialog.dismiss(
                                                                            status: SmartStatus.loading);
                                                                        subscription?.cancel();
                                                                        SmartDialog.show(
                                                                            widget: EvieSingleButtonDialogCupertino(
                                                                                title: "Error",
                                                                                content: "Cannot unlock bike, please place the phone near the bike and try again.",
                                                                                rightContent: "OK",
                                                                                onPressedRight: () {
                                                                                  SmartDialog.dismiss();
                                                                                }));
                                                                      });
                                                                }
                                                                    : null,
                                                                //icon inside button
                                                                child: lockImage,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 12.h,
                                                            ),
                                                            if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                                              Text(
                                                                "Connecting bike",
                                                                style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    color: Color(
                                                                        0xff3F3F3F)),
                                                              ),
                                                            } else if(deviceConnectResult == DeviceConnectResult.connected)...{
                                                              Text(
                                                                "Tap to unlock bike",
                                                                style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    color: Color(
                                                                        0xff3F3F3F)),
                                                              ),
                                                            }else ...{
                                                              Text(
                                                                "Tap to connect bike",
                                                                style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    color: Color(
                                                                        0xff3F3F3F)),
                                                              ),
                                                            },
                                                            SizedBox(
                                                              height: 11.h,
                                                            ),
                                                            SvgPicture.asset(
                                                              "assets/buttons/up.svg",
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      }
                                      ///Bike Not Connected
                                      else ...{
                                        Container(
                                            height: 636.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECEDEB),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 11.h),
                                                        child: Image.asset("assets/buttons/home_indicator.png",
                                                          width: 40.w, height: 4.h,),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        EdgeInsets.fromLTRB(16.w, 9.h, 0, 0),
                                                        child: Bike_Name_Row(
                                                          bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
                                                          distanceBetween: "Bike is not connected",
                                                          currentBikeStatusImage: "assets/images/bike_HPStatus/bike_normal.png",
                                                          isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected),
                                                      ),

                                                      Padding(
                                                        padding:
                                                        EdgeInsets.fromLTRB(16.w, 17.15.h, 0, 0),
                                                        child: IntrinsicHeight(
                                                          child: Bike_Status_Row(
                                                            connectText: "-",
                                                            estKm: "",
                                                            currentSecurityIcon: currentSecurityIcon,
                                                            currentBatteryIcon: "assets/icons/battery_not_available.svg",
                                                            isLocked: cableLockState?.lockState ?? LockState.unknown,
                                                            child:Text(
                                                              "NOT AVAILABLE",
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                                                            ),),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding: EdgeInsets.only(top: 31.h),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 96.h,
                                                              width: 96.w,
                                                              child: FloatingActionButton(
                                                                elevation: 0,
                                                                backgroundColor:
                                                                lockColour,
                                                                onPressed: () {

                                                                  ///Check bluetooth status
                                                                  var bleStatus =
                                                                      _bluetoothProvider
                                                                          .bleStatus;
                                                                  switch (bleStatus) {
                                                                    case BleStatus
                                                                        .poweredOff:
                                                                      SmartDialog.show(
                                                                          keepSingle:
                                                                          true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Bluetooth is off, please turn on your bluetooth",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog
                                                                                    .dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .unknown:
                                                                    // TODO: Handle this case.
                                                                      break;
                                                                    case BleStatus
                                                                        .unsupported:
                                                                      SmartDialog.show(
                                                                          keepSingle:
                                                                          true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Bluetooth unsupported",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog
                                                                                    .dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .unauthorized:
                                                                      SmartDialog.show(
                                                                          keepSingle:
                                                                          true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Bluetooth Permission is off",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog
                                                                                    .dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .locationServicesDisabled:
                                                                      SmartDialog.show(
                                                                          keepSingle:
                                                                          true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Location service disabled",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog
                                                                                    .dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .ready:
                                                                      if (deviceConnectResult != DeviceConnectResult.connected) {
                                                                        connectionStream = _bluetoothProvider.startScanAndConnect().listen((deviceConnectResult) {

                                                                          switch(deviceConnectResult){
                                                                            case DeviceConnectResult.scanning:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.scanTimeout:
                                                                              connectionStream?.cancel();
                                                                              SmartDialog.show(
                                                                                  tag: "SCAN_TIMEOUT",
                                                                                  widget: EvieSingleButtonDialogCupertino(
                                                                                      title: "Cannot connect bike",
                                                                                      content: "Scan timeout",
                                                                                      rightContent: "OK",
                                                                                      onPressedRight: () {
                                                                                        SmartDialog.dismiss();
                                                                                      }));
                                                                              break;
                                                                            case DeviceConnectResult.scanError:
                                                                              connectionStream?.cancel();
                                                                              SmartDialog.show(
                                                                                  keepSingle: true,
                                                                                  widget: EvieSingleButtonDialogCupertino(
                                                                                      title: "Cannot connect bike",
                                                                                      content: "Scan error",
                                                                                      rightContent: "OK",
                                                                                      onPressedRight: () {
                                                                                        SmartDialog.dismiss();
                                                                                      }));
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.connecting:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.partialConnected:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.connected:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.disconnecting:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.disconnected:
                                                                              // TODO: Handle this case.
                                                                              break;
                                                                            case DeviceConnectResult.connectError:
                                                                              connectionStream?.cancel();
                                                                              SmartDialog.show(
                                                                                  keepSingle: true,
                                                                                  widget: EvieSingleButtonDialogCupertino(
                                                                                      title: "Cannot connect bike",
                                                                                      content: "Connect error",
                                                                                      rightContent: "OK",
                                                                                      onPressedRight: () {
                                                                                        SmartDialog.dismiss();
                                                                                      }));
                                                                              break;
                                                                          }
                                                                        });

                                                                        // if(connectionStateUpdate != null){
                                                                        //   if(connectionStateUpdate?.failure.toString() != null){
                                                                        //     SmartDialog.show(
                                                                        //         keepSingle: true,
                                                                        //         widget: EvieSingleButtonDialogCupertino(
                                                                        //             title: "Error",
                                                                        //             content: "Cannot connect bike, please place the phone near the bike and try again.",
                                                                        //             rightContent: "OK",
                                                                        //             onPressedRight: (){SmartDialog.dismiss();})
                                                                        //     );
                                                                        //   }
                                                                        // }

                                                                      } else {

                                                                      }
                                                                      break;
                                                                    default:
                                                                      break;
                                                                  }
                                                                },
                                                                //icon inside button
                                                                child: connectImage,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 12.h,
                                                            ),
                                                            if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
                                                              Text(
                                                                "Connecting bike",
                                                                style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    color: Color(
                                                                        0xff3F3F3F)),
                                                              ),
                                                            } else ...{
                                                              Text(
                                                                "Tap to connect bike",
                                                                style: TextStyle(
                                                                    fontSize: 12.sp,
                                                                    fontWeight:
                                                                    FontWeight.w400,
                                                                    color: Color(
                                                                        0xff3F3F3F)),
                                                              ),
                                                            },
                                                            SizedBox(
                                                              height: 11.h,
                                                            ),
                                                            SvgPicture.asset(
                                                              "assets/buttons/up.svg",
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      }
                                    ]) :
                                Container (
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEDEB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(
                                        height: 28.h,
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left:17.w),
                                            child: Text("Threat History",style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),),
                                          ),
                                          IconButton(
                                            onPressed: (){
                                              _bikeProvider
                                                  .controlBikeList("next");
                                              _bluetoothProvider
                                                  .disconnectDevice();
                                            },
                                            icon: SvgPicture.asset(
                                              "assets/buttons/filter.svg",
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 11.h,
                                      ),
                                      const Divider(thickness: 2,),

                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Column(
                                          children: [

                                            Padding(
                                              padding: EdgeInsets.only(left:15.w, right:15.w),
                                              child: SvgPicture.asset(
                                                "assets/images/free_plan_threat.svg",
                                                height:608.h,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                  height: 720.h,
                                ),
                              ],
                            );


                          }),
                    ),
                  ),
                )
              ],
            ),
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


  void setConnectImage() {
    if (deviceConnectResult == DeviceConnectResult.connected) {
      setState(() {
        connectImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) {
      setState(() {
        connectImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (deviceConnectResult == DeviceConnectResult.disconnected) {
      setState(() {
        connectImage = SvgPicture.asset(
          "assets/buttons/bluetooth_not_connected.svg",
          width: 52.w,
          height: 50.h,
        );
      });
    } else {
      setState(() {
        connectImage = SvgPicture.asset(
          "assets/buttons/bluetooth_not_connected.svg",
          width: 52.w,
          height: 50.h,
        );
      });
    }
  }

  void setLockImage() {
    if (cableLockState?.lockState == LockState.unlock) {
      setState(() {
        lockImage = SvgPicture.asset(
          "assets/buttons/lock_unlock.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (cableLockState?.lockState == LockState.lock) {
      setState(() {
        lockImage = SvgPicture.asset(
          "assets/buttons/lock_lock.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (cableLockState?.lockState == LockState.unknown) {
      setState(() {
        lockImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
      });
    }
  }


  void setBikeImage() {
    if (deviceConnectResult == DeviceConnectResult.connected) {
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
    if(userLocation != null){
      mapController.move(LatLng(userLocation!.latitude!, userLocation!.longitude!), 14);
    }
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

    setConnectImage();
    setLockImage();
    setBikeImage();
  }


}

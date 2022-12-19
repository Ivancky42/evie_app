import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/mapbox_widget.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat_history.dart';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:provider/provider.dart';
import '../../../api/model/location_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../free_plan/free_plan.dart';
import '../home_page_widget.dart';
import 'bottom_sheet_widget.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class PaidPlan extends StatefulWidget  {
  const PaidPlan({Key? key}) : super(key: key);

  @override
  _PaidPlanState createState() => _PaidPlanState();
}

class _PaidPlanState extends State<PaidPlan> with WidgetsBindingObserver{
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  Color lockColour = const Color(0xff6A51CA);

  ///When get data from _bluetoothProvider.cableLockState is not equal to unknown
  ///Need either lock/unlock
  bool? isDeviceConnected;
  String carbonFootprint = "D";
  String mileage = "D";

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
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
      "assets/buttons/bike_security_lock_and_secure.svg";

  late LocationProvider _locationProvider;
  late LatLngBounds latLngBounds;

  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;

  StreamSubscription? locationSubscription;
  StreamSubscription? userLocationSubscription;

  static const double initialRatio = 424 / 700;
  static const double minRatio = 186 / 700;
  static const double maxRatio = 1.0;
  bool isBottomSheetExpanded = false;
  bool isMapListShowing = false;
  List<map_launcher.AvailableMap>? availableMaps;

  LocationData? userLocation;
  MapController? mapController;
  final Location _locationService = Location();

  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    mapController = MapController();

    initLocationService();
    WidgetsBinding.instance.addObserver(this);

  }

  void initLocationService() async {
    ///For user live location
    await _locationService.getLocation();
    userLocationSubscription =
        _locationService.onLocationChanged.listen((LocationData result) async {
          if (mounted) {
            setState(() {
              userLocation = result;

              if(userLocation != null && _locationProvider.locationModel?.status != null) {
                getDistanceBetween();
                animateBounce();
              }
            });
          }
        });
    if(userLocation != null && _locationProvider.locationModel?.status != null){
      locationListener();
    }
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    mapController?.dispose();
    userLocationSubscription?.cancel();
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
    _locationProvider = Provider.of<LocationProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
    cableLockState = _bluetoothProvider.cableLockState;

    ///Handle all data if bool isDeviceConnected is true
    if (connectionState == DeviceConnectionState.connected &&
            cableLockState?.lockState == LockState.lock ||
        cableLockState?.lockState == LockState.unlock) {
      setState(() {
        isDeviceConnected = true;
      });
    } else {
      setState(() {
        isDeviceConnected = false;
      });
    }

    Future.delayed(Duration.zero, () {
      if (_bluetoothProvider.connectionStateUpdate?.failure != null) {
        _bluetoothProvider.disconnectDevice();
        SmartDialog.show(
            keepSingle: true,
            widget: EvieSingleButtonDialogCupertino(
                title: "Cannot connect bike",
                content: "Move your device near the bike and try again",
                rightContent: "OK",
                onPressedRight: () {
                  SmartDialog.dismiss();
                }));
      }
    });


      setConnectImage();
      setLockImage();

    LatLng currentLatLng;

    if (userLocation != null) {
      currentLatLng = LatLng(userLocation!.latitude!, userLocation!.longitude!);
    } else {
      currentLatLng = LatLng(0, 0);
    }

    var markers = <Marker>[
      Marker(
        width: 42.w,
        height: 56.h,
        point: LatLng(_locationProvider.locationModel?.geopoint.latitude ?? 0,
            _locationProvider.locationModel?.geopoint.longitude ?? 0),
        builder: (ctx) => Image(
          image: AssetImage(loadMarkerImageString(currentDangerStatus)),
        ),
      ),

      Marker(
        width: 42.w,
        height: 56.h,
        point: currentLatLng,
        builder: (ctx) {
          return _buildCompass();
        },
      ),
    ];



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
                  // SizedBox(
                  //   height: 34.h,
                  // ),
                  FutureBuilder(
                      future: _currentUserProvider.fetchCurrentUserModel,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return HomePageWidget_Status(
                                  currentDangerState: currentDangerStatus,
                                  location: _locationProvider.currentPlaceMark);
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
                            height: 636.h,
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
                                  onMapReady: () {
                                    loadImage(currentDangerStatus);
                                  },
                                ),

                                // _buildCompass(),
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
                    if(userLocation != null && _locationProvider.locationModel?.status != null){
                    animateBounce();
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
                      builder: (BuildContext context,
                          ScrollController _scrollController) {
                        return ListView(
                          controller: _scrollController,
                          children: [
                            mapLauncher(),
                            navigateButton(),
                            currentScroll <= 0.8
                                ? Stack(children: [
                                    ///Bike Connected
                                    if (isDeviceConnected == true) ...{
                                      Container(
                                          height: 636.h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECEDEB),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 11.h),
                                                      child: Image.asset(
                                                        "assets/buttons/home_indicator.png",
                                                        width: 40.w,
                                                        height: 4.h,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              16.w, 9.h, 0, 0),
                                                      child: Bike_Name_Row(
                                                        bikeName: _bikeProvider
                                                                .currentBikeModel
                                                                ?.deviceName ??
                                                            "",
                                                        distanceBetween:
                                                            distanceBetween ??
                                                                "-",
                                                        currentBikeStatusImage:
                                                            currentBikeStatusImage, isDeviceConnected: isDeviceConnected!,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              16.w,
                                                              17.15.h,
                                                              0,
                                                              0),
                                                      child: IntrinsicHeight(
                                                        child: Bike_Status_Row(
                                                          batteryImage: getBatteryImage(
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.batteryPercent ??
                                                                  0),
                                                          batteryPercentage:
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.batteryPercent ??
                                                                  0,
                                                          currentSecurityIcon:
                                                          getSecurityImageWidgetBluetooth(
                                                              _bluetoothProvider
                                                                  .cableLockState
                                                                  ?.lockState ??
                                                                  LockState
                                                                      .unknown,
                                                              _bikeProvider
                                                                  .currentBikeModel
                                                                  ?.location!
                                                                  .status ??
                                                                  ""),
                                                          child: getSecurityTextWidget(
                                                              _bluetoothProvider
                                                                      .cableLockState
                                                                      ?.lockState ??
                                                                  LockState
                                                                      .unknown,
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.location!
                                                                      .status ??
                                                                  ""),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 31.h),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 96.h,
                                                            width: 96.w,
                                                            child:
                                                                FloatingActionButton(
                                                              elevation: 0,
                                                              backgroundColor: cableLockState
                                                                          ?.lockState ==
                                                                      LockState
                                                                          .lock
                                                                  ? lockColour
                                                                  : const Color(
                                                                      0xffC1B7E8),
                                                              onPressed: cableLockState
                                                                          ?.lockState ==
                                                                      LockState
                                                                          .lock
                                                                  ? () {
                                                                      ///Check is connected

                                                                      SmartDialog
                                                                          .showLoading(
                                                                              msg: "Unlocking");
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
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              content: Text(
                                                                                'Bike is unlocked. To lock bike, pull the lock handle on the bike.',
                                                                                style: TextStyle(fontSize: 16.sp),
                                                                              ),
                                                                              duration: Duration(seconds: 2),
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          SmartDialog.dismiss(
                                                                              status: SmartStatus.loading);
                                                                          subscription
                                                                              ?.cancel();
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              width: 358.w,
                                                                              behavior: SnackBarBehavior.floating,
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                              content: Container(
                                                                                height: 80.h,
                                                                                child: Text(
                                                                                  'Bike is unlocked. To lock bike, pull the lock handle on the bike.',
                                                                                  style: TextStyle(fontSize: 16.sp),
                                                                                ),
                                                                              ),
                                                                              duration: const Duration(seconds: 4),
                                                                            ),
                                                                          );
                                                                        }
                                                                      }, onError: (error) {
                                                                        SmartDialog.dismiss(
                                                                            status:
                                                                                SmartStatus.loading);
                                                                        subscription
                                                                            ?.cancel();
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
                                                          if (connectionState
                                                                  ?.name ==
                                                              "connecting") ...{
                                                            Text(
                                                              "Connecting bike",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xff3F3F3F)),
                                                            ),
                                                          } else if (connectionState
                                                                  ?.name ==
                                                              "connected") ...{
                                                            Text(
                                                              "Tap to unlock bike",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color(
                                                                      0xff3F3F3F)),
                                                            ),
                                                          } else ...{
                                                            Text(
                                                              "",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
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
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 11.h),
                                                      child: Image.asset(
                                                        "assets/buttons/home_indicator.png",
                                                        width: 40.w,
                                                        height: 4.h,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              16.w, 9.h, 0, 0),
                                                      child: Bike_Name_Row(
                                                        bikeName: _bikeProvider
                                                                .currentBikeModel
                                                                ?.deviceName ??
                                                            "",
                                                        distanceBetween:
                                                            distanceBetween ??
                                                                "-",
                                                        currentBikeStatusImage:
                                                            currentBikeStatusImage,
                                                          isDeviceConnected: isDeviceConnected!
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              16.w,
                                                              17.15.h,
                                                              0,
                                                              0),
                                                      child: IntrinsicHeight(
                                                        child: Bike_Status_Row(
                                                          currentSecurityIcon:
                                                          getSecurityImageWidget(
                                                              _bikeProvider.currentBikeModel?.isLocked ??
                                                                  false,
                                                              _bikeProvider
                                                                  .currentBikeModel
                                                                  ?.location!
                                                                  .status ??
                                                                  ""),
                                                          batteryImage: getBatteryImage(
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.batteryPercent ??
                                                                  0),
                                                          batteryPercentage:
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.batteryPercent ??
                                                                  0,
                                                          child: getFirestoreSecurityTextWidget(
                                                              _bikeProvider
                                                                  .currentBikeModel
                                                                  ?.isLocked,
                                                              _bikeProvider
                                                                      .currentBikeModel
                                                                      ?.location!
                                                                      .status ??
                                                                  ""),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 31.h),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                              height: 96.h,
                                                              width: 96.w,
                                                              child:
                                                                  FloatingActionButton(
                                                                elevation: 0,
                                                                backgroundColor:
                                                                    lockColour,
                                                                onPressed: () {
                                                                  ///Check bluetooth status

                                                                  var bleStatus =
                                                                      _bluetoothProvider
                                                                          .bleStatus;
                                                                  switch (
                                                                      bleStatus) {
                                                                    case BleStatus
                                                                        .poweredOff:
                                                                      SmartDialog.show(
                                                                          keepSingle: true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Bluetooth is off, please turn on your bluetooth",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog.dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .unknown:
                                                                      // TODO: Handle this case.
                                                                      break;
                                                                    case BleStatus
                                                                        .unsupported:
                                                                      SmartDialog.show(
                                                                          keepSingle: true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Bluetooth unsupported",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog.dismiss();
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
                                                                          keepSingle: true,
                                                                          widget: EvieSingleButtonDialogCupertino(
                                                                              title: "Error",
                                                                              content: "Location service disabled",
                                                                              rightContent: "OK",
                                                                              onPressedRight: () {
                                                                                SmartDialog.dismiss();
                                                                              }));
                                                                      break;
                                                                    case BleStatus
                                                                        .ready:
                                                                      if (connectionState ==
                                                                              null ||
                                                                          connectionState ==
                                                                              DeviceConnectionState.disconnected) {
                                                                        _bluetoothProvider
                                                                            .startScanAndConnect();

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
                                                                      } else {}
                                                                      break;
                                                                    default:
                                                                      break;
                                                                  }
                                                                },
                                                                //icon inside button
                                                                child:
                                                                    connectImage,
                                                              )),
                                                          SizedBox(
                                                            height: 12.h,
                                                          ),
                                                          if (connectionState
                                                                  ?.name ==
                                                              "connecting") ...{
                                                            Text(
                                                              "Connecting bike",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color(
                                                                      0xff3F3F3F)),
                                                            ),
                                                          } else ...{
                                                            Text(
                                                              "Tap to connect bike",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
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
                                  ])
                                : Threat_History(bikeProvider: _bikeProvider, bluetoothProvider: _bluetoothProvider, locationProvider: _locationProvider,),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return Center(
            child: Text("Device does not have sensors !"),
          );
        }

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

  Widget mapLauncher() {
    if (isBottomSheetExpanded) {
      return const SizedBox();
    } else {
      return Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () async {
            List<map_launcher.AvailableMap> availableMaps =
                await map_launcher.MapLauncher.installedMaps;
            if (isMapListShowing) {
              setState(() {
                this.availableMaps = null;
                isMapListShowing = false;
              });
            } else {
              setState(() {
                this.availableMaps = availableMaps;
                isMapListShowing = true;
              });
            }
          },
          child: Container(
              height: 50.h,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    availableMaps != null
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  map_launcher.MapLauncher.showDirections(
                                      mapType: availableMaps![index].mapType,
                                      destination: map_launcher.Coords(
                                          _bikeProvider.currentBikeModel!
                                              .location!.geopoint.latitude,
                                          _bikeProvider.currentBikeModel!
                                              .location!.geopoint.longitude));
                                },
                                child: SvgPicture.asset(
                                  availableMaps![index].icon,
                                  width: 36.w,
                                  height: 36.h,
                                ),
                              );
                            },
                            itemCount: availableMaps?.length,
                          )
                        : SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(right: 8.h),
                      child: SvgPicture.asset(
                        "assets/buttons/direction.svg",
                        width: 50.w,
                        height: 50.h,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      );
    }
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
    if (connectionState?.name == "connected") {
        connectImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
    } else if (connectionState?.name == "connecting") {
        connectImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
    } else if (connectionState?.name == "disconnected") {
        connectImage = SvgPicture.asset(
          "assets/buttons/bluetooth_not_connected.svg",
          width: 52.w,
          height: 50.h,
        );
    } else {
        connectImage = SvgPicture.asset(
          "assets/buttons/bluetooth_not_connected.svg",
          width: 52.w,
          height: 50.h,
        );
    }
  }

  void setLockImage() {
    if (cableLockState?.lockState == LockState.unlock) {
        lockImage = SvgPicture.asset(
          "assets/buttons/lock_unlock.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
    } else if (cableLockState?.lockState == LockState.lock) {
        lockImage = SvgPicture.asset(
          "assets/buttons/lock_lock.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
    } else if (cableLockState?.lockState == LockState.unknown) {
        lockImage = SvgPicture.asset(
          "assets/buttons/loading.svg",
          width: 52.w,
          height: 50.h,
        );
        lockColour = const Color(0xff6A51CA);
    }
  }

  void setBikeImage() {
    if (isDeviceConnected == true) {
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

  void getDistanceBetween() {
    if (userLocation != null) {
      if (userLocation != null && distanceBetween == "-") {
        setState(() {
          distanceBetween = Geolocator.distanceBetween(
                  userLocation!.latitude!,
                  userLocation!.longitude!,
                  _locationProvider.locationModel!.geopoint.latitude,
                  _locationProvider.locationModel!.geopoint.longitude)
              .toStringAsFixed(0);
        });
      } else {
        distanceBetween = Geolocator.distanceBetween(
                userLocation!.latitude!,
                userLocation!.longitude!,
                _locationProvider.locationModel!.geopoint.latitude,
                _locationProvider.locationModel!.geopoint.longitude)
            .toStringAsFixed(0);
      }
    } else {
      distanceBetween = "-";
    }
  }

  void animateBounce() {
    if (_locationProvider.locationModel != null && userLocation != null) {
      final LatLng southwest = LatLng(
        min(_locationProvider.locationModel!.geopoint.latitude,
            userLocation!.latitude!),
        min(_locationProvider.locationModel!.geopoint.longitude,
            userLocation!.longitude!),
      );

      final LatLng northeast = LatLng(
        max(_locationProvider.locationModel!.geopoint.latitude,
            userLocation!.latitude!),
        max(_locationProvider.locationModel!.geopoint.longitude,
            userLocation!.longitude!),
      );

      latLngBounds = LatLngBounds(southwest, northeast);

      final LatLng center = LatLng(
        ((_locationProvider.locationModel!.geopoint.latitude +
                userLocation!.latitude!) /
            2),
        ((_locationProvider.locationModel!.geopoint.longitude +
                userLocation!.longitude!) /
            2),
      );

      if (currentScroll <= (initialRatio) && currentScroll > minRatio + 0.01) {
        mapController?.fitBounds(latLngBounds,
            options: FitBoundsOptions(
              padding: EdgeInsets.fromLTRB(170.w, 100.h, 170.w, 360.h),
            ));
      } else if (currentScroll >= minRatio) {
        mapController?.fitBounds(latLngBounds,
            options: FitBoundsOptions(
              padding: EdgeInsets.fromLTRB(80.w, 80.h, 80.w, 120.h),
            ));
      }
    }
  }

  void locationListener() {
    currentDangerStatus = _locationProvider.locationModel!.status;

    loadImage(currentDangerStatus);
    setConnectImage();
    setLockImage();
    setBikeImage();

    getDistanceBetween();
    animateBounce();

    // loadImage(currentDangerStatus);
  }

  void loadImage(String dangerStatus) {
    switch (dangerStatus) {
      case 'safe':
        {
          if (cableLockState?.lockState == LockState.unlock) {
            currentBikeStatusImage =
                "assets/images/bike_HPStatus/bike_safe.png";
            currentSecurityIcon = "assets/buttons/bike_security_unlock.svg";
          } else {
            currentBikeStatusImage =
                "assets/images/bike_HPStatus/bike_safe.png";
            currentSecurityIcon =
                "assets/buttons/bike_security_lock_and_secure.svg";
          }
        }
        break;
      case 'warning':
        {
          currentBikeStatusImage =
              "assets/images/bike_HPStatus/bike_warning.png";
          currentSecurityIcon = "assets/buttons/bike_security_warning.svg";
        }
        break;
      case 'danger':
        {
          currentBikeStatusImage =
              "assets/images/bike_HPStatus/bike_danger.png";
          currentSecurityIcon = "assets/buttons/bike_security_danger.svg";
        }
        break;
      default:
        {
          currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
          currentSecurityIcon =
              "assets/buttons/bike_security_lock_and_secure.svg";
        }
    }
  }
}

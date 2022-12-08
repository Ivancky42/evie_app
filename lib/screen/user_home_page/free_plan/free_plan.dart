import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/mapbox_widget.dart';
import 'package:evie_test/widgets/page_widget/home_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import '../../../api/model/location_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
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

  ///When get data from _bluetoothProvider.cableLockState is not equal to unknown
  ///Need either lock/unlock
  bool? isDeviceConnected;

  final CarouselController _pageController = CarouselController();

  String carbonFootprint = "D";
  String mileage = "D";

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
  CableLockResult? cableLockState;

  Image connectImage = Image(
    image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
    width: 35.w,
    height: 35.h,
    fit: BoxFit.fitWidth,
  );

  Image lockImage = Image(
    image: const AssetImage("assets/buttons/lock_lock.png"),
    width: 35.w,
    height: 35.h,
    fit: BoxFit.fitWidth,
  );

  List<String> imgList = [
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  final List<String> dangerStatus = ['safe', 'warning', 'danger'];
  String currentDangerStatus = 'safe';
  String currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
  String currentSecurityIcon =
      "assets/buttons/bike_security_lock_and_secure.png";

  late LocationProvider _locationProvider;
  late LatLngBounds latLngBounds;

  MapboxMapController? mapController;
  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;
  UserLocation? userLocation;

  StreamSubscription? locationSubscription;
  bool myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    mapController?.dispose();
    super.dispose();
  }


  void loadImage(String dangerStatus) {
    switch (dangerStatus) {
      case 'safe':
        {
          currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
          currentSecurityIcon =
          "assets/buttons/bike_security_lock_and_secure.png";
        }
        break;
      case 'warning':
        {
          currentBikeStatusImage =
          "assets/images/bike_HPStatus/bike_warning.png";
          currentSecurityIcon = "assets/buttons/bike_security_warning.png";
        }
        break;
      case 'danger':
        {
          currentBikeStatusImage =
          "assets/images/bike_HPStatus/bike_danger.png";
          currentSecurityIcon = "assets/buttons/bike_security_danger.png";
        }
        break;
      default:
        {
          currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
          currentSecurityIcon =
          "assets/buttons/bike_security_lock_and_secure.png";
        }
    }
  }


  ///Change icon according to dangerous level
  void addSymbol() async {

    var markerImage = await loadMarkerImage(currentDangerStatus);
    mapController?.addImage('marker', markerImage);

    locationSymbol = (await mapController?.addSymbol(
      SymbolOptions(
        iconImage: 'marker',
        iconSize: 2,
        geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
            _locationProvider.locationModel!.geopoint.longitude),
      ),
    ));
  }

  void getPlace() {
    _locationProvider.getPlaceMarks(
        _locationProvider.locationModel!.geopoint.latitude,
        _locationProvider.locationModel!.geopoint.longitude);

    mapController?.onSymbolTapped.add((argument) {

    });
  }

  void _onMapCreated(MapboxMapController mapController) async {
    setState(() {
      this.mapController = mapController;
    });
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
        _bluetoothProvider.disconnectDevice(connectionStateUpdate!.deviceId);
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
    setBikeImage();

    // final TextEditingController _bikeNameController = TextEditingController();
    // final FocusNode _textFocus = FocusNode();


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
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 34.h,
                  ),
                  FutureBuilder(
                      future: _currentUserProvider.fetchCurrentUserModel,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GestureDetector(
                              onTap: (){},
                              child:Padding(
                                padding: EdgeInsets.fromLTRB(16.w, 28.h, 146.w, 28.h),
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
                            height: 636.h,
                            child: Stack(
                              children: [
                                Mapbox_Widget(
                                  accessToken: _locationProvider.defPublicAccessToken,
                                  onMapCreated: _onMapCreated,
                                  onStyleLoadedCallback:  () {
                                    loadImage(currentDangerStatus);
                                    //runSymbol();
                                    getPlace();
                                  },
                                  onUserLocationUpdate: (userLocation) {
                                    this.userLocation = userLocation;
                                //    animateBounce();
                                //    getDistanceBetween();
                                  },
                                  latitude: _locationProvider
                                      .locationModel!.geopoint.latitude,
                                  longitude:_locationProvider
                                      .locationModel!.geopoint.longitude,
                                  )
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
                    setState(() {
                      currentScroll = notification.extent;
                    });

                    return false;
                  },
                  child: DraggableScrollableSheet(
                      initialChildSize: 324 / 710,
                      minChildSize: 120 / 710,
                      maxChildSize: 1.0,
                      snap: true,
                      snapSizes: const [120 / 710, 324 / 710, 1.0],
                      expand: true,
                      builder: (BuildContext context, ScrollController _scrollController) {


                        // if(currentScroll == (120 / 710)){
                        //   animateBounce();
                        // }else if(currentScroll == (324 / 710)){
                        //   animateBounce();
                        // }

                        return ListView(
                          controller: _scrollController,
                          children: [
                            currentScroll <= 0.8 ?
                            Stack(
                                children: [
                                  ///Bike Connected
                                  if (isDeviceConnected == true) ...{
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
                                                      isDeviceConnected: this.isDeviceConnected,
                                                      bikeName: _bikeProvider.currentBikeModel?.deviceName ?? "",
                                                      distanceBetween: "Est. ${distanceBetween}m",
                                                      currentBikeStatusImage: currentBikeStatusImage,),
                                                  ),

                                                  Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(16.w, 22.5.h, 0, 0),
                                                    child: IntrinsicHeight(
                                                      child: Bike_Status_Row(
                                                        estKm:"Est -km",
                                                        currentBatteryIcon: getBatteryImageFromBLE(_bluetoothProvider.bikeInfoResult!.batteryLevel!),
                                                        connectText: _bluetoothProvider.bikeInfoResult!.batteryLevel!,
                                                        currentSecurityIcon: currentSecurityIcon,
                                                        child: Text(
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
                                                          child:FittedBox(
                                                            child:
                                                            FloatingActionButton(
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
                                                                            SmartDialog.dismiss(
                                                                                status:
                                                                                SmartStatus.loading);
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
                                                                                duration:
                                                                                const Duration(seconds: 4),
                                                                              ),
                                                                            );
                                                                          }
                                                                        }, onError: (error) {
                                                                      SmartDialog.dismiss(
                                                                          status: SmartStatus
                                                                              .loading);
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
                                                            ),),
                                                        ),
                                                        SizedBox(
                                                          height: 12.h,
                                                        ),
                                                        if (connectionState?.name ==
                                                            "connecting") ...{
                                                          Text(
                                                            "Connecting bike",
                                                            style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                color: Color(
                                                                    0xff3F3F3F)),
                                                          ),
                                                        } else if(connectionState?.name ==
                                                            "connected")...{
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
                                                        const Image(
                                                          image: AssetImage(
                                                              "assets/buttons/up.png"),
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
                                                      isDeviceConnected: this.isDeviceConnected,),
                                                  ),

                                                  Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(16.w, 22.5.h, 0, 0),
                                                    child: IntrinsicHeight(
                                                      child: Bike_Status_Row(
                                                        connectText: "-",
                                                        estKm: "",
                                                        currentSecurityIcon: "assets/buttons/bike_security_not_available.png",
                                                        currentBatteryIcon: "assets/icons/battery_not_available.png",
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
                                                          child: FittedBox(
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
                                                                    // TODO: Handle this case.
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
                                                                      if (connectionState ==
                                                                          null ||
                                                                          connectionState ==
                                                                              DeviceConnectionState
                                                                                  .disconnected) {
                                                                        _bluetoothProvider
                                                                            .connectDevice();

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
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          height: 12.h,
                                                        ),
                                                        if (connectionState?.name ==
                                                            "connecting") ...{
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
                                                        const Image(
                                                          image: AssetImage(
                                                              "assets/buttons/up.png"),
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
                                            _bikeProvider.controlBikeList("next");
                                          },
                                          icon: const Image(
                                            image: AssetImage("assets/buttons/filter.png"),
                                          )),
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
        //        ),
        //   )
      ),
    );
  }


  void setConnectImage() {
    if (connectionState?.name == "connected") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/lock_lock.png"),
          width: 35.w,
          height: 35.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "connecting") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/loading.png"),
          width: 35.w,
          height: 35.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "disconnected") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
          width: 35.w,
          height: 35.h,
          fit: BoxFit.fitWidth,
        );
      });
    }
  }

  void setLockImage() {
    if (cableLockState?.lockState == LockState.lock) {
      setState(() {
        lockImage = Image(
          image: const AssetImage("assets/buttons/lock_lock.png"),
          width: 35.w,
          height: 35.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (cableLockState?.lockState == LockState.unlock) {
      setState(() {
        lockImage = Image(
          image: const AssetImage("assets/buttons/lock_unlock.png"),
          width: 35.w,
          height: 35.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
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
      distanceBetween = Geolocator.distanceBetween(
          userLocation!.position.latitude,
          userLocation!.position.longitude,
          _locationProvider.locationModel!.geopoint.latitude,
          _locationProvider.locationModel!.geopoint.longitude)
          .toStringAsFixed(0);
    } else {
      distanceBetween = "-";
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
    currentDangerStatus = _bikeProvider.currentBikeModel!.location!.status;

    getDistanceBetween();
    loadImage(currentDangerStatus);
    //runSymbol();
  }


  // runSymbol() async {
  //   if (mapController?.symbols != null  && locationSymbol != null) {
  //
  //     var markerImage = await loadMarkerImage(currentDangerStatus);
  //     mapController?.addImage('marker', markerImage);
  //
  //     mapController?.updateSymbol(
  //       locationSymbol!,
  //       SymbolOptions(
  //         iconImage: 'marker',
  //         iconSize: 2,
  //         geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude!,
  //             _locationProvider.locationModel!.geopoint.longitude!),
  //       ),
  //     );
  //     animateBounce();
  //   } else {
  //     if(mapController != null){
  //       addSymbol();
  //       animateBounce();
  //     }
  //   }
  //   //  getPlace();
  // }
}

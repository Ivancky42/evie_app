import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
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
import '../../api/model/location_model.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/location_provider.dart';
import '../../bluetooth/modelResult.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_single_button_dialog.dart';

class PaidPlan extends StatefulWidget {
  const PaidPlan({Key? key}) : super(key: key);

  @override
  _PaidPlanState createState() => _PaidPlanState();
}

class _PaidPlanState extends State<PaidPlan> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;
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
    width: 21.w,
    height: 24.h,
    fit: BoxFit.fitWidth,
  );

  Image lockImage = Image(
    image: const AssetImage("assets/buttons/lock_lock.png"),
    width: 21.w,
    height: 24.h,
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

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    mapController!.dispose();
    super.dispose();
  }

  ///Load image according danger status
  Future<Uint8List> loadMarkerImage(String dangerStatus) async {
    switch (dangerStatus) {
      case 'safe':
        {
          var byteData = await rootBundle.load("assets/icons/marker_safe.png");
          return byteData.buffer.asUint8List();
        }
      case 'warning':
        {
          var byteData =
          await rootBundle.load("assets/icons/marker_warning.png");

          return byteData.buffer.asUint8List();
        }
      case 'danger':
        {
          var byteData =
          await rootBundle.load("assets/icons/marker_danger.png");

          return byteData.buffer.asUint8List();
        }
      default:
        {
          var byteData = await rootBundle.load("assets/icons/marker_safe.png");

          return byteData.buffer.asUint8List();
        }
    }
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
    // String key = '856822fd8e22db5e1ba48c0e7d69844a';
    // WeatherFactory wf = WeatherFactory(key);
    // List<Weather> forecast = await wf.fiveDayForecastByCityName("Bayan Lepas, Penang");

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
      SmartDialog.showAttach(
        keepSingle: true,
        alignmentTemp: Alignment.center,
        targetContext: context,
        widget: Container(
          width: 200,
          height: 50,
          color: Colors.white,
          child: _locationProvider.currentPlaceMark != null
              ? Text("Bike Location:\n "
              "${_locationProvider.currentPlaceMark?.name} "
              "${_locationProvider.currentPlaceMark?.country}")
              : const Text("Not Available"),
        ),
      );
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
    _authProvider = Provider.of<AuthProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
    cableLockState = _bluetoothProvider.cableLockState;

    final TextEditingController _bikeNameController = TextEditingController();
    final FocusNode _textFocus = FocusNode();

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
        body:

        Stack(
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
                              onTap: (){
                                _bikeProvider.controlBikeList("next");
                              },
                              child:HomePageWidget_Status(
                                  currentDangerState: currentDangerStatus,
                                  location: _locationProvider.currentPlaceMark)
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

                                IconButton(
                                    onPressed: (){},
                                    icon: Image(
                                      image: AssetImage(
                                          "assets/buttons/direction.png"),
                                      //height: 1.h,
                                    ),),

                                MapboxMap(
                                  useHybridCompositionOverride: true,
                                  useDelayedDisposal: true,
                                  myLocationEnabled: true,
                                  trackCameraPosition: true,
                                  myLocationTrackingMode:
                                  MyLocationTrackingMode.Tracking,
                                  //    myLocationRenderMode: MyLocationRenderMode.COMPASS,
                                  accessToken:
                                  _locationProvider.defPublicAccessToken,
                                  compassEnabled: true,
                                  onMapCreated: _onMapCreated,
                                  styleString:
                                  "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                                  onStyleLoadedCallback: () {
                                    loadImage(currentDangerStatus);
                                    runSymbol();
                                    getPlace();
                                  },
                                  onUserLocationUpdated: (userLocation) {
                                    setState(() {
                                      this.userLocation = userLocation;
                                    });
                                    animateBounce();
                                    getDistanceBetween();
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        _locationProvider
                                            .locationModel!.geopoint.latitude,
                                        _locationProvider
                                            .locationModel!.geopoint.longitude),
                                    zoom: 16,
                                  ),
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
                //color: Color(0xfff5f5f5),

                //      child: Column(
                //          children: [

                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() {
                      currentScroll = notification.extent;
                    });
                    return false;
                  },
                  child: DraggableScrollableSheet(
                      initialChildSize: .40,
                      minChildSize: .14,
                      maxChildSize: 1.0,
                      snap: true,
                      snapSizes: const [.14, .40, 1.0],
                      //expand: true,
                      builder: (BuildContext context,
                          ScrollController _scrollController) {


                        if(currentScroll > 0.36 && currentScroll < 0.45){
                          animateBounce();
                        }else if(currentScroll < 0.36){
                          animateBounce();
                        }

                        if (currentScroll <= 0.80) {
                          return Stack(children: [
                            if (isDeviceConnected == true) ...{
                              Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEDEB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListView(
                                    controller: _scrollController,
                                    children: [
                                      SizedBox(
                                        height: 324.h,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              Stack(
                                                children: [
                                                  Image.asset("assets/buttons/home_indicator.png",
                                                    width: 40.w, height: 4.h,)
                                                ],
                                              ),

                                              Padding(
                                                padding:
                                                const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          _bikeProvider
                                                              .currentBikeModel!
                                                              .deviceName!,
                                                          style: TextStyle(
                                                              fontSize: 16.5.sp,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w700),
                                                        ),
                                                        SizedBox(
                                                          height: 4.h,
                                                        ),
                                                        Text(
                                                          "Est. ${distanceBetween}m",
                                                          style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                        ),
                                                      ],
                                                    ),
                                                    Image(
                                                      image: AssetImage(
                                                          currentBikeStatusImage),
                                                      height: 60.h,
                                                      width: 87.w,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding:
                                                const EdgeInsets.all(10.0),
                                                child: IntrinsicHeight(
                                                  child: Row(children: [
                                                    Container(
                                                      width: 21.w,
                                                      height:24.h,
                                                      child: Image(
                                                        image: AssetImage(
                                                            currentSecurityIcon),
                                                        height: 24.0,
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          width: 135.w,
                                                          child: getSecurityTextWidget(
                                                              cableLockState!.lockState,
                                                              _bikeProvider
                                                                  .currentBikeModel!.location!.status),
                                                        ),
                                                      ],
                                                    ),
                                                    const VerticalDivider(
                                                      thickness: 1,
                                                    ),
                                                    getBatteryImage(
                                                        _bikeProvider.currentBikeModel!.batteryPercent!),
                                                    SizedBox(
                                                      width: 3.w,
                                                    ),
                                                    Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text("${_bikeProvider.currentBikeModel!.batteryPercent!.toString()} %"),
                                                          Text("Est 0km"),
                                                        ])
                                                  ]),
                                                ),
                                              ),

                                              Transform.translate(
                                                offset: const Offset(0, -15),
                                                child: Align(
                                                  alignment:
                                                  Alignment.bottomCenter,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10.h,
                                                        width: 10.h,
                                                        child: FittedBox(
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
                                                                          subscription
                                                                              ?.cancel();
                                                                          ScaffoldMessenger.of(
                                                                              context)
                                                                              .showSnackBar(
                                                                            const SnackBar(
                                                                              content:
                                                                              Text('Bike is unlocked. To lock bike......'),
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
                                                                              90.w,
                                                                              behavior:
                                                                              SnackBarBehavior.floating,
                                                                              shape: const RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                  BorderRadius.all(Radius.circular(10))),
                                                                              content:
                                                                              Container(
                                                                                height:
                                                                                9.h,
                                                                                child:
                                                                                Column(
                                                                                  children: [
                                                                                    const Align(
                                                                                      alignment: Alignment.topLeft,
                                                                                      child: Text('Bike is unlocked. To lock bike......'),
                                                                                    ),
                                                                                    Align(
                                                                                      alignment: Alignment.centerRight,
                                                                                      child: TextButton(
                                                                                        child: const Text(
                                                                                          'LEARN MORE',
                                                                                          style: TextStyle(color: Color(0xff836ED3)),
                                                                                        ),
                                                                                        onPressed: () {},
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
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
                                                        height: 0.5.h,
                                                      ),
                                                      if (connectionState?.name ==
                                                          "connecting") ...{
                                                        const Text(
                                                          "Connecting bike",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              color: Color(
                                                                  0xff3F3F3F)),
                                                        ),
                                                      } else ...{
                                                        const Text(
                                                          "Tap to connect bike",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              color: Color(
                                                                  0xff3F3F3F)),
                                                        ),
                                                      },
                                                      SizedBox(
                                                        height: 1.h,
                                                      ),
                                                      const Image(
                                                        image: AssetImage(
                                                            "assets/buttons/up.png"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            } else ...{
                              Container(
                                  height: 636.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEDEB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    controller: _scrollController,
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
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [

                                                      Text(
                                                        _bikeProvider.currentBikeModel?.deviceName ?? " ",
                                                        style: TextStyle(
                                                            fontSize: 16.5.sp,
                                                            fontWeight:
                                                            FontWeight
                                                                .w700),
                                                      ),
                                                      SizedBox(
                                                        height: 4.h,
                                                      ),
                                                      Text(
                                                        "Est. ${distanceBetween}m",
                                                        style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400),
                                                      ),
                                                    ],
                                                  ),
                                                  Image(
                                                    image: AssetImage(
                                                        currentBikeStatusImage),
                                                    height: 60.h,
                                                    width: 87.w,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding:
                                              EdgeInsets.fromLTRB(16.w, 22.5.h, 0, 0),
                                              child: IntrinsicHeight(
                                                child: Row(children: [
                                                  Container(
                                                    width: 21.w,
                                                    height: 24.h,
                                                    child: Image(
                                                      image: AssetImage(
                                                          currentSecurityIcon),
                                                    ),
                                                  ),
                                                  SizedBox(width: 11.5.w),
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Container(
                                                        width: 135.w,
                                                        child: getSecurityTextWidget(
                                                            LockState.unknown,
                                                            _bikeProvider.currentBikeModel?.location!.status ?? ""),
                                                      )
                                                    ],
                                                  ),
                                                  const VerticalDivider(
                                                    thickness: 1,
                                                  ),
                                                  const Image(
                                                    image: AssetImage(
                                                        "assets/icons/unlink.png"),
                                                    //height: 1.h,
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: const [
                                                        Text(
                                                          "Not Connected",
                                                          style: TextStyle(
                                                              fontStyle:
                                                              FontStyle
                                                                  .italic),
                                                        ),
                                                        Text("Est -km")
                                                      ])
                                                ]),
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

                                                                } else {}
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
                                                    const Text(
                                                      "Connecting bike",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          color: Color(
                                                              0xff3F3F3F)),
                                                    ),
                                                  } else ...{
                                                    const Text(
                                                      "Tap to connect bike",
                                                      style: TextStyle(
                                                          fontSize: 12,
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
                          ]);}else{
                          return Stack(children: [

                            Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListView(
                                  controller: _scrollController,
                                  children: [

                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Text("Threat History",style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
                                    Divider(thickness: 2,),

                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        children: [

                                          const Text("scroll to load more",style:TextStyle(color: Color(0xff7A7A79), fontSize: 12),),
                                          SizedBox(height: 1.h),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Container(

                                              child: ElevatedButton(
                                                child: Text(
                                                  "Show All Data",
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color:
                                                    Color(0xff7A7A79),
                                                  ),
                                                ),
                                                onPressed: () {},
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          14.0),
                                                      side: const BorderSide(
                                                          color: Color(
                                                              0xff7A7A79))),
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 120,
                                                      vertical: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                )),
                          ]);
                        }


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
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "connecting") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/loading.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "disconnected") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
          height: 2.5.h,
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
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (cableLockState?.lockState == LockState.unlock) {
      setState(() {
        lockImage = Image(
          image: const AssetImage("assets/buttons/lock_unlock.png"),
          height: 2.5.h,
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

  void animateBounce() {
    if(_locationProvider.locationModel != null && userLocation?.position != null){
      final LatLng southwest = LatLng(
        min(_locationProvider.locationModel!.geopoint.latitude,
            userLocation!.position.latitude),
        min(_locationProvider.locationModel!.geopoint.longitude,
            userLocation!.position.longitude),
      );

      final LatLng northeast = LatLng(
        max(_locationProvider.locationModel!.geopoint.latitude,
            userLocation!.position.latitude),
        max(_locationProvider.locationModel!.geopoint.longitude,
            userLocation!.position.longitude),
      );

      latLngBounds = LatLngBounds(southwest: southwest, northeast: northeast);

      if(currentScroll == 0.40){
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          latLngBounds,
          left: 170,
          right: 170,
          top: 100,
          bottom: 300,
        ));

      }else{
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          latLngBounds,
          left: 80,
          right: 80,
          top: 80,
          bottom: 80,
        ));
      }
    }
  }

  void locationListener() {
    currentDangerStatus = _bikeProvider.currentBikeModel!.location!.status;

    getDistanceBetween();
    loadImage(currentDangerStatus);
    runSymbol();
  }

  runSymbol() async {


    if (mapController?.symbols != null  && locationSymbol != null) {

      var markerImage = await loadMarkerImage(currentDangerStatus);
      mapController?.addImage('marker', markerImage);

      mapController?.updateSymbol(
        locationSymbol!,
        SymbolOptions(
          iconImage: 'marker',
          iconSize: 0.2.h,
          geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
              _locationProvider.locationModel!.geopoint.longitude),
        ),
      );
      animateBounce();
    } else {
      if(mapController != null){
        addSymbol();
        animateBounce();
      }
    }
    //  getPlace();
  }
}

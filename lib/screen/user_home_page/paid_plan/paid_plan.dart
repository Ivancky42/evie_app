import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/model/threat_routes_model.dart';
import 'package:evie_test/api/navigator.dart';
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
import 'package:lottie/lottie.dart' as lottie;
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/model/location_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/toast.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../free_plan/free_plan.dart';
import '../home_page_widget.dart';
import 'bike_security_status/connection_lost/connection_lost.dart';
import 'bike_security_status/crash/crash_alert.dart';
import 'bike_security_status/danger/theft_attempt.dart';
import 'bike_security_status/fall/fall_detected.dart';
import 'bike_security_status/safe/bike_safe.dart';
import 'bike_security_status/warning/movement_detected.dart';
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
  late NotificationProvider _notificationProvider;
  late SettingProvider _settingProvider;

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;

  Widget? buttonImage;

  late LocationProvider _locationProvider;
  late LatLngBounds latLngBounds;

  double currentScroll = 0.40;

  Symbol? locationSymbol;
  String? distanceBetween;

  StreamSubscription? locationSubscription;
  StreamSubscription? userLocationSubscription;

  
  /// +100 , +100
  static const double initialRatio = 424 / 700;
  static const double minRatio = 186 / 700;

  static const double maxRatio = 1.0;
  bool isBottomSheetExpanded = false;
  bool isMapListShowing = false;
  bool isFirstLoadUserLocation = true;
  List<map_launcher.AvailableMap>? availableMaps;

  LocationData? userLocation;
  MapController? mapController;
  final Location _locationService = Location();

  bool isScanned = false;
  bool isFirstTimeConnected = false;
  var markers = <Marker>[];

  GeoPoint? selectedGeopoint;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    mapController = MapController();

    initLocationService();
    WidgetsBinding.instance.addObserver(this);

    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
  }

  void initLocationService() async {

    ///If 5 seconds are passed AND if the phone is moved at least 1 meters, listen the location
    await _locationService.changeSettings(interval: 5000, distanceFilter: 1);

    ///For user live location
    userLocationSubscription = _locationService.onLocationChanged.listen((LocationData result) async {
          if (mounted) {
            setState(() {
              userLocation = result;

              if(userLocation != null && _locationProvider.locationModel?.status != null) {
                getDistanceBetween();

                if(isFirstLoadUserLocation == true){
                  Future.delayed(const Duration(milliseconds: 50), () {
                    animateBounce();
                  });
                  isFirstLoadUserLocation = false;
                }

                ///User location update will bounce every once, causing almost infinity bounce if open comment
                //       animateBounce();

              }
            });
          }
        });

    locationListener();
    // if(userLocation != null && _locationProvider.locationModel?.status != null){
    //   locationListener();
    // }
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
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

    setButtonImage();

    LatLng currentLatLng;
    if (userLocation != null) {
      currentLatLng = LatLng(userLocation!.latitude!, userLocation!.longitude!);
    } else {
      currentLatLng = LatLng(0, 0);
    }

    loadMarker(currentLatLng);

    Color statusBarColor = Colors.transparent;

    if(_bikeProvider.rfidList.length == 0 && _notificationProvider.isTimeArrive){
        statusBarColor = Colors.transparent;
    }else{
      if (_locationProvider.locationModel?.isConnected == false) {
        statusBarColor = EvieColors.orange;
      } else {
        if (_locationProvider.locationModel?.status == "safe") {
          statusBarColor = Colors.transparent;
        } else if (_locationProvider.locationModel?.status == "warning" ||
            _locationProvider.locationModel?.status == "fall") {
          statusBarColor = EvieColors.orange;
        } else if (_locationProvider.locationModel?.status == "danger" ||
            _locationProvider.locationModel?.status == "crash") {
          statusBarColor = EvieColors.darkRed;
        } else {
          statusBarColor = Colors.transparent;
        }
      }
    }



    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
          backgroundColor:statusBarColor,
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
                          return switchBikeStatusBar(_locationProvider.locationModel?.status ?? "");
                        } else {
                          return Center(
                            child: Text("${_currentUserProvider.getGreeting() ?? "Hello"} ${_currentUserProvider.currentUserModel?.name ?? ""}",
                              style: EvieTextStyles.h3,),
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
                                  latitude: _locationProvider.locationModel!.geopoint.latitude,
                                  longitude: _locationProvider.locationModel!.geopoint.longitude,
                                  onMapReady: () {

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

            stackActionableBar(context, _bikeProvider, _notificationProvider),

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
                      builder: (BuildContext context, ScrollController _scrollController) {
                        return ListView(

                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            mapLauncher(),
                            navigateButton(),
                            currentScroll <= 0.8

                                ? Stack(children: [
                                      switchBikeStatusBottom(_locationProvider.locationModel?.status ?? ""),
                                  ])
                        //           ListView(
                        //
                        //           controller: _scrollController,
                        //           physics: const BouncingScrollPhysics(),
                        //           children: [
                        //           // mapLauncher(),
                        //           // navigateButton(),
                        //           currentScroll <= 0.8
                        //           ? ClipRect(
                        //           child: Stack(children: [
                        //           switchBikeStatusBottom(_locationProvider.locationModel?.status ?? ""),
                        //
                        //           Transform.translate(
                        //           offset: Offset(MediaQuery.of(context).size.width - 50.w, -10),
                        //           child: Icon(Icons.ice_skating)
                        //           ),
                        //
                        //           ]),
                        //           )
                        //               : Threat_History(bikeProvider: _bikeProvider, bluetoothProvider: _bluetoothProvider, locationProvider: _locationProvider,),
                        // ],
                        // );
                                : Threat_History(bikeProvider: _bikeProvider, bluetoothProvider: _bluetoothProvider, locationProvider: _locationProvider,),
                          ],
                        );
                      }),
                ),
              ),
            ),



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

        if (direction == null) {
          return const Center(
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
                                  if(selectedGeopoint != null){
                                    map_launcher.MapLauncher.showDirections(
                                        mapType: availableMaps![index].mapType,
                                        destination: map_launcher.Coords(
                                            selectedGeopoint!.latitude,
                                            selectedGeopoint!.longitude));
                                  }else{
                                    map_launcher.MapLauncher.showDirections(
                                        mapType: availableMaps![index].mapType,
                                        destination: map_launcher.Coords(
                                            _bikeProvider.currentBikeModel!.location!.geopoint.latitude,
                                            _bikeProvider.currentBikeModel!.location!.geopoint.longitude));
                                  }

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
    Future.delayed(Duration.zero, () {
      _bikeProvider.saveDistanceBetween(distanceBetween);
    });
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
    setButtonImage();
    getDistanceBetween();
    animateBounce();
    // loadImage(currentDangerStatus);
  }

  switchBikeStatusBar(String status) {
    if(_locationProvider.locationModel?.isConnected == false){
      return HomePageWidget_StatusBar(currentDangerState: 'warning',location: _locationProvider.currentPlaceMark);
    }else{
      return HomePageWidget_StatusBar(currentDangerState: status,location: _locationProvider.currentPlaceMark, selectedGeopoint: selectedGeopoint, locationProvider: _locationProvider,);
    }
  }

  switchBikeStatusBottom(String status) {
    if(_locationProvider.locationModel?.isConnected == false){
      return ConnectionLost( connectImage:buttonImage,distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected);
    }
    else{
      switch(status) {
        case "safe":
          return BikeSafe(connectImage:buttonImage,distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
        case "warning":
          return BikeWarning(connectImage:buttonImage, distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
        case "danger":
          return BikeDanger(connectImage:buttonImage, distanceBetween: distanceBetween,  isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
        case "fall":
          return FallDetected(connectImage:buttonImage, distanceBetween: distanceBetween, isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
        case "crash":
          return CrashAlert(connectImage:buttonImage,distanceBetween: distanceBetween,  isDeviceConnected: deviceConnectResult == DeviceConnectResult.connected,);
        default:
          return const CircularProgressIndicator();
      }
    }
  }

  void loadMarker(LatLng currentLatLng) {

      markers = <Marker>[
        if(_bikeProvider.currentBikeModel?.location?.status == "danger")...{

      ///load a few more marker
      for(int i = 0; i < _bikeProvider.threatRoutesLists.length; i++)...{
        Marker(
          width: 30.w,
          height: 40.h,
          point: LatLng(_bikeProvider.threatRoutesLists.values
              .elementAt(i)
              .geopoint
              .latitude ?? 0,
              _bikeProvider.threatRoutesLists.values
                  .elementAt(i)
                  .geopoint
                  .longitude ?? 0),
          builder: (ctx) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    selectedGeopoint = _bikeProvider.threatRoutesLists.values
                        .elementAt(i)
                        .geopoint;
                  });
                },
                child: _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint == selectedGeopoint ?
                SvgPicture.asset("assets/icons/marker_danger.svg",)
                    : SvgPicture.asset("assets/icons/marker_danger_deactive.svg",),
              ),
        ),
      },

      Marker(
        width: 42.w,
        height: 56.h,
        point: LatLng(_locationProvider.locationModel?.geopoint.latitude ?? 0,
            _locationProvider.locationModel?.geopoint.longitude ?? 0),
        builder: (ctx) =>
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  selectedGeopoint = _locationProvider.locationModel?.geopoint;
                });
              },
              child: _locationProvider.locationModel?.geopoint == selectedGeopoint ?
              SvgPicture.asset(
                "assets/icons/marker_danger.svg",
                height: 56.h,
              )
                  : SvgPicture.asset(
                "assets/icons/marker_danger_deactive.svg",
                height: 56.h,
              ),
            ),
      ),

        }else...{

          Marker(
            width: 42.w,
            height: 56.h,
            point: LatLng(_locationProvider.locationModel?.geopoint.latitude ?? 0,
                _locationProvider.locationModel?.geopoint.longitude ?? 0),
            builder: (ctx) => Image(
              image: AssetImage(!_locationProvider.locationModel!.isConnected ? "assets/icons/marker_warning.png" : loadMarkerImageString(_locationProvider.locationModel?.status ?? "")),
            ),
          ),
        },

        Marker(
          width: 42.w,
          height: 56.h,
          point: currentLatLng,
          builder: (ctx) {
            return _buildCompass();
          },
        ),
      ];
  }

  ///Load image according danger status
  loadMarkerImageString(String dangerStatus){
    switch (dangerStatus) {
      case 'safe':
        return "assets/icons/marker_safe.png";
      case 'warning':
        return "assets/icons/marker_warning.png";
      case 'fall':
        return "assets/icons/marker_warning.png";
      case 'danger':
        return "assets/icons/marker_danger.png";
      case 'crash':
        return "assets/icons/marker_danger.png";
      default:
        return "assets/icons/marker_safe.png";
    }
  }
}

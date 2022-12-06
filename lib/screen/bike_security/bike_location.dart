import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/model/location_model.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather/weather.dart';

import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/location_provider.dart';

///Temporary use for location and map service

class BikeLocation extends StatefulWidget {
  const BikeLocation({Key? key}) : super(key: key);

  @override
  _BikeLocationState createState() => _BikeLocationState();
}

class _BikeLocationState extends State<BikeLocation> {
  final List<String> dangerStatus = ['safe', 'warning', 'danger'];
  String currentDangerStatus = 'safe';
  String currentBikeStatusImage = "assets/images/bike_HPStatus/bike_safe.png";
  String currentSecurityIcon =
      "assets/buttons/bike_security_lock_and_secure.png";

  late LocationProvider _locationProvider;
  late BikeProvider _bikeProvider;
  late LatLngBounds latLngBounds;

  MapboxMapController? mapController;

  double currentScroll = 0.28;

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

  runSymbol() async {
    var markerImage = await loadMarkerImage(currentDangerStatus);
    mapController?.addImage('marker', markerImage);

    if (mapController!.symbols.isNotEmpty) {
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

      addSymbol();
      animateBounce();

    }
    //  getPlace();
  }

  ///Change icon according to dangerous level
  void addSymbol() async {

    String key = '856822fd8e22db5e1ba48c0e7d69844a';
    WeatherFactory wf = WeatherFactory(key);
    List<Weather> forecast = await wf.fiveDayForecastByCityName("Bayan Lepas, Penang");





    locationSymbol = (await mapController?.addSymbol(
      SymbolOptions(
        iconImage: 'marker',
        iconSize: 0.2.h,
        geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
            _locationProvider.locationModel!.geopoint.longitude),
      ),
    ))!;
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
    _bikeProvider = Provider.of<BikeProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToUserHomePageScreen(context);
        return true;
      },
      child: Scaffold(
        body:
            //Padding(
            //    padding: const EdgeInsets.all(16.0),
            //     child: Center(
            //    child:
            Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: getLocationModel(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            width: double.infinity,
                            height: 55.h,
                            child: MapboxMap(
                              useHybridCompositionOverride: true,
                              //                           useDelayedDisposal: true,
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
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),

                  /*
                  FloatingActionButton.small(
                    child: const Icon(Icons.person),
                    onPressed: () async {
                      var position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            position.latitude,
                            position.longitude,
                          ),
                          14,
                        ),
                      );
                    },
                  ),

                   */
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200.h,
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
                      initialChildSize: .28,
                      minChildSize: .28,
                      maxChildSize: .97,
                      snap: true,
                      builder: (BuildContext context,
                          ScrollController _scrollController) {
                        if (currentScroll <= 0.80) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEB),
                                  borderRadius: BorderRadius.circular(16),
                                  //more than 50% of width makes circle
                                ),
                                child: ListView(
                                  controller: _scrollController,
                                  children: [
                                    //             SingleChildScrollView(
                                    //              controller: ModalScrollController.of(context),
                                    //              child:
                                    SizedBox(
                                      height: 60.h,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 5.h),
                                            Stack(
                                              children: [
                                                Positioned(
                                                  left: 5.w,
                                                  top: 7.h,
                                                  child: Visibility(
                                                    visible: _bikeProvider
                                                                .userBikeList
                                                                .length >
                                                            1
                                                        ? true
                                                        : false,
                                                    child: IconButton(
                                                      icon: const Image(
                                                        image: AssetImage(
                                                            "assets/buttons/back.png"),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _locationProvider.removeListener(locationListener);
                                                    //      mapController?.dispose();
                                                        });
                                                        _bikeProvider
                                                            .controlBikeList(
                                                                "back");
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _bikeProvider
                                                      .currentBikeModel!
                                                      .deviceName!,
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Positioned(
                                                  right: 2.w,
                                                  top: 5.h,
                                                  child: Visibility(
                                                    visible: _bikeProvider
                                                                .userBikeList
                                                                .length >
                                                            1
                                                        ? true
                                                        : false,
                                                    child: IconButton(
                                                      icon: const Image(
                                                        image: AssetImage(
                                                            "assets/buttons/next.png"),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _locationProvider.removeListener(locationListener);
                                                    //      mapController?.dispose();
                                                        });
                                                        _bikeProvider
                                                            .controlBikeList(
                                                                "next");
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1.h),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10.w,
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
                                                      const Text(
                                                        "Last Seen",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),
                                                      Container(
                                                        width: 77.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              _locationProvider
                                                                      .currentPlaceMark
                                                                      ?.name! ??
                                                                  "Not Available",
                                                              //    "Random Place",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            Text(
                                                              "Est. ${distanceBetween}m",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),
                                                      Text(
                                     getDateTime(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 10.sp),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //           )
                                    Divider(),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        children: [
                                          const Text("pull to load more"),
                                          SizedBox(height: 1.h),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 48.w,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                      "Clear Data",
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
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xff7A7A79))),
                                                      elevation: 0.0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 40,
                                                          vertical: 20),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 48.w,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                      "Download Data",
                                                      style: TextStyle(
                                                        fontSize: 10.2.sp,
                                                        color:
                                                            Color(0xff6A51CA),
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
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xff6A51CA))),
                                                      elevation: 0.0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 40,
                                                          vertical: 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 2.w,
                                child: Visibility(
                                  visible: _bikeProvider.userBikeList.length > 1
                                      ? true
                                      : false,
                                  child: IconButton(
                                    icon: const Image(
                                      image:
                                          AssetImage("assets/buttons/back.png"),
                                    ),
                                    onPressed: () {
                                      _bikeProvider.controlBikeList("back");
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Transform.translate(
                                  child: Container(
                                    height: 12.h,
                                    width: 50.w,
                                    child: Stack(
                                      children: [
                                        Image(
                                          image: AssetImage(
                                              currentBikeStatusImage),
                                          height: 12.h,
                                          width: 50.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                  offset: Offset(0, -70),
                                ),
                              ),
                              Positioned(
                                right: 2.w,
                                child: Visibility(
                                  visible: _bikeProvider.userBikeList.length > 1
                                      ? true
                                      : false,
                                  child: IconButton(
                                    icon: const Image(
                                      image:
                                          AssetImage("assets/buttons/next.png"),
                                    ),
                                    onPressed: () {
                                      _bikeProvider.controlBikeList("next");
                                    },
                                  ),
                                ),
                              ),

                            ],
                          );
                        } else {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEB),
                                  borderRadius: BorderRadius.circular(16),
                                  //more than 50% of width makes circle
                                ),
                                child: ListView(
                                  controller: _scrollController,
                                  children: [
                                    //             SingleChildScrollView(
                                    //              controller: ModalScrollController.of(context),
                                    //              child:
                                    SizedBox(
                                      height: 60.h,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 5.h),
                                            Image(
                                              image: AssetImage(
                                                  currentBikeStatusImage),
                                              height: 12.h,
                                              width: 50.w,
                                            ),
                                            Text(
                                              _bikeProvider.currentBikeModel!
                                                  .deviceName!,
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 3.h),
                                            Text(
                                              "Track My Bike History",
                                              style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Divider(),
                                            SizedBox(height: 1.h),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10.w,
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
                                                      const Text(
                                                        "Last Seen",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),
                                                      Container(
                                                        width: 77.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              _locationProvider
                                                                      .currentPlaceMark
                                                                      ?.name! ??
                                                                  "Not Available",
                                                              //    "Random Place",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            Text(
                                                            "Est. ${distanceBetween}m",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0.5.h,
                                                      ),
                                                      Text(
                                                        getDateTime(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 10.sp),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //           )
                                    Divider(),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        children: [
                                          const Text("pull to load more"),
                                          SizedBox(height: 1.h),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 48.w,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                      "Clear Data",
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
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xff7A7A79))),
                                                      elevation: 0.0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 40,
                                                          vertical: 20),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 48.w,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                      "Download Data",
                                                      style: TextStyle(
                                                        fontSize: 10.2.sp,
                                                        color:
                                                            Color(0xff6A51CA),
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
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xff6A51CA))),
                                                      elevation: 0.0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 40,
                                                          vertical: 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /*
                           Align(
                            alignment: Alignment.topCenter,
                            child: Transform.translate(
                              child: Container(
                                height: 12.h,
                                width: 50.w,
                                child: Image(
                                  image: AssetImage(currentBikeStatusImage),
                                  height: 12.h,
                                  width: 50.w,
                                ),
                              ),
                              offset: Offset(0, -70),
                            ),
                          ),
                           */
                            ],
                          );
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

  String getDateTime() {
    final now = DateTime.now();
    String? month;

    switch(now.month){
      case 1:month = "Jan";
        break;
      case 2:month = "Feb";
        break;
      case 3:month = "Mar";
        break;
      case 4:month = "Apr";
        break;
      case 5:month = "May";
        break;
      case 6:month = "Jun";
        break;
      case 7:month = "Jly";
        break;
      case 8:month = "Aug";
        break;
      case 9:month = "Sep";
        break;
      case 10:month = "Oct";
        break;
      case 11:month = "Nov";
        break;
      case 12:month = "Dec";
        break;
    }

    String returnValue = "$month ${now.day.toString()}, ${now.year.toString()} at ${now.hour.toString()} : ${now.minute.toString()}";

    return returnValue;
  }

  void animateBounce() {
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

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
      latLngBounds,
      left: 80,
      right: 80,
      top: 80,
      bottom: 80,
    ));
  }

  void locationListener(){
    currentDangerStatus = _bikeProvider.currentBikeModel!.location!.status;

    getDistanceBetween();
    loadImage(currentDangerStatus);
    runSymbol();
  }

}

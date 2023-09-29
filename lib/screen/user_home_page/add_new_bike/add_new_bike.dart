import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
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
import 'package:get/utils.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../api/dialog.dart';
import '../../../api/model/location_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_button.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../home_page_widget.dart';
import '../paid_plan/paid_plan.dart';
import 'bottom_sheet_widget.dart';

class AddNewBike extends StatefulWidget {
  const AddNewBike({Key? key}) : super(key: key);

  @override
  _AddNewBikeState createState() => _AddNewBikeState();
}

class _AddNewBikeState extends State<AddNewBike> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late NotificationProvider _notificationProvider;

  Color lockColour = const Color(0xff6A51CA);


  DeviceConnectResult? deviceConnectResult;
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
  bool isFirstLoadUserLocation = true;

  LocationData? userLocation;
  late LatLng currentLatLngFree;
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
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;


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
              child: Column(
                children: [
                  Container(
                    height: 77.77.h,
                    color:  EvieColors.lightBlack,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset('assets/images/bike_round_empty.png', width: 56.w, height: 56.w,),
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
                                        "My Bike",
                                        style: EvieTextStyles.h1.copyWith(fontWeight: FontWeight.w800, color: EvieColors.grayishWhite),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 32.h, left: 18.w, right: 18.w, bottom: 32.h),
                    child: Container(
                      width: double.infinity,
                      height: Platform.isIOS ? (MediaQuery.of(context).size.height - 77.h - 50.h - 64.h - 96.h) : (MediaQuery.of(context).size.height - 77.h - 30.h - 64.h - 64.h),
                      decoration: BoxDecoration(
                        color: EvieColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Lottie.asset(
                                  'assets/animations/add-bike.json',
                                    repeat:false,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 17.w, right: 14.w),
                                child: Text("Register your bike",
                                  style: EvieTextStyles.h2.copyWith(color: EvieColors.dividerWhite, fontWeight: FontWeight.w500),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 17.w, right: 14.w),
                                child: Text("To start riding and using EVIE app "
                                    "you’ll need to pair your bike to your account.",
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.dividerWhite, fontWeight: FontWeight.w400),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 55.h, bottom: 24.h, left: 17.w, right: 14.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(

                                      child: EvieButton_ReversedColor(
                                        width: double.infinity,
                                        height: 48.h,
                                        onPressed: () { changeToBeforeYouStart(context); },
                                        child: Center(
                                          child: Text(
                                            "Register New Bike",
                                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],

                          ),
                        ],
                      ),

                    ),
                  ),
                ],
              )
            ),
          )
        //        ),
        //   )
      ),
    );
  }
}

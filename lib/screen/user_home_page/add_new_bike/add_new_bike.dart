import 'dart:async';
import 'dart:math' as math;
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
    cableLockState = _bluetoothProvider.cableLockState;


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
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                          Container(
                            height: 73.33.h,
                            color:  EvieColors.lightBlack,
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
                                                "My Bike",
                                                style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite),
                                              ),
                                              // Text(
                                              //   "icons",
                                              //   style: EvieTextStyles.h3.copyWith(color: EvieColors.grayishWhite),
                                              // ),
                                            ],
                                          ),

                                          Text(
                                            "Bike status",
                                            style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],),
                              ],
                            ),
                          ),


                              GestureDetector(
                                onTap: (){
                                  changeToBeforeYouStart(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.68.h),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(left:15.w, right:15.w),
                                          child: SvgPicture.asset(
                                            "assets/images/bike_register_required.svg",
                                            height:608.h,
                                          ),
                                        ),
                                      ),

                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 120.h),
                                          child: Lottie.asset('assets/animations/add-bike.json'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        //        ),
        //   )
      ),
    );
  }
}

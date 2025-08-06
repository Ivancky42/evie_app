import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../api/dialog.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_button.dart';

class AddNewBike extends StatefulWidget {
  const AddNewBike({super.key});

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
                                        style: EvieTextStyles.target_reference_h1.copyWith(color: EvieColors.grayishWhite),
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
                                padding: EdgeInsets.only(top: 67.h, bottom: 0, left: 17.w, right: 14.w),
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

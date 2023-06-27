import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import '../switch_bike.dart';
import 'package:location/location.dart';
import 'home_element/battery.dart';
import 'home_element/orbital_anti_theft.dart';
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

  bool isActionBarAppear = false;

  CableLockResult? cableLockState;
  DeviceConnectResult? deviceConnectResult;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;


    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },

      child: Scaffold(
          backgroundColor: EvieColors.lightBlack,
          appBar: const EmptyAppbar(),
          body: SafeArea(
              child: Container(
                color: EvieColors.grayishWhite,
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
                                onTap: (){

                                },
                                child:Padding(
                                  padding: EdgeInsets.fromLTRB(0, Platform.isIOS ? 5.h : 10.h, 0, 5.h),
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
                                                _bikeProvider.currentBikeModel?.bikeIMG == ''
                                                    ? Image(
                                                  image: const AssetImage("assets/buttons/bike_left_pic.png"),
                                                  width: 49.h,
                                                  height: 49.h,
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.only(left: 15.0),
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      //imageUrl: document['profileIMG'],
                                                      imageUrl: _bikeProvider.currentBikeModel!.bikeIMG!,
                                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                      width: 66.67.h,
                                                      height: 66.67.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:  EdgeInsets.only(left: 12.w),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        //color: Colors.red,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              _bikeProvider.currentBikeModel?.deviceName ?? "loading",
                                                              style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite),
                                                            ),
                                                            SvgPicture.asset(
                                                              "assets/icons/batch_tick.svg",
                                                              height: 25.h,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        //color: Colors.green,
                                                        child: Expanded(
                                                          child: Row(
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
                                                                padding: EdgeInsets.only(left: 9.w, right: 5.w),
                                                                child: SvgPicture.asset(
                                                                  "assets/icons/break_line.svg",
                                                                  height: 20.h,
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
                                                            ],),
                                                        ),
                                                      )
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
                            }
                            else {
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
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                              child: OrbitalAntiTheft(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(19.w, 0, 8.w, 16.h),
                                    child: Battery(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 16.h),
                                    child: Rides(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(19.w, 0, 8.w, 20.h),
                                      child: Setting(),
                                    ),
                                  )
                              ),
                              Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 20.h),
                                      child: UnlockingSystem(),
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          )
      ),
    );
  }
}

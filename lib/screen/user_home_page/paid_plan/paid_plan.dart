import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/firmware_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/threat_unlocking_system.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:evie_test/widgets/actionable_bar.dart';
import 'package:evie_test/widgets/evie-unlocking-button.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_card.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_slider_button.dart';
import '../switch_bike.dart';
import 'package:location/location.dart';
import 'home_element/actionable_bar.dart';
import 'home_element/battery.dart';
import 'home_element/loading_map.dart';
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
  late FirmwareProvider _firmwareProvider;
  bool isActionBarAppear = false;
  DeviceConnectResult? deviceConnectResult;
  Widget arrowDirection = SvgPicture.asset("assets/buttons/down_white.svg",);
  ActionableBarItem actionableBarItem = ActionableBarItem.none;

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
    _firmwareProvider = Provider.of<FirmwareProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    if (_firmwareProvider.currentFirmVer != _firmwareProvider.latestFirmVer) {
      print(_firmwareProvider.latestFirmVer);
      print(_firmwareProvider.currentFirmVer);
      setState(() {
        actionableBarItem = ActionableBarItem.bikeUpdate;
      });
    }
    else {
      if (_bikeProvider.rfidList.isEmpty) {
        setState(() {
          actionableBarItem = ActionableBarItem.registerEVKey;
        });
      }
      else {
        setState(() {
          actionableBarItem = ActionableBarItem.none;
        });
      }
    }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //color:  EvieColors.lightBlack,
                      decoration: BoxDecoration(
                        color: EvieColors.lightBlack,
                        border: Border.all(
                          color: EvieColors.lightBlack,
                          width: 0,
                        ),
                      ),
                      child: FutureBuilder(
                          future: _currentUserProvider.fetchCurrentUserModel,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: (){

                                },
                                child:Padding(
                                  padding: EdgeInsets.fromLTRB(0, Platform.isIOS ? 5.h : 10.h, 0, 0),
                                  child: Container(
                                      height: 73.33.h,
                                      color:  EvieColors.lightBlack,
                                      //color:  EvieColors.blue,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left: 15.w),
                                                  child: _bikeProvider.currentBikeModel?.model == 'S1' ?
                                                  Image(
                                                    image: const AssetImage("assets/buttons/bike_default_S1.png"),
                                                    width: 56.h,
                                                    height: 56.h,
                                                  ) :
                                                  Image(
                                                    image: const AssetImage("assets/buttons/bike_default_T1.png"),
                                                    width: 56.h,
                                                    height: 56.h,
                                                  ),
                                                ),
                                                // _bikeProvider.currentBikeModel?.bikeIMG == ''
                                                //     ? Padding(
                                                //   padding: const EdgeInsets.only(left: 15.0),
                                                //       child: Image(
                                                //   image: const AssetImage("assets/buttons/bike_left_pic.png"),
                                                //   width: 56.h,
                                                //   height: 56.h,
                                                // ),)
                                                //     : Padding(
                                                //   padding: const EdgeInsets.only(left: 15.0),
                                                //   child: _bikeProvider.currentBikeModel != null ?
                                                //   _bikeProvider.currentBikeModel!.bikeIMG != null ?
                                                //   ClipOval(
                                                //     child: CachedNetworkImage(
                                                //       //imageUrl: document['profileIMG'],
                                                //       imageUrl: _bikeProvider.currentBikeModel!.bikeIMG!,
                                                //       placeholder: (context, url) => const CircularProgressIndicator(color: EvieColors.primaryColor,),
                                                //       errorWidget: (context, url, error) => Icon(Icons.error),
                                                //       width: 56.h,
                                                //       height: 56.h,
                                                //       fit: BoxFit.cover,
                                                //     ),
                                                //   ) : Container() : Container()
                                                Padding(
                                                  padding:  EdgeInsets.only(left: 12.w),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        //color: Colors.red,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              _bikeProvider.currentBikeModel?.deviceName ?? "loading",
                                                              style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite, height: 1.2),
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

                                                    setState(() {
                                                      arrowDirection = SvgPicture.asset("assets/buttons/up_white.svg",);
                                                    });

                                                    showCupertinoModalBottomSheet(
                                                        expand: false,
                                                        useRootNavigator: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return SwitchBike();
                                                        }).then((value) {
                                                      setState(() {
                                                        arrowDirection = SvgPicture.asset("assets/buttons/down_white.svg",);
                                                      });
                                                    });
                                                  },
                                                  icon: arrowDirection,
                                              ),
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

                    ///No Actionable Bar
                    actionableBarItem == ActionableBarItem.none ?
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _bikeProvider.currentBikeModel?.location != null ?
                            Padding(
                                padding: EdgeInsets.fromLTRB(19.w, 19.42.h, 19.w, 16.w),
                                //  padding: EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                                child: Container(
                                    height: 250.h,
                                    child: OrbitalAntiTheft())
                            ) :
                            Padding(
                                padding: EdgeInsets.fromLTRB(19.w, 19.42.h, 19.w, 16.w),
                                //  padding: EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                                child: Container(
                                    height: 255.h,
                                    child: LoadingMap())
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(19.w, 0, 8.w, 16.h),
                                      child: Battery(isShow: false),
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
                                        child: _bikeProvider.currentBikeModel?.location?.status == "danger" ? ThreatUnlockingSystem(page: 'home') : EvieCard(
                                          child: UnlockingButton(),
                                        ),
                                      ),
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ) :
                    ///Has Actionable Bar
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: actionableBarItem == ActionableBarItem.none ?
                              EdgeInsets.zero : EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                              child: ActionableBarHome(actionableBarItem: actionableBarItem,),
                            ),

                            _bikeProvider.currentBikeModel?.location != null ?
                            Padding(
                              padding: EdgeInsets.fromLTRB(19.w, 0.h, 19.w, 16.w),
                              //  padding: EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                              child: Container(
                                  height: 240.h,
                                  child: OrbitalAntiTheft()),
                            ) :
                            Padding(
                              padding: EdgeInsets.fromLTRB(19.w, 0.h, 19.w, 16.w),
                              child: Container(
                                height: 255.h,
                                child: LoadingMap(),
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
                                      child: Battery(isShow: false),
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
                                        child: _bikeProvider.currentBikeModel?.location?.status == "danger" ? ThreatUnlockingSystem(page: 'home') : EvieCard(
                                          child: UnlockingButton(),
                                        ),
                                      ),
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
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

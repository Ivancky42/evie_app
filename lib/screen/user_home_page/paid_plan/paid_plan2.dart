import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
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
import '../switch_bike.dart';
import 'package:location/location.dart';
import 'home_element/battery.dart';
import 'home_element/orbital_anti_theft2.dart';
import 'home_element/rides.dart';
import 'home_element/setting.dart';

class PaidPlan2 extends StatefulWidget  {
  const PaidPlan2({Key? key}) : super(key: key);

  @override
  _PaidPlan2State createState() => _PaidPlan2State();
}

class _PaidPlan2State extends State<PaidPlan2> with WidgetsBindingObserver{
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  bool isActionBarAppear = false;
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
                      color:  EvieColors.lightBlack,
                      child: FutureBuilder(
                          future: _currentUserProvider.fetchCurrentUserModel,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: (){},
                                child:Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/bike_round.png', width: 56.w, height: 56.w,),
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
                              padding: EdgeInsets.all(6),
                              child: OrbitalAntiTheft2(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8, 2, 4, 4),
                                    child: Battery(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(4, 2, 8, 4),
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
                                      padding: EdgeInsets.fromLTRB(8, 4, 4, 8),
                                      child: Setting(),
                                    ),
                                  )
                              ),
                              Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(4, 4, 8, 8),
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

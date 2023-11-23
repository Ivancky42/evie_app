import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie-unlocking-button.dart';
import 'package:evie_test/widgets/evie_card.dart';

import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart' as SnackBar;
import '../../../bluetooth/modelResult.dart';
import '../paid_plan/home_element/actionable_bar.dart';
import '../paid_plan/home_element/battery.dart';
import '../switch_bike.dart';

class FreePlan extends StatefulWidget {
  const FreePlan({Key? key}) : super(key: key);

  @override
  _FreePlanState createState() => _FreePlanState();
}

class _FreePlanState extends State<FreePlan> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  DeviceConnectResult? deviceConnectResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
     _settingProvider = Provider.of<SettingProvider>(context);

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
              child: Stack(
                children: [
                Align(
                  alignment: Alignment.topCenter,
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
                                    padding: EdgeInsets.fromLTRB(0, Platform.isIOS ? 5.h : 10.h, 0, 0),

                                    child: Container(
                                        height: 73.33.h,
                                        color:  EvieColors.lightBlack,
                                        child: Container(
                                          //color: Colors.red,
                                          alignment: Alignment.centerLeft,
                                          child: SingleChildScrollView(
                                            physics: NeverScrollableScrollPhysics(),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
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
                                                    //   padding: EdgeInsets.only(left: 15.w),
                                                    //   child: Image(
                                                    //     image: const AssetImage("assets/buttons/bike_left_pic.png"),
                                                    //     width: 56.h,
                                                    //     height: 56.h,
                                                    //   ),
                                                    // )
                                                    //     : Container(
                                                    //   padding: EdgeInsets.only(left: 15.w),
                                                    //   child: ClipOval(
                                                    //     child: CachedNetworkImage(
                                                    //       //imageUrl: document['profileIMG'],
                                                    //       imageUrl: _bikeProvider.currentBikeModel!.bikeIMG!,
                                                    //       placeholder: (context, url) => CircularProgressIndicator( color: EvieColors.primaryColor,),
                                                    //       errorWidget: (context, url, error) => Icon(Icons.error),
                                                    //       width: 56.h,
                                                    //       height: 56.h,
                                                    //       fit: BoxFit.cover,
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Padding(
                                                      padding:  EdgeInsets.only(left: 12.w),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [

                                                          Container(
                                                            padding: EdgeInsets.only(left: 2),
                                                            //color: Colors.red,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  _bikeProvider.currentBikeModel?.deviceName ?? "loading",
                                                                  style: EvieTextStyles.h1.copyWith(color: EvieColors.grayishWhite, height: 1.2),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

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
                                                          Container(
                                                            padding: EdgeInsets.zero,
                                                            //color: Colors.green,
                                                            child: Row(
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
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],),

                                                Padding(
                                                  padding: EdgeInsets.only(right: 22.5.w),
                                                  child: IconButton(
                                                      onPressed: (){
                                                        showCupertinoModalBottomSheet(
                                                            expand: false,
                                                            useRootNavigator: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return SwitchBike();
                                                            });
                                                  },
                                                      icon: SvgPicture.asset("assets/buttons/down_white.svg",)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "Loading",
                                    style: EvieTextStyles.h3,
                                  ),
                                );
                              }
                            }),
                      ),

                      ///Start page element


                      ///No Actionable Bar
                      _bikeProvider.actionableBarItem == ActionableBarItem.none ?
                     Expanded(
                       child: Column(
                         children: [
                           Expanded(
                             child: Padding(
                               padding: EdgeInsets.fromLTRB(19.w, 19.42.h, 19.w, 16.w),
                               child: Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(10.w),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
                                         offset: Offset(0, 8), // X and Y offset
                                         blurRadius: 16, // Blur radius
                                         spreadRadius: 0, // Spread radius
                                       ),
                                     ],
                                   ),
                                 child: EvieCard(
                                   onPress: (){
                                     _settingProvider.changeSheetElement(SheetList.proPlan);
                                     showSheetNavigate(context);
                                   },
                                   height: double.infinity,
                                   width: double.infinity,
                                   child: Container(
                                     child: Stack(
                                       alignment: Alignment.centerLeft,
                                       children: [
                                         Padding(
                                           padding: EdgeInsets.only(left: 16.w, top: 18.h, bottom: 17.58.h, right: 59.79.w),
                                           child: Container(
                                             //color:Colors.red,
                                             child: SvgPicture.asset(
                                               "assets/images/bike_illustration.svg",
                                               // width: 295.21.w,
                                               // height: 196.42.h,
                                             ),
                                           )
                                         ),

                                         Align(
                                           alignment: Alignment.centerRight,
                                           child: Padding(
                                             padding: EdgeInsets.only(top: 100.h),
                                             child: Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Padding(
                                                   padding: EdgeInsets.only(top: 0.h, left: 185.w, right: 15.w),
                                                   child: Container(
                                                     width: 180.h,
                                                     child: Text("Your bike will never be out of sight.",
                                                         style: EvieTextStyles.headlineB2.copyWith(height: 1.2.h)),
                                                   ),
                                                 ),

                                                 Padding(
                                                   padding: EdgeInsets.only(top: 0.h, left: 185.w, right: 15.w),
                                                   child:SvgPicture.asset(
                                                     "assets/buttons/EVIE+.svg",
                                                   ),
                                                 )
                                               ],
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 )
                               ),
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
                                     child: Battery(isShow: true),
                                   ),
                                 ),
                               ),

                               Expanded(
                                 child: AspectRatio(
                                   aspectRatio: 1,
                                 child: Padding(
                                     padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 16.h),
                                     child: EvieCard(
                                       onPress: (){    SnackBar.showUpgradePlanToast(context, _settingProvider, true);},
                                       color: EvieColors.grayishWhite,
                                       title: "Rides",
                                       decoration: BoxDecoration(
                                         border: Border.all(
                                           color: EvieColors.lightGrayishCyan,
                                           width: 2.w,
                                         ),
                                         borderRadius: BorderRadius.circular(10), // Optional: To add rounded corners
                                       ),
                                       child: Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.end,
                                           children: [
                                             // SvgPicture.asset(
                                             //   "assets/icons/bar_chart.svg",
                                             // ),
                                             Text("- km", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                             Padding(
                                               padding:  EdgeInsets.only(bottom: 16.h),
                                               child: Text("ridden this week", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     )
                                 ),),
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
                                   padding: EdgeInsets.fromLTRB(19.w, 0, 8.w, 16.h),
                                     child: EvieCard(
                                       onPress: (){
                                         _settingProvider.changeSheetElement(SheetList.bikeSetting);
                                         showSheetNavigate(context, 'Home');
                                       },
                                       title: "Setting",
                                       child: Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.end,
                                           children: [
                                             SvgPicture.asset(
                                               "assets/icons/setting_black.svg",
                                             ),
                                             Padding(
                                               padding: EdgeInsets.only(bottom: 16.h),
                                               child: Text("Bike Settings", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),),
                                 ),
                               ),

                               Expanded(
                                 child: AspectRatio(
                                   aspectRatio: 1,
                                 child: Padding(
                                     padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 16.h),
                                     child: EvieCard(
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.center,
                                         children: [
                                           UnlockingButton(),
                                         ],
                                       ),
                                     )
                                 ),),
                               ),
                             ],
                           ),
                         ],
                       ),)

                      ///Has Actionable Bar
                      :
                      Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: _bikeProvider.actionableBarItem == ActionableBarItem.none ?
                                EdgeInsets.zero : EdgeInsets.fromLTRB(19.w, 16.42.h, 19.w, 16.w),
                                child: ActionableBarHome(),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(19.w, 0.h, 19.w, 16.w),
                                child: Container(
                                  height: 232.h,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.w),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
                                            offset: Offset(0, 8), // X and Y offset
                                            blurRadius: 16, // Blur radius
                                            spreadRadius: 0, // Spread radius
                                          ),
                                        ],
                                      ),
                                      child: EvieCard(
                                        onPress: (){
                                          _settingProvider.changeSheetElement(SheetList.proPlan);
                                          showSheetNavigate(context);
                                        },
                                        height: double.infinity,
                                        width: double.infinity,

                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 16.w, top: 18.h, bottom: 17.58.h,
                                                  right: 59.79.w
                                              ),
                                              child: SvgPicture.asset(
                                                "assets/images/bike_illustration.svg",
                                                width: 295.21.w,
                                                height: 196.42.h,
                                              ),
                                            ),

                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 93.h),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 0.h, left: 185.w, right: 15.w),
                                                      child: Container(
                                                        width: 180.h,
                                                        child: Text("Your bike will never be out of sight.",
                                                            style: EvieTextStyles.headlineB2.copyWith(height: 1.2.h)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 0.h, left: 185.w, right: 15.w),
                                                      child: SvgPicture.asset(
                                                        "assets/buttons/EVIE+.svg",
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
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
                                        child: Battery(isShow: true),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 16.h),
                                          child: EvieCard(
                                            color: EvieColors.grayishWhite,
                                            title: "Rides",
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: EvieColors.lightGrayishCyan,
                                                width: 2.w,
                                              ),
                                              borderRadius: BorderRadius.circular(10), // Optional: To add rounded corners
                                            ),
                                            child: Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  // SvgPicture.asset(
                                                  //   "assets/icons/bar_chart.svg",
                                                  // ),
                                                  Text("- km", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                                  Padding(
                                                    padding:  EdgeInsets.only(bottom: 16.h),
                                                    child: Text("ridden this week", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                      ),),
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
                                        child: EvieCard(
                                          onPress: (){
                                            _settingProvider.changeSheetElement(SheetList.bikeSetting);
                                            showSheetNavigate(context, 'Home');
                                          },
                                          title: "Setting",
                                          child: Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icons/setting_black.svg",
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 16.h),
                                                  child: Text("Bike Settings", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),),
                                    ),
                                  ),

                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(8.w, 0, 19.w, 20.h),
                                          child: EvieCard(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                UnlockingButton(),
                                              ],
                                            ),
                                          )
                                      ),),
                                  ),
                                ],
                              ),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Expanded(
                              //       child: Padding(
                              //           padding: EdgeInsets.all(8),
                              //           child:Container()
                              //       ),
                              //     ),
                              //
                              //
                              //   ],
                              // ),

                            ],
                          ),
                        ),)
                      ,


                    ],
                  ),
                ),
              ],),
            )
          )
        //        ),
        //   )
      ),
    );
  }
}

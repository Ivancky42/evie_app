import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/setting.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';



class ResetBike2 extends StatefulWidget{
  const ResetBike2({ Key? key }) : super(key: key);
  @override
  _ResetBike2State createState() => _ResetBike2State();
}

class _ResetBike2State extends State<ResetBike2> {

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    //V COMMENT: THIS IS HOW BACK BUTTON IS WRITTEN NOW

    return WillPopScope(
      onWillPop: () async {
        _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Reset',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // GestureDetector(
                //   onTap: () {
                //     _settingProvider.changeSheetElement(SheetList.restoreBike);
                //   },
                //   child: Container(
                //     padding: EdgeInsets.fromLTRB(16.w, 36.5.h, 16.w, 2.0.h),
                //     child: Column(
                //       children: [
                //         Row(
                //           children: [
                //             Text(
                //               "Reset Bike",
                //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                //             ),
                //             SizedBox(width: 3.w),
                //             SvgPicture.asset(
                //               "assets/icons/bluetooth_disconnect.svg",
                //               height: 18.0,
                //               width: 18.0,
                //             ),
                //           ],
                //         ),
                //         Padding(
                //           padding: EdgeInsets.fromLTRB(0.w, 2.w, 16.w, 12.w),
                //           child: Row(
                //             children: [
                //               Expanded(
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     Text(
                //                       "Restore the bike to its original state while",
                //                       style: TextStyle(fontSize: 14.sp, color: EvieColors.darkGrayishCyan),
                //                     ),
                //                     Text(
                //                       "keeping it connected to your account",
                //                       style: TextStyle(fontSize: 14.sp, color: EvieColors.darkGrayishCyan),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Padding(
                //                 padding: EdgeInsets.only(left: 8.w),
                //                 child: SvgPicture.asset(
                //                   "assets/buttons/next.svg",
                //                   height: 24.0,
                //                   width: 24.0,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                //
                //
                // Padding(
                //   padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
                //   child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                // ),


                GestureDetector(
                  onTap: () {
                    _settingProvider.changeSheetElement(SheetList.forgetBike);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 2.h),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Unlink Bike",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.h, 2.h, 16.h, 12.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Disconnect the bike from your account",
                                  style: TextStyle(fontSize: 14.sp, color: EvieColors.darkGrayishCyan),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: SvgPicture.asset(
                                  "assets/buttons/next.svg",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
                  child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                ),


        GestureDetector(
          onTap: () {
            _settingProvider.changeSheetElement(SheetList.fullReset);
            //showConnectBluetoothDialog (context);
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 2.0.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Full Reset",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 3.0),
                    SvgPicture.asset(
                      "assets/icons/bluetooth_disconnect.svg",
                      height: 18.0,
                      width: 18.0,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 2.h, 16.w, 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          children: [
                            Text(
                              "Completely reset and disconnect the bike from",
                              style: TextStyle(fontSize: 14.sp, color: EvieColors.darkGrayishCyan),
                            ),
                            Text(
                              " your account",
                              style: TextStyle(fontSize: 14.sp, color: EvieColors.darkGrayishCyan),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3.w),
                        child: SvgPicture.asset(
                          "assets/buttons/next.svg",
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                ),


             //RESET BIKE BUTTON BOTTOM COMMENTED OUT
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
            //     child: EvieButton(
            //       width: double.infinity,
            //       height: 48.h,
            //       child: Text(
            //         "Reset Bike",
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16.sp,
            //             fontWeight: FontWeight.w700),
            //       ),
            //       onPressed: () {
            //         showResetBike(context, _bikeProvider);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),]),
    ));
  }

}
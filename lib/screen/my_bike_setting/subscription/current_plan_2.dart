import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/function.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';

class CurrentPlan2 extends StatefulWidget {
  const CurrentPlan2({Key? key}) : super(key: key);

  @override
  _CurrentPlan2State createState() => _CurrentPlan2State();
}

class _CurrentPlan2State extends State<CurrentPlan2> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
       // _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'EV+ ',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h),
            child: _bikeProvider.isPlanSubscript == true ?
            calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0 && calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) <= 30 == true ?
                GestureDetector(
                  onTap: () {
                    _settingProvider.changeSheetElement(SheetList.proPlan);
                  },
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          height: 172.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xFFF4F4F4), // Background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/antitheft_2.svg",
                                      width: 48.w,
                                      height: 48.w,
                                    ),
                                    Container(
                                      child: SvgPicture.asset("assets/icons/yellow_dot.svg"),
                                      color: Colors.transparent,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "EV-Secure",
                                      style: EvieTextStyles.h2,
                                    ),
                                    Text(
                                      "Expiring in ${calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate())} Days (" + "${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}" + ")",
                                      style: EvieTextStyles.caption,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ) :
                GestureDetector(
                  onTap: () {
                    _settingProvider.changeSheetElement(SheetList.proPlan);
                  },
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          height: 172.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xFFF4F4F4), // Background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/antitheft_2.svg",
                                      width: 48.w,
                                      height: 48.w,
                                    ),
                                    Container(
                                      child: SvgPicture.asset("assets/icons/green_dot.svg"),
                                      color: Colors.transparent,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "EV-Secure",
                                      style: EvieTextStyles.h2,
                                    ),
                                    Text(
                                      "${_bikeProvider.currentBikePlanModel!.startAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.startAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.startAt?.toDate().year} - "
                                          "${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}",
                                      style: EvieTextStyles.caption,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ) :
            _bikeProvider.currentBikePlanModel != null && _bikeProvider.currentBikePlanModel?.expiredAt != null && _bikeProvider.isPlanSubscript == false ?
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _settingProvider.changeSheetElement(SheetList.proPlan);
                      },
                      child: Container(
                          width: double.infinity,
                          height: 172.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xFFF4F4F4), // Background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/add_button.svg",
                                      width: 48.w,
                                      height: 48.w,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add EV-Secure",
                                      style: EvieTextStyles.h2,
                                    ),
                                    Text(
                                      "Secure your ride with EV-Secure",
                                      style: EvieTextStyles.caption,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 19.h,),
                    Container(
                        width: double.infinity,
                        height: 172.h,
                      child : Opacity(
                        opacity: 0.4, // Apply opacity to the entire container
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xFFF4F4F4), // Background color without opacity
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/antitheft_2.svg",
                                      width: 48.w,
                                      height: 48.w,
                                    ),
                                    Container(
                                      child: SvgPicture.asset("assets/icons/grey_dot.svg"),
                                      color: Colors.transparent,
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "EV-Secure",
                                      style: EvieTextStyles.h2,
                                    ),
                                    Text(
                                      "Expired in " + "${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}",
                                      style: EvieTextStyles.caption,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ) :
                GestureDetector(
                  onTap: () {
                    _settingProvider.changeSheetElement(SheetList.proPlan);
                  },
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          height: 172.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xFFF4F4F4), // Background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 20.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/add_button.svg",
                                      width: 48.w,
                                      height: 48.w,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add EV-Secure",
                                      style: EvieTextStyles.h2,
                                    ),
                                    Text(
                                      "Secure your ride with EV-Secure",
                                      style: EvieTextStyles.caption,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                )
        ),
      ),
    );
  }
}
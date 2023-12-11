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

class CurrentPlan extends StatefulWidget {
  const CurrentPlan({Key? key}) : super(key: key);

  @override
  _CurrentPlanState createState() => _CurrentPlanState();
}

class _CurrentPlanState extends State<CurrentPlan> {

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
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:28.h),
                    child: Text("Current Plan", style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),),
                  ),
                 Text(_bikeProvider.isPlanSubscript == false ? "No Subscription" : "EV-Secure", style: EvieTextStyles.headline.copyWith(color: EvieColors.lightBlack)),
                  Text(_bikeProvider.isPlanSubscript == false ?"" : "${_bikeProvider.currentBikePlanModel!.startAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.startAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.startAt?.toDate().year} - "
                        "${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}",
                        style: EvieTextStyles.body18.copyWith(color:EvieColors.darkGrayishCyan)),
                  _bikeProvider.isPlanSubscript == false ? Container() : SizedBox(height:11.h,),

                  Visibility(
                    visible: _bikeProvider.isPlanSubscript == true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bikeProvider.isPlanSubscript == false ? "" : "Status",
                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                        ),
                        
                        ///Add expiring soon condition statement
                        Row(
                          children: [
                            Text(
                              _bikeProvider.isPlanSubscript == false ? "" : "Active",
                              style: EvieTextStyles.body16.copyWith(color: EvieColors.green),
                            ),

                            _bikeProvider.currentBikePlanModel != null ?
                            Visibility(
                              visible: calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0 &&
                                calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) <= 30,
                              child: Text(
                              " (Expiring in ${calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate())} Days)",
                              style: EvieTextStyles.body16.copyWith(color: EvieColors.green),
                              ),
                            ) : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _bikeProvider.isPlanSubscript == false ?
                  Container() :
                  Padding(
                    padding: EdgeInsets.only(left: 0, top: 10.h),
                    child: const EvieDivider(),
                  ),

                  _bikeProvider.currentBikePlanModel != null ?
                  Visibility(
                    visible: _bikeProvider.currentBikePlanModel != null && _bikeProvider.currentBikePlanModel?.expiredAt != null && _bikeProvider.isPlanSubscript == false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:28.h),
                          child: Text("Previously on", style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack, letterSpacing: 0.1.w),),
                        ),
                        Text("EV-Secure", style: EvieTextStyles.headline.copyWith(color: EvieColors.lightBlack)),
                        Text("${_bikeProvider.currentBikePlanModel!.startAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.startAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.startAt?.toDate().year} - "
                            "${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().day} ${monthsInYear[_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().month]} ${_bikeProvider.currentBikePlanModel!.expiredAt?.toDate().year}",
                            style: EvieTextStyles.body18.copyWith(color:EvieColors.darkGrayishCyan)),
                        Padding(
                          padding: EdgeInsets.only(top:19.h),
                          child: Text("Status",style: EvieTextStyles.body14.copyWith(color:EvieColors.darkGrayishCyan),),
                        ),

                        ///Active Color (0xff05A454)    Expired Color (0xffF42525)

                        Text("Expired",        style: EvieTextStyles.body16.copyWith(color: EvieColors.lightRed)),
                        SizedBox(height: 10.h,),

                        const EvieDivider(),

                      ],
                    ),
                  ) : Container(),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.screen_bottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(_bikeProvider.isPlanSubscript == false ? "Upgrade Plan" : "See Plan Detail",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                  ),
                  onPressed: () {
                    _settingProvider.changeSheetElement(SheetList.proPlan);
                    //changeToProPlanScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }
}
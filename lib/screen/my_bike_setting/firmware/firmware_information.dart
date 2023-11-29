import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/setting.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/text_column.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';
import 'package:lottie/lottie.dart' as lottie;

import 'package:intl/intl.dart';


///User profile page with user account information

class FirmwareInformation extends StatefulWidget {
  const FirmwareInformation({Key? key}) : super(key: key);

  @override
  _FirmwareInformationState createState() => _FirmwareInformationState();
}

class _FirmwareInformationState extends State<FirmwareInformation> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late FirmwareProvider _firmwareProvider;
  late SettingProvider _settingProvider;

  bool isExpanded = false;

  int totalSeconds = 105;

  StreamSubscription? stream;

  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _firmwareProvider = Provider.of<FirmwareProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    return WillPopScope(

      ///Only pop up dialog when updating
      onWillPop: () async {
        if(_firmwareProvider.isUpdating == true){
          bool shouldClose = true;
          await showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  EvieTwoButtonDialog(
                      title: Text("Exit Update?",
                        style:EvieTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      childContent: Text("App need to be stay open to complete upgrade."
                          " Any changes made during the update may not be saved if exit update.",
                        textAlign: TextAlign.center,
                        style: EvieTextStyles.body18,),
                      svgpicture: SvgPicture.asset(
                        "assets/images/people_search.svg",
                      ),
                      upContent: "Stay Updating",
                      downContent: "Cancel Update",
                      onPressedUp: () {
                        shouldClose = false;
                        Navigator.of(context).pop();
                      },
                      onPressedDown: () {
                        ///Dismiss dialog here
                        stream?.cancel();
                        _bluetoothProvider.disconnectDevice();
                        shouldClose = true;
                        Navigator.of(context).pop();
                        _settingProvider.changeSheetElement(SheetList.bikeSetting);
                      })
                  // EvieDoubleButtonDialog(
                  //     title: "Close this sheet?",
                  //     childContent: Text("Are you sure you want to close this sheet? This will end the upgrade.",
                  //       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
                  //     leftContent: "No",
                  //     rightContent: "Yes",
                  //     onPressedLeft: () {
                  //       shouldClose = false;
                  //       Navigator.of(context).pop();
                  //     },
                  //     onPressedRight: () {
                  //       _bluetoothProvider.firmwareUpgradeListener.onCancel;
                  //       shouldClose = true;
                  //       Navigator.of(context).pop();
                  //     })
        );
          return shouldClose;
        }else{
         //_settingProvider.changeSheetElement(SheetList.bikeSetting);
         return true;
        }
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Bike Software',
          onPressed: () async {
            // if(_firmwareProvider.isUpdating == true){
            //   showFirmwareUpdateQuit(context, stream);
            // }
            if(_firmwareProvider.isUpdating == true){
              showFirmwareUpdateQuit(context, stream, _settingProvider, _bluetoothProvider);
            }
            else{
              _settingProvider.changeSheetElement(SheetList.bikeSetting);
            }
          },
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(_firmwareProvider.isLatestFirmVer == true)...{
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w,13.h),
                          child: Text(
                            "Your bike software is up to date.",
                            style: EvieTextStyles.h2,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w,4.h),
                          child:TextColumn(
                              title: "Current Version",
                              body: _firmwareProvider.currentFirmVer ?? "Not available"),
                        ),

                        const AccountPageDivider(),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                          child:TextColumn(
                            title: "Last Update",
                            body:  DateFormat('MMMM d, yyyy').format(_firmwareProvider.latestFirmwareModel!.updated!.toDate()),
                          ),
                        ),

                        const AccountPageDivider(),

                        Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
                            child: Text(
                              "About This Update",
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            )
                        ),

                        Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(16.w,0, 40.w, 0),
                                        child: Text(
                                          isExpanded
                                              ? _firmwareProvider.latestFirmwareModel?.desc?.replaceAll("\\n", "\n") ?? ''
                                              : (_firmwareProvider.latestFirmwareModel?.desc?.replaceAll("\\n", "\n")?.substring(0, 155) ?? ''),
                                          softWrap: true,
                                          style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20.w, top: 10.5.h, bottom: 10.h),
                                    child: Row(
                                      children: [
                                        Text(
                                          isExpanded ? 'View Less' : 'View More',
                                          style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.w800, color: EvieColors.primaryColor),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.w),
                                          child: SvgPicture.asset(
                                              isExpanded ?
                                              "assets/buttons/up_mini.svg" : "assets/buttons/down_mini.svg"
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const AccountPageDivider(),
                      }

                      else...{

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                          child: Text(
                            "Better bike software available",
                            style:EvieTextStyles.h2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.w, 0.h, 16.w,13.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                "assets/buttons/bike_security_warning.svg",
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(width: 8.w,),
                              Expanded(
                                child: Text(
                                    "Stay close to your bike and keep app open to complete firmware update.",
                                    style: EvieTextStyles.body18
                                ),
                              ),
                            ],
                          ),
                        ),

                        Visibility(
                          visible: _firmwareProvider.isUpdating,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                              child: Column(
                                children: [
                                  LinearPercentIndicator(
                                    padding: EdgeInsets.zero,
                                    width: 355.w,
                                    animation: false,
                                    lineHeight: 4.h,
                                    animationDuration: 0,
                                    percent: _bluetoothProvider.fwUpgradeProgress,
                                    progressColor: EvieColors.primaryColor,
                                    backgroundColor: EvieColors.lightGray,
                                  ),

                                  Visibility(
                                    visible: _firmwareProvider.isUpdating,
                                    child: Padding(
                                      padding: EdgeInsets.only(left:0, right: 4.w, top :4.h),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Time remaining: ${intToTimeLeft(((_bluetoothProvider.fwUpgradeProgress * 100)*
                                              (totalSeconds/100)-totalSeconds).abs().toInt())}",
                                              style: EvieTextStyles.body12.copyWith(color: EvieColors.mediumBlack)

                                          ),

                                          Text(
                                              (_bluetoothProvider.fwUpgradeProgress * 100).toStringAsFixed(0) + "%",
                                              style: EvieTextStyles.body12.copyWith(color: EvieColors.mediumBlack)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w,4.h),
                          child:TextColumn(
                              title: "Current Version",
                              body: _firmwareProvider.currentFirmVer ?? "None"),
                        ),
                        const AccountPageDivider(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                          child:TextColumn(
                            title: "Last Update",
                            body: DateFormat('MMMM d, yyyy').format(_firmwareProvider.latestFirmwareModel!.updated!.toDate()),
                          ),
                        ),
                        const AccountPageDivider(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                          child: Text(
                            "What's New",
                            style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(16.w,0,40.w,0),
                                    child: Text(
                                      isExpanded
                                          ? _firmwareProvider.latestFirmwareModel?.desc?.replaceAll("\\n", "\n") ?? ''
                                          : (_firmwareProvider.latestFirmwareModel?.desc?.replaceAll("\\n", "\n")?.substring(0, 155) ?? ''),
                                      softWrap: true,
                                      style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 20.w, top: 10.5.h, bottom: 10.h),
                                child: Row(
                                  children: [
                                    Text(
                                      isExpanded ? 'View Less' : 'View More',
                                      style: TextStyle(color: EvieColors.primaryColor),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: SvgPicture.asset(
                                          isExpanded ?
                                          "assets/buttons/up_mini.svg" : "assets/buttons/down_mini.svg"
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const AccountPageDivider(),
                      },
                      SizedBox(
                        height: 170.h,
                      )
                    ],
                  ),
                  !_firmwareProvider.isLatestFirmVer && _firmwareProvider.isUpdating == false ?
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, EvieLength.screen_bottom),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                          "Download and Update",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                      ),
                      onPressed: () {
                        //showFirmwareUpdate(context, _firmwareProvider, stream, _bluetoothProvider, _settingProvider);
                        showSoftwareUpdate(context, _firmwareProvider, stream, _bluetoothProvider, _settingProvider);
                      },
                    ),
                  ) :
                  !_firmwareProvider.isLatestFirmVer && _firmwareProvider.isUpdating == true ?
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, EvieLength.screen_bottom),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      backgroundColor: EvieColors.lightPurple,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/buttons/update_loading.svg',
                            width: 24.w,
                            height: 24.h,
                            //color: EvieColors.green,
                          ),
                          Text(
                            "Updating",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),

                      onPressed: () {
                        _settingProvider.changeSheetElement(SheetList.bikeSetting);
                      },
                    ),
                  ) :
                  Container(),
                ],
              ),
            ),
          ],
        ),),
    );
  }

  String intToTimeLeft(int value) {
    int h, m, s;

    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);

    String hourLeft = h.toString().length < 2 ? "0" + h.toString() : h.toString();
    String minuteLeft = m.toString().length < 2 ? "0" + m.toString() : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0" + s.toString() : s.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }
}




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

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';


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

  int totalSeconds = 105;

  StreamSubscription? stream;


  @override
  void initState() {
    Wakelock.enable();
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
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
      onWillPop: () async {
        if(_firmwareProvider.isUpdating == true){}else{
         _settingProvider.changeSheetElement(SheetList.bikeSetting);
        }
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Firmware Information',
          onPressed: () {
            if(_firmwareProvider.isUpdating == true){

            }else{
              _settingProvider.changeSheetElement(SheetList.bikeSetting);
            }
          },
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if(_firmwareProvider.isLatestFirmVer == true)...{
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                      child: Text(
                        "Your firmware is up to date",
                        style: EvieTextStyles.h2,
                      ),
                    ),
                  Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                    child:TextColumn(
                        title: "Current Version",
                        body: _firmwareProvider.currentFirmVer ?? "Not available"),
                  ),
                    const AccountPageDivider(),
                  Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                    child:TextColumn(
                        title: "What's New",
                        body: _firmwareProvider.latestFirmwareModel?.desc ?? "Not available"),
                  ),
                    const AccountPageDivider(),
                  }

                  else...{

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                      child: Text(
                        "Better Firmware available",
                        style:EvieTextStyles.h2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            "assets/buttons/bike_security_warning.svg",
                            height: 24.h,
                            width: 24.w,
                          ),
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
                                  padding: EdgeInsets.only(left:4.w, right: 4.w, top :4.h),
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
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                    child:TextColumn(
                        title: "Update Version",
                        body: _firmwareProvider.latestFirmVer ?? "None"),
                  ),
                    const AccountPageDivider(),
                  Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                    child:TextColumn(
                        title: "Current Version",
                        body: _firmwareProvider.currentFirmVer ?? "None"),
                  ),
                     const AccountPageDivider(),
                  Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child: TextColumn(
                        title: "What's New",
                        body: _firmwareProvider.latestFirmwareModel?.desc ?? "None"),
                  ),
                    const AccountPageDivider(),
                  },

                  SizedBox(
                    height: 150.h,
                  )
                ],
              ),
            ),

            Visibility(
              visible: !_firmwareProvider.isLatestFirmVer && _firmwareProvider.isUpdating == false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                  child: EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Download and Update",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                    ),
                    onPressed: () {
                      showFirmwareUpdate(context, _firmwareProvider, stream, _bluetoothProvider);
                    },
                  ),
                ),
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




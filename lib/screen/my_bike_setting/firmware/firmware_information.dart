import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/text_column.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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

  bool isUpdating = false;

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

    return WillPopScope(
      onWillPop: () async {
        if(isUpdating){
          SmartDialog.show(
              widget: EvieDoubleButtonDialog(
                  title: "Quit Update",
                  childContent: Text("App must stay open to complete update. Are you sure you want to quit?"),
                  leftContent: "Cancel Update",
                  rightContent: "Stay",
                  onPressedLeft: (){
                    SmartDialog.dismiss();
                    changeToNavigatePlanScreen(context);
                    stream?.cancel();
                  },
                  onPressedRight: (){
                    SmartDialog.dismiss();
                  }));
        }else{
          changeToNavigatePlanScreen(context);
        }
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Firmware Information',
          onPressed: () {
            if(isUpdating){
              SmartDialog.show(
                  widget: EvieDoubleButtonDialog(
                      title: "Quit Update",
                      childContent: Text("App must stay open to complete update. Are you sure you want to quit?"),
                      leftContent: "Cancel Update",
                      rightContent: "Stay",
                      onPressedLeft: (){
                        SmartDialog.dismiss();
                        changeToNavigatePlanScreen(context);
                        stream?.cancel();
                      },
                      onPressedRight: (){
                        SmartDialog.dismiss();
                      }));
            }else{
              changeToNavigatePlanScreen(context);
            }
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(_firmwareProvider.isLatestFirmVer == true)...{
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                    child: Text(
                      "Your firmware is up to date",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
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
                      "Firmware update available",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                    child: Text(
                      "Stay close to your bike and keep app open to complete firmware update.",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    ),
                  ),

                  Visibility(
                    visible: isUpdating,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 20.h, 0, 20.h),
                        child: Column(
                          children: [
                            LinearPercentIndicator(
                              width: 360.w,
                              animation: false,
                              lineHeight: 4.h,
                              animationDuration: 0,
                              percent: _bluetoothProvider.fwUpgradeProgress,
                              progressColor: EvieColors.primaryColor,
                              backgroundColor: EvieColors.lightGray,
                            ),

                            Visibility(
                              visible: isUpdating,
                              child: Padding(
                                padding: EdgeInsets.only(left:16.w, right: 16.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(  "Time remaining: ${intToTimeLeft(((_bluetoothProvider.fwUpgradeProgress * 100)*
                                        (totalSeconds/100)-totalSeconds).abs().toInt())}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: EvieColors.mediumBlack,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                    Text(
                                      (_bluetoothProvider.fwUpgradeProgress * 100).toStringAsFixed(0) + "%",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: EvieColors.mediumBlack,
                                        fontWeight: FontWeight.w400,
                                      ),
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
                child:TextColumn(
                      title: "What's New",
                      body: _firmwareProvider.latestFirmwareModel?.desc ?? "None"),
                ),
                  const AccountPageDivider(),
                },
              ],
            ),

            Visibility(
              visible: _bluetoothProvider.iotInfoModel?.firmwareVer != null &&
                  _bluetoothProvider.iotInfoModel?.firmwareVer != _firmwareProvider.currentFirmVer &&
                  isUpdating == false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                  child: EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Download and Update",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      SmartDialog.show(
                          widget:   EvieDoubleButtonDialog(
                          title: "Firmware update",
                          childContent: Text(
                            "Stay close with your bike and make sure keeping EVIE app opened during firmware update. "
                                "Firmware update will ne disrupted if you close the app.",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          leftContent: "Later",
                          rightContent: "Update Now",
                          onPressedLeft: (){
                            SmartDialog.dismiss();
                          },
                          onPressedRight: () async {

                            SmartDialog.dismiss();
                            SmartDialog.showLoading(backDismiss: false);

                            Reference ref = FirebaseStorage.instance.refFromURL(_firmwareProvider.latestFirmwareModel!.url);
                            File file = await _firmwareProvider.downloadFile(ref);

                            stream = _bluetoothProvider.firmwareUpgradeListener.stream.listen((firmwareUpgradeResult) {
                              if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.startUpgrade) {
                                SmartDialog.dismiss();
                              }
                              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgrading) {
                                Future.delayed(Duration.zero, () {
                                  isUpdating = true;
                                });
                              }
                              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeSuccessfully) {
                                ///go to success page
                                 isUpdating = false;
                                 stream?.cancel();
                                _firmwareProvider.uploadFirmVerToFirestore("57_V${_firmwareProvider.latestFirmVer!}");
                                changeToFirmwareUpdateCompleted(context);
                              }
                              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeFailed) {
                                isUpdating = false;
                                stream?.cancel();
                                changeToFirmwareUpdateFailed(context);
                              }
                            });

                            _bluetoothProvider.startUpgradeFirmware(file);

                          })
                      );
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




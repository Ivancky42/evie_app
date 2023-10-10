import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/firmware_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/api/snackbar.dart';
import 'package:evie_test/api/toast.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_bike_recovered.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_dialog.dart';
import 'package:evie_test/test/widget_test.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_radio_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../screen/my_bike_setting/my_bike_function.dart';
import '../widgets/evie_checkbox.dart';
import '../widgets/evie_divider.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_progress_indicator.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_slider_button.dart';
import '../widgets/evie_switch.dart';
import '../widgets/evie_textform.dart';
import 'colours.dart';
import 'model/rfid_model.dart';
import 'navigator.dart';

showQuitApp(){
  SmartDialog.show(
      widget: EvieDoubleButtonDialog(
          title: "Close this app?",
          childContent: Text("Are you sure you want to close this App?", style: EvieTextStyles.body18,),
          leftContent: "No",
          rightContent: "Yes",
          onPressedLeft: () {
            SmartDialog.dismiss();
          },
          onPressedRight: () {
            SystemNavigator.pop();
          }));
}

showCannotClose(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "This page cannot be close",
          content: "This page cannot be close",
          rightContent: "Ok",
          onPressedRight: () {
            SmartDialog.dismiss();
            // SystemNavigator.pop();
          }));
}

showCloseSheet(){

}

showResentEmailSuccess(CurrentUserProvider currentUserProvider){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Email Resent",
          content: "We've resend email to ${currentUserProvider.currentUserModel?.email ?? "your account."} Do check on spam mailbox too!",
          rightContent: "Ok",
          onPressedRight:(){SmartDialog.dismiss();})
  );
}

showResentEmailFailed(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "You need to wait 30 seconds before sending another email",
          rightContent: "Ok",
          onPressedRight:(){SmartDialog.dismiss();})
  );
}

showWhereToFindQRCode(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Where to find QR Code?",
          widget:  SvgPicture.asset(
              "assets/images/allow_camera.svg",
            ),
          content: "QR code can be found on the back side of greeting card.",
          rightContent: "Ok",
          onPressedRight:(){SmartDialog.dismiss();})
  );
}

showWhereToFindCodes(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Where to find these?",
          widget:  SvgPicture.asset(
            "assets/images/where_to_find_these.svg",
          ),
          content: "The Serial Number and Validation Key can be found on the back of your ownership card.",
          rightContent: "Ok",
          onPressedRight:(){SmartDialog.dismiss();})
  );
}

showBackToLogin(context, BikeProvider _bikeProvider, AuthProvider _authProvider){
  SmartDialog.show(
      widget:
      EvieDoubleButtonDialog(
          title: "Back to Login Page?",
          childContent: Text("Are you sure you want to sign out and back to login page?", style: EvieTextStyles.body18),
          leftContent: "No",
          rightContent: "Yes",
          onPressedLeft: (){SmartDialog.dismiss();},
          onPressedRight: () async {
            SmartDialog.dismiss();
            SmartDialog.showLoading();
            await _authProvider.signOut(context).then((result) async {
              if(result == true){
                SmartDialog.dismiss(status: SmartStatus.loading);
                changeToWelcomeScreen(context);
                SmartDialog.dismiss();
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text('Signed out'),
                    duration: Duration(
                        seconds: 2),),
                );
              }
              else{
                SmartDialog.dismiss(status: SmartStatus.loading);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text('Error, Try Again'),
                    duration: Duration(
                        seconds: 4),),
                );
              }
            });
          }));
}

showAddBikeNameSuccess(context, BikeProvider bikeProvider, bikeNameController){
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Success",
          content: "Update successful",
          rightContent: "Ok",
          onPressedRight: (){
            SmartDialog.dismiss();
            if(bikeProvider.isAddBike == true){
              bikeProvider.setIsAddBike(false);
              changeToCongratsBikeAdded(context, bikeNameController);
            }else{
              // changeToTurnOnNotificationsScreen(context);
              changeToCongratsBikeAdded(context, bikeNameController);
            }
          }
          ));
}

showAddBikeNameFailed(){
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Not Success",
          content: "An error occur, try again",
          rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

showFailed(){
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Not Success",
          content: "An error occur, try again",
          rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

showBluetoothNotTurnOn() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Bluetooth is off, please turn on your bluetooth",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          }));
}

showBluetoothNotSupport() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Bluetooth unsupported",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog
                .dismiss();
          }));
}

showBluetoothNotAuthorized() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Bluetooth permission is off, turn on bluetooth permission in setting",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            //OpenSettings.openBluetoothSetting();
            openAppSettings();
           ///Redirect user to enable bluetooth permission.
          }));
}

showLocationServiceDisable() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialog(
          title: "Disable",
          content: "Location service is disabled, please enable your location service in settings",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            openAppSettings();
          }));
}

showCameraDisable() {
  SmartDialog.dismiss();
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialog(
          title: "Disable",
          content: "Camera is disabled, please enable your camera service in settings",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            openAppSettings();
          }));
}

showNotificationNotAuthorized() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Notification permission is off, turn on notification permission in setting",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            openAppSettings();
            ///Redirect user to enable bluetooth permission.
          }));
}

showConnectDialog(BluetoothProvider bluetoothProvider, BikeProvider bikeProvider) async {
   await SmartDialog.show(
      widget: EvieDoubleButtonDialog(
      title: "Please Connect Your Bike",
      childContent: Text(
        "Please connect your bike to access the function...?",
        style: TextStyle(fontSize: 16.sp,
            fontWeight: FontWeight.w400),),
      leftContent: "Cancel",
      rightContent: "Connect Bike",
      onPressedLeft: () async {
        SmartDialog.dismiss();
      },
      onPressedRight: ()async {
        SmartDialog.dismiss();
        checkBleStatusAndConnectDevice(bluetoothProvider, bikeProvider);
      })
  );
}

showEditBikeNameDialog(_formKey, _bikeNameController, _bikeProvider) {
  SmartDialog.show(
      widget: Form(
        key: _formKey,
        child: EvieDoubleButtonDialog(
            title: "Name Your Bike",
            childContent: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:  EdgeInsets.fromLTRB(0.h, 12.h, 0.h, 8.h),
                    child: EvieTextFormField(
                      controller: _bikeNameController,
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      hintText: _bikeProvider.currentBikeModel?.deviceName ?? "Bike Name",
                      labelText: "Bike Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bike name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 25.h),
                    child: Text("100 Maximum Character", style: TextStyle(fontSize: 12.sp, color: Color(0xff252526)),),
                  ),
                ],
              ),
            ),
            leftContent: "Cancel",
            rightContent: "Save",
            onPressedLeft: (){SmartDialog.dismiss();},
            onPressedRight: (){
              if (_formKey.currentState!.validate()) {

                ///For keyboard un focus
                FocusManager.instance.primaryFocus?.unfocus();

                _bikeProvider.updateBikeName(_bikeNameController.text.trim()).then((result){
                  SmartDialog.dismiss();
                  if(result == true){
                    showUpdateSuccessDialog();
                  } else{
                    showUpdateFailedDialog();
                  }
                });
              }

            }),
      ));
}

showUpdateSuccessDialog() {
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Success",
          content: "Update successful",
          rightContent: "Ok",
          onPressedRight: (){
            SmartDialog.dismiss();
          } ));
}

showUpdateFailedDialog() {
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Not Success",
          content: "An error occur, try again",
          rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

Future<String> showDeleteShareBikeUser(BikeProvider _bikeProvider, int index) async {
  String result = 'none';
  await SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Remove Pal",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you would like to remove " + _bikeProvider.bikeUserDetails.values.elementAt(index).name! + " from " + _bikeProvider.currentBikeModel!.pedalPalsModel!.name! + "?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Remove",
        downContent: "Cancel",
        onPressedUp: () async {
          result = 'action';
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );

  return result;
}

Future<String> showRemoveAllPals(BuildContext context, String teamName) async {
  String result = 'none';
  await SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Remove All PedalPals?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you would like to remove all PedalPals from " + teamName + "?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Confirm",
        downContent: "Cancel",
        onPressedUp: () async {
          result = 'action';
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );

  return result;
}

showDeleteNotificationSuccess(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Deleted",
          content: "Notification deleted",
          rightContent: "OK",
          onPressedRight: ()=>SmartDialog.dismiss()
      ));
}

showDeleteNotificationFailed(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Failed",
          content: "Try again",
          rightContent: "OK",
          onPressedRight: ()=>SmartDialog.dismiss()
      ));
}

showFirmwareUpdate(context, FirmwareProvider firmwareProvider, StreamSubscription? stream, BluetoothProvider bluetoothProvider, SettingProvider settingProvider){
  SmartDialog.show(
      widget:   EvieDoubleButtonDialog(
          title: "Better bike software update",
          childContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get more out of your EVIE bike with the latest firmware update. Smoother ride, "
                    "longer battery, fewer bugs. Charge bike and ensure stable Wi-Fi connection before updating. ",
                style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumBlack),
              ),
              SizedBox(height: 14.h),
              Text("Tip: Stay connected during update.",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.mediumBlack),
                  textAlign: TextAlign.left,
                ),
              SizedBox(height: 14.h),
            ],
          ),
          leftContent: "Later",
          rightContent: "Update Now",
          onPressedLeft: (){
            SmartDialog.dismiss();
          },
          onPressedRight: () async {

            SmartDialog.dismiss();
            SmartDialog.showLoading(backDismiss: false);

            Reference ref = FirebaseStorage.instance.refFromURL(firmwareProvider.latestFirmwareModel!.url);
            File file = await firmwareProvider.downloadFile(ref);

            stream = bluetoothProvider.firmwareUpgradeListener.stream.listen((firmwareUpgradeResult) {
              if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.startUpgrade) {
              }
              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgrading) {
                SmartDialog.dismiss();
                Future.delayed(Duration.zero, () {
                  firmwareProvider.changeIsUpdating(true);
                });
              }
              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeSuccessfully) {
                ///go to success page
                firmwareProvider.changeIsUpdating(false);
                stream?.cancel();
                firmwareProvider.uploadFirmVerToFirestore("57_V${firmwareProvider.latestFirmVer!}");
                settingProvider.changeSheetElement(SheetList.firmwareUpdateCompleted);
              }
              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeFailed) {
                firmwareProvider.changeIsUpdating(false);
                stream?.cancel();
                settingProvider.changeSheetElement(SheetList.firmwareUpdateFailed);
              }else{}
            });

            bluetoothProvider.startUpgradeFirmware(file);

          })
  );
}

showFirmwareUpdateQuit(context, StreamSubscription? stream){
  SmartDialog.show(
      keepSingle: true,
      backDismiss: false,
      widget: EvieDoubleButtonDialog(
          title: "Exit Update?",
          childContent: Text("App need to be stay open to complete upgrade."
              " Any changes made during the update may not be saved if exit update."),
          leftContent: "Cancel Update",
          rightContent: "Stay Updating",
          onPressedLeft: (){
            SystemNavigator.pop();
            SmartDialog.dismiss();

            showBikeSettingSheet(context);
            stream?.cancel();
          },
          onPressedRight: (){
            SmartDialog.dismiss();
          }));
}

showCannotUnlockBike(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Cannot unlock bike, please place the phone near the bike and try again.",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          }));
}

showFilterTreat(BuildContext context, BikeProvider bikeProvider, setState){
  
  bool warning = bikeProvider.threatFilterArray.contains("warning") ? true : false;
  bool fall = bikeProvider.threatFilterArray.contains("fall") ? true : false;
  bool danger = bikeProvider.threatFilterArray.contains("danger") ? true : false;
  bool crash = bikeProvider.threatFilterArray.contains("crash") ? true : false;

  int _selectedRadio = -1;

  ///all, today, yesterday, last7days, custom
  ThreatFilterDate pickedDate = ThreatFilterDate.all;
  DateTimeRange? pickedDateRange;
  DateTime? pickedDate1;
  DateTime? pickedDate2;

  SmartDialog.show(
      useSystem: true,
      widget: StatefulBuilder(
          builder: (context, setState){
        return    EvieDoubleButtonDialog(
            title: "Filter Bike Status",
            childContent: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Movement Detected", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                      onChanged: (value) {
                        setState(() {
                          warning = value!;
                        });
                      },
                        value: warning,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Fall Detected", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            fall = value!;
                          });
                        },
                        value: fall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Theft Attempt", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            danger = value!;
                          });
                        },
                        value: danger,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Crash Alert", style: EvieTextStyles.body18,
                      ),
                      EvieCheckBox(
                        onChanged: (value) {
                          setState(() {
                            crash = value!;
                          });
                        },
                        value: crash,
                      ),
                    ],
                  ),

                  ///Switch
                  // EvieSwitch(
                  //   text: "Movement Detected",
                  //   value: warning,
                  //   thumbColor: EvieColors.thumbColorTrue,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       warning = value!;
                  //     });
                  //   },
                  // ),
                  // EvieSwitch(
                  //   text: "Fall Detected",
                  //   value: fall,
                  //   thumbColor: EvieColors.thumbColorTrue,
                  //   onChanged: (value) async {
                  //     setState(() {
                  //       fall = value!;
                  //     });
                  //   },
                  // ),
                  //
                  // EvieSwitch(
                  //   text: "Theft Attempt",
                  //   value: danger,
                  //   thumbColor: EvieColors.thumbColorTrue,
                  //   onChanged: (value) async {
                  //     setState(() {
                  //       danger = value!;
                  //     });
                  //   },
                  // ),
                  //
                  // EvieSwitch(
                  //   text: "Crash Alert",
                  //   value: crash,
                  //   thumbColor: EvieColors.thumbColorTrue,
                  //   onChanged: (value) async {
                  //     setState(() {
                  //       crash = value!;
                  //     });
                  //   },
                  // ),

                  Text("Filter Date", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),),

                  Divider(
                    thickness: 0.5.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),

                  EvieRadioButton(
                      text: "Today",
                      value: 0,
                      groupValue: _selectedRadio,
                      onChanged: (value){
                        setState(() {
                          _selectedRadio = value;
                          pickedDate = ThreatFilterDate.today;
                          pickedDate1 != null ? pickedDate1 = null : -1;
                          pickedDate2 != null ? pickedDate2 = null : -1;
                        });
                      }),

                  EvieRadioButton(
                      text: "Yesterday",
                      value: 1,
                      groupValue: _selectedRadio,
                      onChanged: (value){
                        setState(() {
                          _selectedRadio = value;
                          pickedDate =ThreatFilterDate.yesterday;
                          pickedDate1 != null ? pickedDate1 = null : -1;
                          pickedDate2 != null ? pickedDate2 = null : -1;
                        });
                      }),

                  EvieRadioButton(
                      text: "Last 7 days",
                      value: 2,
                      groupValue: _selectedRadio,
                      onChanged: (value){

                        setState(() {
                          _selectedRadio = value;
                          pickedDate = ThreatFilterDate.last7days;
                          pickedDate1 != null ? pickedDate1 = null : -1;
                          pickedDate2 != null ? pickedDate2 = null : -1;
                        });
                      }),

                  EvieRadioButton(
                      text: "Custom Date",
                      value: 3,
                      groupValue: _selectedRadio,
                      onChanged: (value){
                        setState(() {
                          _selectedRadio = value;
                          pickedDate = ThreatFilterDate.custom;
                        });
                      }),

                  Visibility(
                    visible: _selectedRadio == 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: EvieButton_PickDate(
                            onPressed: () async {
                              if(_selectedRadio == 3){

                                var range = await showDateRangePicker(
                                      context: context,
                                      initialDateRange: pickedDateRange,
                                      firstDate: DateTime(DateTime.now().year-2),
                                      lastDate: pickedDate2 ?? DateTime.now(),
                                  builder: (context, child) {
                                        return Theme(data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: EvieColors.primaryColor,

                                            ), ), child: child!);
                                      },
                                );

                                // pickedDate1 = await showDatePicker(
                                //     context: context,
                                //     initialDate: bikeProvider.threatFilterDate1 ?? pickedDate2 ?? DateTime.now(),
                                //     firstDate: DateTime(DateTime.now().year-2),
                                //     lastDate: pickedDate2 ?? DateTime.now(),
                                //     builder: (context, child) {
                                //       return Theme(data: Theme.of(context).copyWith(
                                //           colorScheme: ColorScheme.light(
                                //             primary: EvieColors.primaryColor,
                                //
                                //           ), ), child: child!);
                                //     },
                                // );
                                //
                                if(range != null){
                                  pickedDateRange = range;
                                  pickedDate1 = range.start;
                                  pickedDate2 = range.end;
                                 // if (pickedDate1 != null) {
                                    setState(() {
                                      pickedDate1 = pickedDate1;
                                      pickedDate2 = pickedDate2;
                                    });
                                  //}
                                }

                              }
                            },
                            child: Row(
                              children: [
                                Text(pickedDate1 != null ? "${monthsInYear[pickedDate1!.month]} ${pickedDate1!.day} ${pickedDate1!.year}": "",
                                  style: TextStyle(color: EvieColors.darkGrayishCyan),),
                                SvgPicture.asset(
                                  "assets/buttons/calendar.svg",
                                  height: 24.h,
                                  width: 24.w,
                                ),
                              ],
                            ),),
                        ),

                     // Expanded(child: const Text("-"),),

                      Expanded(
                        child:  EvieButton_PickDate(
                        width: 155.w,
                        onPressed: () async {
                          if(_selectedRadio == 3){

                            var range = await showDateRangePicker(
                              context: context,
                              initialDateRange: pickedDateRange,
                              firstDate: DateTime(DateTime.now().year-2),
                              lastDate: pickedDate2 ?? DateTime.now(),
                              builder: (context, child) {
                                return Theme(data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: EvieColors.primaryColor,

                                  ), ), child: child!);
                              },
                            );

                            // pickedDate2 = await showDatePicker(
                            //     context: context,
                            //     initialDate: bikeProvider.threatFilterDate2 ?? pickedDate1 ?? DateTime.now(),
                            //     firstDate: pickedDate1 ?? DateTime(DateTime.now().year-2),
                            //     lastDate: DateTime.now(),
                            //   builder: (context, child) {
                            //     return Theme(data: Theme.of(context).copyWith(
                            //       colorScheme: ColorScheme.light(
                            //         primary: EvieColors.primaryColor,
                            //
                            //       ), ), child: child!);
                            //   },
                            // );

                            if(range != null){
                              pickedDateRange = range;
                              pickedDate1 = range.start;
                              pickedDate2 = range.end;
                              // if (pickedDate1 != null) {
                              setState(() {
                                pickedDate1 = pickedDate1;
                                pickedDate2 = pickedDate2;
                              });
                              //}
                            }
                            // if (pickedDate2 != null) {
                            //   setState(() {
                            //     pickedDate2 = pickedDate2;
                            //   });
                            // }
                          }
                        },
                        child: Row(
                          children: [
                            Text(pickedDate2 != null ? "${monthsInYear[pickedDate2!.month]} ${pickedDate2!.day} ${pickedDate2!.year}": "",
                              style: const TextStyle(color: EvieColors.darkGrayishCyan),),
                            SvgPicture.asset(
                              "assets/buttons/calendar.svg",
                              height: 24.h,
                              width: 24.w,
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],),
                  ),
                ],
              ),
            ),
            leftContent: "Cancel",
            rightContent: "Apply Filter",
            onPressedLeft: (){
              SmartDialog.dismiss();
            },
            onPressedRight: () async {

              List<String> filter = [];

              if(warning == true){filter.add("warning");}
              if(fall == true){filter.add("fall");}
              if(danger == true){filter.add("danger");}
              if(crash == true){filter.add("crash");}

              if(pickedDate == ThreatFilterDate.custom){
                if(pickedDate1 != null && pickedDate2 != null){
                  await bikeProvider.applyThreatFilter(filter,pickedDate,pickedDate1, pickedDate2);
                  SmartDialog.dismiss();
                }else{
                  showNoSelectDate();
                }
              }else{
                await bikeProvider.applyThreatFilter(filter, pickedDate, pickedDate1, pickedDate2);
                SmartDialog.dismiss();
              }
            });
      })
  );
}

showNoSelectDate(){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Please select the date",
          content: "Date not selected",
          rightContent: "Ok",
          onPressedRight: (){
            SmartDialog.dismiss();
          }));
}

showResetBike(BuildContext context, BikeProvider bikeProvider){
  SmartDialog.show(widget: EvieDoubleButtonDialog(
      title: "Reset biker",
      childContent: Text("Are you sure you want to reset bike?"),
      leftContent: "Cancel",
      rightContent: "Yes",
      onPressedLeft: (){SmartDialog.dismiss();},
      onPressedRight: () async {
        SmartDialog.dismiss();
        SmartDialog.showLoading(backDismiss: false);
       var result =  await bikeProvider.resetBike(bikeProvider.currentBikeModel!.deviceIMEI!);

       if(result == true){
         SmartDialog.dismiss();
         SmartDialog.show(widget: EvieSingleButtonDialog(
             title: "Success",
             content: "Bike reset",
             rightContent: "Ok",
             onPressedRight: (){
               SmartDialog.dismiss();
             changeToUserHomePageScreen(context);}));
       }else{
         SmartDialog.dismiss();
         SmartDialog.show(widget: EvieSingleButtonDialog(
             title: "Failed",
             content: "Try again",
             rightContent: "Ok",
             onPressedRight: (){
               SmartDialog.dismiss();}));
       }
      }));
}

showErrorChangeDetectionSensitivity(){
  SmartDialog.show(widget: EvieSingleButtonDialog(
      title: "Error",
      content: "Error update motion sensitivity",
      rightContent: "Ok",
      onPressedRight: (){SmartDialog.dismiss();}));
}

showAddEVKeyFailed(BuildContext context){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Error upload rfid to firestore",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            //changeToEVAddFailed(context);
          }));
}

showUploadEVKeyToFirestoreFailed(BuildContext context){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Error",
          content: "Error upload rfid to firestore",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();

          }));
}

showEVKeyExistAndUploadToFirestore(BuildContext context, String rfidNumber){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Success",
          content: "Card data uploaded",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();

          }));
}

showAddEVKeySuccess(BuildContext context, String rfidNumber){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Success",
          content: "Card added",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();

          }));
}


showAddEVKeyNameSuccess(BuildContext context){
  SmartDialog.show(
      widget:EvieSingleButtonDialog(
          title: "Success",
          content: "Name uploaded",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          }));
}

showDeleteEVKeyFailed(BuildContext context, String error){
  SmartDialog.show(
      widget: EvieSingleButtonDialog(
          title: "Error deleting EV-Card",
          content: error,
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          }));
}

showRemoveEVKeyDialog (BuildContext context, RFIDModel rfidModel, BikeProvider _bikeProvider, BluetoothProvider _bluetoothProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Remove EV-Key",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you would like to remove " + rfidModel.rfidName! + '?',
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Remove",
        downContent: "Cancel",
        onPressedUp: () {
          SmartDialog.dismiss();

          SmartDialog.showLoading(msg: "Removing EV Key....");
          StreamSubscription? deleteRFIDStream;
          deleteRFIDStream = _bluetoothProvider
              .deleteRFID(rfidModel.rfidID!)
              .listen((deleteRFIDStatus) {

            SmartDialog.dismiss(status: SmartStatus.loading);

            if (deleteRFIDStatus.result == CommandResult.success) {
              deleteRFIDStream?.cancel();
              final result = _bikeProvider.deleteRFIDFirestore(rfidModel.rfidID!);
              if (result == true) {
                showTextToast("${rfidModel.rfidName} have been removed from your EV-Key list.");
                SmartDialog.dismiss(status: SmartStatus.loading);
              } else {
                showDeleteEVKeyFailed(context, "Error removing EV Card");
              }
            }
          }, onError: (error) {
            deleteRFIDStream?.cancel();
            SmartDialog.dismiss(status: SmartStatus.loading);
            showDeleteEVKeyFailed(context, error.toString());
          });
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );
}

showRemoveAllEVKeyDialog (BuildContext context, BikeProvider  _bikeProvider, BluetoothProvider _bluetoothProvider, SettingProvider _settingProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Remove All EV-Key?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you would like to remove all EV-Key?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Confirm",
        downContent: "Cancel",
        onPressedUp: () async {
          SmartDialog.dismiss();
          SmartDialog.showLoading(msg: "Removing all EV-Key....");
          List keysToDelete = _bikeProvider.rfidList.keys.toList();
          for (var key in keysToDelete) {
            final rfidModel = _bikeProvider.rfidList[key];
            _bluetoothProvider.deleteRFID(key);
            await _bikeProvider.deleteRFIDFirestore(key);
            await Future.delayed(Duration(seconds: 2));
          }
          SmartDialog.dismiss(status: SmartStatus.loading);
          showTextToast('Successfully removed all the EV-Key from your bike.');
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );
}


showExitOrbitalAntiTheft(BuildContext context){
  SmartDialog.show(
      widget: EvieDoubleButtonDialog(
          title: "Exit Orbital Anti-theft? 2",
          childContent: Text("Are you sure you would like to exit orbital anti-theft page?",style: EvieTextStyles.body18,),
          leftContent: "Cancel",
          rightContent: "OK",
        onPressedLeft: (){
            SmartDialog.dismiss();
        },
          onPressedRight: () {
            SmartDialog.dismiss();
            changeToUserHomePageScreen(context);
          },
          ));
}

showMeasurementUnit(SettingProvider settingProvider){

  int _selectedRadio = 0;

  if(settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem){
    _selectedRadio = 0;
  }else if(settingProvider.currentMeasurementSetting == MeasurementSetting.imperialSystem){
    _selectedRadio = 1;
  }else{
    _selectedRadio = 0;
  }
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Measurement Unit",
         widget: Column(
           children: [
             EvieRadioButton(
                 text: "Metric System (meters)",
                 value: 0,
                 groupValue: _selectedRadio,
                 onChanged: (value){
                   settingProvider.changeMeasurement(MeasurementSetting.metricSystem);
                   SmartDialog.dismiss();
                 }),

             EvieDivider(),

             EvieRadioButton(
                 text: "Imperial System (miles)",
                 value: 1,
                 groupValue: _selectedRadio,
                 onChanged: (value){
                   settingProvider.changeMeasurement(MeasurementSetting.imperialSystem);
                   SmartDialog.dismiss();
                 }),

             EvieDivider(),

         ],),
         rightContent: "Cancel",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

///V DIALOGS
///Email resent
showEvieResendDialog(BuildContext context, String email) {
  SmartDialog.show(
    widget: EvieOneDialog(
        title: "Email Re-Sent",
        content1: "We've re-sent email to ",
        content2: ". Do check the spam mailbox too!",
        email: email,
        middleContent: "Done",
        svgpicture: SvgPicture.asset('assets/images/email_resend.svg', width: 180.w, height: 150.h,),
        onPressedMiddle: () {
          SmartDialog.dismiss();
        }));
}

showErrorLoginDialog (BuildContext context){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("User Not Found",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Oops, it seems like the email address you entered is incorrect. Please double-check and try again, or sign up for a new account if you haven't already.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/user_not_found.svg",
          width: 173.w,
          height: 150.h,
        ),
        upContent: "Retry",
        downContent: "Register Now",
        onPressedUp: () {
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          SmartDialog.dismiss();
          changeToInputNameScreen(context);
        }),
  );
}

showDeactivateTheftDialog (BuildContext context, BikeProvider _bikeProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Deactivate Theft Alert?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure that this is a false alarm? "
            "By turning off Theft Attempt mode, your app will revert to its default state until it is triggered again.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/deactivate_theft_alert.svg",
        ),
        upContent: "Cancel",
        downContent: "Confirm Deactivate",
        onPressedUp: () {
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          _bikeProvider.updateBikeStatus('safe');
          SmartDialog.dismiss();
        }),
  );
}


///User not found
showEvieNotFoundDialog (BuildContext context){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("User not found",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Oops, it seems like the email address you "
            "entered is incorrect. Please double-check and try again, "
            "or sign up for a new account if you haven't already.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Retry",
        downContent: "Register Now",
        onPressedUp: () {
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          SmartDialog.dismiss();
          changeToWelcomeScreen(context);
        }),
  );
}

///Exit Registration
showEvieExitRegistrationDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
      title: Text(
        "Exit Registration?",
        style: EvieTextStyles.h2,
        textAlign: TextAlign.center,
      ),
      childContent: Text(
        "Are you sure you want to quit bike registration?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/exit.svg"),
      upContent: "Not Now",
      downContent: "Exit Registration",
      onPressedUp: () {
        SmartDialog.dismiss();
      },
      onPressedDown: () {
        // change to new way of changing pages
        SmartDialog.dismiss();
        changeToUserHomePageScreen(context);
      },
    ),
  );
}

///permission to open settings to enable camera
showEvieCameraSettingDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
      title: Text(
        "Open Camera Setting?",
        style: EvieTextStyles.h2,
        textAlign: TextAlign.center,
      ),
      childContent: Text(
        "You are required to allow EVIE permission to access your camera. Go to EVIE permission settings?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/people_search.svg"),
      upContent: "Yes",
      downContent: "No",
      onPressedUp: () {
        SmartDialog.dismiss();
        openAppSettings();
      },
      onPressedDown: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

showEvieFindQRDialog(BuildContext context){
  SmartDialog.show(
      widget: EvieOneButtonDialog(
          title: "Where to find the QR Code?",
          content: "The QR code can be found on the back of your ownership card.",
          middleContent: "Done",
          svgpicture: SvgPicture.asset(
            "assets/images/find_the_qrcode.svg",
            height: 140.h,
            width: 266.w,
          ),
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }
          ));
}

///where to find serial number and validation key
showEvieFindSerialDialog(BuildContext context){
  SmartDialog.show(
      widget: EvieOneButtonDialog(
          title: "Where to Find These?",
          content: "The Serial Number and Validation Key can be found on the back of your ownership card.",
          middleContent: "Done",
          svgpicture: SvgPicture.asset('assets/images/where_to_find_these.svg', width: 252.w, height: 126.h,),
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }
          ));
}

///free/paid plan bluetooth connection
showSyncRideThrive (context, BluetoothProvider _bluetoothProvider, BikeProvider _bikeProvider){
  /// icon not yet altered
  SmartDialog.show(
      widget: Evie2IconOneButtonDialog(
          bikeProvider: _bikeProvider,
          title: "Sync. Ride. Thrive.",
          miniTitle1: "Stay Connected",
          miniTitle2: "One Tap Unlock",
          content1:"Seamlessly sync your bike and stay in control with Bluetooth connectivity." ,
          content2:"Security has never been this convenient with EVIE's built-in locking system." ,
          middleContent: "Allow Bluetooth",
          onPressedMiddle: () async {

           checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);

            SmartDialog.dismiss();
            showMasterYourRide();
            })
  );
}

showMasterYourRide(){
  SmartDialog.show(
      widget: Evie3IconOneButtonDialog(
          title: "Master Your Ride",
          miniTitle1: "Bike Setting",
          miniTitle2: "Battery Life",
          miniTitle3: "Multiple Accounts",
          content1:"Tailor your ride to perfection with Bike Setting. "
              "Fine-tune your preferences, optimize performance, "
              "and create your ultimate cycling experience." ,
          content2:"Check your bike’s battery life before it needs its next charge." ,
          content3: "See all your bikes’ details and switch between accounts easily." ,
          middleContent: "Done",
          onPressedMiddle: (){
            SmartDialog.dismiss();
          }));
}

// showSyncRideThrive(){
//
//   bool isChange = false;
//
//   SmartDialog.show(
//       widget: StatefulBuilder(
//             builder: (context, setState) {
//
//               return isChange == false ?
//               EvieOneButtonDialog(
//                   havePic: false,
//                   widget: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//
//                       const EvieProgressIndicator(currentPageNumber: 0, totalSteps: 2, ),
//
//                       Padding(
//                         padding: EdgeInsets.only(top: 32.h),
//                         child: SvgPicture.asset(
//                           "assets/images/people_search.svg",
//                           height: 150.h,
//                           width: 239.w,
//                         ),
//                       ),
//
//                       Container(
//                         width: 325.w,
//                         child: Padding(
//                           padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
//                           child: Text("Sync. Ride. Thrive.",
//                               style:EvieTextStyles.h1.copyWith(fontWeight: FontWeight.w800),
//                               textAlign: TextAlign.center
//                           ),
//                         ),
//                       ),
//
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(10.w, 0.h, 8.w, 8.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/bluetooth_connected.svg",
//                               height: 36.h,
//                               width: 36.w,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Stay Connected", style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800)),
//
//                                 Text("Seamlessly sync your bike and stay in control with Bluetooth connectivity.", style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.w400),)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(10.w, 0.h, 8.w, 8.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/lock_safe.svg",
//                               height: 36.h,
//                               width: 36.w,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("One Tap Unlock", style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800),),
//                                 Text("Security has never been this convenient with EVIE's built-in locking system.", style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.w400),)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(10.w, 0.h, 8.w, 8.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(4.h),
//                               child: SvgPicture.asset(
//                                 "assets/icons/bar_chart.svg",
//                                 height: 32.h,
//                                 width: 32.w,
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Ride History", style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800),),
//                                     SvgPicture.asset(
//                                       "assets/icons/batch_tick.svg",
//                                       //height: 157.h,
//                                       //width: 164.w,
//                                     ),
//                                   ],
//                                 ),
//                                 Text("Explore your journey through time with Ride History. "
//                                     "An immersive experience that unveils your past adventure.", style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.w400),)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     ],
//                   ),
//
//                   middleContent: "Next",
//                   onPressedMiddle: (){
//                     setState(() {
//                       isChange = true;
//                     });
//                   }
//               ) :
//               EvieOneButtonDialog(
//                   havePic: false,
//                   widget: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const EvieProgressIndicator(currentPageNumber: 0, totalSteps: 2, ),
//
//                       Padding(
//                         padding: EdgeInsets.only(top: 32.h),
//                         child: SvgPicture.asset(
//                           "assets/images/people_search.svg",
//                           height: 150.h,
//                           width: 239.w,
//                         ),
//                       ),
//
//                       Container(
//                         width: 325.w,
//                         child: Padding(
//                           padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
//                           child: Text("Master Your Ride",
//                               style:EvieTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
//                               textAlign: TextAlign.center
//                           ),
//                         ),
//                       ),
//
//                       Padding(
//                         padding: EdgeInsets.all(0.1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/bluetooth_connected.svg",
//                               height: 36.h,
//                               width: 36.w,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Bike Setting", style: EvieTextStyles.body18,),
//
//                                 Text("Seamlessly sync your bike and stay in control with Bluetooth connectivity.", style: EvieTextStyles.body14,)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       Padding(
//                         padding: EdgeInsets.all(0.1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/lock_safe.svg",
//                               height: 36.h,
//                               width: 36.w,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("One Tap Unlock", style: EvieTextStyles.body18,),
//                                 Text("Security has never been this convenient with EVIE's built-in locking system.", style: EvieTextStyles.body14,)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//
//                       Padding(
//                         padding: EdgeInsets.all(0.1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/bar_chart.svg",
//                               height: 36.h,
//                               width: 36.w,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Ride History", style: EvieTextStyles.body18,),
//                                     SvgPicture.asset(
//                                       "assets/icons/batch_tick.svg",
//                                       //height: 157.h,
//                                       //width: 164.w,
//                                     ),
//                                   ],
//                                 ),
//                                 Text("Explore your journey through time with Ride History. "
//                                     "An immersive experience that unveils your past adventure.", style: EvieTextStyles.body14,)
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     ],
//                   ),
//
//                   middleContent: "Done",
//                   onPressedMiddle: (){
//                     SmartDialog.dismiss();
//                   }
//               )
//               ;
//             }
//       )
//       );
// }

///Allow location permission to access Orbital Anti_Theft
///icon paddings need to be altered
showEvieAllowOrbitalDialog(BuildContext context){
  SmartDialog.show(
      widget:Evie2IconBatchOneButtonDialog(
          title: "Worry-free with EV-Secure",
          miniTitle1: "Orbital Anti-theft",
          miniTitle2: "GPS Tracking",
          content1:"Built-in theft detection, GPS tracking and notifications" ,
          content2:"Built-in theft detection, GPS tracking and notifications" ,
          middleContent: "Allow Location",
          onPressedMiddle: (){
            SmartDialog.dismiss();
          }));
}

///Signal Strength Indicator
showEvieSignalStrengthDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieOneButtonDialog(
      title: "Signal Strength Indicator",
      content: "Use this as an indicator to find out if you are near your bike. "
          "You can only connect to your bike if you have sufficient signal strength.",
      middleContent: "Connect Bike",
      onPressedMiddle: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

///What should i do?
showEvieOrbitalQuestionDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieOneButtonDialog(
      title: "What should I do?",
      content: "You can ...",
      middleContent: "Done",
      onPressedMiddle: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

///Exit Orbital Anti-Theft
showEvieExitOrbitalDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
      title: Text(
        "Exit Orbital Anti-theft?",
        style: EvieTextStyles.h2,
        textAlign: TextAlign.center,
      ),
      childContent: Text(
        "Are you sure you would like to exit orbital anti-theft page?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/exit_anti_theft.svg"),
      upContent: "Exit Orbital Anti-theft",
      downContent: "Cancel",
      onPressedUp: () {
        SmartDialog.dismiss();
        changeToUserHomePageScreen(context);
      },
      onPressedDown: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

///Bike recovered
showEvieBikeRecoveredDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieOneButtonDialog(
      svgpicture: SvgPicture.asset(
        "assets/images/bike_champion.svg",
        height: 157.h,
        width: 164.w,),
      title: "Bike Recovered!",
      content: "Your bike is back in your possession after a theft attempt. "
          "Ensure [bike name]'s security and enjoy it once again.",
      middleContent: "Done",
      onPressedMiddle: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

///Actionable bar
showEvieActionableBarDialog(BuildContext context, BluetoothProvider bluetoothProvider, BikeProvider bikeProvider) {
  SmartDialog.show(
    widget: EvieOneButtonDialog(
      title: "Bluetooth Connection Needed",
      content: "Embark on the next step by connecting with your bike. "
          "An essential requirement to unlock and progress through this seamless process.",
      middleContent: "Connect Bike",
      onPressedMiddle: () {
        SmartDialog.dismiss();
        checkBleStatusAndConnectDevice(bluetoothProvider, bikeProvider);
      },
    ),
  );
}

///to fully reset the bike
showFullResetDialog (BuildContext context ,SettingProvider _settingProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Fully Reset Your Bike?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure that you want to start over? "
            "Choosing this option will completely reset your current settings "
            "for both your bike and the app.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Full Reset",
        downContent: "Cancel",
        onPressedUp: () {
          SmartDialog.dismiss();
          // Navigator.of(context, rootNavigator: true).pop();
          // showBikeEraseSheet(context);
          _settingProvider.changeSheetElement(SheetList.bikeEraseReset);
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );
}

showWelcomeToEVClub (BuildContext context){
  /// icon not yet altered
  SmartDialog.show(
      widget: EvieOneButtonDialog(
          title: "Welcome to the EV+ Club!",
          content: "Are you ready for an adventure? "
              "Perks of having an EV+ subscription include having access rto exclusive features such as "
              "GPS Tracking, Theft Detection, Ride History and more!",
          middleContent: "Let's Go!",
          onPressedMiddle: (){
            SmartDialog.dismiss();
          }));

}

///to unlink the bike
showUnlinkBikeDialog (BuildContext context, SettingProvider _settingProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Unlink Your Bike?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure that you want to unlink your bike? "
            "Your bike will be removed from the app, and its settings will be "
            "forgotten until you sync your bike with the app again.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Unlink Bike",
        downContent: "Cancel",
        onPressedUp: () {
          SmartDialog.dismiss();
          // Navigator.of(context, rootNavigator: true).pop();
          // showBikeEraseSheet(context);
          _settingProvider.changeSheetElement(SheetList.bikeEraseUnlink);
        },
        onPressedDown: () {
          SmartDialog.dismiss();
          //changeToWelcomeScreen(context);
        }),
  );
}


///connect bike to bluetooth before full reset
showConnectBluetoothDialog (BuildContext context, BluetoothProvider _bluetoothProvider,BikeProvider _bikeProvider){
  Widget? buttonImage = Text(
    'Connect Bike',
    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
  );

  SmartDialog.show(
    keepSingle: true,
    backDismiss: false,
    clickBgDismissTemp: false,

    widget:  Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          return StatefulBuilder(
              builder: (context, setState) {


                ///Set button image
                if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected &&
                    _bluetoothProvider.currentConnectedDevice ==
                        _bikeProvider.currentBikeModel?.macAddr) {
                  buttonImage = SvgPicture.asset(
                    "assets/buttons/ble_button_connect.svg",
                    width: 52.w,
                    height: 50.h,
                  );
                  SmartDialog.dismiss();
                }  else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                    _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                    _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected) {
                  buttonImage =
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/loading_button.json',
                            width: 45.w,
                            height: 50.h,
                              repeat: true
                          ),
                          Text('Connecting Bike', style: EvieTextStyles.body18,)
                        ],
                      );
                }
                else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected) {
                  buttonImage = Text('Connect Bike', style: EvieTextStyles.body18,);
                  SmartDialog.dismiss();
                }
                else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout) {
                  SmartDialog.dismiss();
                }
                else {
                  buttonImage = Text('Connect Bike', style: EvieTextStyles.body18,);
                }


                return EvieTwoButtonDialog(
                    title: Text("Connect Your Bike",
                      style: EvieTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    childContent: Text(
                      "Embark on the next step by connecting with your bike. "
                          "An essential requirement to unlock and progress through this seamless process.",
                      textAlign: TextAlign.center,
                      style: EvieTextStyles.body18,),
                    svgpicture: SvgPicture.asset(
                      "assets/images/people_search.svg",
                    ),
                    customButtonUp: EvieButton(
                        backgroundColor: _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                            _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                            _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected ? EvieColors.primaryColor.withOpacity(0.3) : EvieColors.primaryColor,
                        width: double.infinity,
                        height: 48.h,
                        child: buttonImage!,

                        onPressed: (){
                          if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected &&
                              _bluetoothProvider.currentConnectedDevice ==
                                  _bikeProvider.currentBikeModel?.macAddr){

                          }else{
                            _bluetoothProvider.bleScanSub?.cancel();
                            checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
                          }
                        }
                    ),

                    downContent: "Cancel",
                    onPressedDown: () async {
                      if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected) {

                        showDontConnectBike(context, _bikeProvider, _bluetoothProvider);
                      }
                      SmartDialog.dismiss();
                    });
              }
          );

        }
    ),
  );
}

showResetPasswordDialog(BuildContext context, AuthProvider _authProvider){
  SmartDialog.show(
    keepSingle: true,
    backDismiss: false,
    clickBgDismissTemp: false,
    widget: EvieTwoButtonDialog(
        title: Text("Lost Your Password?",
          style: EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text(
          "That’s okay, it happens! We’ll send you instructions to recover your password.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        customButtonUp: EvieButton(
            backgroundColor: EvieColors.primaryColor,
            width: double.infinity,
            height: 48.h,
            child: Text(
              'Reset Password',
              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
            ),
            onPressed: () async {
              SmartDialog.dismiss();
              SmartDialog.showLoading();
              await _authProvider.resetPassword(_authProvider.getEmail);
              SmartDialog.dismiss(status: SmartStatus.loading);
              changeToCheckYourEmail(context);
            }
        ),
        downContent: "Cancel",
        onPressedDown: () async {
          SmartDialog.dismiss();
        }),
  );
}

showLogoutDialog(BuildContext context, AuthProvider _authProvider){
  SmartDialog.show(
    keepSingle: true,
    backDismiss: false,
    clickBgDismissTemp: false,
    widget: EvieTwoButtonDialog(
        title: Text("Log Out",
          style: EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text(
          "You are about to log out. Are you sure you would like to logout?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/logout.svg",
        ),
        customButtonUp: EvieButton(
            backgroundColor: EvieColors.primaryColor,
            width: double.infinity,
            height: 48.h,
            child: Text(
              'Log Out',
              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
            ),
            onPressed: () async {
              SmartDialog.dismiss();
              SmartDialog.showLoading();
              try {
                await _authProvider.signOut(context).then((result) async {
                  if (result == true) {
                    SmartDialog.dismiss();
                    changeToWelcomeScreen(context);
                  }
                  else {
                    SmartDialog.dismiss();
                  }
                });
              } catch (e) {
                debugPrint(e.toString());
                SmartDialog.dismiss();
                showFailed();
              }
            }
        ),
        downContent: "Cancel",
        onPressedDown: () async {
          SmartDialog.dismiss();
        }),
  );
}

showRevokeAccountDialog(BuildContext context, AuthProvider _authProvider){
  SmartDialog.show(
    keepSingle: true,
    backDismiss: false,
    clickBgDismissTemp: false,
    widget: EvieTwoButtonDialog(
        title: Text("Revoke Account",
          style: EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text(
          "Are you sure that you want to permanently delete your account? The account will no longer be available, and all data in the account will be permanently deleted.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/revoke_account.svg", width: 131.96.w, height: 149.09.h,
        ),
        customButtonUp: EvieButton(
            backgroundColor: EvieColors.primaryColor,
            width: double.infinity,
            height: 48.h,
            child: Text(
              'Revoke Account',
              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
            ),
            onPressed: () async {
              SmartDialog.dismiss();
              changeToRevokingAccount(context);
              // await _authProvider.deactivateAccount();
              // await _authProvider.signOut(context);
              // await Future.delayed(const Duration(seconds: 3));
              // changeToRevokedAccount(context);
              // await Future.delayed(const Duration(seconds: 3));
              // changeToWelcomeScreen(context);
            }
        ),
        downContent: "Cancel",
        onPressedDown: () async {
          SmartDialog.dismiss();
        }),
  );
}


showScanTimeout(BuildContext context) {
  SmartDialog.show(
    widget: EvieOneButtonDialog(
      title: "Bluetooth Scan Timeout",
      content: "Scan Timeout, please try again",
      middleContent: "OK",
      onPressedMiddle: () {
        SmartDialog.dismiss();
      },
    ),
  );
}

showThreatDialog(BuildContext context) {
  SmartDialog.show(
    //keepSingle: true,
    clickBgDismissTemp: false,
    backDismiss: false,
    widget: ThreatDialog(contextS: context,),
    tag: 'threat'
  );
}

showThreatConnectBikeDialog(BuildContext context, setState, BluetoothProvider _bluetoothProvider,BikeProvider _bikeProvider){

  Widget? buttonImage = Text(
    'Connect Bike',
    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
  );

  SmartDialog.show(
    keepSingle: true,
    clickBgDismissTemp: false,
    backDismiss: false,
    widget:  Consumer<BluetoothProvider>(
      builder: (consumerContext, bluetoothProvider, child) {

        final valueOfRSSI = bluetoothProvider.deviceRssi;

      return StatefulBuilder(
        builder: (statefulContext, setState) {


          ///Open slide to unlock dialog
          if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected &&
              _bluetoothProvider.currentConnectedDevice ==
                  _bikeProvider.currentBikeModel?.macAddr){
            SmartDialog.dismiss();
            _bluetoothProvider.bleScanSub?.cancel();
            _bluetoothProvider.deviceRssi = 0;

            Future.delayed(Duration.zero).then((value) {
              showSlideToUnlock(context, setState, _bluetoothProvider,_bikeProvider);
            });
          }

          ///Set button image
            if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected &&
                _bluetoothProvider.currentConnectedDevice ==
                    _bikeProvider.currentBikeModel?.macAddr) {
              buttonImage = SvgPicture.asset(
                "assets/buttons/ble_button_connect.svg",
                width: 52.w,
                height: 50.h,
              );
            }  else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected) {
              buttonImage =
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lottie.asset(
                      //   'assets/animations/loading_button.json',
                      //   width: 45.w,
                      //   height: 50.h,
                      //     repeat: true
                      // ),
                      Text('Connecting Bike', style: EvieTextStyles.body18,)
                    ],
                  );
            }
            else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected) {
              buttonImage = Text('Connect Bike', style: EvieTextStyles.body18,);
            }
            else {
              buttonImage = Text('Connect Bike', style: EvieTextStyles.body18,);
            }

          if(valueOfRSSI == 0){
            if(_bluetoothProvider.scanResult == BLEScanResult.scanTimeout){
              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: EvieTwoButtonDialog(
                  havePic: false,
                  childContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text("No Bike Found.", style: EvieTextStyles.h2.copyWith(
                          color: EvieColors.mediumBlack)),

                      Padding(
                        padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/no_bike.svg",
                            ),

                            Positioned(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: EvieColors.grayishWhite,
                                  ),
                                  height: 48.h,
                                  width: 48.w,
                                )
                            ),



                            // Consumer<BluetoothProvider>(
                            //   builder: (context, dialogModel, child) {
                            //     return Text(
                            //       _bluetoothProvider.deviceRssi.toString(),
                            //     );
                            //       }
                            //     ),

                          ],
                        ),
                      ),

                      Center(
                        child:
                        Text(
                            "You're still too far away from your bike."
                                " Try getting closer to your bike location before scanning again.",
                          style: EvieTextStyles.body18.copyWith(
                              color: EvieColors.lightBlack),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                        height: 18.h,
                      ),
                    ],
                  ),

                  customButtonUp: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text("Scan Again", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),),
                      onPressed: (){
                        _bluetoothProvider.checkBLEStatus().listen((event) {
                          if(event == BleStatus.ready){
                            showThreatConnectBikeDialog(context, setState, _bluetoothProvider,_bikeProvider);
                            _bluetoothProvider.startScanRSSI();
                          }else if(event == BleStatus.poweredOff || event == BleStatus.unauthorized){
                            showBluetoothNotTurnOn();
                          }
                        });
                      }
                  ),

                  downContent: "Close",
                  onPressedDown: () {
                    SmartDialog.dismiss();
                  },
                ),
              );
            }
            else{
              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: EvieOneButtonDialog(
                  havePic: false,
                  // childContent: Text("Connect your bike and access "
                  //     "all the bike setting features smoothly.",
                  //   textAlign: TextAlign.center,
                  //   style: EvieTextStyles.body18,),
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32.h,
                      ),
                      Text("Scanning Your Bike.", style: EvieTextStyles.h2.copyWith(
                          color: EvieColors.mediumBlack)),

                      Padding(
                        padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
                        child: Lottie.asset(
                          'assets/animations/scanning-for-bike.json',
                          repeat:false,
                        ),
                      ),

                      Center(
                        child:
                        Text(
                          "Hold tight, we're searching for your bike within a 10m range.",
                          style: EvieTextStyles.body18.copyWith(
                              color: EvieColors.lightBlack),
                        ),
                      ),

                      SizedBox(
                        height: 140.h,
                      ),

                    ],
                  ),
                  middleContent: "Stop Scan",
                  onPressedMiddle: () async {
                    showDontConnectBike(context, _bikeProvider, _bluetoothProvider);
                  },
                ),
              );
            }
          }
          else{
              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: EvieTwoButtonDialog(
                  havePic: false,
                  childContent: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected ?
                          Text("Connecting Bike", style: EvieTextStyles.h2.copyWith(
                              color: EvieColors.mediumBlack)) :
                          Text("Your Bike Is Nearby!", style: EvieTextStyles.h2.copyWith(
                             color: EvieColors.mediumBlack)),

                      Padding(
                        padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // SvgPicture.asset(
                            //   "assets/icons/rssi_middle.svg",
                            // ),
                            _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                                _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                                _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected ?
                            Center(
                              child: Lottie.asset(
                                'assets/animations/scanning-connecting-bike.json',
                                repeat:false,
                              ),
                            ) : Center(
                              child: Lottie.asset(
                                'assets/animations/scanning-proximity.json',
                                repeat:false,
                              ),
                            ),

                            Positioned(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: EvieColors.grayishWhite,
                                  ),
                                  height: 55.h,
                                  width: 55.w,
                                )
                            ),


                            Positioned(
                              child: _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                                  _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                                  _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected ?
                              SvgPicture.asset(
                                "assets/icons/loading_purple.svg",
                              ) :
                              Text(
                                valueOfRSSI.toString(), style: EvieTextStyles.batteryPercent.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                            ),

                            // Consumer<BluetoothProvider>(
                            //   builder: (context, dialogModel, child) {
                            //     return Text(
                            //       _bluetoothProvider.deviceRssi.toString(),
                            //     );
                            //       }
                            //     ),

                          ],
                        ),
                      ),

                      Center(
                        child:
                        Text(
                          "The number indicates your proximity to the bike. Lower numbers are closer while higher numbers are further. "
                              "Do note that continuous scanning will drain your battery.",
                          style: EvieTextStyles.body18.copyWith(
                              color: EvieColors.lightBlack),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                        height: 18.h,
                      ),

                    ],
                  ),

                  customButtonUp: EvieButton(
                    backgroundColor: _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                        _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                        _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected ? EvieColors.primaryColor.withOpacity(0.3) : EvieColors.primaryColor,
                      width: double.infinity,
                      height: 48.h,
                      child: buttonImage!,
                      onPressed: (){
                        if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected &&
                            _bluetoothProvider.currentConnectedDevice ==
                                _bikeProvider.currentBikeModel?.macAddr){

                        }else{
                          _bluetoothProvider.bleScanSub?.cancel();
                          _bluetoothProvider.startScanAndConnect();
                        }
                      }
                  ),

                  downContent: "Stop Scan",
                  onPressedDown: () async {
                    showDontConnectBike(context, _bikeProvider, _bluetoothProvider);
                  },
                ),
              );

          }
        }
        );},
    )
  )
  ;}


showSlideToUnlock(context, setState, BluetoothProvider _bluetoothProvider, BikeProvider _bikeProvider){
  SmartDialog.show(
      backDismiss: false,
      clickBgDismissTemp: false,
      keepSingle: true,
      widget:
      ///Consumer<BluetoothProvider>(
       /// builder: (context, bluetoothProvider, child) {

      ///    return StatefulBuilder(
      ///        builder: (context, setState) {

             ///     return
                    WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: EvieOneButtonDialog(
                      havePic: false,
                      // childContent: Text("Connect your bike and access "
                      //     "all the bike setting features smoothly.",
                      //   textAlign: TextAlign.center,
                      //   style: EvieTextStyles.body18,),
                      widget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 32.h,
                          ),
                          Text("Slide to Unlock", style: EvieTextStyles.h2.copyWith(
                              color: EvieColors.mediumBlack)),

                          Padding(
                            padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
                            child: Container(
                              height: 120.h,
                              width: 120.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: EvieColors.primaryColor,
                              ),
                              child: SvgPicture.asset(
                                "assets/buttons/lock_lock.svg",
                                  width: 48.w,
                                  height: 48.h,
                                  fit: BoxFit.scaleDown
                              ),
                            ),
                          ),

                          Center(
                            child: Text(
                              "Slide to unlock your bike. "
                                  "By unlocking your bike, your bike status will return back to secure status.",
                              style: EvieTextStyles.body18.copyWith(
                                  color: EvieColors.lightBlack),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(
                            height: 38.h,
                          ),

                          EvieSliderButton(
                            backgroundColor: EvieColors.pastelPurple,
                            dismissible: true,
                            action:() {
                              _bluetoothProvider.setIsUnlocking(true);
                              //showUnlockingToast(context);

                              StreamSubscription? subscription;

                              subscription = _bluetoothProvider.cableUnlock().listen((unlockResult) {

                                    if (unlockResult.result == CommandResult.success) {
                                      SmartDialog.dismiss();
                                      ///Change to page

                                        changeToThreatBikeRecovered(context);

                                        showToLockBikeInstructionToast(context);
                                        subscription?.cancel();

                                    } else {

                                      SmartDialog.dismiss();
                                      ///Change to page

                                        changeToThreatBikeRecovered(context);

                                        showToLockBikeInstructionToast(context);
                                        subscription?.cancel();

                                      // print("failes");
                                      // SmartDialog.dismiss();
                                      // subscription?.cancel();
                                      // //  showToLockBikeInstructionToast(context);
                                    }
                                  },

                                  onError: (error) {
                                // SmartDialog.dismiss();
                                // subscription?.cancel();
                                // SmartDialog.show(
                                //     widget: EvieSingleButtonDialog(
                                //         title: "Error",
                                //         content: "Cannot unlock bike, please place the phone near the bike and try again.",
                                //         rightContent: "OK",
                                //         onPressedRight: () {
                                //           SmartDialog.dismiss();
                                //         }));
                              });

                            },
                            text: 'Unlock My Bike',
                          )

                        ],
                      ),

                     customButton: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text( "Exit",
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                          ),
                          onPressed: ()async {
                            showNoLockExit(context, _bikeProvider, _bluetoothProvider);
                          },
                      ),

                    ),
          ///        )

      ///        }
      ///    );

      ///    },
     )
  );
}

showDontConnectBike (BuildContext context ,BikeProvider _bikeProvider,  BluetoothProvider _bluetoothProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Don't Connect Bike?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("We're still trying to connect your bike. "
            "Are you sure that you want to stop the connection process?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/revoke_account.svg",
        ),

        customButtonUp: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: EvieButton(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Cancel",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
              ),
              onPressed: () {
                SmartDialog.dismiss();
              }),
        ),
        customButtonDown:EvieButton_ReversedColor(
          width: double.infinity,
          height: 48.h,
          child: Text(
            "Stop Connect",
            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
          ),
          onPressed: () async {
            await _bluetoothProvider.stopScan();
            await _bluetoothProvider.disconnectDevice();
            _bluetoothProvider.bleScanSub?.cancel();
            _bluetoothProvider.startScanTimer?.cancel();
            _bluetoothProvider.scanResultStream.add(BLEScanResult.unknown);
            _bluetoothProvider.scanResult = BLEScanResult.unknown;

            _bluetoothProvider.stopScanTimer();

            _bluetoothProvider.bleStatusSubscription?.cancel();
            _bluetoothProvider.bleScanSub?.cancel();
            _bluetoothProvider.deviceRssi = 0;
            SmartDialog.dismiss();
            SmartDialog.dismiss();
          },
        ),
        ),
  );
}


showNoLockExit (BuildContext context ,BikeProvider _bikeProvider,  BluetoothProvider _bluetoothProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Exit Bike Unlock?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure that you want to keep this bike locked? "
            "The bike will only revert to its secure state once you unlock it.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/exit_anti_theft.svg",
        ),

        customButtonDown:  EvieButton_ReversedColor(
          width: double.infinity,
          height: 48.h,
          child: Text(
            "Stop Unlock Bike",
            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
          ),
          onPressed: () async {
            await _bluetoothProvider.stopScan();
            await _bluetoothProvider.disconnectDevice();
            _bluetoothProvider.bleScanSub?.cancel();
            _bluetoothProvider.startScanTimer?.cancel();
            _bluetoothProvider.scanResultStream.add(BLEScanResult.unknown);
            _bluetoothProvider.scanResult = BLEScanResult.unknown;

            _bluetoothProvider.stopScanTimer();

            _bluetoothProvider.bleStatusSubscription?.cancel();
            _bluetoothProvider.bleScanSub?.cancel();
            _bluetoothProvider.deviceRssi = 0;
            SmartDialog.dismiss();
            SmartDialog.dismiss();
          },
        ),

        customButtonUp: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: EvieButton(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Cancel",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
              ),
              onPressed: () {
                SmartDialog.dismiss();
              }),
        ),
  ));
}

showClearFeed(NotificationProvider _notificationProvider){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Clear all Feeds?",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you want to clear all feeds list?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Cancel",
        downContent: "Confirm",

        onPressedUp: () {
          SmartDialog.dismiss();
        },

        onPressedDown: () async {
          SmartDialog.dismiss();
          SmartDialog.showLoading();
          // for (int i = 0; i < _notificationProvider.notificationList.length; i++) {
          //   print('indexLLLLLLLLLLLLL : ' + i.toString());
          //   var result = await _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(i));
          //   if (!result) {
          //     showDeleteNotificationFailed();
          //   }
          // }
          await _notificationProvider.deleteAllNotification();
          SmartDialog.dismiss(status: SmartStatus.loading);
          // Dismiss the SmartDialog after the loop finishes

        }),
  );
}


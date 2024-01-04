import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/model/pedal_pals_model.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/firmware_provider.dart';
import 'package:evie_test/api/provider/location_provider.dart';
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
import '../widgets/evie_checkbox.dart';
import '../widgets/evie_divider.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_progress_indicator.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_slider_button.dart';
import '../widgets/evie_switch.dart';
import '../widgets/evie_textform.dart';
import 'colours.dart';
import 'model/bike_user_model.dart';
import 'model/rfid_model.dart';
import 'model/user_model.dart';
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
          title: "Opps!",
          content: "This page cannot be close",
          rightContent: "Ok",
          onPressedRight: () {
            SmartDialog.dismiss();
            // SystemNavigator.pop();
          }));
}

showWhereToFindQRCode(){
  SmartDialog.show(
      widget: EvieSingleButtonDialogOld(
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
      widget: EvieSingleButtonDialogOld(
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
      widget: EvieSingleButtonDialogOld
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
          rightContent: "Retry",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

showFailed(){
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog
        (title: "Not Success",
          content: "An error occur, try again",
          rightContent: "Retry",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

showBluetoothNotTurnOn() {
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialog(
          title: "Bluetooth Error",
          content: "Uh-oh! Bluetooth is off. Turn it on for connection.",
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
          content: "Bluetooth Unsupported",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog
                .dismiss();
          }));
}

showBluetoothNotAuthorized() {
  SmartDialog.dismiss();
  // SmartDialog.show(
  //     keepSingle: true,
  //     widget: EvieSingleButtonDialogOld(
  //         title: "Error",
  //         content: "Bluetooth permission is off, turn on bluetooth permission in setting.",
  //         rightContent: "OK",
  //         onPressedRight: () {
  //           SmartDialog.dismiss();
  //           if (Platform.isAndroid) {
  //             openAppSettings();
  //           }
  //           else {
  //             OpenSettings.openBluetoothSetting();
  //             //AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  //           }
  //           //openAppSettings();
  //          ///Redirect user to enable bluetooth permission.
  //         }));

  SmartDialog.show(
      widget: EvieTwoButtonDialog(
          title: Text("Bluetooth Required",
            style:EvieTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          childContent: Text(
            "Please enable Bluetooth for bike connectivity.",
            style: TextStyle(fontSize: 16.sp,
                fontWeight: FontWeight.w400),),
          downContent: "Cancel",
          upContent: "Go to Setting",
          svgpicture: SvgPicture.asset(
            "assets/images/bluetooth_required.svg",
          ),
          onPressedDown: () async {
            SmartDialog.dismiss();
          },
          onPressedUp: ()async {
            SmartDialog.dismiss();
            if (Platform.isAndroid) {
              openAppSettings();
            }
            else {
              OpenSettings.openBluetoothSetting();
              //AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            }
          })
  );
}

showLocationServiceDisable() {
  SmartDialog.dismiss();
  SmartDialog.show(
      widget: EvieTwoButtonDialog(
          title: Text("Location Services Disabled",
            style:EvieTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          childContent: Text(
            "Enable location services in your settings to elevate your experience. Tap on Always or While Using.",
            style: TextStyle(fontSize: 16.sp,
                fontWeight: FontWeight.w400),),
          downContent: "No, Thanks",
          upContent: "Go to Setting",
          svgpicture: SvgPicture.asset(
            "assets/images/location_required.svg",
          ),
          onPressedDown: () async {
            SmartDialog.dismiss();
          },
          onPressedUp: ()async {
            SmartDialog.dismiss();
            if (Platform.isAndroid) {
              openAppSettings();
            }
            else {
              OpenSettings.openLocationSourceSetting();
              //AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            }
          })
  );
}

showCameraDisable() {
  SmartDialog.dismiss();
  SmartDialog.dismiss();
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialogOld(
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
      widget: EvieSingleButtonDialogOld(
          title: "Error",
          content: "Notification permission is off, turn on notification permission in setting",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
            openAppSettings();
            ///Redirect user to enable bluetooth permission.
          }));
}

showEditBikeNameDialog(_formKey, _bikeNameController, BikeProvider _bikeProvider) {
  bool isFirst = true;

  _bikeNameController = TextEditingController(text: _bikeProvider.currentBikeModel?.deviceName);

  FocusNode _nameFocusNode = FocusNode();
  _nameFocusNode.requestFocus();

  _bikeNameController.addListener(() {
    if (_bikeNameController.selection.baseOffset != _bikeNameController.selection.extentOffset) {
      // Text is selected
      //print('Text selected: ${_nameController.text.substring(_nameController.selection.baseOffset, _nameController.selection.extentOffset)}');
    } else {
      // Cursor is moved
      if (isFirst) {
        isFirst = false;
        _bikeNameController.selection = TextSelection(
            baseOffset: 0, extentOffset: _bikeNameController.text.length);
      }
    }
  });

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
                      focusNode: _nameFocusNode,
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
      widget: EvieSingleButtonDialogOld
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
          content: "An error occur, try again.",
          rightContent: "Retry",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

Future<String> showDeleteShareBikeUser(BikeUserModel bikeUserModel, UserModel? userModel, PedalPalsModel pedalPalsModel) async {
  String result = json.encode({
    "result" : 'none'
  });
  await SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Remove Pal",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Are you sure you would like to remove " + userModel!.name! + " from " + pedalPalsModel.name! + "?",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/people_search.svg",
        ),
        upContent: "Remove",
        downContent: "Cancel",
        onPressedUp: () async {
          result = json.encode({
            "uid": bikeUserModel.uid,
            "name": userModel.name!,
            "teamName": pedalPalsModel.name!,
            "status": bikeUserModel.status,
            "notificationId": bikeUserModel.notificationId,
            "result": 'action',
          });
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
      widget: EvieSingleButtonDialogOld(
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
          content: "Try again.",
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

// showFirmwareUpdateQuit(context, StreamSubscription? stream){
//   SmartDialog.show(
//       keepSingle: true,
//       backDismiss: false,
//       widget: EvieDoubleButtonDialog(
//           title: "Exit Update?",
//           childContent: Text("App need to be stay open to complete upgrade."
//               " Any changes made during the update may not be saved if exit update."),
//           leftContent: "Cancel Update",
//           rightContent: "Stay Updating",
//           onPressedLeft: (){
//             SystemNavigator.pop();
//             SmartDialog.dismiss();
//
//             showBikeSettingSheet(context);
//             stream?.cancel();
//           },
//           onPressedRight: (){
//             SmartDialog.dismiss();
//           }));
// }

showFirmwareUpdateQuit(context, StreamSubscription? stream, _settingProvider, BluetoothProvider _bluetoothProvider) async {
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
                Navigator.of(context).pop();
              },
              onPressedDown: () {
                ///Dismiss dialog here
                stream?.cancel();
                _bluetoothProvider.disconnectDevice();
                Navigator.of(context).pop();
                _settingProvider.changeSheetElement(SheetList.bikeSetting);
              })
  );
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
          title: "Please select the date.",
          content: "Date not selected.",
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
         SmartDialog.show(widget: EvieSingleButtonDialogOld(
             title: "Success",
             content: "Bike reset",
             rightContent: "Ok",
             onPressedRight: (){
               SmartDialog.dismiss();
             changeToUserHomePageScreen(context);}));
       }else{
         SmartDialog.dismiss();
         SmartDialog.show(widget: EvieSingleButtonDialogOld(
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
      rightContent: "Retry",
      onPressedRight: (){SmartDialog.dismiss();}));
}


showEVKeyExistAndUploadToFirestore(BuildContext context, String rfidNumber){
  SmartDialog.show(
      widget: EvieSingleButtonDialogOld(
          title: "Success",
          content: "Card data already existed.",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();

          }));
}


showAddEVKeyNameSuccess(BuildContext context){
  SmartDialog.show(
      widget:EvieSingleButtonDialogOld(
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
          "assets/images/dustbin.svg",
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

            if (deleteRFIDStatus.result == CommandResult.success) {
              deleteRFIDStream?.cancel();
              final result = _bikeProvider.deleteRFIDFirestore(rfidModel.rfidID!);
              _bikeProvider.removeRFIDByID(rfidModel.rfidID!);
              showTextToast("${rfidModel.rfidName} have been removed from your EV-Key list.");
              SmartDialog.dismiss(status: SmartStatus.loading);
            }
            else {
              print(deleteRFIDStatus.result);
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
          "assets/images/dustbin.svg",
        ),
        upContent: "Confirm",
        downContent: "Cancel",
        onPressedUp: () async {
          SmartDialog.dismiss();
          SmartDialog.showLoading(msg: "Removing all EV-Key....");

          // Explicitly declare the type of the list
          List<String> keysToDelete = _bikeProvider.rfidList.keys.cast<String>().toList();

          await Future.forEach(keysToDelete, (String key) async {
            _bluetoothProvider.deleteRFID(key);
            await _bikeProvider.deleteRFIDFirestore(key);
            _bikeProvider.removeRFIDByID(key);
            await Future.delayed(Duration(seconds: 1));
          });

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
          title: "Exit EV-Secure?",
          childContent: Text("Are you sure you would like to exit EV-Secure page?",style: EvieTextStyles.body18,),
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

showMeasurementUnit(SettingProvider settingProvider, context){

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
      widget: EvieSingleButtonDialogOld(
        isReversed: true,
          title: "Measurement Unit",
         widget: Column(
           children: [
             EvieRadioButton(
                 text: "Metric System (meters)",
                 value: 0,
                 groupValue: _selectedRadio,
                 onChanged: (value){
                   settingProvider.changeMeasurement(MeasurementSetting.metricSystem);
                   showUpdateMetric(context, "Metric System.");
                   SmartDialog.dismiss();
                 }),

             EvieDivider(),

             EvieRadioButton(
                 text: "Imperial System (miles)",
                 value: 1,
                 groupValue: _selectedRadio,
                 onChanged: (value){
                   settingProvider.changeMeasurement(MeasurementSetting.imperialSystem);
                   showUpdateMetric(context, "Imperial System.");
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
        content2: ". Remember to check your spam folder too!",
        email: email,
        middleContent: "Done",
        svgpicture: SvgPicture.asset('assets/images/email_resend.svg', width: 180.w, height: 150.h,),
        onPressedMiddle: () {
          SmartDialog.dismiss();
        }));
}

showGPSNotFound() {
  SmartDialog.show(
      widget: EvieOneDialog(
          title: "Oops! We missed capturing GPS data",
          content1: "It’s possible that the bike was in a location with weak satellite signals, like inside a building, a tunnel, or under some thick trees. Don’t worry, we’ll get the next one!",
          middleContent: "Done",
          svgpicture: SvgPicture.asset('assets/images/lost_gps.svg', width: 180.w, height: 150.h,),
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }));
}

showMissingGPSDataDialog(BuildContext context) {
  SmartDialog.show(
      widget: EvieOneDialog(
          title: "Oops! We missed capturing GPS data",
          content1: "It’s possible that the bike was in a location with weak satellite signals, like inside a building, a tunnel, or under some thick trees. Don’t worry, we’ll get the next one!",
          middleContent: "Done",
          svgpicture: SvgPicture.asset('assets/images/missing_gps.svg'),
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }));
}

showBatteryInfoDialog(BuildContext context) {
  SmartDialog.show(
      widget: EvieOneDialog(
          title: "Battery info",
          content1: "Please note that the battery info displayed is based on the last time your device was connected to your bike, and may not reflect real-time data.",
          middleContent: "Done",
          svgpicture: SvgPicture.asset('assets/images/battery_info.svg'),
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

showWrongPasswordDialog(BuildContext context){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Invalid Password",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Oops, the password seems incorrect.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/lost_your_password.svg",
          width: 173.w,
          height: 150.h,
        ),
        upContent: "Retry",
        downContent: "Forget Password?",
        onPressedUp: () {
          SmartDialog.dismiss();
        },
        onPressedDown: () {
          SmartDialog.dismiss();
          changeToForgetPasswordScreen(context);
        }),
  );
}

showWhatToDoDialog(BuildContext context) {
  SmartDialog.show(
    widget: Dialog(
        insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite2,
        child: Container(
          padding:  EdgeInsets.only(
              left: 17.w,
              right: 17.w,
              top: 16.w,
              bottom: 16.w
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child:  SvgPicture.asset(
                      "assets/images/wsid.svg",
                    ),
                  ),
              ),

              Container(
                width: 325.w,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                  child: Text("What Should I Do??",
                    style:EvieTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Column(
                children: [
                  Text("Take deep breaths and stay calm. We've compiled a list of actions you can take:",
                    style:EvieTextStyles.body18,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: 20.h,),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("1.  ",
                    style:EvieTextStyles.body18,
                    textAlign: TextAlign.center,
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: EvieTextStyles.body18,
                        children: [
                          TextSpan(
                            text: "Report to authorities: ",
                            style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800, color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                          TextSpan(
                            text: "Immediately contact your local police to file a theft report with the EV-Secure tracking list.",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 6.h,),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("2.  ",
                    style:EvieTextStyles.body18,
                    textAlign: TextAlign.center,
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: EvieTextStyles.body18,
                        children: [
                          TextSpan(
                            text: "Spread the word: ",
                            style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800, color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                          TextSpan(
                            text: "Post about the incident on social media, share pictures of your bike, and update the tracking pathway with friends and family. Ask them to keep a lookout.",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 6.h,),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("3.  ",
                    style:EvieTextStyles.body18,
                    textAlign: TextAlign.center,
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: EvieTextStyles.body18,
                        children: [
                          TextSpan(
                            text: "Stay vigilant: ",
                            style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w800, color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                          TextSpan(
                            text: "Keep an eye out for your bike, both in person and on online platforms. ",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),


              Padding(
                padding: EdgeInsets.only(top: 37.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: EvieButton(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(
                              'Done',
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                            onPressed: () {
                              SmartDialog.dismiss();
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        )
    )
  );
}

showLookingForYourBikeDialog(BuildContext context) {
  SmartDialog.show(
      widget: Dialog(
          insetPadding: EdgeInsets.only(left: 15.w, right: 17.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0.0,
          backgroundColor: EvieColors.grayishWhite2,
          child: Container(
            padding:  EdgeInsets.only(
                left: 17.w,
                right: 17.w,
                top: 16.w,
                bottom: 16.w
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child:  SvgPicture.asset(
                      "assets/images/lfyb.svg",
                    ),
                  ),
                ),

                Container(
                  width: 325.w,
                  child: Padding(
                    padding:  EdgeInsets.only(bottom: 16.h, top: 24.h),
                    child: Text("Looking for Your Bike?",
                      style:EvieTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                Column(
                  children: [
                    Text("Scan for your bike within a 10m radius. Frequent scanning may consume battery. It’s best to scan when you are near to your bike’s potential location.",
                      style:EvieTextStyles.body18,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(top: 37.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: EvieButton(
                              width: double.infinity,
                              height: 48.h,
                              child: Text(
                                'Done',
                                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                              ),
                              onPressed: () {
                                SmartDialog.dismiss();
                              }
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              ],
            ),
          )
      )
  );
}

showDeactivateTheftDialog (BuildContext context, BikeProvider _bikeProvider){
  SmartDialog.show(
    widget: Builder(
      builder: (BuildContext buildContext) {
        return EvieTwoButtonDialog(
            title: Text("Dismiss Theft Alert?",
              style:EvieTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            childContent: Text("Are you certain this is a false alarm? By turning off Theft Attempt mode, your bike will restore back to safe mode until the next trigger. ",
              textAlign: TextAlign.center,
              style: EvieTextStyles.body18,),
            svgpicture: SvgPicture.asset(
              "assets/images/deactivate_theft_alert.svg",
            ),
            upContent: "Cancel",
            downContent: "Confirm Dismiss",
            onPressedUp: () {
              SmartDialog.dismiss();
            },
            onPressedDown: () {
              _bikeProvider.updateBikeStatus('safe');
              showTheftDismiss(buildContext);
              SmartDialog.dismiss();
            });
      },
    )
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
        "Enable Camera",
        style: EvieTextStyles.h2,
        textAlign: TextAlign.center,
      ),
      childContent: Text(
        "EVIE app needs access to your camera roll for scanning QR codes.",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/enable_camera.svg"),
      upContent: "Go to Setting",
      downContent: "No, Thanks",
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

showSyncRideThrive3(){
  /// icon not yet altered
  SmartDialog.show(
    widget: Evie4OneButtonDialog(),
  );
}

///Allow location permission to access Orbital Anti_Theft
///icon paddings need to be altered
showEvieAllowOrbitalDialog(LocationProvider _locationProvider){
  SmartDialog.show(
      widget:Evie2IconBatchOneButtonDialog(
          title: "Worry-free with \n EV-Secure",
          miniTitle1: "Orbital Anti-theft",
          miniTitle2: "GPS Tracking",
          content1:"Built-in theft detection. Receive instant security alerts when a theft attempt is detected." ,
          content2:"Monitor your bike’s location remotely. Be notified when your bike move beyond its GPS Geofence." ,
          middleContent: "Allow Location",
          onPressedMiddle: () async {
            //SmartDialog.dismiss();
            if (await Permission.location.request().isGranted && await Permission.locationWhenInUse.request().isGranted) {

            }else if(await Permission.location.isPermanentlyDenied || await Permission.location.isDenied){
              //OpenSettings.openLocationSourceSetting();
            }
            _locationProvider.checkLocationPermissionStatus();
            SmartDialog.dismiss();
          }));
}

///Exit Orbital Anti-Theft
showEvieExitOrbitalDialog(BuildContext context) {
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
      title: Text(
        "Exit EV-Secure Page?",
        style: EvieTextStyles.h2,
        textAlign: TextAlign.center,
      ),
      childContent: Text(
        "Are you sure you would like to exit EV-Secure page?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/exit_anti_theft.svg"),
      upContent: "Exit EV-Secure Page",
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
          "assets/images/full_reset_your_bike.svg",
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
      keepSingle: true,
      widget: EvieClubDialog()
  );

  // SmartDialog.show(
  //     keepSingle: true,
  //     widget: EvieClubDialog(
  //         title: "Welcome to the EV+ \nClub!",
  //         content: "Are you ready for an adventure? "
  //             "Perks of having an EV+ subscription include having access rto exclusive features such as "
  //             "GPS Tracking, Theft Detection, Ride History and more!",
  //         middleContent: "Let's Go!",
  //         svgpicture: SvgPicture.asset(
  //           "assets/images/ev_club.svg",
  //         ),
  //         onPressedMiddle: (){
  //           SmartDialog.dismiss();
  //         })
  // );

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
          "assets/images/unlink_your_bike.svg",
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

  Widget? animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: false);

  Future.delayed(Duration.zero).then((value) {
    _bikeProvider.blockConnectingToast(true);
  });

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
                  animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: false);
                  Future.delayed(Duration.zero).then((value) {
                    _bikeProvider.blockConnectingToast(false);
                  });
                  SmartDialog.dismiss();
                }  else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connecting ||
                    _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanning ||
                    _bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected) {
                  animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: true);
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
                          Text('Connecting Bike', style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),)
                        ],
                      );
                }
                else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected) {
                  buttonImage = Text('Connect Bike', style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),);
                  animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: false);
                  Future.delayed(Duration.zero).then((value) {
                    _bikeProvider.blockConnectingToast(false);
                  });
                  SmartDialog.dismiss();
                }
                else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout) {
                  animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: false);
                  _bikeProvider.blockConnectingToast(false);
                  SmartDialog.dismiss();
                }
                else {
                  animation = Lottie.asset('assets/images/connect-to-bike.json', repeat: true, animate: false);
                  buttonImage = Text('Connect Bike', style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),);
                }

                return EvieConnectingDialog(
                    title: Text("Connect Your Bike",
                      style: EvieTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    childContent: Text(
                      "Ready for the next step? Simply connect with your bike to unlock and experience the next stage of this process.",
                      textAlign: TextAlign.center,
                      style: EvieTextStyles.body18,),
                    // svgpicture: SvgPicture.asset(
                    //   "assets/images/connect_your_bike.svg",
                    // ),
                    havePic: false,
                    lottie: Container(
                      padding: EdgeInsets.zero,
                      //color: Colors.red,
                      child: animation
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

                        await _bluetoothProvider.stopScan();
                        await _bluetoothProvider.connectSubscription?.cancel();
                        await _bluetoothProvider.disconnectDevice();
                        _bluetoothProvider.switchBikeDetected();
                        _bluetoothProvider.startScanTimer?.cancel();
                      }
                      Future.delayed(Duration.zero).then((value) {
                        _bikeProvider.blockConnectingToast(false);
                      });
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
          "assets/images/lost_your_password.svg",
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


showThreatDialog(BuildContext context) {
  SmartDialog.show(
    //keepSingle: true,
    clickBgDismissTemp: false,
    backDismiss: false,
    widget: ThreatDialog(contextS: context,),
    tag: 'threat'
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

      customButtonUp:  EvieButton(
          width: double.infinity,
          height: 48.h,
          child: Text(
            "Continue Unlock Bike",
            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.white),
          ),
          onPressed: () async {
            SmartDialog.dismiss();
          },
        ),

        customButtonDown: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: EvieButton_ReversedColor(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Exit Unlock Bike",
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
                SmartDialog.dismiss(status: SmartStatus.allDialog);
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

showSoftwareUpdate(BuildContext context, FirmwareProvider firmwareProvider, StreamSubscription? stream, BluetoothProvider bluetoothProvider, SettingProvider settingProvider) {
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Better Bike Software Update",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Get more out of your EVIE bike with the latest software update. Charge your bike and ensure stable Wi-Fi connection before updating. Tip: Stay connected during update.",
          textAlign: TextAlign.center,
          style: EvieTextStyles.body18,),
        svgpicture: SvgPicture.asset(
          "assets/images/better_bike_software_update.svg",
        ),
        upContent: "Update Now",
        downContent: "Cancel",
        onPressedUp: () async {
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
        },
        onPressedDown: () {
          SmartDialog.dismiss();
        }),
  );
}


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
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sheet_2.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/test/widget_test.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_radio_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screen/my_bike_setting/my_bike_function.dart';
import '../widgets/evie_checkbox.dart';
import '../widgets/evie_divider.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_switch.dart';
import '../widgets/evie_textform.dart';
import 'colours.dart';
import 'navigator.dart';

showQuitApp(){
  SmartDialog.show(
      widget: EvieDoubleButtonDialog(
          title: "Close this app?",
          childContent: const Text("Are you sure you want to close this App?"),
          leftContent: "No",
          rightContent: "Yes",
          onPressedLeft: () {
            SmartDialog.dismiss();
          },
          onPressedRight: () {
            SystemNavigator.pop();
          }));
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
            "assets/images/allow_camera.svg",
          ),
          content: "Serial Number and Validation Key can be found on the back side of greeting card.",
          rightContent: "Ok",
          onPressedRight:(){SmartDialog.dismiss();})
  );
}

showBackToLogin(context, BikeProvider _bikeProvider, AuthProvider _authProvider){
  SmartDialog.show(
      widget:
      EvieDoubleButtonDialog(
          title: "Back to Login Page?",
          childContent: Text("Are you sure you want to sign out and back to login page?"),
          leftContent: "No",
          rightContent: "Yes",
          onPressedLeft: (){SmartDialog.dismiss();},
          onPressedRight: () async {
            SmartDialog.dismiss();
            SmartDialog.showLoading();
            await _authProvider.signOut(context).then((result) async {
              if(result == true){
                await _bikeProvider.clear();
                SmartDialog.dismiss(status: SmartStatus.loading);
                // _authProvider.clear();

                changeToWelcomeScreen(context);
                SmartDialog.dismiss();
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text('Signed out'),
                    duration: Duration(
                        seconds: 2),),
                );
              }else{
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
              changeToTurnOnNotificationsScreen(context);
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
      onPressedRight: () async {
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

showDeleteShareBikeUser(BikeProvider _bikeProvider, int index){

  SmartDialog.show(
      widget: EvieDoubleButtonDialog(
        title: "Are you sure you want to delete this user",
        childContent: Text('Are you sure you want to delete ${_bikeProvider.bikeUserDetails.values.elementAt(index).name!}',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
        leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
        rightContent: "Yes",
        onPressedRight: () async {
          SmartDialog.dismiss();
          SmartDialog.showLoading();

          StreamSubscription? currentSubscription;

          ///Cancel user invitation
          if(_bikeProvider.bikeUserList.values.elementAt(index).status == "pending"){
            currentSubscription = _bikeProvider.cancelSharedBike(
                _bikeProvider.bikeUserList.values.elementAt(index).uid,
                _bikeProvider.bikeUserList.values.elementAt(index).notificationId!).listen((uploadStatus) {

              if(uploadStatus == UploadFirestoreResult.success){
                SmartDialog.dismiss(status: SmartStatus.loading);
                SmartDialog.show(
                    keepSingle: true,
                    widget: EvieSingleButtonDialog(
                        title: "Success",
                        content: "You canceled the invitation",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(uploadStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialog(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }else{};

            },
            );
          }else{

            ///Remove user
            currentSubscription = _bikeProvider.removedSharedBike(
                _bikeProvider.bikeUserList.values.elementAt(index).uid,
                _bikeProvider.bikeUserList.values.elementAt(index).notificationId!).listen((uploadStatus) {

              if(uploadStatus == UploadFirestoreResult.success){

                SmartDialog.dismiss(status: SmartStatus.loading);
                SmartDialog.show(
                    keepSingle: true,
                    widget: EvieSingleButtonDialog(
                        title: "Success",
                        content: "You removed the user",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(uploadStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialog(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }else{}

            },
            );}}));
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


showExitOrbitalAntiTheft(BuildContext context){
  SmartDialog.show(
      widget: EvieDoubleButtonDialog(
          title: "Exit Orbital Anti-theft?",
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
         rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();} ));
}

///V DIALOGS
///Email resent
showEvieResendDialog(BuildContext context, String email) {
  SmartDialog.show(
    widget: EvieOneDialog(
        title: "Email re-sent",
        content1: "We've re-sent email to ",
        content2: ". Do check the spam mailbox too!",
        email: email,
        middleContent: "Done",
        onPressedMiddle: () {
          SmartDialog.dismiss();
        }));
}

showErrorLoginDialog (BuildContext context){
  SmartDialog.show(
    widget: EvieTwoButtonDialog(
        title: Text("Login Error",
          style:EvieTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        childContent: Text("Oops, the password you "
            "entered is incorrect or you do not have an account yet. "
            "Please double-check and try again",
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
        "Are you sure you want to cancel registering your bike?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/people_search.svg"),
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
          title: "Where to find QR Code?",
          content: "QR code can be found on the ownership card.",
          middleContent: "Done",
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }
          ));
}

///where to find serial number and validation key
showEvieFindSerialDialog(BuildContext context){
  SmartDialog.show(
      widget: EvieOneButtonDialog(
          title: "Where to find these?",
          content: "Serial Number and Validation Key can be found on the ownership card.",
          middleContent: "Done",
          onPressedMiddle: () {
            SmartDialog.dismiss();
          }
          ));
}

///free/paid plan bluetooth connection
showEviePlanBluetoothDialog (BuildContext context){
  /// icon not yet altered
  SmartDialog.show(
      widget: Evie2IconOneButtonDialog(
          title: "Sync. Ride. Thrive.",
          miniTitle1: "Stay Connected",
          miniTitle2: "One Tap Unlock",
          content1:"Seamlessly sync your bike and stay in control with Bluetooth connectivity." ,
          content2:"Security has never been this convenient with EVIE's built-in locking system." ,
          middleContent: "Allow Bluetooth",
          onPressedMiddle: (){
            SmartDialog.dismiss();
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
                    }));;
          }));

}

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
        "Are you sure you would like to exit the Orbital Anti-theft page?",
        textAlign: TextAlign.center,
        style: EvieTextStyles.body18,
      ),
      svgpicture: SvgPicture.asset("assets/images/people_search.svg"),
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





import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/firmware_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../screen/my_bike_setting/my_bike_function.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_textform.dart';
import 'navigator.dart';

showBluetoothNotTurnOn() {
  SmartDialog.show(
      keepSingle: true,
      widget: EvieSingleButtonDialogCupertino(
          title: "Error",
          content: "Bluetooth is off, please turn on your bluetooth",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          }));
}

showBluetoothNotSupport() {
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialogCupertino(
          title: "Error",
          content: "Bluetooth unsupported",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog
                .dismiss();
          }));
}

showBluetoothNotAuthorized() {
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialogCupertino(
          title: "Error",
          content: "Bluetooth Permission is off",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog
                .dismiss();
          }));
}

showLocationServiceDisable() {
  SmartDialog.show(
      keepSingle:
      true,
      widget: EvieSingleButtonDialogCupertino(
          title: "Error",
          content: "Location service disabled",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog
                .dismiss();
          }));
}

showConnectDialog(BluetoothProvider bluetoothProvider) async {
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
        await bluetoothProvider.disconnectDevice();
        await bluetoothProvider.stopScan();
        bluetoothProvider.startScanAndConnect();
        SmartDialog.dismiss();
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
      widget: EvieSingleButtonDialogCupertino
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
      widget: EvieSingleButtonDialogCupertino
        (title: "Not Success",
          content: "An error occur, try again",
          rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();} ));
}


showDeleteShareBikeUser(BikeProvider _bikeProvider, int index){

  SmartDialog.show(
      widget: EvieDoubleButtonDialogCupertino(
        title: "Are you sure you want to delete this user",
        content: 'Are you sure you want to delete ${_bikeProvider.bikeUserDetails.values.elementAt(index).name!}',
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
                    widget: EvieSingleButtonDialogCupertino(
                        title: "Success",
                        content: "You canceled the invitation",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(uploadStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialogCupertino(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }

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
                    widget: EvieSingleButtonDialogCupertino(
                        title: "Success",
                        content: "You removed the user",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(uploadStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialogCupertino(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }

            },
            );}}));
    }

showDeleteNotificationSuccess(){
  SmartDialog.show(
      widget: EvieSingleButtonDialogCupertino(
          title: "Deleted",
          content: "Notification deleted",
          rightContent: "OK",
          onPressedRight: ()=>SmartDialog.dismiss()
      ));
}


showDeleteNotificationFailed(){
  SmartDialog.show(
      widget: EvieSingleButtonDialogCupertino(
          title: "Failed",
          content: "Try again",
          rightContent: "OK",
          onPressedRight: ()=>SmartDialog.dismiss()
      ));
}

showFirmwareUpdate(context, FirmwareProvider firmwareProvider, StreamSubscription? stream, bool isUpdating, BluetoothProvider bluetoothProvider){
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

            Reference ref = FirebaseStorage.instance.refFromURL(firmwareProvider.latestFirmwareModel!.url);
            File file = await firmwareProvider.downloadFile(ref);

            stream = bluetoothProvider.firmwareUpgradeListener.stream.listen((firmwareUpgradeResult) {
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
                firmwareProvider.uploadFirmVerToFirestore("57_V${firmwareProvider.latestFirmVer!}");
                changeToFirmwareUpdateCompleted(context);
              }
              else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeFailed) {
                isUpdating = false;
                stream?.cancel();
                changeToFirmwareUpdateFailed(context);
              }
            });

            bluetoothProvider.startUpgradeFirmware(file);

          })
  );
}

showFirmwareUpdateQuit(context, StreamSubscription? stream){
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
}
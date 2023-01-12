import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../screen/my_bike/my_bike_function.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_textform.dart';

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
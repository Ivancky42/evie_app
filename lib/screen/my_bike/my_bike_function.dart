import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_single_button_dialog.dart';

returnBikeStatusImage(bool isConnected,String status) {
  if (isConnected == false) {
    return "assets/images/bike_HPStatus/bike_warning.png";
  } else {
    switch (status) {
      case "safe":
        return "assets/images/bike_HPStatus/bike_safe.png";
      case "warning":
      case "fall":
        return "assets/images/bike_HPStatus/bike_warning.png";
      case "danger":
      case "crash":
        return "assets/images/bike_HPStatus/bike_danger.png";
      default:
        return CircularProgressIndicator();
    }
  }
}


checkBLEPermissionAndAction(BluetoothProvider _bluetoothProvider, DeviceConnectionState? connectionState, connectStream){
  var bleStatus = _bluetoothProvider.bleStatus;
  switch (bleStatus) {
    case BleStatus.poweredOff:
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialogCupertino(
              title: "Error",
              content: "Bluetooth is off, please turn on your bluetooth",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();
              }));
      break;
    case BleStatus.unknown:
    // TODO: Handle this case.
      break;
    case BleStatus.unsupported:
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialogCupertino(
              title: "Error",
              content: "Bluetooth unsupported",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();
              }));
      break;
    case BleStatus.unauthorized:
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
      break;
    case BleStatus.locationServicesDisabled:
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialogCupertino(
              title: "Error",
              content: "Location service disabled",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();
              }));
      break;
    case BleStatus.ready:
      if (connectionState == null || connectionState == DeviceConnectionState.disconnected) {
        connectStream = _bluetoothProvider.startScanAndConnect();
      } else {}
      break;
    default:
      break;
  }
}


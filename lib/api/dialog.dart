import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../screen/my_bike/my_bike_function.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';

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

Future<String?> showConnectDialog(BluetoothProvider bluetoothProvider, String? label) async {
  String? result;
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
        await bluetoothProvider.disconnectDevice();
        await bluetoothProvider.stopScan();
        bluetoothProvider.startScanAndConnect();
        SmartDialog.dismiss();
        result = "CANCEL";
      },
      onPressedRight: () {
        SmartDialog.dismiss();
        result = "OK";
      })
  ).then((value) {
    if (result == "OK") {
      return label;
    }
    else {
      return null;
    }
  });
}
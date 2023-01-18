// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
//
// import '../../api/provider/bluetooth_provider.dart';
// import '../../bluetooth/modelResult.dart';
// import '../../widgets/evie_single_button_dialog.dart';
//
//
// checkBLEPermissionAndAction(BluetoothProvider _bluetoothProvider, DeviceConnectResult? deviceConnectResult, connectStream){
//   var bleStatus = _bluetoothProvider.bleStatus;
//   switch (bleStatus) {
//     case BleStatus.poweredOff:
//       SmartDialog.show(
//           keepSingle: true,
//           widget: EvieSingleButtonDialogCupertino(
//               title: "Error",
//               content: "Bluetooth is off, please turn on your bluetooth",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog.dismiss();
//               }));
//       break;
//     case BleStatus.unknown:
//     // TODO: Handle this case.
//       break;
//     case BleStatus.unsupported:
//       SmartDialog.show(
//           keepSingle: true,
//           widget: EvieSingleButtonDialogCupertino(
//               title: "Error",
//               content: "Bluetooth unsupported",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog.dismiss();
//               }));
//       break;
//     case BleStatus.unauthorized:
//       SmartDialog.show(
//           keepSingle:
//           true,
//           widget: EvieSingleButtonDialogCupertino(
//               title: "Error",
//               content: "Bluetooth Permission is off",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog
//                     .dismiss();
//               }));
//       break;
//     case BleStatus.locationServicesDisabled:
//       SmartDialog.show(
//           keepSingle: true,
//           widget: EvieSingleButtonDialogCupertino(
//               title: "Error",
//               content: "Location service disabled",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog.dismiss();
//               }));
//       break;
//     case BleStatus.ready:
//       if (deviceConnectResult == null) {
//         handleConnection(connectStream, _bluetoothProvider);
//       }
//       else {
//         if (deviceConnectResult == DeviceConnectResult.disconnected
//             || deviceConnectResult == DeviceConnectResult.scanTimeout
//             || deviceConnectResult == DeviceConnectResult.connectError
//             || deviceConnectResult == DeviceConnectResult.scanError
//         ) {
//           handleConnection(connectStream, _bluetoothProvider);
//         } else {}
//       }
//       break;
//     default:
//       break;
//   }
// }
//
//
// handleConnection(connectStream, _bluetoothProvider) async {
//   await _bluetoothProvider.disconnectDevice();
//   await _bluetoothProvider.stopScan();
//   connectStream = _bluetoothProvider.startScanAndConnect().listen((deviceConnectResult) {
//     switch(deviceConnectResult){
//       case DeviceConnectResult.scanning:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.scanTimeout:
//         connectStream?.cancel();
//         _bluetoothProvider.clearDeviceConnectStatus();
//         SmartDialog.show(
//             tag: "SCAN_TIMEOUT",
//             widget: EvieSingleButtonDialogCupertino(
//                 title: "Cannot connect bike",
//                 content: "Scan timeout",
//                 rightContent: "OK",
//                 onPressedRight: () {
//                   SmartDialog.dismiss();
//                 }));
//         break;
//       case DeviceConnectResult.scanError:
//         _bluetoothProvider.clearDeviceConnectStatus();
//         connectStream?.cancel();
//         SmartDialog.show(
//             keepSingle: true,
//             widget: EvieSingleButtonDialogCupertino(
//                 title: "Cannot connect bike",
//                 content: "Scan error",
//                 rightContent: "OK",
//                 onPressedRight: () {
//                   SmartDialog.dismiss();
//                 }));
//         // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.connecting:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.partialConnected:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.connected:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.disconnecting:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.disconnected:
//       // TODO: Handle this case.
//         break;
//       case DeviceConnectResult.connectError:
//         _bluetoothProvider.clearDeviceConnectStatus();
//         connectStream?.cancel();
//         SmartDialog.show(
//             keepSingle: true,
//             widget: EvieSingleButtonDialogCupertino(
//                 title: "Cannot connect bike",
//                 content: "Connect error",
//                 rightContent: "OK",
//                 onPressedRight: () {
//                   SmartDialog.dismiss();
//                 }));
//         break;
//     }
//   });
// }
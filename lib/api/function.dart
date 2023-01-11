import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

checkBleStatusAndConnectDevice(BluetoothProvider _bluetoothProvider) {
  BleStatus? bleStatus = _bluetoothProvider.bleStatus;
  switch (bleStatus) {
    case BleStatus.poweredOff:
      showBluetoothNotTurnOn();
      break;
    case BleStatus.unsupported:
      showBluetoothNotSupport();
      break;
    case BleStatus.unauthorized:
      showBluetoothNotAuthorized();
      break;
    case BleStatus.locationServicesDisabled:
      showLocationServiceDisable();
      break;
    case BleStatus.ready:
      connectDevice(_bluetoothProvider);
      break;
    default:
      break;
  }
}

connectDevice(BluetoothProvider _bluetoothProvider) async {
  DeviceConnectResult? deviceConnectResult = _bluetoothProvider.deviceConnectResult;
  if (deviceConnectResult == null
      || deviceConnectResult == DeviceConnectResult.disconnected
      || deviceConnectResult == DeviceConnectResult.scanTimeout
      || deviceConnectResult == DeviceConnectResult.connectError
      || deviceConnectResult == DeviceConnectResult.scanError)
  {
    await _bluetoothProvider.disconnectDevice();
    await _bluetoothProvider.stopScan();
    _bluetoothProvider.startScanAndConnect();
  }
}
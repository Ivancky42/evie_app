import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:evie_test/bluetooth/bluetooth_command.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hex/hex.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothProvider extends ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  final bluetoothCommand = BluetoothCommand();
  Uuid serviceUUID = Uuid.parse("49535343-fe7d-4ae5-8fa9-9fafd205e455");
  Uuid notifyingUUID = Uuid.parse("49535343-1e4d-4bd9-ba61-23c647249616");
  Uuid writeUUID = Uuid.parse("49535343-8841-43f4-a8d4-ecbe34729bb3");

  StreamSubscription? scanSubscription;
  StreamSubscription? connectSubscription;
  StreamSubscription? notifySubscription;

  ConnectionStateUpdate? connectionStateUpdate;
  BleStatus? bleStatus;
  String? selectedDeviceId;

  LinkedHashMap<String, DiscoveredDevice> discoverDeviceList = LinkedHashMap<String, DiscoveredDevice>();

  BluetoothProvider() {
    init();
  }

  void init() {
    flutterReactiveBle.statusStream.listen((status) async {
      bleStatus = status;
      printLog("BLE Status", bleStatus.toString());

      switch (bleStatus) {
        case BleStatus.unknown:
          // TODO: Handle this case.
          break;
        case BleStatus.unsupported:
          // TODO: Handle this case.
          break;
        case BleStatus.unauthorized:
          handlePermission();
          break;
        case BleStatus.poweredOff:
          // TODO: Handle this case.
          break;
        case BleStatus.locationServicesDisabled:
          // TODO: Handle this case.
          break;
        case BleStatus.ready:
          // TODO: Handle this case.
          break;
        default:
          break;
      }

      notifyListeners();
    });
  }

  void startScan() {
    discoverDeviceList.clear();
    scanSubscription = flutterReactiveBle.scanForDevices(scanMode: ScanMode.lowLatency, withServices: []).listen((device) {
      if (device.name.contains("REEVO")) {
        discoverDeviceList.update(device.id, (existingDevice) => device, ifAbsent: () => device,);
        notifyListeners();
      }
    }, onError: (error) {
      discoverDeviceList.clear();
      print(error);
    });
  }

  void stopScan() {
    scanSubscription?.cancel();
  }
  
  void connectDevice(String deviceId) async {

    if (selectedDeviceId != null) {
      await disconnectDevice(selectedDeviceId!);
    }

    selectedDeviceId = deviceId;

    connectSubscription = flutterReactiveBle.connectToDevice(id: selectedDeviceId!, connectionTimeout: const Duration(seconds: 10),).listen((event) {

      connectionStateUpdate = event;

      printLog("Connect State", connectionStateUpdate!.deviceId);
      printLog("Connect State", connectionStateUpdate!.connectionState.name);
      printLog("Connect State", connectionStateUpdate!.failure.toString());

      switch(connectionStateUpdate?.connectionState) {
        case DeviceConnectionState.connecting:
          // TODO: Handle this case.
          break;
        case DeviceConnectionState.connected:
          discoverServices(connectionStateUpdate!.deviceId);
          break;
        case DeviceConnectionState.disconnecting:
          stopServices(connectionStateUpdate!.deviceId);
          break;
        case DeviceConnectionState.disconnected:
          // TODO: Handle this case.
          break;
        default:
          break;
      }
      notifyListeners();
    }, onError: (error) {
      printLog("Connect Error", error.toString());
    });
  }

  disconnectDevice(String deviceId) async {

    if (notifySubscription != null) {
      await notifySubscription!.cancel();
    }

    if (connectSubscription != null) {
      await connectSubscription!.cancel();
    }

    connectionStateUpdate = ConnectionStateUpdate(deviceId: deviceId, connectionState: DeviceConnectionState.disconnected, failure: null);
    notifyListeners();
  }

  void discoverServices(String deviceId) async {
    final notifyCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: notifyingUUID, deviceId: deviceId);
    notifySubscription = flutterReactiveBle.subscribeToCharacteristic(notifyCharacteristic).listen((data) {
      printLog("Notify Value", deviceId + " " + utf8.decode(data));
      handleNotifyData(data);
    }, onError: (dynamic error) {
      printLog("Notify Error", error.toString());
    });
  }

  void stopServices(String deviceId) async {
    await flutterReactiveBle.clearGattCache(deviceId);
    await notifySubscription?.cancel();
  }

  void sendCommand(String deviceId, String value) async {
    final writeCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: writeUUID, deviceId: deviceId);
    await flutterReactiveBle.writeCharacteristicWithoutResponse(writeCharacteristic, value: ('0:C-0-3,' + (DateTime.now().millisecondsSinceEpoch/1000).floor().toString() + '@').codeUnits);
  }

  void requestKey(String deviceId, String value) async {
    final writeCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: writeUUID, deviceId: deviceId);
    await flutterReactiveBle.writeCharacteristicWithoutResponse(writeCharacteristic, value: bluetoothCommand.requestKey("yOTmK50z"));
  }

  void handleNotifyData(List<int> data) {
    // List<int> decodedData = bluetoothCommand.decodeData([0xA3, 0xA4, 0x02, 0xB0, 0x27, 0x7F, 0x7F, 0x27, 0x1A]);
    List<int> decodedData = bluetoothCommand.decodeData(data);
    var command = decodedData[5];

    if (command == bluetoothCommand.requestKeyCmd) {
      //requestKeyDataListener;
    }
  }

  void handlePermission() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      return;
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      return;
    }

    status = await Permission.bluetoothScan.request();
    if (status.isPermanentlyDenied) {
      return;
    }
  }

  void printLog(String title, String log) {
    if (kDebugMode) {
      print(DateTime.now().toString() + " " + title + " : " + log);
    }
  }
}

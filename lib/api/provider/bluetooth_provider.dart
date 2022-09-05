import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:evie_test/bluetooth/command.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bluetooth/model.dart';


class BluetoothProvider extends ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  final bluetoothCommand = BluetoothCommand();
  static Uuid serviceUUID = Uuid.parse("49535343-fe7d-4ae5-8fa9-9fafd205e455");
  static Uuid notifyingUUID = Uuid.parse("49535343-1e4d-4bd9-ba61-23c647249616");
  static Uuid writeUUID = Uuid.parse("49535343-8841-43f4-a8d4-ecbe34729bb3");

  StreamSubscription? scanSubscription;
  StreamSubscription? connectSubscription;
  StreamSubscription? notifySubscription;

  ConnectionStateUpdate? connectionStateUpdate;
  BleStatus? bleStatus;
  String? selectedDeviceId;

  LinkedHashMap<String, DiscoveredDevice> discoverDeviceList = LinkedHashMap<String, DiscoveredDevice>();

  RequestComKeyResult? requestComKeyResult;
  late ErrorPromptResult errorPromptResult;
  late UnlockResult unlockResult;

  /// * Command Listener ***/
  StreamController<UnlockResult> unlockResultListener = StreamController.broadcast();
  StreamController<ChangeBleKeyResult> chgBleKeyResultListener = StreamController.broadcast();

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
          discoverServices();
          break;
        case DeviceConnectionState.disconnecting:
          stopServices();
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

  void discoverServices() async {
    final notifyCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: notifyingUUID, deviceId: connectionStateUpdate!.deviceId);
    notifySubscription = flutterReactiveBle.subscribeToCharacteristic(notifyCharacteristic).listen((data) {
      printLog("Notify Value", connectionStateUpdate!.deviceId + " " + utf8.decode(data));
      handleNotifyData(data);
    }, onError: (dynamic error) {
      printLog("Notify Error", error.toString());
    });

    sendCommand(bluetoothCommand.getComKey('yOTmK50z')); /// Get communication key from device.
  }

  void stopServices() async {
    await flutterReactiveBle.clearGattCache(connectionStateUpdate!.deviceId);
    await notifySubscription?.cancel();
  }

  bool sendCommand(List<int> command) {
    if (connectionStateUpdate?.connectionState == DeviceConnectionState.connected) {
      final writeCharacteristic = QualifiedCharacteristic(
          serviceId: serviceUUID,
          characteristicId: writeUUID,
          deviceId: selectedDeviceId!);
      flutterReactiveBle.writeCharacteristicWithoutResponse(
          writeCharacteristic, value: command);

      return true;
    }
    else {
      return false;
    }
  }

  void handleNotifyData(List<int> data) {
    //List<int> decodedData = [0xA3, 0xA4, 0x09, 0xB0, 0x27, 0x32, 0x01, 0x0C, 0x0A, 0x0B, 0x01, 0x02, 0x02, 0x02, 0x02];
    List<int> decodedData = bluetoothCommand.decodeData(data); //Decode data and get actual data
    if (decodedData.isEmpty) {
      /// CRC value not valid. Failed decoded. Ignore invalid data.
    }
    else {
      var command = decodedData[5];
      switch(command) {
        case BluetoothCommand.requestComKeyCmd :
          requestComKeyResult = RequestComKeyResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.errorPromptInstruction :
          errorPromptResult = ErrorPromptResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.unlockBikeCmd :
          unlockResultListener.add(UnlockResult(decodedData));
          break;
        case BluetoothCommand.changeBleKeyCmd :
          chgBleKeyResultListener.add(ChangeBleKeyResult(decodedData));
          break;
        default:
          break;
      }
    }
  }

  bool checkIsBluetoothOn() {
    if (bleStatus == BleStatus.ready) {
      return true;
    }
    else {
      return false;
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

  /// **********************/
  /// *** Command Action ***/
  /// **********************/

  /// 1). Function for unlock bike and listening for acknowledge status from bike.
  Stream<UnlockResult> unlockBike(int userId, int timestamp) {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.unlockBike(requestComKeyResult!.communicationKey, userId, timestamp));
      if (isConnected) {
        return unlockResultListener.stream.timeout(
            const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      }
      else {
        return unlockResultListener.stream.timeout(const Duration(milliseconds: 500), onTimeout: (sink){
          sink.addError("Bike is not connected");
        });
      }
    }
    else {
      return unlockResultListener.stream.timeout(const Duration(milliseconds: 500), onTimeout: (sink){
        sink.addError("Communication key is empty value");
      });
    }
  }

  /// 2). Function for change BLE Key and listening for acknowledge status from bike.
  Stream<ChangeBleKeyResult> changeBleKey() {
    requestComKeyResult = RequestComKeyResult([0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01]);
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.changeBleKey(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return chgBleKeyResultListener.stream.timeout(
            const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      }
      else {
        return chgBleKeyResultListener.stream.timeout(const Duration(milliseconds: 500), onTimeout: (sink){
          sink.addError("Bike is not connected.");
        });
      }
    }
    else {
      return chgBleKeyResultListener.stream.timeout(const Duration(milliseconds: 500), onTimeout: (sink){
        sink.addError("Communication key is empty value");
      });
    }
  }

  /// 3). Function for change MQTT login password and listening for acknowledge status from bike. *4.5.9
  // TODO: Handle this case.

  /// 4). Function for enable/disable GPS tracking and listening for acknowledge status from bike. *4.5.10
  // TODO: Handle this case.

  /// 5). Function for add RFID card and listening for acknowledge status from bike. *4.5.11
  // TODO: Handle this case.

  /// 6). Function for delete RFID card and listening for acknowledge status from bike. *4.5.11
  // TODO: Handle this case.

}

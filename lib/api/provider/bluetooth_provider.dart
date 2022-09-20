import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/bluetooth/command.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bluetooth/model.dart';
import '../../widgets/evie_double_button_dialog.dart';
import 'package:open_settings/open_settings.dart';

import '../model/bike_user_model.dart';
import '../model/user_bike_model.dart';
import '../model/user_model.dart';
import '../navigator.dart';
import 'bike_provider.dart';

class BluetoothProvider extends ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  final bluetoothCommand = BluetoothCommand();

  static Uuid serviceUUID =
      Uuid.parse(dotenv.env['BLE_SERVICE_UUID'] ?? 'UUID not found');
  static Uuid notifyingUUID =
      Uuid.parse(dotenv.env['BLE_NOTIFY_UUID'] ?? 'UUID not found');
  static Uuid writeUUID =
      Uuid.parse(dotenv.env['BLE_WRITE_UUID'] ?? 'UUID not found');
  String? mainBatteryLevel = "Unknown";

  StreamSubscription? scanSubscription;
  StreamSubscription? connectSubscription;
  StreamSubscription? notifySubscription;

  ConnectionStateUpdate? connectionStateUpdate;
  BleStatus? bleStatus;
  String? selectedDeviceId;

  LinkedHashMap<String, DiscoveredDevice> discoverDeviceList =
      LinkedHashMap<String, DiscoveredDevice>();

  RequestComKeyResult? requestComKeyResult;
  late ErrorPromptResult errorPromptResult;
  late UnlockResult unlockResult;
  UserModel? currentUserModel;

  bool _isPaired = false;
  bool get isPaired => _isPaired;

  String? _deviceID;
  String? get deviceID => _deviceID;

  /// * Command Listener ***/
  StreamController<UnlockResult> unlockResultListener =
      StreamController.broadcast();
  StreamController<ChangeBleKeyResult> chgBleKeyResultListener =
      StreamController.broadcast();

  Future<void> init(currentUserModel) async {
    checkBLEStatus();
    if (currentUserModel != null) {
      this.currentUserModel = currentUserModel;
      notifyListeners();
    }
  }

  checkBLEStatus() async {
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
    scanSubscription = flutterReactiveBle.scanForDevices(
        scanMode: ScanMode.lowLatency, withServices: []).listen((device) {
      if (device.name.contains("REEVO")) {
        discoverDeviceList.update(
          device.id,
          (existingDevice) => device,
          ifAbsent: () => device,
        );
        notifyListeners();
      }
    }, onError: (error) {
      stopScan();
      scanSubscription = null;
      discoverDeviceList.clear();
      notifyListeners();
      debugPrint(error.toString());
    });
  }

  void stopScan() {
    scanSubscription?.cancel();
  }

  connectDevice(String deviceId) async {
    if (selectedDeviceId != null) {
      await disconnectDevice(selectedDeviceId!);
    }

    selectedDeviceId = deviceId;

    connectSubscription = flutterReactiveBle
        .connectToDevice(
      id: selectedDeviceId!,
      connectionTimeout: const Duration(seconds: 10),
    )
        .listen((event) {
      connectionStateUpdate = event;

      printLog("Connect State", connectionStateUpdate!.deviceId);
      printLog("Connect State", connectionStateUpdate!.connectionState.name);
      printLog("Connect State", connectionStateUpdate!.failure.toString());

      switch (connectionStateUpdate?.connectionState) {
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

    connectionStateUpdate = ConnectionStateUpdate(
        deviceId: deviceId,
        connectionState: DeviceConnectionState.disconnected,
        failure: null);
    notifyListeners();
  }

  void setIsPairedResult(bool result) {
    _isPaired = result;
    notifyListeners();
  }


  ///Discover device service and characteristic
  void discoverServices() async {
    final notifyCharacteristic = QualifiedCharacteristic(
        serviceId: serviceUUID,
        characteristicId: notifyingUUID,
        deviceId: connectionStateUpdate!.deviceId);
    notifySubscription = flutterReactiveBle
        .subscribeToCharacteristic(notifyCharacteristic)
        .listen((data) async {
      printLog("Notify Value",
          connectionStateUpdate!.deviceId + " " + utf8.decode(data));
      handleNotifyData(data);

      ///==========================REEVO START=============================

      String? mainBatteryLevel = "Unknown";

      Uint8List bytes = Uint8List.fromList(data);
      String notifyValue = String.fromCharCodes(bytes);
      //print(notifyValue);

      if (notifyValue.contains('R-1-1')) {
        var data = notifyValue.split(",");
        mainBatteryLevel = data[1].trim();
      } else if (notifyValue.contains('R-0-1')) {
        if (notifyValue.contains(':R-0-1')) {
          var data = notifyValue.split(",");
          if (data[7].toString().length == 12) {
            print(data[7].toString());

            _isPaired = true;
            _deviceID = data[7].toString();
            notifyListeners();

          }
        }
      }

      notifyListeners();

      ///==========================REEVO END=============================

    }, onError: (dynamic error) {
      printLog("Notify Error", error.toString());
    });

    sendCommand(bluetoothCommand.getComKey('yOTmK50z'));

    /// Get communication key from device.
  }

  void stopServices() async {
    await flutterReactiveBle.clearGattCache(connectionStateUpdate!.deviceId);
    await notifySubscription?.cancel();
  }

  bool sendCommand(List<int> command) {
    if (connectionStateUpdate?.connectionState ==
        DeviceConnectionState.connected) {
      final writeCharacteristic = QualifiedCharacteristic(
          serviceId: serviceUUID,
          characteristicId: writeUUID,
          deviceId: selectedDeviceId!);
      flutterReactiveBle.writeCharacteristicWithoutResponse(writeCharacteristic,
          value: command);

      return true;
    } else {
      return false;
    }
  }

  void handleNotifyData(List<int> data) {
    //List<int> decodedData = [0xA3, 0xA4, 0x09, 0xB0, 0x27, 0x32, 0x01, 0x0C, 0x0A, 0x0B, 0x01, 0x02, 0x02, 0x02, 0x02];
    List<int> decodedData =
        bluetoothCommand.decodeData(data); //Decode data and get actual data
    if (decodedData.isEmpty) {
      /// CRC value not valid. Failed decoded. Ignore invalid data.
    } else {
      var command = decodedData[5];
      switch (command) {
        case BluetoothCommand.requestComKeyCmd:
          requestComKeyResult = RequestComKeyResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.errorPromptInstruction:
          errorPromptResult = ErrorPromptResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.unlockBikeCmd:
          unlockResultListener.add(UnlockResult(decodedData));
          break;
        case BluetoothCommand.changeBleKeyCmd:
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
    } else {
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
      bool isConnected = sendCommand(bluetoothCommand.unlockBike(
          requestComKeyResult!.communicationKey, userId, timestamp));
      if (isConnected) {
        return unlockResultListener.stream.timeout(const Duration(seconds: 6),
            onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return unlockResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected");
        });
      }
    } else {
      return unlockResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  /// 2). Function for change BLE Key and listening for acknowledge status from bike.
  Stream<ChangeBleKeyResult> changeBleKey() {
    requestComKeyResult =
        RequestComKeyResult([0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01]);
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.changeBleKey(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return chgBleKeyResultListener.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return chgBleKeyResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return chgBleKeyResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
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

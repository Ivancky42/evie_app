import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:evie_test/bluetooth/command.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hex/hex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bluetooth/modelResult.dart';

import '../model/bike_model.dart';

enum NotifyDataState {
  notifying,
  getIotInfo,
  firmwareUpgrade,
}

enum FirmwareUpgradeState {
  unknown,
  startUpgrade,
  upgrading,
  upgradeFailed,
  upgradeSuccessfully,
}

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
  StreamSubscription? bleStatusSubscription;

  ConnectionStateUpdate? connectionStateUpdate;
  BleStatus? bleStatus;
  StreamController<BleStatus> bleStatusListener = StreamController.broadcast();
  String? selectedDeviceId;
  IotInfoModel? iotInfoModel;
  String? deviceIMEI;
  String? firmwareVer;
  File? fwFile;
  bool isAutoConnect = false;

  LinkedHashMap<String, DiscoveredDevice> discoverDeviceList = LinkedHashMap<String, DiscoveredDevice>();

  RequestComKeyResult? requestComKeyResult;
  ErrorPromptResult? errorPromptResult;
  BikeInfoResult? bikeInfoResult;
  CableLockResult? cableLockState;
  QueryRFIDCardResult? queryRFIDCardResult;
  BikeModel? currentBikeModel;


  bool _isPaired = false;
  bool get isPaired => _isPaired;

  String? _deviceID;
  String? get deviceID => _deviceID;

  NotifyDataState notifyDataState = NotifyDataState.notifying;

  /// * Get Iot Info **********/
  int iotDataIndex = 0;
  String iotInfoString = "";
  int totalIotPacketData = 0;
  ///*/////////////////////////

  /// * Firmware Upgrade *****/
  int fwUpgradeDataIndex = 0;
  int totalPacketOfFwFile = 0;
  double fwUpgradeProgress = 0;
  bool isFwUpgraded = false;
  FirmwareUpgradeState firmwareUpgradeState = FirmwareUpgradeState.unknown;
  ///*/////////////////////////

  /// * Command Listener ***/

  StreamController<UnlockResult> unlockResultListener =
  StreamController.broadcast();
  StreamController<ChangeBleKeyResult> chgBleKeyResultListener =
  StreamController.broadcast();
  StreamController<ChangeBleNameResult> chgBleNameResultListener =
  StreamController.broadcast();
  StreamController<AddRFIDCardResult> addRFIDCardResultListener =
  StreamController.broadcast();
  StreamController<QueryRFIDCardResult> queryRFIDCardResultListener =
  StreamController.broadcast();
  StreamController<DeleteRFIDCardResult> deleteRFIDCardResult =
  StreamController.broadcast();
  StreamController<CableLockResult> cableLockResult =
  StreamController.broadcast();
  StreamController<MovementSettingResult> chgMoveSettingResultListener =
  StreamController.broadcast();
  StreamController<FactoryResetResult> factoryResetResultListener =
  StreamController.broadcast();
  StreamController<IotInfoModel> iotInfoModelListener =
  StreamController.broadcast();
  late Stream<IotInfoModel> iotInfoModelStream;

  BluetoothProvider() {
    checkBLEStatus();
  }

  Future<void> update(currentBikeModel) async {
    if (currentBikeModel != null) {
      if (this.currentBikeModel != currentBikeModel) {
        this.currentBikeModel = currentBikeModel;
        notifyListeners();

        if (isAutoConnect) {
          startScanAndConnect();
          isAutoConnect = false;
        }
      }
    }
  }

  Stream<BleStatus> checkBLEStatus() {
    bleStatusSubscription?.cancel();
    bleStatusSubscription = flutterReactiveBle.statusStream.listen((status) async {
      bleStatus = status;
      bleStatusListener.add(status);
      printLog("BLE Status", bleStatus.toString());

      switch (bleStatus) {
        case BleStatus.unknown:
        // TODO: Handle this case.
          break;
        case BleStatus.unsupported:
        // TODO: Handle this case.
          break;
        case BleStatus.unauthorized:
        // handlePermission();
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

    return bleStatusListener.stream;
  }

  void startScan() {
    discoverDeviceList.clear();
    scanSubscription = flutterReactiveBle.scanForDevices(scanMode: ScanMode.lowLatency, withServices: []).listen((device) {
      if (device.name.contains("EVIE")) {
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

  stopScan() async {
    await scanSubscription?.cancel();
  }

  setAutoConnect() {
    isAutoConnect = true;
    notifyListeners();
  }

  startScanAndConnect() async {
    await disconnectDevice();
    if (Platform.isAndroid) {
      connectDevice(currentBikeModel!.macAddr!);
    }
    else {
      await stopScan();
      scanSubscription = flutterReactiveBle.scanForDevices(
          scanMode: ScanMode.lowLatency, withServices: []).listen((device) {
        if (device.name == currentBikeModel?.bleName) {
          connectDevice(device.id);
        }
      }, onError: (error) {
        stopScan();
        scanSubscription = null;
      });
    }
  }

  connectDevice(String foundDeviceId) async {

    await scanSubscription?.cancel();

    selectedDeviceId = foundDeviceId;

    connectSubscription = flutterReactiveBle.connectToDevice(id: selectedDeviceId!, connectionTimeout: const Duration(seconds: 6),).listen((event) {
      connectionStateUpdate = event;

      printLog("Connect State", connectionStateUpdate!.deviceId);
      printLog("Connect State", connectionStateUpdate!.connectionState.name);
      printLog("Connect State", connectionStateUpdate!.failure.toString());

      switch (connectionStateUpdate?.connectionState) {
        case DeviceConnectionState.connecting:
        // TODO: Handle this case.
          break;
        case DeviceConnectionState.connected:
          discoverServices(currentBikeModel!.bleKey!);
          break;
        case DeviceConnectionState.disconnecting:
          stopServices();
          break;
        case DeviceConnectionState.disconnected:
        // TODO: Handle this case.
          clearBluetoothStatus();
          connectSubscription?.cancel();
          break;
        default:
          break;
      }
      notifyListeners();
    }, onError: (error) {
      printLog("Connect Error", error.toString());
      connectSubscription?.cancel();
    });
  }

  disconnectDevice() async {

    await notifySubscription?.cancel();
    await Future.delayed(const Duration(milliseconds: 300));
    await connectSubscription?.cancel();
    await Future.delayed(const Duration(milliseconds: 300));


    if (connectionStateUpdate != null) {
      connectionStateUpdate = ConnectionStateUpdate(
          deviceId: connectionStateUpdate!.deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null);
    }
    clearBluetoothStatus();
    notifyListeners();
  }

  void setIsPairedResult(bool result) {
    _isPaired = result;
    notifyListeners();
  }


  ///Discover device service and characteristic
  void discoverServices(String bleKey) async {
    final notifyCharacteristic = QualifiedCharacteristic(
        serviceId: serviceUUID,
        characteristicId: notifyingUUID,
        deviceId: connectionStateUpdate!.deviceId);
    notifySubscription = flutterReactiveBle
        .subscribeToCharacteristic(notifyCharacteristic)
        .listen((data) async {
      printLog("Notify Value", connectionStateUpdate!.deviceId + " " + HexCodec().encode(data));
      handleNotifyData(data);
    }, onError: (dynamic error) {
      printLog("Notify Error", error.toString());
    });

    ///Dummy data device keys
    //sendCommand(bluetoothCommand.getComKey('yOTmK50z'));
    //sendCommand(bluetoothCommand.getComKey('abcdefgh'));
    sendCommand(bluetoothCommand.getComKey(bleKey));
    //sendCommand(bluetoothCommand.getComKey('Ijdn8V2o'));
    //sendCommand(bluetoothCommand.getComKey('EVIE+'));
    //sendCommand(bluetoothCommand.cableUnlock(0));
    //sendCommand(bluetoothCommand.getComKey('REw40n21'));
    //sendCommand(bluetoothCommand.getComKey('RIiOU5wK'));

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
    switch(notifyDataState) {
      case NotifyDataState.notifying:
        getNotifyingData(data);
        break;
      case NotifyDataState.getIotInfo:
        getIotInfo(data);
        break;
      case NotifyDataState.firmwareUpgrade:
        getFirmwareUpgradeData(data);
        break;
    }
  }

  void clearBluetoothStatus() {
    requestComKeyResult = null;
    cableLockState = null;
    mainBatteryLevel = "";
    bikeInfoResult = null;
    iotInfoModel = null;
    exitNotifyIotInfoState();
    exitNotifyFirmwareUpgradeState();
    notifyListeners();
  }

  Future<PermissionStatus> handlePermission() async {

    var bleConnectStatus = await Permission.bluetoothConnect.request();
    if (bleConnectStatus.isGranted) {
      //return PermissionStatus.granted;
      var bleScanStatus = await Permission.bluetoothScan.request();
      if (bleScanStatus.isDenied){
        return PermissionStatus.denied;
      }
      else if (bleScanStatus.isPermanentlyDenied) {
        return PermissionStatus.permanentlyDenied;
      }
      else if (bleScanStatus.isLimited) {
        return PermissionStatus.limited;
      }
      else if (bleScanStatus.isGranted) {
        return PermissionStatus.granted;
      }
      else {
        return PermissionStatus.restricted;
      }
    }
    else if (bleConnectStatus.isDenied){
      return PermissionStatus.denied;
    }
    else if (bleConnectStatus.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    }
    else if (bleConnectStatus.isLimited) {
      return PermissionStatus.limited;
    }
    else {
      return PermissionStatus.restricted;
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
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.changeBleKey(requestComKeyResult!.communicationKey));
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

  Stream<ChangeBleNameResult> changeBleName() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.changeBleName(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return chgBleNameResultListener.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return chgBleNameResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return chgBleNameResultListener.stream
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

  Stream<AddRFIDCardResult> addRFID() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.addRFID(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return addRFIDCardResultListener.stream
            .timeout(const Duration(seconds: 30), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return addRFIDCardResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return addRFIDCardResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  Stream<QueryRFIDCardResult> queryRFID(int rfidIndex) {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.queryRFID(requestComKeyResult!.communicationKey, rfidIndex));
      if (isConnected) {
        return queryRFIDCardResultListener.stream
            .timeout(const Duration(seconds: 10), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return queryRFIDCardResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return queryRFIDCardResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  /// 6). Function for delete RFID card and listening for acknowledge status from bike. *4.5.11

  Stream<DeleteRFIDCardResult> deleteRFID(String rfidID) {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.deleteRFID(requestComKeyResult!.communicationKey, rfidID));
      if (isConnected) {
        return deleteRFIDCardResult.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return deleteRFIDCardResult.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return deleteRFIDCardResult.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }
  //Command 0: delete card
  //Request rfid ID


  /// 7). Function for external cable lock. *4.5.19
  Stream<CableLockResult> cableLock() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.cableLock(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return cableLockResult.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return cableLockResult.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return cableLockResult.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  /// 8). Function for external cable unlock. *4.5.19
  Stream<CableLockResult> cableUnlock() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.cableUnlock(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return cableLockResult.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
          sink.close();
        });
      } else {
        return cableLockResult.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
          sink.close();
        });
      }
    } else {
      return cableLockResult.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
        sink.close();
      });
    }
  }

  /// 8). Function for external cable unlock. *4.5.19
  Stream<CableLockResult> getCableLockStatus() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.getCableLockStatus(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return cableLockResult.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return cableLockResult.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return cableLockResult.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  Stream<MovementSettingResult> changeMovementSetting() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.changeMovementSetting(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return chgMoveSettingResultListener.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return chgMoveSettingResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return chgMoveSettingResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  Stream<FactoryResetResult> factoryReset() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(
          bluetoothCommand.factoryReset(requestComKeyResult!.communicationKey));
      if (isConnected) {
        return factoryResetResultListener.stream
            .timeout(const Duration(seconds: 6), onTimeout: (sink) {
          sink.addError("Operation timeout");
        });
      } else {
        return factoryResetResultListener.stream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected.");
        });
      }
    } else {
      return factoryResetResultListener.stream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  void getNotifyingData(data) {
    List<int> decodedData = bluetoothCommand.decodeData(data); //Decode data and get actual data
    if (decodedData.isEmpty) {
      /// CRC value not valid. Failed decoded. Ignore invalid data.
    } else {
      var command = decodedData[5];
      switch (command) {
        case BluetoothCommand.requestComKeyCmd:
          requestComKeyResult = RequestComKeyResult(decodedData);
          if (requestComKeyResult?.communicationKey != null) {
            sendCommand(bluetoothCommand.getBikeInfo(requestComKeyResult!.communicationKey));
            sendCommand(bluetoothCommand.getCableLockStatus(requestComKeyResult!.communicationKey));
          }else{

          }
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
        case BluetoothCommand.changeBleNameCmd:
          chgBleNameResultListener.add(ChangeBleNameResult(decodedData));
          break;
        case BluetoothCommand.externalCableLock:
          cableLockResult.add(CableLockResult(decodedData));
          cableLockState = CableLockResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.addRFIDCmd:
          addRFIDCardResultListener.add(AddRFIDCardResult(decodedData));
          break;
        case BluetoothCommand.deleteRFIDCmd:
          deleteRFIDCardResult.add(DeleteRFIDCardResult(decodedData));
          notifyListeners();
          break;
        case BluetoothCommand.queryRFIDCmd:
          queryRFIDCardResultListener.add(QueryRFIDCardResult(decodedData));
          queryRFIDCardResult = QueryRFIDCardResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.requestBikeInfo:
          bikeInfoResult = BikeInfoResult(decodedData);
          notifyListeners();
          break;
        case BluetoothCommand.changeMovementSettingCmd:
          chgMoveSettingResultListener.add(
              MovementSettingResult(decodedData));
          break;
        case BluetoothCommand.factoryResetCmd:
          factoryResetResultListener.add(FactoryResetResult(decodedData));
          break;
        case BluetoothCommand.dataTransferCmd:
          enterNotifyIotInfoState(decodedData);
          break;
        default:
          break;
      }
    }
  }

  /// ********************* ///
  /// Get IOT Data Function ///
  /// *************** ***** ///
  /// Command for request total packet of IOT information

  Stream<IotInfoModel> requestTotalPacketOfIotInfo() {
    if (requestComKeyResult != null) {
      bool isConnected = sendCommand(bluetoothCommand.requestTotalPacketOfIotInfo(requestComKeyResult!.communicationKey));
      iotInfoModelStream = iotInfoModelListener.stream;
      if (isConnected) {
        return iotInfoModelStream.timeout(const Duration(seconds: 30),
            onTimeout: (sink) {
              sink.addError("Operation timeout");
            });
      } else {
        return iotInfoModelStream
            .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
          sink.addError("Bike is not connected");
        });
      }
    } else {
      return iotInfoModelStream
          .timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
        sink.addError("Communication key is empty value");
      });
    }
  }

  ///Entering NotifyDataState.getIotInfo : search this --> @getIotInfo()
  void enterNotifyIotInfoState(List<int> decodedData) {
    notifyDataState = NotifyDataState.getIotInfo;
    totalIotPacketData = decodedData[8] - 1;
    sendCommand(bluetoothCommand.getPacketDataByIndex(iotDataIndex, requestComKeyResult!.communicationKey));
  }

  void getIotInfo(data) {
    //printLog("IOT Data", data.toString());
    const asciiDecoder = AsciiDecoder();
    ///if iotDataIndex is lesser than totalBikePacketData
    if (iotDataIndex < totalIotPacketData) {
      iotInfoString = iotInfoString + asciiDecoder.convert(data.sublist(4, 20)); ///Partial IOTInfo String
      /// increase bikeDataIndex
      iotDataIndex++;
      ///send command to get next bikeDataIndex Packet Data.
      sendCommand(bluetoothCommand.getPacketDataByIndex(iotDataIndex, requestComKeyResult!.communicationKey));
      printLog("IOT INFO ", iotInfoString);
    }
    /// Check if iotDataIndex is last index
    else if (iotDataIndex == totalIotPacketData) {
      iotInfoString = iotInfoString + asciiDecoder.convert(data.sublist(4, 20)); ///Final BikeInfo String.
      //printLog("FINAL IOT Info Data", iotInfoString); ///Print final IOTInfo String.
      iotInfoModel = IotInfoModel(iotInfoString);
      iotInfoModelListener.add(iotInfoModel!);
      exitNotifyIotInfoState();
      sendCommand(bluetoothCommand.getBikeInfo(requestComKeyResult!.communicationKey));
      sendCommand(bluetoothCommand.getCableLockStatus(requestComKeyResult!.communicationKey));
      notifyListeners();
    }
  }

  /// Return to NotifyDataState.notifying : search this --> @getNotifyingData()
  void exitNotifyIotInfoState() {
    notifyDataState = NotifyDataState.notifying;
    iotDataIndex = 0;
    totalIotPacketData = 0;
  }

  /// ************************* ///
  /// Firmware Upgrade Function ///
  /// ************************* ///
  void getFirmwareUpgradeData(data) {
    List<int> decodedData = bluetoothCommand.decodeData(data); //Decode data and get actual data
    if (decodedData.isEmpty) {
      /// CRC value not valid. Failed decoded. Ignore invalid data.
    }
    else {
      var command = decodedData[5];
      switch (command) {
        case BluetoothCommand.getFirmwareUpgradeDataCmd:
        // printLog("Sending Packet ", fwUpgradeDataIndex.toString());
        // printLog("Remaining Packet ", (totalPacketOfFwFile - fwUpgradeDataIndex).toString());
          if (fwUpgradeDataIndex == totalPacketOfFwFile - 2) {
            // printLog("Data Index: ", fwUpgradeDataIndex.toString());
            // printLog("Total Data Index: ", (totalPacketOfFwFile - 2).toString());
            sendFwFileBytesByIndex(decodedData);
            /// get IOT data to check whether firmware is upgraded.
            //exitNotifyFirmwareUpgradeState();
          }
          else if (fwUpgradeDataIndex < totalPacketOfFwFile) {
            // printLog("Data Index: ", fwUpgradeDataIndex.toString());
            // printLog("Total Data Index: ", (totalPacketOfFwFile - 2).toString());
            sendFwFileBytesByIndex(decodedData);
          }
          break;
      }
    }
  }

  /// Entering NotifyDataState.firmwareUpgrade : search this --> @getFirmwareUpgradeData()
  void startUpgradeFirmware(File file) async {
    List<int>? fileBytes = await file.readAsBytes();
    fwFile = file;
    notifyDataState = NotifyDataState.firmwareUpgrade;
    firmwareUpgradeState = FirmwareUpgradeState.startUpgrade;

    /// Get totalPacket with divided by 128. it might be decimal places.
    double doubleTotalPacket = fileBytes.length / 128;

    ///Make sure total packet do not have decimal places, if do, then increment as one packet.
    int totalPacket = 0;
    if(doubleTotalPacket % 1 == 0) {
      totalPacket = doubleTotalPacket.toInt();
    }
    else {
      totalPacket = doubleTotalPacket.toInt() + 1;
    }
    List<int> totalPacketByte = bluetoothCommand.integerTo16bytes(totalPacket);
    //printLog("Total Packet Byte", totalPacketByte.toString());

    ///Convert totalPacketByte to Integer, for easier calculation.
    totalPacketOfFwFile = totalPacket;

    bool result = sendCommand(bluetoothCommand.upgradeFirmwareCommand(requestComKeyResult!.communicationKey, fileBytes, totalPacketByte));
    notifyListeners();
  }

  void sendFwFileBytesByIndex(List<int> decodedData) async {
    ///Get Data Index that request by IOT
    List<int> packetIndexBytes = decodedData.sublist(6, 8);

    ///Convert data Index to Integer for further calculation
    fwUpgradeDataIndex = bluetoothCommand.hexToInt(packetIndexBytes);
    printLog("Current Index", fwUpgradeDataIndex.toString());

    /// Current firmware bin file
    List<int> fwFileBytes = await fwFile!.readAsBytes();

    /// Extract firmware file bytes follow by index
    int startIndex = fwUpgradeDataIndex * 128;
    int endIndex = ((fwUpgradeDataIndex + 1) * 128);
    List<int> fwFileBytesByIndex = List<int>.filled(0, 0, growable: true);
    if (endIndex > fwFileBytes.length) {
      fwFileBytesByIndex.insertAll(0, fwFileBytes.sublist(startIndex, fwFileBytes.length));
      ///If the packet not enough 128bytes then filled remaining byte to 0x00
      List<int> remainingList = List<int>.filled(128 - fwFileBytesByIndex.length, 0, growable: true);
      fwFileBytesByIndex.insertAll(fwFileBytesByIndex.length, remainingList);
    }
    else {
      fwFileBytesByIndex = fwFileBytes.sublist(startIndex, endIndex);
    }

    /// Send firmware file bytes packet follow by index
    sendCommand(bluetoothCommand.sendFwFileBytesByIndex(fwFileBytesByIndex, packetIndexBytes, fwUpgradeDataIndex));

    /// Count on firmware upgrading progress %
    fwUpgradeProgress = fwUpgradeDataIndex/(totalPacketOfFwFile - 1);
    printLog("Upgrading firmware ", (fwUpgradeProgress * 100).toString() + "%");

    if (fwUpgradeDataIndex == totalPacketOfFwFile - 1) {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        return firmwareUpgradeState = FirmwareUpgradeState.upgradeSuccessfully;
      });
    }
    else {
      firmwareUpgradeState = FirmwareUpgradeState.upgrading;
    }

    notifyListeners();
  }

  /// Return to NotifyDataState.notifying : search this --> @getNotifyingData()
  void exitNotifyFirmwareUpgradeState() {
    if (firmwareUpgradeState == FirmwareUpgradeState.upgrading) {
      if (fwUpgradeDataIndex < totalPacketOfFwFile - 1) {
        firmwareUpgradeState = FirmwareUpgradeState.upgradeFailed;
      }
    }

    notifyDataState = NotifyDataState.notifying;
    fwFile = null;
    fwUpgradeDataIndex = 0;
    totalPacketOfFwFile = 0;
    fwUpgradeProgress = 0;
    notifyListeners();
  }
}

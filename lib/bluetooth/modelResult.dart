import 'dart:convert';

import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hex/hex.dart';

enum DeviceConnectResult {
  scanning,
  scanTimeout,
  scanError,
  connecting,
  partialConnected,
  connected,
  disconnecting,
  disconnected,
  connectError,
}

enum CommandResult {
  unknown,
  success,
  failed,
}

enum LockState {
  unknown,
  lock,
  unlock,
}

enum ErrorMessage {
  unknown,
  crcAuthErr, ///CRC authentication error
  comKeyNotObtained, ///The communication KEY was not obtained
  wrongComKey, ///The communication KEY has been obtained, but the communication KEY is wrong
  transportMode
}

enum AddRFIDState {
  unknown,
  startReadCard,
  addCardSuccess,
  addCardFailed,
  cardIsExist,
}

enum PairingState {
  unknown,
  startPairing,
  pairing,
  gettingIotInfo,
  errorPrompt,
  pairDeviceSuccess,
  pairDeviceFailed,
}

enum MovementSensitivity {
  low,
  medium,
  high
}

class RequestComKeyResult {

  int dataSize = 0;
  int communicationKey = 0;
  CommandResult result = CommandResult.unknown;
  bool isValidKey = false;


  RequestComKeyResult(List<int> data) {

    /// Verification ID: (1: Success, 0: Failure)
    result = data[6] == 1 ? CommandResult.success : CommandResult.failed;

    if (result == CommandResult.success) {
      dataSize = data[2];
      communicationKey = data[7];
      isValidKey = true;
    }
    else {
      isValidKey = false;
    }
  }
}

class ErrorPromptResult {
  int dataSize = 0;
  ErrorMessage errorMessage = ErrorMessage.unknown;

  ErrorPromptResult(List<int> data) {
    /// Error message:
    /// 1: CRC authentication error
    /// 2: The communication KEY was not obtained
    /// 3: The communication KEY has been obtained, but the communication KEY is wrong

    errorMessage =
    data[6] == 1 ? ErrorMessage.crcAuthErr :
    data[6] == 2 ? ErrorMessage.comKeyNotObtained :
    data[6] == 3 ? ErrorMessage.wrongComKey :
    data[6] == 4 ? ErrorMessage.transportMode :
    ErrorMessage.unknown;
    print(errorMessage);
  }
}

///Need to wait motor controller for verify
class BikeInfoResult {
  int dataSize = 0;
  String? batteryLevel;
  String? modeOfBike;
  String? speed;
  String? singleRidingMileage;
  String? remainingMileage;


  BikeInfoResult(List<int> data) {
    dataSize = data[2];
    batteryLevel = data[6].toString();
    modeOfBike = data[7].toString();
    speed = data[8].toString() + data[9].toString();
    singleRidingMileage = data[10].toString() + data[11].toString();
    remainingMileage = data[12].toString() + data[13].toString();
  }
}

class UnlockResult {
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  int unlockTs = 0;
  int unlockedTs = 0;

  UnlockResult(List<int> data) {
    /// Unlock Result :
    /// 1: Success
    /// 2: Failed / Timeout

    result = data[6] == 1 ? CommandResult.success : CommandResult.failed;
    if (result == CommandResult.success) {
      unlockTs = int.parse(const HexCodec().encode(data.sublist(7, 11)), radix: 16);
      unlockedTs = int.parse(const HexCodec().encode(data.sublist(11, 15)), radix: 16);
    }
  }
}

class ChangeBleKeyResult {
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  String? bleKey;

  ChangeBleKeyResult(List<int> data) {
    /// Change BLE key Result :
    /// 0: Success
    /// 1: Failed

    result = data[6] == 0 ? CommandResult.success : CommandResult.failed;
    if (result == CommandResult.success) {
      const asciiDecoder = AsciiDecoder();
      bleKey = asciiDecoder.convert(data.sublist(7, 15));
      //bleKey = const HexCodec().encode(data.sublist(7, 15));
      print(bleKey);
    }
    else {
      print(bleKey);
    }
  }
}

class ChangeBleNameResult {
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  String? bleKey;

  ChangeBleNameResult(List<int> data) {

    result = data[6] == 0 ? CommandResult.success : CommandResult.failed;
    const asciiDecoder = AsciiDecoder();
    bleKey = asciiDecoder.convert(data.sublist(7, 13));
    if (result == CommandResult.success) {
      const asciiDecoder = AsciiDecoder();
      bleKey = asciiDecoder.convert(data.sublist(7, 13));
      print(bleKey);
    }
    else {
      print(bleKey);
    }
  }
}

///Can combine add and delete result together since return data only success/failed
class AddRFIDCardResult{

  int dataSize = 0;
  AddRFIDState addRFIDState = AddRFIDState.unknown;
  String? rfidNumber;


  AddRFIDCardResult(List<int> data) {
    if (data[6] == 0) {
      addRFIDState = AddRFIDState.startReadCard;
    }
    else if (data[6] == 1) {
      addRFIDState = AddRFIDState.addCardSuccess;
    }
    else if (data[6] == 2) {
      addRFIDState = AddRFIDState.addCardFailed;
    }
    else if (data[6] == 3) {
      addRFIDState = AddRFIDState.cardIsExist;
    }

    List<int> rfidData = [data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14]];
    print("RFID State : " + addRFIDState.name.toString());
    print("RFID Byte Data: " + rfidData.toString());
    rfidNumber = const HexCodec().encode(rfidData);
    print(rfidNumber);
  }
}

class QueryRFIDCardResult{

  int dataSize = 0;
  String? rfidNumber = "0000000000000000";


  QueryRFIDCardResult(List<int> data) {
    List<int> rfidData = [data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13]];
    print("RFID Byte Data: " + rfidData.toString());
    rfidNumber = const HexCodec().encode(rfidData);
    print(rfidNumber);
  }
}

class DeleteRFIDCardResult{
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;

  DeleteRFIDCardResult(List<int> data) {
    /// Delete rfid Result :
    /// 0: Success
    /// 1: Failed

    result = data[6] == 0 ? CommandResult.failed : CommandResult.success;
    print(result);
  }
}

class CableLockResult{
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  LockState lockState = LockState.unknown;


  CableLockResult(List<int> data) {

    /// Result type:
    /// 0x03-> Cable lock unlock
    /// 0x13-> Cable lock lock

    /// Result :
    /// 0: Success
    /// 1: Failed
    /// 2: Communication timeout
    /// 10: locked state

    // data[6] = result type
    if (data[6] == 0x23) {
      ///For lock status -> 0x10 = "LOCK" , 0x11 = "UNLOCK"
      lockState = data[7] == 0x10 ? LockState.lock : LockState.unlock;
    }
    else if (data[6] == 0x13) {
      lockState = data[7] == 0x00 ? LockState.lock : LockState.unlock;
    }
    else if (data[6] == 0x03) {
      lockState = data[7] == 0x00 ? LockState.unlock : LockState.lock;
    }
    // else {
    //   result = data[7] == 0 ? CommandResult.success : CommandResult.failed;
    // }
  }
}

class MovementSettingResult {
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  MovementSettingResult(List<int> data) {
    result = data[6] == 0 ? CommandResult.success : CommandResult.failed;
    print(result);
  }
}

class FactoryResetResult {
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;
  FactoryResetResult(List<int> data) {
    result = data[6] == 0 ? CommandResult.success : CommandResult.failed;
    print(result);
  }
}

class IotInfoModel {
  String? apnName;
  String? apnMode;
  int? ipMode;
  String? ipAddress;
  String? port;
  String? deviceIMEI;
  String? iccid;
  String? qrCode;
  String? firmwareVer;

  IotInfoModel(String iotInfoString) {
    if (iotInfoString == "") {

    }
    else {
      List<String> IotDataList = iotInfoString.split(",");

      if (IotDataList[0].toString().contains("APN")) {
        apnName = ((IotDataList[0].toString()).split(":"))[1];
      }

      if (IotDataList[1].toString().contains("APNMODE")) {
        apnMode = ((IotDataList[1].toString()).split(":"))[1];
      }

      if (IotDataList[4].toString().contains("IPMODE")) {
        ipMode = int.parse(((IotDataList[4].toString()).split(":"))[1]);
      }

      if (IotDataList[5].toString().contains("IP")) {
        ipAddress = ((IotDataList[5].toString()).split(":"))[1];
      }

      if (IotDataList[6].toString().contains("PORT")) {
        port = ((IotDataList[6].toString()).split(":"))[1];
      }

      if (IotDataList[7].toString().contains("IMEI")) {
        deviceIMEI = ((IotDataList[7].toString()).split(":"))[1];
      }

      if (IotDataList[8].toString().contains("ICCID")) {
        iccid = ((IotDataList[8].toString()).split(":"))[1];
      }

      if (IotDataList[9].toString().contains("QRCODE")) {
        qrCode = ((IotDataList[9].toString()).split(":"))[1];
      }

      if (IotDataList[12].toString().contains("VERSION")) {
        firmwareVer = ((IotDataList[12].toString()).split(":"))[1];
      }
    }
  }
}

class PairDeviceResult {
  IotInfoModel? iotInfoModel;
  PairingState pairingState = PairingState.unknown;
  DeviceConnectionState? deviceConnectionState;

  PairDeviceResult(this.iotInfoModel, this.pairingState, this.deviceConnectionState);
}

class FirmwareUpgradeResult {
  FirmwareUpgradeState firmwareUpgradeState;
  double progress;

  FirmwareUpgradeResult({this.firmwareUpgradeState = FirmwareUpgradeState.startUpgrade, this.progress = 0});
}

class TransportModeResult{
  int dataSize = 0;
  CommandResult result = CommandResult.unknown;

  TransportModeResult(List<int> data) {
    result = data[6] == 1 ? CommandResult.failed : CommandResult.success;
    print(result);
  }
}
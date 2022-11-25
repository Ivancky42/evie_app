import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crclib/catalog.dart';
import 'package:crclib/crclib.dart';
import 'package:hex/hex.dart';


class BluetoothCommand {

  static final BluetoothCommand _sharedInstance = BluetoothCommand._();
  factory BluetoothCommand() => _sharedInstance;

  List<int> header = [0xA3, 0xA4];
  Random random = Random();

  /// Command
  static const int requestComKeyCmd = 0x01; /// 4.5.1
  static const int requestBikeInfo = 0x60; /// 4.5.16
  static const int unlockBikeCmd = 0x15; /// 4.5.3
  static const int changeBleKeyCmd = 0x32; /// 4.5.6
  static const int changeBleNameCmd = 0x33; /// 4.5.7
  static const int changeMovementSettingCmd = 0x36; /// 4.5.10
  static const int factoryResetCmd = 0x39; /// 4.5.13
  static const int requestTotalPacketCmd = 0xFA; /// 4.5.20
  static const int dataTransferCmd = 0xFB; /// 4.5.21
  static const int upgradeFirmwareCmd = 0xFB; /// 4.5.21
  static const int fetchDataCommand = 0xFC; /// 4.5.22
  static const int getFirmwareUpgradeDataCmd = 0xFC; /// 4.5.22

  static const int addRFIDCmd = 0x85; ///4.5.11
  static const int deleteRFIDCmd = 0x86; ///4.5.11
  static const int queryRFIDCmd = 0x87; ///4.5.11
  static const int externalCableLock = 0x81; ///4.5.11  ///1:add card 0:delete card

  String dataString = "";
  int dataIndex = 0;




  /// Report
  static const int errorPromptInstruction = 0x10; /// 4.5.2

  BluetoothCommand._() {}

  List<int> getComKey(String deviceKey) {
    int dataSize = 8;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = 0x00; ///  key will be zero.
    data[5] = requestComKeyCmd; /// cmd : 0x01

    for (var i = 0; i < deviceKey.length; i++) {
      data[i + 6] = (utf8.encode(deviceKey[i])[0]); //device key
    }

    return encodeData(dataSize, rand, data);
  }

  List<int> getBikeInfo(int comKey) {
    int dataSize = 1;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey;
    data[5] = requestBikeInfo; /// cmd : 0x60
    data[6] = 0x01;

    return encodeData(dataSize, rand, data);
  }

  List<int> unlockBike(int comKey, int userId, int timestamp) {
    int dataSize = 10;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    String hexUserId = userId.toRadixString(16).padLeft(8, '0');
    List<int> bytesUserId = HexCodec().decode(hexUserId);

    String hexTs = timestamp.toRadixString(16).padLeft(8, '0'); /// Hex value of timestamp
    List<int> bytesTs = HexCodec().decode(hexTs); /// List<int> value of timestamp

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = unlockBikeCmd; /// cmd : 0x05

    data[6] = 0x01; /// Control instruction
    data[7] = bytesUserId[0];
    data[8] = bytesUserId[1];
    data[9] = bytesUserId[2];
    data[10] = bytesUserId[3];

    data[11] = bytesTs[0];
    data[12] = bytesTs[1];
    data[13] = bytesTs[2];
    data[14] = bytesTs[3];

    data[15] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
  }

  List<int> changeBleKey(int comKey) {
    /// Current EVIE app not required to have this function. Disable it to prevent ble key changed.
    // int dataSize = 8;
    // int totalDataSize = 6 + dataSize;
    // List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    // int rand = random.nextInt(255);
    // String randBleKey = getRandomString(8);
    // List<int> bytesBleKey = utf8.encode(randBleKey);
    //
    // data[0] = header[0]; /// header
    // data[1] = header[1]; /// header
    // data[2] = dataSize; /// data length
    // data[3] = (rand + 0x32) & 0xFF; /// random number
    // data[4] = comKey; ///  Communication key
    // data[5] = changeBleKeyCmd; /// cmd : 0x32
    //
    // data[6] = bytesBleKey[0];
    // data[7] = bytesBleKey[1];
    // data[8] = bytesBleKey[2];
    // data[9] = bytesBleKey[3];
    // data[10] = bytesBleKey[4];
    // data[11] = bytesBleKey[5];
    // data[12] = bytesBleKey[6];
    // data[13] = bytesBleKey[7];
    //
    // return encodeData(dataSize, rand, data);
    return [];
  }

  List<int> changeBleName(int comKey) {
    int dataSize = 0x06;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);
    //String randHexBleKey = randomHexString(8);
    String randBleKey = "EVIE17";
    //String randBleKey = "abcdefgh";
    //List<int> bytesBleKey = HexCodec().decode(randHexBleKey);
    List<int> bytesBleKey = utf8.encode(randBleKey);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = changeBleNameCmd; /// cmd : 0x33

    data[6] = bytesBleKey[0];
    data[7] = bytesBleKey[1];
    data[8] = bytesBleKey[2];
    data[9] = bytesBleKey[3];
    data[10] = bytesBleKey[4];
    data[11] = bytesBleKey[5];

    return encodeData(dataSize, rand, data);
  }

  List<int> addRFID(int comKey) {
    int dataSize = 0x01;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    //rfidID.split(' ').forEach((char) => bytesRFID.add(char));

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = addRFIDCmd; /// cmd : 0x85

    data[6] = 0x01;

    return encodeData(dataSize, rand, data);
  }

  List<int> queryRFID(int comKey, int rfidIndex) {
    int dataSize = 0x01;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    //rfidID.split(' ').forEach((char) => bytesRFID.add(char));

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = queryRFIDCmd; /// cmd : 0x87
    data[6] = rfidIndex;

    return encodeData(dataSize, rand, data);
  }

  List<int> deleteRFID(int comKey, String rfidID) {
    int dataSize = 0x08;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = deleteRFIDCmd; /// cmd : 0x86

    List<int> rfidBytes = HexDecoder().convert(rfidID);
    print(rfidBytes.toString());
    data[6] = rfidBytes[0];
    data[7] = rfidBytes[1];
    data[8] = rfidBytes[2];
    data[9] = rfidBytes[3];
    data[10] = rfidBytes[4];
    data[11] = rfidBytes[5];
    data[12] = rfidBytes[6];
    data[13] = rfidBytes[7];

    return encodeData(dataSize, rand, data);
  }

  List<int> cableLock(int comKey) {
    int dataSize = 1;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = externalCableLock; /// cmd : 0x81

    data[6] = 0x13; /// 3: Cable lock unlock   13: Cable lock lock
    data[7] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
  }

  List<int> cableUnlock(int comKey) {
    int dataSize = 1;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = externalCableLock; /// cmd : 0x81

    data[6] = 0x03; /// 3: Cable lock unlock   13: Cable lock lock
    //data[7] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
  }

  List<int> getCableLockStatus(int comKey) {
    int dataSize = 1;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = externalCableLock; /// cmd : 0x81

    data[6] = 0x23;
    //data[7] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
  }

  List<int> changeMovementSetting(int comKey) {
    int dataSize = 2;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = changeMovementSettingCmd; /// cmd : 0x81

    data[6] = 0x01; /// 1 = enable, 0 = disable
    data[7] = 0x03; /// 1 = low, 2 = medium, 3 = high

    return encodeData(dataSize, rand, data);
  }

  List<int> factoryReset(int comKey) {
    int dataSize = 5;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = factoryResetCmd; /// cmd : 0x39

    data[6] = 0xff;
    data[7] = 0xff;
    data[8] = 0xff;
    data[9] = 0xff;
    data[10] = 0x01;

    return encodeData(dataSize, rand, data);
  }

  List<int> requestTotalPacketOfIotInfo(int comKey) {
    int dataSize = 0;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = requestTotalPacketCmd; /// cmd : 0xFA

    return encodeData(dataSize, rand, data);
  }

  List<int> upgradeFirmwareCommand(int comKey, List<int> fileBytes, List<int> totalPacketByte) {
    int dataSize = 0x0A;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    int totalFileSize = fileBytes.length;
    List<int> totalFileByte = integerTo32bytes(totalFileSize);

    CrcValue crc = Crc8Maxim().convert(fileBytes);
    List<int> fileCrcByte = integerTo16bytes(int.parse(crc.toString()));

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = upgradeFirmwareCmd; /// cmd : 0xFB
    data[6] = 0x00; /// 0x00 = Upgrade firmware type, 0x01 get system information
    data[7] = totalPacketByte[1];
    data[8] = totalPacketByte[0];
    data[9] = fileCrcByte[1];
    data[10] = fileCrcByte[0];
    data[11] = 0x86; ///For Mqtt protocol device type
    data[12] = totalFileByte[3];
    data[13] = totalFileByte[2];
    data[14] = totalFileByte[1];
    data[15] = totalFileByte[0];

    return encodeData(dataSize, rand, data);
  }

  List<int> getPacketDataByIndex(int dataIndex, int comKey) {
    int dataSize = 0x03;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = fetchDataCommand; /// cmd : 0xFC
    data[6] = 0x00;
    data[7] = dataIndex;
    data[8] = 0x57; //deviceType

    return encodeData(dataSize, rand, data);
  }

  List<int> sendFwFileBytesByIndex(List<int> dataPacket, List<int> indexPacket, int fwUpgradeDataIndex) {
    List<int> dataBeforeCrc = List<int>.filled(2, 0, growable: true);
    dataBeforeCrc[0] = indexPacket[0];
    dataBeforeCrc[1] = indexPacket[1];
    dataBeforeCrc.insertAll(2, dataPacket);
    var hexValue = const HexCodec().encode(dataBeforeCrc);
    //print("Hex dataBefore CRC: " + hexValue);

    List<int> dataWithCrc = List<int>.filled(2, 0, growable: true);
    CrcValue crc = Crc16Modbus().convert(dataBeforeCrc);
    //print("CRC :" + crc.toString());
    List<int> fileCrcByte = integerTo16bytes(int.parse(crc.toString()));
    dataWithCrc[0] = fileCrcByte[1];
    dataWithCrc[1] = fileCrcByte[0];
    dataWithCrc.insertAll(2, dataBeforeCrc);
    //print("DataWithCRC: " + dataWithCrc.toString());

    return dataWithCrc;
  }

  List<int> encodeData(int dataSize, int rand, List<int> data) {
    for (var i = 0; i < dataSize + 2; i++) {
      data[i + 4] = data[i + 4] ^ rand; /// device key
      print(data[i + 4].toString());
    }

    var hexValue = const HexCodec().encode(data);
    print(hexValue);//For debugging purpose

    CrcValue crc = Crc8Maxim().convert(data);
    print("CRC :" + crc.toString());
    data.add(int.parse(crc.toString()));

    return data;
  }

  List<int> decodeData(List<int> incomingData) {
    incomingData = incomingData.toList(growable: true);
    if (incomingData[0] == header[0] && incomingData[1] == header[1]) {
      int senderCrc = incomingData.last;
      incomingData.removeLast();
      CrcValue crc = Crc8Maxim().convert(incomingData);
      int countedCrc = int.parse(crc.toString());

      if (countedCrc == senderCrc) {
        List<int> data = incomingData;
        data.add(countedCrc);

        int dataSize = incomingData[2];
        int rand = (incomingData[3] - 0x32) & 0xFF; //& 0xFF
        incomingData[3] = rand;

        for (var i = 0; i < dataSize + 2; i++) {
          data[i + 4] = data[i + 4] ^ rand;

          /// device key
        }
        //print("Decode Byte Data: " +  data.toString());
        var hexValue = const HexCodec().encode(data);
        //print(hexValue);
        return data;
      }
      else {
        //show decode failed data.
        return [];
      }
    }
    else {
      const asciiDecoder = AsciiDecoder();
      dataString = dataString + asciiDecoder.convert(incomingData.sublist(4, 20));
      //print(dataString);
      return [];
    }
  }

  String getRandomString(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  String randomHexString(int length) {
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write("0" + random.nextInt(16).toRadixString(16));
    }
    print(sb.toString());
    return sb.toString();
  }

  Uint8List integerTo16bytes(int value) =>
      Uint8List(2)..buffer.asInt16List()[0] = value;

  Uint8List integerTo32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;

  int fromBytesToInt16(Uint8List uintList) {
    int decimalValue = ByteData.view(uintList.buffer).getInt16(0, Endian.little);
    return decimalValue;
  }

  int hexToInt(List<int> data) {
    var hexValue = const HexCodec().encode(data);
    int myInt = int.parse(hexValue, radix: 16);
    return myInt;
  }
}
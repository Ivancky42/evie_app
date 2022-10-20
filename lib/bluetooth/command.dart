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
  static const int unlockBikeCmd = 0x15; /// 4.5.3
  static const int changeBleKeyCmd = 0x32; /// 4.5.6

  static const int rfidCardAddDelete = 0x37; ///4.5.11  ///1:add card 0:delete card




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
    int dataSize = 8;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);
    String randHexBleKey = randomHexString(8);
    List<int> bytesBleKey = HexCodec().decode(randHexBleKey);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = changeBleKeyCmd; /// cmd : 0x32

    data[6] = bytesBleKey[0];
    data[7] = bytesBleKey[1];
    data[8] = bytesBleKey[2];
    data[9] = bytesBleKey[3];
    data[10] = bytesBleKey[4];
    data[11] = bytesBleKey[5];
    data[12] = bytesBleKey[6];
    data[13] = bytesBleKey[7];

    return encodeData(dataSize, rand, data);
  }

  List<int> addRFID(int comKey, List<int> rfidID) {
    int dataSize = 10;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    //rfidID.split(' ').forEach((char) => bytesRFID.add(char));

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = rfidCardAddDelete; /// cmd : 0x37

    data[6] = 0x01; /// 1: Add RFID   0: Delete RFID
    data[7] = rfidID[0];
    data[8] = rfidID[1];
    data[9] = rfidID[2];
    data[10] = rfidID[3];

    data[11] = 0x00;
    data[12] = 0x00;
    data[13] = 0x00;
    data[14] = 0x00;

    data[15] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
  }

  List<int> deleteRFID(int comKey, List<int> rfidID) {
    int dataSize = 10;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; /// header
    data[1] = header[1]; /// header
    data[2] = dataSize; /// data length
    data[3] = (rand + 0x32) & 0xFF; /// random number
    data[4] = comKey; ///  Communication key
    data[5] = rfidCardAddDelete; /// cmd : 0x37

    data[6] = 0x00; /// 1: Add RFID   0: Delete RFID
    data[7] = rfidID[0];
    data[8] = rfidID[1];
    data[9] = rfidID[2];
    data[10] = rfidID[3];

    data[11] = 0x00;
    data[12] = 0x00;
    data[13] = 0x00;
    data[14] = 0x00;

    data[15] = 0x00; /// Normal unlock

    return encodeData(dataSize, rand, data);
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
    if (incomingData[0] == header[0] && incomingData[1] == header[1]) {
      int senderCrc = incomingData.last;
      incomingData.removeLast();
      CrcValue crc = Crc8Maxim().convert(incomingData);
      int countedCrc = int.parse(crc.toString());

      if (countedCrc == senderCrc) {
        List<int> data = incomingData;
        data.add(countedCrc);

        int dataSize = incomingData[2];
        int rand = incomingData[3] - 0x32;
        incomingData[3] = rand;

        for (var i = 0; i < dataSize + 2; i++) {
          data[i + dataSize + 2] = data[i + dataSize + 2] ^ rand;

          /// device key
        }
        var hexValue = const HexCodec().encode(data);
        print(hexValue);
        return data;
      }
      else {
        //show decode failed data.
        return [];
      }
    }
    else {
      return [];
    }
  }

  String randomHexString(int length) {
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write("0" + random.nextInt(16).toRadixString(16));
    }
    print(sb.toString());
    return sb.toString();
  }
}
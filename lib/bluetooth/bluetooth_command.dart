import 'dart:convert';
import 'dart:math';
import 'package:crclib/catalog.dart';
import 'package:crclib/crclib.dart';
import 'package:hex/hex.dart';

class BluetoothCommand {

  static final BluetoothCommand _sharedInstance = BluetoothCommand._();
  factory BluetoothCommand() => _sharedInstance;

  List<int> header = [0xA3, 0xA4];
  int requestKeyCmd = 0x01;

  Random random = Random();

  BluetoothCommand._() {

  }

  List<int> requestKey(String deviceKey) {
    int dataSize = 8;
    int totalDataSize = 6 + dataSize;
    List<int> data = List<int>.filled(totalDataSize, 0, growable: true);
    int rand = random.nextInt(255);

    data[0] = header[0]; //header
    data[1] = header[1]; //header
    data[2] = dataSize; //data length
    data[3] = rand + 0x32; //random number
    data[4] = 0x00; // key will be zero.
    data[5] = requestKeyCmd; // cmd : 0x01

    for (var i = 0; i < deviceKey.length; i++) {
      data[i + 6] = (utf8.encode(deviceKey[i])[0]); //device key
    }

    return encodeData(dataSize, rand, data);
  }

  List<int> encodeData(int dataSize, int rand, List<int> data) {
    for (var i = 0; i < dataSize + 2; i++) {
      data[i + 4] = data[i + 4] ^ rand; //device key
    }

    var hexValue = const HexCodec().encode(data);
    print(hexValue);//For debugging purpose

    CrcValue crc = Crc8Maxim().convert(data);
    data.add(int.parse(crc.toString()));

    return data;
  }

  List<int> decodeData(List<int> incomingData) {
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
        data[i + dataSize + 2] = data[i + dataSize + 2] ^ rand; //device key
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
}
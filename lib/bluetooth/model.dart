import 'package:evie_test/bluetooth/result.dart';
import 'package:hex/hex.dart';

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
      ErrorMessage.wrongComKey;
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
    /// 1: Success
    /// 2: Failed

    result = data[6] == 1 ? CommandResult.success : CommandResult.failed;
    if (result == CommandResult.success) {
      bleKey = const HexCodec().encode(data.sublist(7, 15)).replaceAll("0", "");
      print(bleKey);
    }
  }
}

class AddRFIDCardResult{

}
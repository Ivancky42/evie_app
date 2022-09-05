enum CommandResult {
  unknown,
  success,
  failed,
}

enum ErrorMessage {
  unknown,
  crcAuthErr, ///CRC authentication error
  comKeyNotObtained, ///The communication KEY was not obtained
  wrongComKey, ///The communication KEY has been obtained, but the communication KEY is wrong
}
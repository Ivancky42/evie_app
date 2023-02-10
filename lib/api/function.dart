import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

checkBleStatusAndConnectDevice(BluetoothProvider _bluetoothProvider, BikeProvider _bikeProvider) {
  BleStatus? bleStatus = _bluetoothProvider.bleStatus;
  switch (bleStatus) {
    case BleStatus.poweredOff:
      showBluetoothNotTurnOn();
      break;
    case BleStatus.unsupported:
      showBluetoothNotSupport();
      break;
    case BleStatus.unauthorized:
      showBluetoothNotAuthorized();
      break;
    case BleStatus.locationServicesDisabled:
      showLocationServiceDisable();
      break;
    case BleStatus.ready:
      connectDevice(_bluetoothProvider, _bikeProvider);
      break;
    default:
      break;
  }
}

connectDevice(BluetoothProvider _bluetoothProvider, BikeProvider _bikeProvider) async {
  DeviceConnectResult? deviceConnectResult = _bluetoothProvider.deviceConnectResult;
  if (deviceConnectResult == null
      || deviceConnectResult == DeviceConnectResult.disconnected
      || deviceConnectResult == DeviceConnectResult.scanTimeout
      || deviceConnectResult == DeviceConnectResult.connectError
      || deviceConnectResult == DeviceConnectResult.scanError
      || _bluetoothProvider.currentConnectedDevice != _bikeProvider.currentBikeModel?.macAddr
  )
  {
    await _bluetoothProvider.disconnectDevice();
    await _bluetoothProvider.stopScan();
    _bluetoothProvider.startScanAndConnect();
  }
}

calculateTimeAgo(DateTime dateTime){
    Duration diff = DateTime.now().difference(dateTime);

    String timeAgo;
    if (diff.inMinutes > 0 && diff.inMinutes < 60){
      timeAgo = "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }else if(diff.inHours > 0 && diff.inHours < 24){
      timeAgo = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }else{
      timeAgo = "${dateTime.day.toString()} ${monthsInYear[dateTime.month]}";
    }
    return timeAgo;
}

const Map<int,String> monthsInYear = {
  1: "Jan",
  2: "Feb",
  3: "Mar",
  4: "Apr",
  5: "Mar",
  6: "Jun",
  7: "Jul",
  8: "Aug",
  9: "Sep",
  10: "Oct",
  11: "Nov",
  12: "Dec",
};


// List<String> itemsBetweenDates({
//   required List<String> dates,
//   required List<String> items,
//   required DateTime start,
//   required DateTime end,
// }) {
//   assert(dates.length == items.length);
//
//   var dateFormat = DateFormat('y-MM-dd');
//
//   var output = <String>[];
//   for (var i = 0; i < dates.length; i += 1) {
//     var date = dateFormat.parse(dates[i], true);
//     if (date.compareTo(start) >= 0 && date.compareTo(end) <= 0) {
//       output.add(items[i]);
//     }
//   }
//   return output;
// }
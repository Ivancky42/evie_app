import 'dart:async';

import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import 'colours.dart';

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
      //showBluetoothNotAuthorized();
      _bluetoothProvider.handlePermission();
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

calculateTimeAgoWithTime(DateTime dateTime){
  Duration diff = DateTime.now().difference(dateTime);

  String timeAgo;
  if (diff.inMinutes > 0 && diff.inMinutes < 60){
    timeAgo = "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  }else if(diff.inHours > 0 && diff.inHours < 24){
    timeAgo = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  }else{
    timeAgo = "${monthsInYear[dateTime.month]} ${dateTime.day.toString()}, at ${dateTime.hour}:${dateTime.minute}";
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
  9: "Sept",
  10: "Oct",
  11: "Nov",
  12: "Dec",
};


capitalizeFirstCharacter(String sentence){
  List<String> words = sentence.split(' ');
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    if (word.isNotEmpty) {
      words[i] = word[0].toUpperCase() + word.substring(1);
    }
  }
  return words.join(' ');
}

/// Yesterday : calculateDifference(date) == -1.
/// Today : calculateDifference(date) == 0.
/// Tomorrow : calculateDifference(date) == 1
int calculateDateDifferenceFromNow(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
}

int calculateDateDifference(DateTime date1, DateTime date2) {
  return DateTime(date1.year, date1.month, date1.day).difference(DateTime(date2.year, date2.month, date2.day)).inDays;
}

/// final year = 2023;
/// final month = 3;
/// final numDaysInMonth = daysInMonth(year, month); // returns 31 for March 2023
int daysInMonth(int year, int month) {
  final lastDayOfMonth = DateTime(year, month + 1, 0);
  return lastDayOfMonth.day;
}



class ShareBikeLeave extends StatefulWidget {

  final BikeProvider bikeProvider;
  final int index;

  const ShareBikeLeave({
    Key? key,
    required this.bikeProvider,
    required this.index,

  }) : super(key: key);

  @override
  State<ShareBikeLeave> createState() => _ShareBikeLeaveState();
}
class _ShareBikeLeaveState extends State<ShareBikeLeave> {

  late NotificationProvider _notificationProvider;

  @override
  Widget build(BuildContext context) {

    _notificationProvider = Provider.of<NotificationProvider>(context);

    return Container(
      width: 82.w,
      height: 35.h,
      child: ElevatedButton(
        child:    Text(
          "Leave",
          style: TextStyle(
              fontSize: 12.sp,
              color: EvieColors.primaryColor),
        ),
        onPressed: (){
          SmartDialog.show(
              widget: EvieDoubleButtonDialog(
                title: "Are you sure you want to leave",
                childContent: Text('Are you sure you want to leave'),
                leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
                rightContent: "Yes",
                onPressedRight: () async {
                  SmartDialog.dismiss();
                  SmartDialog.showLoading();
                  StreamSubscription? currentSubscription;

                  currentSubscription = widget.bikeProvider.leaveSharedBike(
                      widget.bikeProvider.bikeUserList.values.elementAt(widget.index).uid,
                      widget.bikeProvider.bikeUserList.values.elementAt(widget.index).notificationId!).listen((uploadStatus) {

                    if(uploadStatus == UploadFirestoreResult.success){
                      SmartDialog.dismiss(status: SmartStatus.loading);
                      SmartDialog.show(
                          keepSingle: true,
                          widget: EvieSingleButtonDialog(
                              title: "Success",
                              content: "You leave",
                              rightContent: "Close",
                              onPressedRight: () => SmartDialog.dismiss()
                          ));
                      currentSubscription?.cancel();
                    } else if(uploadStatus == UploadFirestoreResult.failed) {
                      SmartDialog.dismiss();
                      SmartDialog.show(
                          widget: EvieSingleButtonDialog(
                              title: "Not success",
                              content: "Try again",
                              rightContent: "Close",
                              onPressedRight: ()=>SmartDialog.dismiss()
                          ));
                    }else{};
                  },
                  );
                },
              ));
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.w)),
          elevation: 0.0,
          backgroundColor: EvieColors.lightGrayishCyan,
        ),
      ),
    );
  }
}




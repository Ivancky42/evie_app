import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:evie_test/api/fonts.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/bluetooth/modelResult.dart' as bluetooth;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../widgets/evie_double_button_dialog.dart';
// import '../widgets/evie_single_button_dialog.dart';
import 'colours.dart';
import 'enumerate.dart';
import 'model/bike_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';


checkBleStatusAndConnectDevice(BluetoothProvider bluetoothProvider, BikeProvider bikeProvider) async {
  BleStatus? bleStatus = bluetoothProvider.bleStatus;
  switch (bleStatus) {
    case BleStatus.poweredOff:
      showBluetoothNotTurnOn();
      break;
    case BleStatus.unsupported:
      showBluetoothNotSupport();
      break;
    case BleStatus.unauthorized:
      // showBluetoothNotAuthorized();
      // _bluetoothProvider.handlePermission2();
      if (Platform.isIOS) {
        showBluetoothNotAuthorized();
      }
      else {

        PermissionStatus locationPermission = await Permission.location.request();
        if (locationPermission == PermissionStatus.permanentlyDenied || locationPermission == PermissionStatus.denied) {
          showLocationServiceDisable();
        }
        else {
          PermissionStatus status = await Permission.bluetoothConnect.request();
          if (status == PermissionStatus.permanentlyDenied ||
              status == PermissionStatus.denied) {
            showBluetoothNotAuthorized();
          }
          else {
            PermissionStatus status = await Permission.bluetoothScan.request();
            if (status == PermissionStatus.permanentlyDenied ||
                status == PermissionStatus.denied) {
              showBluetoothNotAuthorized();
            }
          }
        }
      }
      break;
    case BleStatus.locationServicesDisabled:
      showLocationServiceDisable();
      break;
    case BleStatus.ready:
      connectDevice(bluetoothProvider, bikeProvider);
      break;
    default:
      break;
  }
}

connectDevice(BluetoothProvider bluetoothProvider, BikeProvider bikeProvider) async {
  bluetooth.DeviceConnectResult? deviceConnectResult = bluetoothProvider.deviceConnectResult;
  if (deviceConnectResult == null
              || deviceConnectResult == bluetooth.DeviceConnectResult.disconnected
        || deviceConnectResult == bluetooth.DeviceConnectResult.scanTimeout
        || deviceConnectResult == bluetooth.DeviceConnectResult.connectError
        || deviceConnectResult == bluetooth.DeviceConnectResult.scanError
      || bluetoothProvider.currentConnectedDevice != bikeProvider.currentBikeModel?.macAddr
  )
  {
    await bluetoothProvider.disconnectDevice();
    await bluetoothProvider.stopScan();
    bluetoothProvider.startScanAndConnect();
  }
}

///Return 5 minutes ago/20 Nov
calculateTimeAgo(DateTime dateTime){
    Duration diff = DateTime.now().difference(dateTime);

    String timeAgo;
    if (diff.inMinutes > 0 && diff.inMinutes < 60){
      timeAgo = "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "mins"} ago";
    }
    else if(diff.inHours > 0 && diff.inHours < 24){
      timeAgo = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    ///For current minute
    else if(dateTime.second > 0 && diff.inMinutes < 60){
      timeAgo = "1 min ago";
    }
    else{
      timeAgo = "${dateTime.day.toString()} ${monthsInYear[dateTime.month]}";
    }
    return timeAgo;
}

String calculateTimeAgoWithTime(DateTime dateTime) {
  Duration diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes > 0 && diff.inMinutes < 60){
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "mins"} ago";
  }else if(diff.inHours > 0 && diff.inHours < 24){
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  }

  ///For current minute
  else if(dateTime.second > 0 && diff.inMinutes < 60){
    return "1 min ago";
  }
  else {
    String formattedDate = "${monthsInYear[dateTime.month]} ${dateTime.day} ${dateTime.year}, at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    return formattedDate;
  }
}

///Return today/yesterday/Thursday, Aug 20  16.00 - 16.14
String calculateDateAgo(DateTime startDateTime, DateTime endDateTime) {
  DateTime now = DateTime.now();

  // Check if it's today by comparing year, month, and day
  if (startDateTime.year == now.year &&
      startDateTime.month == now.month &&
      startDateTime.day == now.day) {
    return "Today ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }
  // Check if it's yesterday
  else if (startDateTime.isAfter(now.subtract(Duration(days: 1)))){
    return "Yesterday ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }
  // For all other cases
  else {
    return "${weekdayNameFull[startDateTime.weekday]}, ${monthNameHalf[startDateTime.month]} ${startDateTime.day}, ${startDateTime.year} ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }
}

String calculateDateOnly(DateTime startDateTime, DateTime endDateTime) {
  DateTime now = DateTime.now();

  // Check if it's today by comparing year, month, and day
  if (startDateTime.year == now.year &&
      startDateTime.month == now.month &&
      startDateTime.day == now.day) {
    return "Today ";
  }
  // Check if it's yesterday
  else if (startDateTime.isAfter(now.subtract(Duration(days: 1)))){
    return "Yesterday ";
  }
  // For all other cases
  else {
    return "${weekdayNameFull[startDateTime.weekday]}, ${monthNameHalf[startDateTime.month]} ${startDateTime.day}, ${startDateTime.year}";
  }
}

///Return today/yesterday/Thursday, Aug 20  16.00 - 16.14
String calculateTimeOnly(DateTime startDateTime, DateTime endDateTime) {
  return " ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
}

int calculateDurationInMinutes(DateTime startDateTime, DateTime endDateTime) {
  Duration difference = endDateTime.difference(startDateTime);
  return difference.inMinutes;
}

String formatDuration(DateTime startDateTime, DateTime endDateTime) {
  int durationInMinutes = calculateDurationInMinutes(startDateTime, endDateTime);

  if (durationInMinutes < 60) {
    return '$durationInMinutes mins';
  } else {
    int hours = durationInMinutes ~/ 60; // Get the number of whole hours
    int remainingMinutes = durationInMinutes % 60; // Get the remaining minutes

    if (remainingMinutes > 0) {
      return '$hours h $remainingMinutes m';
    } else {
      return '$hours h';
    }
  }
}

Widget returnTextStyle(DateTime startDateTime, DateTime endDateTime) {
  String durationText = formatDuration(
      startDateTime,
      endDateTime
  );

  if (durationText.contains('mins')) {
    return RichText(
      text: TextSpan(
        text: durationText.replaceAll('mins', ""),
        style: EvieTextStyles.headlineB.copyWith(fontFamily: 'Avenir'),
        children: <TextSpan>[
          TextSpan(
            text: 'mins',
            style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan, fontFamily: 'Avenir',),
          ),
        ],
      ),
    );
  }
  else {
    List<TextSpan> textSpans = [];

    final RegExp regExp = RegExp(
        r'(\d+)\s*([hm]?)'); // Regular expression to capture digits followed by 'h' or 'm'.

    for (final match in regExp.allMatches(durationText)) {
      textSpans.add(
        TextSpan(
          text: match.group(1), // The captured digits
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.darkGray, fontFamily: 'Avenir',),
        ),
      );

      if (match.group(2) == 'h') {
        textSpans.add(
          TextSpan(
            text: ' h ',
            style: EvieTextStyles.body18.copyWith(
                color: EvieColors.darkGrayishCyan, fontFamily: 'Avenir',),
          ),
        );
      } else if (match.group(2) == 'm') {
        textSpans.add(
          TextSpan(
            text: ' m ',
            style: EvieTextStyles.body18.copyWith(
                color: EvieColors.darkGrayishCyan, fontFamily: 'Avenir',),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}

calculateTimeDifferentInHourMinutes(DateTime startDateTime, DateTime endDateTime){
  final duration = startDateTime.difference(endDateTime);
  if (duration.inMinutes > 0) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final minutesFraction = (minutes / 60).toDouble();

    return hours + minutesFraction;
  } else {
    return 1.0;
  }

  // if(startDateTime.difference(endDateTime).inHours.toDouble() > 0){
  //   return startDateTime.difference(endDateTime).inHours.toDouble();
  // }else{
  //   return 1.0;
  // }
}

calculateAverageSpeed(double mileage, double time){
  return ((mileage/1000)/time);
}

formatTotalDuration(double durationInDecimalHours){

  if(!durationInDecimalHours.isNaN && !durationInDecimalHours.isInfinite){

    int hours = durationInDecimalHours.toInt();
    int minutes = ((durationInDecimalHours - hours) * 60).round();
    String formattedDuration = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    return formattedDuration;
  }else{
    return 0;
  }
}

const Map<int,String> monthsInYear = {
  1: "Jan",
  2: "Feb",
  3: "Mar",
  4: "Apr",
  5: "May",
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

checkUserAndChangeText(String sentence) {
  if (sentence == 'owner') {
    return 'Owner';
  }
  else {
    return 'Pal';
  }
}

splitCapitalString(String word){
  RegExp pattern = RegExp(r'(?=[A-Z])'); // Lookahead for capital letter

  return word.split(pattern).join(' ');
}

stringToDouble(String target){
  return double.parse(target);
}

emptyFormatting(dynamic target) {
  //Check if the target is a string
  if (target is String) {
    if (target == '0' || target == '0.00') {
      return '-';
    } else {
      return target;
    }
  }

  //Check if the target is an int or double
  if (target is int || target is double) {
    if (target == 0) {
      return '-';
    } else {
      return target;
    }
  }

  return '-';
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

/// print(thousandSeparateFormatting(1000)); // Output: 1,000
/// print(thousandSeparateFormatting(100000.123)); // Output: 100,000
/// print(thousandSeparateFormatting(100000000)); // Output: 100,000,000
String thousandFormatting(num numbers){
  final formatter = NumberFormat('#,###');
  return formatter.format(numbers);
}

calculateCarbonFP(dynamic carbonFP){

  /// Carbon footprint saved = 180g / km
  if(carbonFP == num || carbonFP == int || carbonFP == double){
    return 180/carbonFP;
  }else{
    return carbonFP;
  }
}


const Map<String, String> dayTimeName = {"12 AM": "12AM", "1 AM": "1AM", "2 AM": "2AM", "3 AM": "3AM", "4 AM": "4AM", "5 AM": "5AM", "6 AM": "6AM", "7 AM": "7AM", "8 AM":"8AM", "9 AM":"9AM", "10 AM":"10AM", "11 AM": "11AM", "12 PM": "12PM", "1 PM": "1PM", "2 PM": "2PM", "3 PM": "3PM", "4 PM": "4PM", "5 PM": "5PM", "6 PM": "6PM", "7 PM": "7PM", "8 PM": "8PM", "9 PM": "9PM", "10 PM": "10PM", "11 PM":"11PM"};
//const Map<int, String> dayTimeName = {1: "12AM", 2: "1AM", 3: "2AM", 4: "3AM", 5: "4AM", 6: "5AM", 7: "6AM", 8: "7AM", 9:"8AM", 10:"9AM", 11:"10AM", 12: "11AM", 13: "12PM", 14: "1PM", 15: "2PM", 16: "3PM", 17: "4PM", 18: "5PM", 19: "6PM", 20: "7PM", 21: "8PM", 22: "9PM", 23: "10PM", 24:"11PM"};

///weekdayName[DateTime.now().weekday]) = Mon
const Map<int, String> weekdayName = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"};

///weekdayName[DateTime.now().weekday]) = Monday
const Map<int, String> weekdayNameFull = {1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday", 7: "Sunday"};

///monthName[DateTime.now().month]) = J
const Map<int, String> monthName = {1: "J", 2: "F", 3: "M", 4: "A", 5: "M", 6: "J", 7: "J", 8:"A",9:"S",10:"O",11:"N",12:"D"};

///monthName[DateTime.now().month]) = Jan
const Map<int, String> monthNameHalf = {1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun", 7: "Jul", 8:"Aug",9:"Sep",10:"Oct",11:"Nov",12:"Dec"};

class ShareBikeLeave extends StatefulWidget {

  final BikeProvider bikeProvider;
  final SettingProvider settingProvider;
  final int index;

  const ShareBikeLeave({
    super.key,
    required this.bikeProvider,
    required this.settingProvider,
    required this.index,

  });

  @override
  State<ShareBikeLeave> createState() => _ShareBikeLeaveState();
}
class _ShareBikeLeaveState extends State<ShareBikeLeave> {

  late NotificationProvider _notificationProvider;

  @override
  Widget build(BuildContext context) {

    _notificationProvider = Provider.of<NotificationProvider>(context);

    return SizedBox(
      width: 82.w,
      height: 35.h,
      child: ElevatedButton(
        onPressed: (){

          ///Change sheet instead of showing dialog
          widget.settingProvider.changeSheetElement(SheetList.leaveTeam);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.w)),
          elevation: 0.0,
          backgroundColor: EvieColors.lightGrayishCyan,
        ),
        child:    Text(
          "Leave",
          style: TextStyle(
              fontSize: 12.sp,
              color: EvieColors.primaryColor),
        ),
      ),
    );
  }
}

getCurrentBikeStatusTag(BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {
  if (bikeProvider.bikesPlan[bikeModel.deviceIMEI]) {
    return SvgPicture.asset(
      "assets/icons/batch_tick.svg",
      height: 20.h,
    );
  }
  else {
    return SizedBox.shrink();
  }
}

getCurrentBikeStatusIcon(BikeModel bikeModel, LinkedHashMap bikesPlan, BluetoothProvider bluetoothProvider) {

  if (bikesPlan[bikeModel.deviceIMEI] != null) {
    if (bikesPlan[bikeModel.deviceIMEI]) {
      if (bikeModel.location?.isConnected == false) {
        return "assets/buttons/bike_security_offline.svg";
      }
      else {
        switch (bikeModel.location?.status) {
          case 'safe':
            {
                          if (bluetoothProvider.deviceConnectResult ==
                bluetooth.DeviceConnectResult.connected) {
                                  if (bluetoothProvider.cableLockState?.lockState ==
                      bluetooth.LockState.unlock) {
                  return "assets/buttons/bike_security_unlock_black.svg";
                }
                else {
                  return "assets/buttons/bike_security_lock_and_secure_black.svg";
                }
              }
              else {
                if (bikeModel.isLocked == false) {
                  return "assets/buttons/bike_security_unlock_black.svg";
                } else {
                  return "assets/buttons/bike_security_lock_and_secure_black.svg";
                }
              }
            }
          case 'warning':
            return "assets/buttons/bike_security_warning.svg";
          case 'danger':
            return "assets/buttons/bike_security_danger.svg";
          case 'fall':
            return "assets/buttons/bike_security_warning.svg";
          case 'crash':
            return "assets/buttons/bike_security_danger.svg";

          default:
            return "assets/buttons/bike_security_lock_and_secure_black.svg";
        }
      }
    }
    else {
              if (bluetoothProvider.deviceConnectResult ==
            bluetooth.DeviceConnectResult.connected &&
            bluetoothProvider.currentConnectedDevice == bikeModel.macAddr) {
          if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.unlock) {
          return "assets/buttons/bike_security_unlock_black.svg";
        }
        else {
          return "assets/buttons/bike_security_lock_and_secure_black.svg";
        }
      }
      else {
        return "assets/buttons/bike_security_not_available.svg";
      }
    }
  }
  else {
    return "assets/buttons/bike_security_not_available.svg";
  }
}

getCurrentBikeStatusIcon2(bluetooth.LockState? lockState) {
  if (lockState == bluetooth.LockState.unlock) {
    return "assets/buttons/bike_security_unlock_black.svg";
  } else {
    return "assets/buttons/bike_security_lock_and_secure_black.svg";
  }
}

getCurrentBikeStatusString(BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {

  if (bikeProvider.bikesPlan[bikeModel.deviceIMEI]) {
    if (bikeModel.location?.isConnected == false) {
      return "Connection Lost";
    } else {
      switch (bikeModel.location?.status) {
        case 'safe':
          {
            if (bluetoothProvider.deviceConnectResult == bluetooth.DeviceConnectResult.connected) {
              if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.unlock) {
                return "Unlocked";
              } else {
                return "Locked & Secured";
              }
            }
            else {
              if (bikeModel.isLocked == false) {
                return "Unlocked";
              } else {
                return "Locked & Secured";
              }
            }
          }
        case 'warning':
          return "Movement Detected";
        case 'danger':
          return "Theft Attempt";
        case 'fall':
          return "Fall Detected";
        case 'crash':
          return "Crash Alert";
        default:
          return "-";
      }
    }
  }
  else {
    if(bluetoothProvider.deviceConnectResult == bluetooth.DeviceConnectResult.connected && bluetoothProvider.currentConnectedDevice == bikeModel.macAddr) {
      if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.unlock) {
        return "Unlocked";
      }
      else {
        return "Locked & Secured";
      }
    }
    else{
      return "-";
    }
  }
}

getCurrentBikeStatusString3(BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {
  if (bikeProvider.currentBikeModel?.location?.isConnected == false) {
    return "Connection Lost";
  }
  else {
    if (bluetoothProvider.deviceConnectResult == bluetooth.DeviceConnectResult.connected) {
      ///Bike connected with bluetooth
      switch (bikeProvider.currentBikeModel?.location?.status) {
        case 'safe':
          if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.unlock && bikeProvider.currentBikeModel?.isLocked == false) {
            return "Unlocked";
          }
          else if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.lock && bikeProvider.currentBikeModel?.isLocked == true) {
            return "Locked & Secured";
          }
          else {
            if (bluetoothProvider.cableLockState?.lockState == bluetooth.LockState.unlock) {
              return "Unlocked";
            }
            else {
              return "Locked & Secured";
            }
            //return 'Loading';
          }
        case 'warning':
          return "Movement Detected";
        case 'danger':
          return "Theft Attempt";
        case 'fall':
          return "Fall Detected";
        case 'crash':
          return "Crash Alert";
        default:
          return "-";
      }
    }
    else {
      ///Bike not connect with bluetooth
      switch (bikeProvider.currentBikeModel?.location?.status) {
        case 'safe':
          if (bikeProvider.currentBikeModel!.isLocked == false) {
            return "Unlocked";
          }
          else {
            return "Locked & Secured";
          }
        case 'warning':
          return "Movement Detected";
        case 'danger':
          return "Theft Attempt";
        case 'fall':
          return "Fall Detected";
        case 'crash':
          return "Crash Alert";
        default:
          return "-";
      }
    }
  }
}

getCurrentBikeStatusString4(bluetooth.LockState? lockState) {
  if (lockState == bluetooth.LockState.unlock) {
    return "Unlocked";
  }
  else if (lockState == bluetooth.LockState.lock){
    return "Locked & Secured";
  }
}

getCurrentBikeStatusColour(bool isLocked, BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {

  if (bikeProvider.bikesPlan[bikeModel.deviceIMEI]) {
    if (bikeModel.location?.isConnected == false) {
      return EvieColors.orange;
    } else {
      switch (bikeModel.location?.status) {
        case 'safe':
          return EvieColors.transparent;
        case 'warning':
          return EvieColors.orange;
        case 'danger':
          return EvieColors.darkRed;
        case 'fall':
          return EvieColors.orange;
        case 'crash':
          return EvieColors.darkRed;
        default:
          return EvieColors.transparent;
      }
    }
  }
  else {
    return EvieColors.transparent;
  }
}

getCurrentBikeStatusColourText(bool isLocked, BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {

  if (bikeProvider.bikesPlan[bikeModel.deviceIMEI]) {
    if (bikeModel.location?.isConnected == false) {
      return EvieColors.orange;
    }
    else {
      switch (bikeModel.location?.status) {
        case 'safe':
          return EvieColors.darkGrayishCyan;
        case 'warning':
          return EvieColors.orange;
        case 'danger':
          return EvieColors.darkRed;
        case 'fall':
          return EvieColors.orange;
        case 'crash':
          return EvieColors.darkRed;
        default:
          return EvieColors.darkGrayishCyan;
      }
    }
  }
  else {
    return EvieColors.darkGrayishCyan;
  }
}

///Load image according danger status
loadMarkerImageString(String dangerStatus, bool isLocked){
  /// connection lost
  switch (dangerStatus) {
    case 'safe':
      if (isLocked) {
        return "assets/icons/security/safe_lock_4x.png";
      }
      else {
        return "assets/icons/security/safe_unlock_4x.png";
      }
    case 'warning':
      return "assets/icons/security/warning_4x.png";
    case 'fall':
      return "assets/icons/marker_warning.png";
    case 'danger':
      return "assets/icons/security/danger_4x.png";
    case 'crash':
      return "assets/icons/marker_danger.png";
    default:
      return "assets/icons/marker_safe.png";
  }
}

getSecurityIconWidget(String eventType) {
  switch (eventType) {
    case "warning":
      return "assets/buttons/bike_security_warning.svg";
    case "danger":
      return "assets/buttons/bike_security_danger.svg";
    case "lock":
      return "assets/buttons/bike_security_lock_and_secure_black.svg";
    case "unlock":
      return "assets/buttons/bike_security_unlock_black.svg";
    case "fall":
      return "assets/buttons/bike_security_warning.svg";
    default:
      return "assets/buttons/bike_security_not_available.svg";
  }
}

getSecurityTextWidget(String eventType) {
  switch (eventType) {
    case "warning":
      return "Movement Detected";
    case "danger":
      return "Theft Attempt";
    case "lock":
      return "Locked & Secured";
    case "unlock":
      return "Bike Unlocked";
    case "fall":
      return "Fall detection";
    default:
      return "empty";
  }
}

pointBounce3(MapboxMap? mapboxMap, LocationProvider locationProvider, userPosition) async {

  if (userPosition.lat == 0 && userPosition.lng == 0) {
    return;
  }

  final LatLng southwest = LatLng(
    min(locationProvider.locationModel?.geopoint!.latitude ?? 0, userPosition.lat.toDouble()),
    min(locationProvider.locationModel?.geopoint!.longitude ?? 0, userPosition.lng.toDouble()),
  );

  final LatLng northeast = LatLng(
    max(locationProvider.locationModel?.geopoint!.latitude ?? 0, userPosition.lat.toDouble()),
    max(locationProvider.locationModel?.geopoint!.longitude ?? 0, userPosition.lng.toDouble()),
  );

  if (mapboxMap != null) {
    if (Platform.isIOS) {
      final CameraOptions cameraOpt = await mapboxMap
          .cameraForCoordinateBounds(
        CoordinateBounds(
          northeast: Point(
            coordinates: Position(northeast.longitude, northeast.latitude),
          ).toJson(),
          southwest: Point(
              coordinates: Position(southwest.longitude, southwest.latitude)
          ).toJson(),
          infiniteBounds: true,
        ),
        MbxEdgeInsets(
          // use whatever padding you need
          left: 170.w,
          top: 300.h,
          bottom: 800.h,
          right: 170.w,
        ),
        null,
        null,
     
      );

      mapboxMap.flyTo(
          cameraOpt, MapAnimationOptions(duration: 1000, startDelay: 0));
    }
    else {
      final CameraOptions cameraOpt = await mapboxMap
          .cameraForCoordinateBounds(
        CoordinateBounds(
          northeast: Point(
            coordinates: Position(northeast.longitude, northeast.latitude),
          ).toJson(),
          southwest: Point(
              coordinates: Position(southwest.longitude, southwest.latitude)
          ).toJson(),
          infiniteBounds: true,
        ),
        MbxEdgeInsets(
          // use whatever padding you need
          left: 170.w,
          top: 300.h,
          bottom: 800.h,
          right: 170.w,
        ),
        null,
        null,
      
      );

      mapboxMap.flyTo(
          cameraOpt, MapAnimationOptions(duration: 1000, startDelay: 0));
    }
  }

}

returnBorderColour(LocationProvider locationProvider){
  if(locationProvider.locationModel?.isConnected == false || locationProvider.locationModel?.status == "fall" || locationProvider.locationModel?.status == "warning"){
    return Border.all(
      color: EvieColors.orange,
      width: 2.8.w,
    );
  }else if(locationProvider.locationModel?.status == "danger"){
    return Border.all(
      color: EvieColors.darkRed,
      width: 2.8.w,
    );
  }else{
    return Border.all(
      color: EvieColors.transparent,
      width: 2.8.w,
    );
  }
}

Future<void> launch(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}





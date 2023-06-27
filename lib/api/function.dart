import 'dart:async';
import 'dart:math';

import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import 'colours.dart';
import 'model/bike_model.dart';
import 'package:latlong2/latlong.dart';

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

///Return 5 minutes ago/20 Nov
calculateTimeAgo(DateTime dateTime){
    Duration diff = DateTime.now().difference(dateTime);

    String timeAgo;
    if (diff.inMinutes > 0 && diff.inMinutes < 60){
      timeAgo = "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }else if(diff.inHours > 0 && diff.inHours < 24){
      timeAgo = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }

    ///For current minute
    else if(dateTime.second > 0 && diff.inMinutes < 60){
      timeAgo = "1 minutes ago";
    }

    else{
      timeAgo = "${dateTime.day.toString()} ${monthsInYear[dateTime.month]}";
    }
    return timeAgo;
}


calculateTimeAgoWithTime(DateTime dateTime){
  Duration diff = DateTime.now().difference(dateTime);

  String timeAgo;
  if (diff.inMinutes >= 0 && diff.inMinutes <= 60){
    timeAgo = "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  }else if(diff.inHours >= 0 && diff.inHours <= 24){
    timeAgo = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  }else{
    timeAgo = "${monthsInYear[dateTime.month]} ${dateTime.day.toString()} ${dateTime.year.toString()}, at ${dateTime.hour}:${dateTime.minute}";
  }
  return timeAgo;
}

///Return today/yesterday/Thursday, Aug 20  16.00 - 16.14
calculateDateAgo(DateTime startDateTime, DateTime endDateTime){
  Duration diff = DateTime.now().difference(startDateTime);

  String timeAgo;
  if (diff.inHours >= 0 && diff.inHours <= 24){
    timeAgo = "Today ${startDateTime.hour.toString().padLeft(2,'0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2,'0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }else if(diff.inHours > 24  && diff.inHours <= 48){
    timeAgo = "Yesterday ${startDateTime.hour.toString().padLeft(2,'0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2,'0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }else{
    timeAgo = "${weekdayNameFull[startDateTime.weekday]}, ${monthNameHalf[startDateTime.month]} ${startDateTime.day}, ${startDateTime.hour.toString().padLeft(2,'0')}:${startDateTime.minute.toString().padLeft(2, '0')} - ${endDateTime.hour.toString().padLeft(2,'0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
  }
  return timeAgo;
}

calculateTimeDifferentInHourMinutes(DateTime startDateTime, DateTime endDateTime){
  final duration = startDateTime.difference(endDateTime);
  if (duration.inMinutes > 0) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final minutesFraction = (minutes / 60).toDouble();

    print(hours+minutesFraction);
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

splitCapitalString(String word){
  RegExp pattern = RegExp(r'(?=[A-Z])'); // Lookahead for capital letter

  return word.split(pattern).join(' ');
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

getCurrentBikeStatusTag(BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {
  if (bikeProvider.userBikePlans.isNotEmpty) {
    for (var index = 0; index < bikeProvider.userBikePlans.length; index++) {
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if (bikeProvider.userBikePlans.values.elementAt(index) != null && bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null) {
          final result = calculateDateDifferenceFromNow(
              bikeProvider.userBikePlans.values
                  .elementAt(index)
                  .periodEnd
                  .toDate());
          if (result < 0) {
            return SizedBox.shrink();
          } else {
           return SvgPicture.asset(
              "assets/icons/batch_tick.svg",
              height: 20.h,
            );
          }
        }else{
          return SizedBox.shrink();
        }
      }
    }
  }else{
    return SizedBox.shrink();
  }
}


getCurrentBikeStatusImage(BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {
  if (bikeProvider.userBikePlans.isNotEmpty) {
    for (var index = 0; index < bikeProvider.userBikePlans.length; index++) {
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if (bikeProvider.userBikePlans.values.elementAt(index) != null && bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null) {
          final result = calculateDateDifferenceFromNow(
              bikeProvider.userBikePlans.values
                  .elementAt(index)
                  .periodEnd
                  .toDate());
          if (result < 0) {
            return "assets/images/bike_HPStatus/bike_normal.png";
          } else {
            if (bikeModel.location?.isConnected == false) {
              return "assets/images/bike_HPStatus/bike_warning.png";
            } else {
              switch (bikeModel.location!.status) {
                case 'safe':
                  {
                    if (bluetoothProvider.cableLockState?.lockState == LockState.unlock) {
                      return "assets/images/bike_HPStatus/bike_safe.png";
                    } else {
                      return "assets/images/bike_HPStatus/bike_safe.png";
                    }
                  }
                case 'warning':
                  return "assets/images/bike_HPStatus/bike_warning.png";

                case 'danger':
                  return "assets/images/bike_HPStatus/bike_danger.png";
                case 'fall':
                  return "assets/images/bike_HPStatus/bike_warning.png";
                case 'crash':
                  return "assets/images/bike_HPStatus/bike_danger.png";

                default:
                  return "assets/images/bike_HPStatus/bike_safe.png";
              }
            }
          }
        }else{
          return "assets/images/bike_HPStatus/bike_normal.png";
        }
      }
    }
  }else{
    return "assets/images/bike_HPStatus/bike_normal.png";
  }
}

getCurrentBikeStatusIcon(BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {
  if (bikeProvider.userBikePlans.isNotEmpty) {
    for (var index = 0; index < bikeProvider.userBikePlans.length; index++) {
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if (bikeProvider.userBikePlans.values.elementAt(index) != null && bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null) {
          final result = calculateDateDifferenceFromNow(
              bikeProvider.userBikePlans.values
                  .elementAt(index)
                  .periodEnd
                  .toDate());
          if (result < 0) {
            return "assets/buttons/bike_security_not_available.svg";
          } else {
            if (bikeModel.location?.isConnected == false) {
              return "assets/buttons/bike_security_warning.svg";
            } else {
              switch (bikeModel.location!.status) {
                case 'safe':
                  {
                    if (bluetoothProvider.cableLockState?.lockState == LockState.unlock) {
                      return "assets/buttons/bike_security_unlock.svg";
                    } else {
                      return "assets/buttons/bike_security_lock_and_secure_black.svg";
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
        }else{
          return "assets/buttons/bike_security_not_available.svg";
        }
      }
    }
  }else{
    return "assets/buttons/bike_security_not_available.svg";
  }
}

getCurrentBikeStatusString(bool isLocked, BikeModel bikeModel, BikeProvider bikeProvider, BluetoothProvider bluetoothProvider) {

  if (bikeProvider.userBikePlans.isNotEmpty) {
    for (var index = 0; index < bikeProvider.userBikePlans.length; index++) {
      if (bikeModel.deviceIMEI ==
          bikeProvider.userBikePlans.keys.elementAt(index)) {
        if (bikeProvider.userBikePlans.values.elementAt(index) != null && bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null) {
          final result = calculateDateDifferenceFromNow(
              bikeProvider.userBikePlans.values
                  .elementAt(index)
                  .periodEnd
                  .toDate());
          if (result < 0) {
            return "-";
          } else {
            if (bikeModel.location?.isConnected == false) {
              return "Connection Lost";
            } else {
              switch (bikeModel.location!.status) {
                case 'safe':
                  {
                    if (bluetoothProvider.cableLockState?.lockState == LockState.unlock) {
                      return "Unlocked";
                    } else {
                      return "Locked & Secured";
                    }
                  }
                case 'warning':
                  return "Movement Detected";
                case 'danger':
                  return "Under Threat";
                case 'fall':
                  return "Fall Detected";
                case 'crash':
                  return "Crash Alert";
                default:
                  return "-";
              }
            }
          }
        }else{
          return "-";
        }
      }
    }
  }else{
    return "-";
  }
}

///Load image according danger status
loadMarkerImageString(String dangerStatus){
  /// connection lost

  switch (dangerStatus) {
    case 'safe':
      return "assets/icons/marker_safe.png";
    case 'warning':
      return "assets/icons/marker_warning.png";
    case 'fall':
      return "assets/icons/marker_warning.png";
    case 'danger':
      return "assets/icons/marker_danger.png";
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
      return "assets/buttons/bike_security_lock_and_secure.svg";
    case "unlock":
      return "assets/buttons/bike_security_unlock.svg";
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
      return "Under threat";
    case "lock":
      return "Lock bike";
    case "unlock":
      return "Unlock bike";
    case "fall":
      return "Fall detection";
    default:
      return "empty";
  }
}

animateBounce(mapboxMap, longitude, latitude) {
  mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
            coordinates: Position(
                longitude,
                latitude))
            .toJson(),
        zoom: 16,
      ),
      MapAnimationOptions(duration: 2000, startDelay: 0));

}


pointBounce(mapboxMap, LocationProvider locationProvider, userPosition) {

  final LatLng southwest = LatLng(
    min(locationProvider.locationModel?.geopoint.latitude ?? 0, userPosition.lat.toDouble()),
    min(locationProvider.locationModel?.geopoint.longitude ?? 0, userPosition.lng.toDouble()),
  );

  final LatLng northeast = LatLng(
    max(locationProvider.locationModel?.geopoint.latitude ?? 0, userPosition.lat.toDouble()),
    max(locationProvider.locationModel?.geopoint.longitude ?? 0, userPosition.lng.toDouble()),
  );
  LatLngBounds latLngBounds = LatLngBounds(southwest, northeast);

  mapboxMap?.flyTo(
    CameraOptions(
      padding: MbxEdgeInsets(top: 100.h, left: 170.w, bottom: 360.h, right: 170.w),
      center: latLngBounds.center.toJson(),
      //    zoom: _getZoomLevel(latLngBounds, 350.w ,750.h),

    ),
    MapAnimationOptions(duration: 2000, startDelay: 0),
  );
}

pointBounce2(MapboxMap? mapboxMap, LocationProvider locationProvider, userPosition) async {

  final LatLng southwest = LatLng(
    min(locationProvider.locationModel?.geopoint.latitude ?? 0, userPosition.lat.toDouble()),
    min(locationProvider.locationModel?.geopoint.longitude ?? 0, userPosition.lng.toDouble()),
  );

  final LatLng northeast = LatLng(
    max(locationProvider.locationModel?.geopoint.latitude ?? 0, userPosition.lat.toDouble()),
    max(locationProvider.locationModel?.geopoint.longitude ?? 0, userPosition.lng.toDouble()),
  );

  final CameraOptions cameraOpt = await mapboxMap!.cameraForCoordinateBounds(
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
      top: 50.h,
      bottom: 1000.h,
      right: 170.w,
    ),
    null,
    null,
  );

  mapboxMap.flyTo(cameraOpt, MapAnimationOptions(duration: 2000, startDelay: 0));

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
      color: Colors.transparent,
      width: 2.8.w,
    );
  }

}



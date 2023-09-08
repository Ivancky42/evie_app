import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../api/function.dart';
import '../../api/model/threat_routes_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/location_provider.dart';
import '../../api/provider/notification_provider.dart';
import '../../api/provider/setting_provider.dart';
import '../../bluetooth/modelResult.dart';
import '../../widgets/actionable_bar.dart';
import '../../widgets/evie_button.dart';


///Double button dialog
class HomePageWidget_StatusBar extends StatefulWidget{
  String currentDangerState;
  String? lastSeen;
  Placemark? location;
  String? minutesAgo;
  GeoPoint? selectedGeopoint;
  LocationProvider? locationProvider;

  HomePageWidget_StatusBar({
    Key? key,
    required this.currentDangerState,
    this.lastSeen,
    this.location,
    this.minutesAgo,
    this.selectedGeopoint,
    this.locationProvider,
  }) : super(key: key);

  @override
  State<HomePageWidget_StatusBar> createState() => _HomePageWidget_StatusBarState();
}

class _HomePageWidget_StatusBarState extends State<HomePageWidget_StatusBar> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    Color dangerColor = Colors.transparent;
    Color fontColor = Color(0xff383838);
    String alertImage = "assets/buttons/location_pin.svg";

    if(widget.currentDangerState == "safe"){
      dangerColor = Colors.transparent;
      fontColor = Color(0xff383838);
      alertImage = "assets/buttons/location_pin.svg";
    } else if(widget.currentDangerState == "warning" || widget.currentDangerState == "fall"){
      dangerColor = Color(0xffE59200);
      fontColor = Color(0xffECEDEB);
    alertImage = "assets/buttons/warning.svg";
    }else if(widget.currentDangerState == "danger" || widget.currentDangerState == "crash"){
      dangerColor = Color(0xffCA0D0D);
      fontColor = Color(0xffECEDEB);
       alertImage = "assets/buttons/alert.svg";
    }else{
      dangerColor = Colors.transparent;
      fontColor = Color(0xff383838);
     alertImage = "assets/buttons/location_pin.svg";
    }

    return Container(
      height: 80.h,
      width:double.infinity,
      decoration: BoxDecoration(
        color: dangerColor,
      ),
      child: Padding(padding:
           EdgeInsets.only(left:22.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
             alertImage,
            ),
            SizedBox(width:12.25.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Last seen",style: TextStyle(fontSize: 12.sp, color: fontColor, fontWeight: FontWeight.w400),),
                widget.currentDangerState == "danger" && widget.selectedGeopoint != null
                    ? FutureBuilder<dynamic>(
                    future: widget.locationProvider?.returnPlaceMarks(widget.selectedGeopoint!.latitude, widget.selectedGeopoint!.longitude),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data.name.toString(),
                          style: TextStyle(fontSize: 20.sp, color: fontColor, fontWeight: FontWeight.w900),
                        );
                      }else{
                        return Text(
                          "loading",
                          style: TextStyle(fontSize: 20.sp, color: fontColor, fontWeight: FontWeight.w900),
                        );
                      }
                    }
                )
                    : Text(widget.location?.name ?? "Not available",style: TextStyle(fontSize: 20.sp, color: fontColor, fontWeight: FontWeight.w900),),

                ///Bike provider lastUpdated minus current timestamp
                Text(calculateTimeAgo(_bikeProvider.currentBikeModel!.lastUpdated!.toDate()),
                   style: TextStyle(fontSize: 16.sp,color: fontColor, fontWeight: FontWeight.w400),),
              ],
            ),
          ],
        ),
      )
      // Center(
      //     child:Text(location!,style: TextStyle(fontSize: 12, color: fontColor),)),
    );
  }
}




Widget getSecurityTextWidgetSafe(bool isLocked) {
  switch (isLocked) {
    case true:
        return Text(
          "Locked And Secured",
          style: EvieTextStyles.headlineB,
        );

    case false:
        return Text(
          "Unlocked",
          style: EvieTextStyles.headlineB,
        );
    default:
        return Text(
          "Unknown",
          style: EvieTextStyles.headlineB,
        );
  }
}

getSecurityImageWidget(bool isLocked) {

  if(isLocked){
    return "assets/buttons/bike_security_lock_and_secure.svg";

  }else{
    return "assets/buttons/bike_security_unlock.svg";
  }

}


getSecurityImageWidgetBluetooth(LockState isLocked, String status) {
  switch (isLocked) {
    case LockState.lock:
      if (status == "safe") {
        return "assets/buttons/bike_security_lock_and_secure.svg";
      }
      break;
    case LockState.unlock:
      if (status == "safe") {
        return "assets/buttons/bike_security_unlock.svg";
      }
      break;
    default:
      return "";
  }
  return "";
}

Widget getFirestoreSecurityTextWidget(bool? isLocked, String status) {
  switch (isLocked) {
    case true:
      if (status == "safe") {
        return  Text(
          "LOCKED & SECURE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
    case false:
      if (status == "safe") {
        return  Text(
          "UNLOCKED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
  }
  return CircularProgressIndicator();
}

String getBatteryImage(int batteryPercent) {

  if (batteryPercent > 75 && batteryPercent <= 100) {
    return "assets/icons/battery_100.svg";
  } else if (batteryPercent > 50 && batteryPercent <= 75) {
    return "assets/icons/battery_75.svg";
  } else if (batteryPercent > 25 && batteryPercent <= 50) {
    return "assets/icons/battery_50.svg";
  } else if (batteryPercent > 5 && batteryPercent <= 25) {
    return "assets/icons/battery_25.svg";
  } else if (batteryPercent >= 0 && batteryPercent <= 5) {
    return "assets/icons/battery_0.svg";
  } else {
    return "assets/icons/battery_?.svg";
  }
}

String getEstDistance(int batteryPercent, SettingProvider settingProvider) {

  if(settingProvider.currentMeasurementSetting == MeasurementSetting.imperialSystem){
    if(batteryPercent == 0){
      return "Est - miles";
    }else{
      return "${settingProvider.convertMeterToMiles((0.7 * batteryPercent)*1000).toStringAsFixed(0)}miles";
    }
  }else{
    if(batteryPercent == 0){
      return "Est - km";
    }else{
      return "${(0.7 * batteryPercent).toStringAsFixed(0)}km";
    }
  }


  // if (batteryPercent > 75 && batteryPercent <= 100) {
  //   return "Est 40km";
  // } else if (batteryPercent > 50 && batteryPercent <= 75) {
  //   return "Est 30km";
  // } else if (batteryPercent > 25 && batteryPercent <= 50) {
  //   return "Est 20km";
  // } else if (batteryPercent > 5 && batteryPercent <= 25) {
  //   return "Est 10km";
  // } else if (batteryPercent >= 0 && batteryPercent <= 5) {
  //   return "Est 0km";
  // } else {
  //   return "Est - km";
  // }
}

String getBatteryImageFromBLE(String? batteryPercentage) {
int batteryPercent = int.parse(batteryPercentage!);

if (batteryPercent > 75 && batteryPercent <= 100) {
  return "assets/icons/battery_full_black.svg";
} else if (batteryPercent > 50 && batteryPercent <= 75) {
  return "assets/icons/battery_half_more_black.svg";
} else if (batteryPercent > 20 && batteryPercent <= 50) {
  return "assets/icons/battery_half_less_black.svg";
} else if (batteryPercent >= 0 && batteryPercent <= 20) {
  return "assets/icons/battery_low_black.svg";
} else {
  return "assets/icons/battery_not_available.svg";
}
}



String getDateTime() {
  final now = DateTime.now();
  String? month;

  switch (now.month) {
    case 1:
      month = "Jan";
      break;
    case 2:
      month = "Feb";
      break;
    case 3:
      month = "Mar";
      break;
    case 4:
      month = "Apr";
      break;
    case 5:
      month = "May";
      break;
    case 6:
      month = "Jun";
      break;
    case 7:
      month = "Jly";
      break;
    case 8:
      month = "Aug";
      break;
    case 9:
      month = "Sep";
      break;
    case 10:
      month = "Oct";
      break;
    case 11:
      month = "Nov";
      break;
    case 12:
      month = "Dec";
      break;
  }

  String returnValue =
      "$month ${now.day.toString()}, ${now.year.toString()} at ${now.hour.toString()} : ${now.minute.toString()}";

  return returnValue;
}


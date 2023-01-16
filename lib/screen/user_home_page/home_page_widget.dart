import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../bluetooth/modelResult.dart';


///Double button dialog
class HomePageWidget_StatusBar extends StatefulWidget{
  String currentDangerState;
  String? lastSeen;
  Placemark? location;
  String? minutesAgo;


  HomePageWidget_StatusBar({
    Key? key,
    required this.currentDangerState,
    this.lastSeen,
    this.location,
    this.minutesAgo,

  }) : super(key: key);

  @override
  State<HomePageWidget_StatusBar> createState() => _HomePageWidget_StatusBarState();
}

class _HomePageWidget_StatusBarState extends State<HomePageWidget_StatusBar> {
  @override
  Widget build(BuildContext context) {
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
                Text(widget.location?.name ?? "Not available",style: TextStyle(fontSize: 20.sp, color: fontColor, fontWeight: FontWeight.w900),),
                Text("1 minutes ago",style: TextStyle(fontSize: 16.sp,color: fontColor, fontWeight: FontWeight.w400),),
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



Widget getSecurityTextWidget(bool isLocked) {
  switch (isLocked) {
    case true:
        return Text(
          "LOCKED AND SECURE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );

    case false:
        return Text(
          "UNLOCKED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
    default:
        return Text(
          "UNKNOWN",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
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

  if (batteryPercent > 50 && batteryPercent <= 100) {
    return "assets/icons/battery_full.svg";
  } else if (batteryPercent > 10 && batteryPercent <= 50) {
    return "assets/icons/battery_half.svg";
  } else if (batteryPercent >= 0 && batteryPercent <= 10) {
    return "assets/icons/battery_low.svg";
  } else {
    return "assets/icons/battery_not_available.svg";
  }
}

String getBatteryImageFromBLE(String? batteryPercentage) {
int batteryPercent;

batteryPercent = int.parse(batteryPercentage!);

  if (batteryPercent > 50 && batteryPercent <= 100) {
    return "assets/icons/battery_full.svg";
  } else if (batteryPercent > 10 && batteryPercent <= 50) {
    return "assets/icons/battery_half.svg";
  } else if (batteryPercent >= 0 && batteryPercent <= 10) {
    return "assets/icons/battery_low.svg";
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


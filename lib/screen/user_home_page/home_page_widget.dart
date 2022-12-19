import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../bluetooth/modelResult.dart';


///Double button dialog
class HomePageWidget_Status extends StatefulWidget{
  String currentDangerState;
  String? lastSeen;
  Placemark? location;
  String? minutesAgo;


  HomePageWidget_Status({
    Key? key,
    required this.currentDangerState,
    this.lastSeen,
    this.location,
    this.minutesAgo,

  }) : super(key: key);

  @override
  State<HomePageWidget_Status> createState() => _HomePageWidget_StatusState();
}

class _HomePageWidget_StatusState extends State<HomePageWidget_Status> {
  @override
  Widget build(BuildContext context) {
    Color dangerColor = Colors.transparent;
    Color fontColor = Color(0xff383838);
    String alertImage = "assets/buttons/location_pin.svg";

    if(widget.currentDangerState == "safe"){
      dangerColor = Colors.transparent;
      fontColor = Color(0xff383838);
      alertImage = "assets/buttons/location_pin.svg";
    } else if(widget.currentDangerState == "warning"){
      dangerColor = Color(0xffE59200);
      fontColor = Color(0xffECEDEB);
    alertImage = "assets/buttons/warning.svg";
    }else if(widget.currentDangerState == "danger"){
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
           EdgeInsets.only(left:16.0, top: 8.0, bottom: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
             alertImage,
            ),
            SizedBox(width:12.25.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Last seen",style: TextStyle(fontSize: 12,color: fontColor),),
                Text(widget.location?.name ?? "Not available",style: TextStyle(fontSize: 20, color: fontColor),),
                Text("1 minutes ago",style: TextStyle(fontSize: 12,color: fontColor),),

              ],
            )
          ],

        ),
      )

      // Center(
      //     child:Text(location!,style: TextStyle(fontSize: 12, color: fontColor),)),
    );
  }
}



Widget getSecurityTextWidget(LockState isLocked, String status) {
  switch (isLocked) {
    case LockState.lock:
      if (status == "safe") {
        return Text(
          "LOCKED AND SECURE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "warning") {
        return Text(
          "MOVEMENT DETECTED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "danger") {
        return  Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
    case LockState.unlock:
      if (status == "safe") {
        return Text(
          "UNLOCKED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "warning") {
        return Text(
          "MOVEMENT DETECTED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "danger") {
        return Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
    case LockState.unknown:
      if (status == "safe") {
        return Text(
          "UNKNOWN",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "warning") {
        return Text(
          "MOVEMENT DETECTED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "danger") {
        return Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
  }

  return Text(
    "LOCKED AND SECURE",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
  );
}

getSecurityImageWidget(bool isLocked, String status) {
  switch (isLocked) {
    case true:
      if (status == "safe") {
        return "assets/buttons/bike_security_lock_and_secure.svg";
          //height: 5.h,
      } else if (status == "warning") {
        return  "assets/buttons/bike_security_warning.svg";
          //height: 5.h,

      } else if (status == "danger") {
        return "assets/buttons/bike_security_danger.svg";
          //height: 5.h,

      }
      break;
    case false:
      if (status == "safe") {
        return "assets/buttons/bike_security_unlock.svg";
          //height: 5.h,

      } else if (status == "warning") {
        return "assets/buttons/bike_security_warning.svg";
          //height: 5.h,

      } else if (status == "danger") {
        return "assets/buttons/bike_security_danger.svg";
          //height: 5.h,
      }
      break;
    default:
    // TODO: Handle this case.
      break;
  }
  return "assets/buttons/bike_security_lock_and_secure.svg";
    //height: 5.h,
}


getSecurityImageWidgetBluetooth(LockState isLocked, String status) {
  switch (isLocked) {
    case LockState.lock:
      if (status == "safe") {
        return "assets/buttons/bike_security_lock_and_secure.svg";
        //height: 5.h,
      } else if (status == "warning") {
        return  "assets/buttons/bike_security_warning.svg";
        //height: 5.h,

      } else if (status == "danger") {
        return "assets/buttons/bike_security_danger.svg";
        //height: 5.h,

      }
      break;
    case LockState.unlock:
      if (status == "safe") {
        return "assets/buttons/bike_security_unlock.svg";
        //height: 5.h,

      } else if (status == "warning") {
        return "assets/buttons/bike_security_warning.svg";
        //height: 5.h,

      } else if (status == "danger") {
        return "assets/buttons/bike_security_danger.svg";
        //height: 5.h,
      }
      break;
    default:
    // TODO: Handle this case.
      break;
  }
  return "assets/buttons/bike_security_lock_and_secure.svg";
  //height: 5.h,
}

Widget getFirestoreSecurityTextWidget(bool? isLocked, String status) {
  switch (isLocked) {
    case true:
      if (status == "safe") {
        return  Text(
          "LOCKED & SECURE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "warning") {
        return  Text(
          "MOVEMENT DETECTED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "danger") {
        return Text(
          "UNDER THREAT",
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
      } else if (status == "warning") {
        return  Text(
          "MOVEMENT DETECTED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      } else if (status == "danger") {
        return Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        );
      }
      break;
  }
  return Text(
    "LOCKED & SECURE",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
  );
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

///Load image according danger status
Future<Uint8List> loadMarkerImage(String dangerStatus) async {
  switch (dangerStatus) {
    case 'safe':
      {
        var byteData = await rootBundle.load("assets/icons/marker_safe.png");
        return byteData.buffer.asUint8List();
      }
    case 'warning':
      {
        var byteData =
        await rootBundle.load("assets/icons/marker_warning.png");

        return byteData.buffer.asUint8List();
      }
    case 'danger':
      {
        var byteData =
        await rootBundle.load("assets/icons/marker_danger.png");

        return byteData.buffer.asUint8List();
      }
    default:
      {
        var byteData = await rootBundle.load("assets/icons/marker_safe.png");

        return byteData.buffer.asUint8List();
      }
  }
}


///Load image according danger status
loadMarkerImageString(String dangerStatus){
  switch (dangerStatus) {
    case 'safe':
      {
        return "assets/icons/marker_safe.png";
      }
    case 'warning':
      {

        return "assets/icons/marker_warning.png";
      }
    case 'danger':
      {

        return "assets/icons/marker_danger.png";
      }
    default:
      {

        return "assets/icons/marker_safe.png";
      }
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


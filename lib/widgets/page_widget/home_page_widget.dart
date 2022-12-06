import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sizer/sizer.dart';

import '../../bluetooth/modelResult.dart';


///Double button dialog
class HomePageWidget_Status extends StatelessWidget{
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
  Widget build(BuildContext context) {
    Color dangerColor = Colors.transparent;
    Color fontColor = Color(0xff383838);
    String alertImage = "assets/buttons/location_pin.png";
    
    if(currentDangerState == "safe"){
      dangerColor = Colors.transparent;
      fontColor = Color(0xff383838);
      alertImage = "assets/buttons/location_pin.png";
    } else if(currentDangerState == "warning"){
      dangerColor = Color(0xffE59200);
      fontColor = Color(0xffECEDEB);
    alertImage = "assets/buttons/warning.png";
    }else if(currentDangerState == "danger"){
      dangerColor = Color(0xffCA0D0D);
      fontColor = Color(0xffECEDEB);
       alertImage = "assets/buttons/alert.png";
    }else{
      dangerColor = Colors.transparent;
      fontColor = Color(0xff383838);
     alertImage = "assets/buttons/location_pin.png";
    }
    
    return Container(
      height: 10.h,
      width:double.infinity,
      decoration: BoxDecoration(
        color: dangerColor,
      ),
      child: Padding(padding:
           EdgeInsets.only(left:16.0, top: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Image(
              image: AssetImage(
                  alertImage),
            ),
            SizedBox(width:3.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Last seen",style: TextStyle(fontSize: 12,color: fontColor),),
                Text(location?.name ?? "Not available",style: TextStyle(fontSize: 20, color: fontColor),),
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
        return const Text(
          "LOCKED AND SECURE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      } else if (status == "warning") {
        return const Text(
          "ATTENTION NEEDED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      } else if (status == "danger") {
        return const Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      }
      break;
    case LockState.unlock:
      if (status == "safe") {
        return const Text(
          "UNLOCKED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      } else if (status == "warning") {
        return const Text(
          "ATTENTION NEEDED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      } else if (status == "danger") {
        return const Text(
          "UNDER THREAT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      }
      break;
    case LockState.unknown:
    // TODO: Handle this case.
      break;
  }

  return const Text(
    "LOCKED AND SECURE",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );
}

Widget getSecurityImageWidget(LockState isLocked, String status) {
  switch (isLocked) {
    case LockState.lock:
      if (status == "safe") {
        return const Image(
          image:
          AssetImage("assets/buttons/bike_security_lock_and_secure.png"),
          //height: 5.h,
        );
      } else if (status == "warning") {
        return const Image(
          image: AssetImage("assets/buttons/bike_security_warning.png"),
          //height: 5.h,
        );
      } else if (status == "danger") {
        return const Image(
          image: AssetImage("assets/buttons/bike_security_danger.png"),
          //height: 5.h,
        );
      }
      break;
    case LockState.unlock:
      if (status == "safe") {
        return const Image(
          image: AssetImage("assets/buttons/bike_security_unlock.png"),
          //height: 5.h,
        );
      } else if (status == "warning") {
        return const Image(
          image: AssetImage("assets/buttons/bike_security_warning.png"),
          //height: 5.h,
        );
      } else if (status == "danger") {
        return const Image(
          image: AssetImage("assets/buttons/bike_security_danger.png"),
          //height: 5.h,
        );
      }
      break;
    case LockState.unknown:
    // TODO: Handle this case.
      break;
  }
  return const Image(
    image: AssetImage("assets/buttons/bike_security_lock_and_secure.png"),
    //height: 5.h,
  );
}

Widget getBatteryImage(int batteryPercent) {
  if (batteryPercent > 50 && batteryPercent <= 100) {
    return Image(
      image: const AssetImage("assets/icons/battery_full.png"),
      height: 1.h,
    );
  } else if (batteryPercent > 10 && batteryPercent <= 50) {
    return Image(
      image: const AssetImage("assets/icons/battery_half.png"),
      height: 1.h,
    );
  } else if (batteryPercent > 0 && batteryPercent <= 10) {
    return Image(
      image: const AssetImage("assets/icons/battery_low.png"),
      height: 1.h,
    );
  } else if (batteryPercent == 0) {
    return Image(
      image: const AssetImage("assets/icons/battery_empty.png"),
      height: 1.h,
    );
  } else {
    return Image(
      image: const AssetImage("assets/icons/battery_empty.png"),
      height: 1.h,
    );
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

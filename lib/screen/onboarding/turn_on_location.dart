import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

class TurnOnLocation extends StatefulWidget {
  const TurnOnLocation({Key? key}) : super(key: key);

  @override
  _TurnOnLocationState createState() => _TurnOnLocationState();
}

class _TurnOnLocationState extends State<TurnOnLocation> {


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Stack(
          children:[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
          padding: EdgeInsets.fromLTRB(70.w, 66.h, 70.w,50.h),
            child:const StepProgressIndicator(
              totalSteps: 10,
              currentStep: 1,
              selectedColor: Color(0xffCECFCF),
              selectedSize: 4,
              unselectedColor: Color(0xffDFE0E0),
              unselectedSize: 3,
              padding: 0.0,
              roundedEdges: Radius.circular(16),
            ),
        ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
              child: Text(
                "First Up, allow Location",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 113.h),
              child: Text(
                "EVIE need to use your location to track and connect with your EVIE bike.",
                style: TextStyle(fontSize: 16.sp,height: 1.5.h),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,221.h),
              child: Center(
                child: SvgPicture.asset(
                  "assets/images/allow_location.svg",
                ),
              ),
            ),
          ],
        ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Allow Location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  onPressed: () async {
                    if (await Permission.location.request().isGranted && await Permission.locationWhenInUse.request().isGranted) {
                      var bluetoothStatus = await Permission.bluetooth.status;

                      if(bluetoothStatus == PermissionStatus.granted){

                        changeToTurnOnQRScannerScreen(context);
                      }else{

                        changeToTurnOnBluetoothScreen(context);
                      }
                    }else if(await Permission.location.isPermanentlyDenied){
                     OpenSettings.openLocationSourceSetting();
                    }
                  },
                ),
              ),
            ),


      ]
        )
      ),
    );
  }
}

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

class TurnOnBluetooth extends StatefulWidget {
  const TurnOnBluetooth({Key? key}) : super(key: key);

  @override
  _TurnOnBluetoothState createState() => _TurnOnBluetoothState();
}

class _TurnOnBluetoothState extends State<TurnOnBluetooth> {

  late CurrentUserProvider _currentUserProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child:  Scaffold(
        body: Stack(
          children:[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5.h,
              ),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child:StepProgressIndicator(
                  totalSteps: 10,
                  currentStep: 2,
                  selectedColor: Color(0xffCECFCF),
                  selectedSize: 4,
                  unselectedColor: Color(0xffDFE0E0),
                  unselectedSize: 3,
                  padding: 0.0,
                  roundedEdges: Radius.circular(16),
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                "Turn on Bluetooth",
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                "EVIE will use Bluetooth to stay connect with your EVIE bike.",
                style: TextStyle(fontSize: 12.sp,height: 0.17.h),
              ),
              SizedBox(
                height: 12.h,
              ),
            ],
          ),
        ),

            Align(
              alignment: Alignment.center,
              child:  Container(
                width: double.infinity,
                child:const Center(
                  child: Image(
                    fit: BoxFit.fitWidth,
                    image: AssetImage("assets/images/evie_bike_shadow_half.png"),
                  ),
                ),

              ),
            ),


            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.buttonWord_ButtonBottom),
                child:  EvieButton(
                  width: double.infinity,
                  child: Text(
                    "Allow Bluetooth",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                  onPressed: () async {
                    if (await Permission.bluetooth.request().isGranted && await Permission.bluetoothScan.request().isGranted) {
                      changeToBikeScanningScreen(context);
                    }else if(await Permission.bluetooth.isPermanentlyDenied || await Permission.bluetooth.isDenied){
                      OpenSettings.openBluetoothSetting();
                    }
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: EvieLength.buttonWord_WordBottom),
                child:

                SizedBox(
                  height: 4.h,
                  width: 30.w,
                  child:
                  TextButton(
                    child: Text(
                      "Maybe Later",
                      style: TextStyle(fontSize: 9.sp,color: EvieColors.PrimaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      changeToTurnOnNotificationsScreen(context);
                    },
                  ),
                ),
              ),
            ),




      ]
        )
      ),
    );
  }
}

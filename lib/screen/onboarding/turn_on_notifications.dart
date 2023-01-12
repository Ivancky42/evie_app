import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bluetooth_provider.dart';

class TurnOnNotifications extends StatefulWidget {
  const TurnOnNotifications({Key? key}) : super(key: key);

  @override
  _TurnOnNotificationsState createState() => _TurnOnNotificationsState();
}

class _TurnOnNotificationsState extends State<TurnOnNotifications> {

  late CurrentUserProvider _currentUserProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

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
                        currentStep: 6,
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
                        "Stay in the know with notifications",
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 113.h),
                      child: Text(
                        "Get updates about updates, offers and more... "
                            "You can always manage your notification categories in Setting anytime.",
                        style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                      ),
                    ),

                  ],
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.buttonWord_ButtonBottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Allow Notification",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {
                        if (await Permission.notification.request().isGranted) {
                          changeToNotificationsControlScreen(context);
                        }else if(await Permission.notification.isPermanentlyDenied || await Permission.notification.isDenied){
                          OpenSettings.openAppNotificationSetting();
                        }
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(150.w,25.h,150.w,EvieLength.buttonWord_WordBottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        child: Text(
                          "Maybe Later",
                          softWrap: false,
                          style: TextStyle(fontSize: 12.sp,color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                        ),
                        onPressed: () {
                          changeToCongratulationScreen(context);
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

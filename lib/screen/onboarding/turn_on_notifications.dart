import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../api/provider/notification_provider.dart';
import '../../widgets/evie_progress_indicator.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_switch.dart';

class TurnOnNotifications extends StatefulWidget {
  const TurnOnNotifications({Key? key}) : super(key: key);

  @override
  _TurnOnNotificationsState createState() => _TurnOnNotificationsState();
}

class _TurnOnNotificationsState extends State<TurnOnNotifications> {

  bool _switchValue1 = true;
  bool _switchValue2 = true;
  bool _switchValue3 = true;
  bool _switchValue4 = true;

  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

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
                    const EvieProgressIndicator(currentPageNumber: 6),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                      child:

                      Text(
                        "Stay in the know with push notifications",
                        style: EvieTextStyles.h2,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
                      child: Text(    "Get latest updates of EVIE bike with EVIE app. You can always manage your push notification in Setting anytime.",
                        style: EvieTextStyles.body18,),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0.h),
                      child: Container(
                          child: Column(
                            children: [
                              EvieSwitch(
                                text: "General Notification",
                                value: _switchValue1,
                                thumbColor: _thumbColor,
                                onChanged: (value) {
                                  setState(() {
                                    _switchValue1 = value!;
                                  });
                                },
                              ),

                              EvieSwitch(
                                text: "Bike Firmware Update",
                                value: _switchValue2,
                                thumbColor: _thumbColor,
                                onChanged: (value) {
                                  setState(() {
                                    _switchValue2 = value!;
                                  });
                                },
                              ),

                              ///Free and pro plan
                              ///
                              EvieSwitch(
                                text: "Bike Security Alert",
                                value: _switchValue3,
                                thumbColor: _thumbColor,
                                onChanged: (value) {
                                  setState(() {
                                    _switchValue3 = value!;
                                  });
                                },
                              ),

                              EvieSwitch(
                                text: "SOS Alerts",
                                value: _switchValue4,
                                thumbColor: _thumbColor,
                                onChanged: (value) {
                                  setState(() {
                                    _switchValue4 = value!;
                                  });
                                },
                              ),
                            ],
                          )
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
                        "Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {
                        SmartDialog.showLoading();
                        try{
                          await _bikeProvider.updateFirestoreNotification("general", _switchValue1);
                          if(_switchValue1){
                            await _notificationProvider.subscribeToTopic("~general");
                          }
                          await _bikeProvider.updateFirestoreNotification("firmwareUpdate", _switchValue2);
                          if(_switchValue2){
                            await _notificationProvider.subscribeToTopic("~firmware-update");
                          }

                          await _bikeProvider.updateFirestoreNotification("connectionLost", _switchValue3);
                          await _bikeProvider.updateFirestoreNotification("movementDetect", _switchValue3);
                          await _bikeProvider.updateFirestoreNotification("theftAttempt", _switchValue3);
                          await _bikeProvider.updateFirestoreNotification("lock", _switchValue3);
                          await _bikeProvider.updateFirestoreNotification("planReminder", _switchValue3);
                          if(_switchValue3){
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~connection-lost");
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~movement-detect");
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~theft-attempt");
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~lock-reminder");
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~plan-reminder");
                          }

                          await _bikeProvider.updateFirestoreNotification("crash", _switchValue4);
                          await _bikeProvider.updateFirestoreNotification("fallDetect", _switchValue4);
                          if(_switchValue4){
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~fall-detect");
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~crash");
                          }

                          SmartDialog.dismiss();

                          changeToCongratulationScreen(context);
                        }catch(e){
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: "Try again",
                                  rightContent: "OK",
                                  onPressedRight: (){
                                    SmartDialog.dismiss();
                                  }));
                        }

                        ///Also need to subscript
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

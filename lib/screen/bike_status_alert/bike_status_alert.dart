import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/model/bike_user_model.dart';
import '../../api/model/user_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/notification_provider.dart';
import '../../theme/ThemeChangeNotifier.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_switch.dart';
import '../my_account/my_account_widget.dart';
import '../my_bike/my_bike_widget.dart';


class BikeStatusAlert extends StatefulWidget{
  const BikeStatusAlert({ Key? key }) : super(key: key);
  @override
  _BikeStatusAlertState createState() => _BikeStatusAlertState();
}

class _BikeStatusAlertState extends State<BikeStatusAlert> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;

  final Color _thumbColor = EvieColors.ThumbColorTrue;


  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    var currentNotificationSettings = _bikeProvider.userBikeList[_bikeProvider.currentBikeModel?.deviceIMEI];

    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Share Bike',
          onPressed: () {
            changeToNavigatePlanScreen(context);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: EvieSwitch(
                    title: "Connection Lost",
                    text: "You will receive an notification when your bike lost connection for more than 10mins",
                    value: currentNotificationSettings?.notificationSettings?.connectionLost ?? false,
                    thumbColor: _thumbColor,
                    onChanged: (value) async {
                      SmartDialog.showLoading();
                      var result = await _bikeProvider.updateFirestoreNotification("connectionLost", value!);
                      if(result == true){
                        SmartDialog.dismiss();
                        switch(value){
                          case true:
                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~connection-lost");
                            break;
                          case false:
                            await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~connection-lost");
                            break;
                        }
                      }else{
                        SmartDialog.show(
                            widget: EvieSingleButtonDialog(
                            title: "Error",
                            content: "Try again",
                            rightContent: "OK",
                            onPressedRight: (){SmartDialog.dismiss();}));
                      }
                    },
                  )
                ),
                const BikePageDivider(),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      title: "Movement Detection",
                      text: "Whenever movement is detection, a push notification will be send",
                      value: currentNotificationSettings?.notificationSettings?.movementDetect ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("movementDetect", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~movement-detect");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~movement-detect");
                                break;
                            }
                          }else{
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: (){SmartDialog.dismiss();}));
                          }
                      },
                    )
                ),
                const BikePageDivider(),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      title: "Theft Attempt",
                      text: "Theft attempt alert will be trigger when your bike is being moved for more than 50m radius",
                      value:  currentNotificationSettings?.notificationSettings?.theftAttempt ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("theftAttempt", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~theft-attempt");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~theft-attempt");
                                break;
                            }
                          }else{
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: (){SmartDialog.dismiss();}));
                          }
                      },
                    )
                ),
                const BikePageDivider(),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      title: "Lock Reminder",
                      text: "Lock Reminder will be sent when your bike is left unlock for more than 10minutes",
                      value:  currentNotificationSettings?.notificationSettings?.lock ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("lock", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~lock-reminder");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~lock-reminder");
                                break;
                            }
                          }else{
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: (){SmartDialog.dismiss();}));
                          }
                      },
                    )
                ),
                const BikePageDivider(),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      text: "Plan Reminder",
                      value:  currentNotificationSettings?.notificationSettings?.planReminder ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("planReminder", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~plan-reminder");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~plan-reminder");
                                break;
                            }
                          }else{
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: (){SmartDialog.dismiss();}));
                          }
                      },
                    )
                ),
                const BikePageDivider(),

            ],
            ),
          ],
        ),),
    );
  }

}
import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_appbar_badge.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_switch.dart';
import '../../my_account/my_account_widget.dart';



class BikeStatusAlert extends StatefulWidget{
  const BikeStatusAlert({ Key? key }) : super(key: key);
  @override
  _BikeStatusAlertState createState() => _BikeStatusAlertState();
}

class _BikeStatusAlertState extends State<BikeStatusAlert> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    var currentNotificationSettings = _bikeProvider.currentBikeModel?.notificationSettings;

    return WillPopScope(
      onWillPop: () async {
       // _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbarWithBadge(
          title: 'Anti-theft Alert',
          onPressedLeading: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 25.h, 16.w, 21.h),
                  child: Text(
                    "Anti-theft Alert will show push notification to your phone. Select based on your reference.",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w,4.h),
                  child: EvieSwitch(
                    height: 82.h,
                    activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                    title: "Connection Lost",
                    text: "You will receive an notification when your bike lost connection for more than 10mins",
                    value: currentNotificationSettings?.connectionLost ?? false,
                    thumbColor: _thumbColor,
                    onChanged: (value) async {

                      if(_bikeProvider.isOwner == true){
                        SmartDialog.showLoading();
                        var result = await _bikeProvider.updateBikeNotifySetting("connectionLost", value!);
                        if(result == true){
                          SmartDialog.dismiss();
                        }
                        else{
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: "Try again",
                                  rightContent: "OK",
                                  onPressedRight: (){SmartDialog.dismiss();}));
                        }
                      }
                      else{
                        showAccNoPermissionToast(context);
                      }
                    },
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: EvieDivider(),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      height: 82.h,
                      activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Movement Detection",
                      text: "Whenever movement is detection, a push notification will be send",
                      value: currentNotificationSettings?.movementDetect ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          if(_bikeProvider.isOwner == true) {
                            SmartDialog.showLoading();
                            var result = await _bikeProvider
                                .updateBikeNotifySetting(
                                "movementDetect", value!);
                            if (result == true) {
                              SmartDialog.dismiss();
                            }
                            else {
                              SmartDialog.show(
                                  widget: EvieSingleButtonDialog(
                                      title: "Error",
                                      content: "Try again",
                                      rightContent: "OK",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }));
                            }
                          }else{
                            showAccNoPermissionToast(context);
                          }
                      },
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: EvieDivider(),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      height: 82.h,
                      activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Theft Attempt",
                      text: "Theft attempt alert will be trigger when your bike is being moved for more than 50m radius",
                      value:  currentNotificationSettings?.theftAttempt ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          if(_bikeProvider.isOwner == true) {
                            SmartDialog.showLoading();
                            var result = await _bikeProvider.updateBikeNotifySetting(
                                "theftAttempt", value!);
                            if (result == true) {
                              SmartDialog.dismiss();
                            } else {
                              SmartDialog.show(
                                  widget: EvieSingleButtonDialog(
                                      title: "Error",
                                      content: "Try again",
                                      rightContent: "OK",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }));
                            }
                          }else{
                            showAccNoPermissionToast(context);
                          }
                      },
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: EvieDivider(),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      height: 82.h,
                      activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Lock / Unlock",
                      text: "You will receive an notification when your bike is lock/unlock.",
                      value:  currentNotificationSettings?.lock ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                        if(_bikeProvider.isOwner == true) {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateBikeNotifySetting(
                              "lock", value!);
                          if (result == true) {
                            SmartDialog.dismiss();
                          } else {
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: () {
                                      SmartDialog.dismiss();
                                    }));
                          }
                        }else{
                          showAccNoPermissionToast(context);
                        }
                      },
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: EvieDivider(),
                ),
                // Padding(
                //     padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                //     child: EvieSwitch(
                //       activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                //       title: "Fall Detection",
                //       text: "Fall Detection Alert will be trigger when bike fall without rider.",
                //       value:  currentNotificationSettings?.notificationSettings?.fallDetect ?? false,
                //       thumbColor: _thumbColor,
                //       onChanged: (value) async {
                //         if(_bikeProvider.isOwner == true) {
                //           SmartDialog.showLoading();
                //           var result = await _bikeProvider.updateFirestoreNotification("fallDetect", value!);
                //           if (result == true) {
                //             SmartDialog.dismiss();
                //             switch(value){
                //               case true:
                //                 await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~fall-detect");
                //                 break;
                //               case false:
                //                 await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~fall-detect");
                //                 break;
                //             }
                //           } else {
                //             SmartDialog.show(
                //                 widget: EvieSingleButtonDialog(
                //                     title: "Error",
                //                     content: "Try again",
                //                     rightContent: "OK",
                //                     onPressedRight: () {
                //                       SmartDialog.dismiss();
                //                     }));
                //           }
                //         }else{
                //           showAccNoPermissionToast(context);
                //         }
                //       },
                //     )
                // ),
                const EvieDivider(),
                // Padding(
                //     padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                //     child: EvieSwitch(
                //       text: "Plan Reminder",
                //       value:  currentNotificationSettings?.notificationSettings?.planReminder ?? false,
                //       thumbColor: _thumbColor,
                //       onChanged: (value) async {
                //           SmartDialog.showLoading();
                //           var result = await _bikeProvider.updateFirestoreNotification("planReminder", value!);
                //           if(result == true){
                //             SmartDialog.dismiss();
                //             switch(value){
                //               case true:
                //                 await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~plan-reminder");
                //                 break;
                //               case false:
                //                 await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~plan-reminder");
                //                 break;
                //             }
                //           }else{
                //             SmartDialog.show(
                //                 widget: EvieSingleButtonDialog(
                //                     title: "Error",
                //                     content: "Try again",
                //                     rightContent: "OK",
                //                     onPressedRight: (){SmartDialog.dismiss();}));
                //           }
                //       },
                //     )
                // ),
                // const EvieDivider(),

            ],
            ),
          ],
        ),),
    );
  }

}
import 'dart:collection';
import 'package:evie_test/api/dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/widgets/evie_appbar_badge.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_switch.dart';



class BikeStatusAlert extends StatefulWidget{
  const BikeStatusAlert({ super.key });
  @override
  _BikeStatusAlertState createState() => _BikeStatusAlertState();
}

class _BikeStatusAlertState extends State<BikeStatusAlert> with WidgetsBindingObserver {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;
  bool hasPermission = false;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationProvider = context.read<NotificationProvider>();
    _notificationProvider.checkNotificationPermission();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationProvider.checkNotificationPermission();
      //print("App resumed");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    var currentNotificationSettings = _bikeProvider.currentBikeModel?.notificationSettings;

    switch(_notificationProvider.permissionStatus) {
      case PermissionStatus.denied:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.granted:
        if (!hasPermission) {
          setState(() {
            hasPermission = true;
          });
        }
        break;
      case PermissionStatus.restricted:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.limited:
        if (!hasPermission) {
          setState(() {
            hasPermission = true;
          });
        }
        break;
      case PermissionStatus.permanentlyDenied:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.provisional:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case null:
      // TODO: Handle this case.
        break;
    }

    return WillPopScope(
      onWillPop: () async {
       // _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbarWithBadge(
          title: 'EV-Secure Alerts',
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
                    "Receive EV-Secure Alerts on your phone through push notifications. As the bike owner, you may customize your preferences.",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                  ),
                ),

                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w,4.h),
                    child: EvieSwitch(
                      height: 82.h,
                      activeColor: hasPermission ? (_bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4)) : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Lock",
                      text: "Receive a notification whenever you lock your bike.",
                      value: currentNotificationSettings?.lock ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          if (_bikeProvider.isOwner == true) {
                            if (hasPermission) {
                              showCustomLightLoading();
                              var result = await _bikeProvider
                                  .updateBikeNotifySetting("lock", value!);
                              if (result == true) {
                                SmartDialog.dismiss();
                              }
                              else {
                                SmartDialog.show(
                                    builder: (_) => EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Try again",
                                        rightContent: "OK",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                            }
                            else {
                              showPermissionNeededForEVSecure(context);
                            }
                          }
                          else {
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
                      activeColor: hasPermission ? (_bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4)) : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Unlock",
                      text: "Receive a notification whenever your bike is unlocked.",
                      value: currentNotificationSettings?.unlock ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {

                        if(_bikeProvider.isOwner == true){
                          if (hasPermission) {
                            showCustomLightLoading();
                            var result = await _bikeProvider
                                .updateBikeNotifySetting("unlock", value!);
                            if (result == true) {
                              SmartDialog.dismiss();
                            }
                            else {
                              SmartDialog.show(
                                  builder: (_) => EvieSingleButtonDialog(
                                      title: "Error",
                                      content: "Try again",
                                      rightContent: "OK",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }));
                            }
                          }
                          else {
                            showPermissionNeededForEVSecure(context);
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

                // Padding(
                //   padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                //   child: EvieSwitch(
                //     height: 82.h,
                //     activeColor: hasPermission ? (_bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4)) : EvieColors.primaryColor.withOpacity(0.4),
                //     title: "Connection Lost",
                //     text: "Receive a notification when your bike has lost connection for more than 10mins",
                //     value: currentNotificationSettings?.connectionLost ?? false,
                //     thumbColor: _thumbColor,
                //     onChanged: (value) async {
                //
                //       if(_bikeProvider.isOwner == true){
                //         if (hasPermission) {
                //           showCustomLightLoading();
                //           var result = await _bikeProvider
                //               .updateBikeNotifySetting(
                //               "connectionLost", value!);
                //           if (result == true) {
                //             SmartDialog.dismiss();
                //           }
                //           else {
                //             SmartDialog.show(
                //                 widget: EvieSingleButtonDialog(
                //                     title: "Error",
                //                     content: "Try again",
                //                     rightContent: "OK",
                //                     onPressedRight: () {
                //                       SmartDialog.dismiss();
                //                     }));
                //           }
                //         }
                //         else {
                //           showPermissionNeededForEVSecure(context);
                //         }
                //       }
                //       else{
                //         showAccNoPermissionToast(context);
                //       }
                //     },
                //   )
                // ),
                // Padding(
                //   padding: EdgeInsets.only(left: 16.w),
                //   child: EvieDivider(),
                // ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: EvieSwitch(
                      height: 82.h,
                      activeColor: hasPermission ? (_bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4)) : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Movement Detection",
                      text: "Receive a notification when movement is detected while your bike is locked.",
                      value: currentNotificationSettings?.movementDetect ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          if(_bikeProvider.isOwner == true) {
                            if (hasPermission) {
                              showCustomLightLoading();
                              var result = await _bikeProvider
                                  .updateBikeNotifySetting(
                                  "movementDetect", value!);
                              if (result == true) {
                                SmartDialog.dismiss();
                              }
                              else {
                                SmartDialog.show(
                                    builder: (_) => EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Try again",
                                        rightContent: "OK",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                            }
                            else {
                              showPermissionNeededForEVSecure(context);
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
                      activeColor: hasPermission ? (_bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4)) : EvieColors.primaryColor.withOpacity(0.4),
                      title: "Theft Attempt",
                      text: "Receive a theft attempt alert when your bike is moved beyond a 50m radius while locked.",
                      value:  currentNotificationSettings?.theftAttempt ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          if(_bikeProvider.isOwner == true) {
                            if (hasPermission) {
                              showCustomLightLoading();
                              var result = await _bikeProvider
                                  .updateBikeNotifySetting(
                                  "theftAttempt", value!);
                              if (result == true) {
                                SmartDialog.dismiss();
                              } else {
                                SmartDialog.show(
                                    builder: (_) => EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Try again",
                                        rightContent: "OK",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                            }
                            else {
                              showPermissionNeededForEVSecure(context);
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
                //       height: 82.h,
                //       activeColor: _bikeProvider.isOwner == true ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                //       title: "Lock / Unlock",
                //       text: "You will receive an notification when your bike is lock/unlock.",
                //       value:  currentNotificationSettings?.lock ?? false,
                //       thumbColor: _thumbColor,
                //       onChanged: (value) async {
                //         if(_bikeProvider.isOwner == true) {
                //           showCustomLightLoading();
                //           var result = await _bikeProvider.updateBikeNotifySetting(
                //               "lock", value!);
                //           if (result == true) {
                //             SmartDialog.dismiss();
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
                // Padding(
                //   padding: EdgeInsets.only(left: 16.w),
                //   child: EvieDivider(),
                // ),
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
                // const EvieDivider(),
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
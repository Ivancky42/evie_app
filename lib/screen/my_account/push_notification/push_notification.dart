import 'dart:collection';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';



class PushNotification extends StatefulWidget{
  const PushNotification({ super.key });
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> with WidgetsBindingObserver{


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;
  late CurrentUserProvider _currentUserProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  bool hasPermission = false;

  @override
  void initState() {
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
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

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

    return Scaffold(
      appBar: PageAppbar(
        title: 'Push Notifications',
        onPressed: () {
          back(context, PushNotification());
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 20.w, 0),
                    child: EvieSwitch(
                      activeColor: hasPermission ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      height: 64.h,
                      title: "General Notifications",
                      value: _currentUserProvider.currentUserModel?.notificationSettings?.general ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                      if (hasPermission) {
                        showCustomLightLoading();
                        var result = await _bikeProvider
                            .updateFirestoreNotification("general", value!);
                        if (result) {
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
                        showPermissionNeeded(context);
                      }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Divider(
                      thickness: 0.2.h,
                      color: EvieColors.darkWhite,
                      height: 0,
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 20.w, 0),
                    child: EvieSwitch(
                      activeColor: hasPermission ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      height: 64.h,
                      title: "Promotions",
                      value: _currentUserProvider.currentUserModel?.notificationSettings?.promo ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                        if (hasPermission) {
                          showCustomLightLoading();
                          var result = await _bikeProvider
                              .updateFirestoreNotification("promo", value!);
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
                          showPermissionNeeded(context);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Divider(
                      thickness: 0.2.h,
                      color: EvieColors.darkWhite,
                      height: 0,
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 20.w, 0),
                    child: EvieSwitch(
                      activeColor: hasPermission ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.4),
                      height: 64.h,
                      title: "Software Updates",
                      value: _currentUserProvider.currentUserModel?.notificationSettings?.firmwareUpdate ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                        if (hasPermission) {
                          showCustomLightLoading();
                          var result = await _bikeProvider
                              .updateFirestoreNotification("firmwareUpdate",
                              value!);
                          if (result) {
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
                          showPermissionNeeded(context);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Divider(
                      thickness: 0.2.h,
                      color: EvieColors.darkWhite,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),);
  }

}
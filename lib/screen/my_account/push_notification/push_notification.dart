import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';
import '../my_account_widget.dart';



class PushNotification extends StatefulWidget{
  const PushNotification({ Key? key }) : super(key: key);
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;
  late CurrentUserProvider _currentUserProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToMyAccount(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Push Notification',
          onPressed: () {
            changeToMyAccount(context);
          },
        ),
        body: Stack(
          children: [
            Padding(
              padding:  EdgeInsets.only(left: 16.w, right: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EvieSwitch(
                    text: "General Notifications",
                    value: _currentUserProvider.currentUserModel?.notificationSettings?.general ?? false,
                    thumbColor: _thumbColor,
                    onChanged: (value) async {
                      SmartDialog.showLoading();
                      var result = await _bikeProvider.updateFirestoreNotification("general", value!);
                      if(result == true){
                        SmartDialog.dismiss();
                        switch(value){
                          case true:
                            await _notificationProvider.subscribeToTopic("~general");
                            break;
                          case false:
                            await _notificationProvider.unsubscribeFromTopic("~general");
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
                  ),
                  const EvieDivider(),

                  EvieSwitch(
                    text: "Firmware Update",
                    value: _currentUserProvider.currentUserModel?.notificationSettings?.firmwareUpdate ?? false,
                    thumbColor: _thumbColor,
                    onChanged: (value) async {
                      SmartDialog.showLoading();
                      var result = await _bikeProvider.updateFirestoreNotification("firmwareUpdate", value!);
                      if(result == true){
                        SmartDialog.dismiss();
                        switch(value){
                          case true:
                            await _notificationProvider.subscribeToTopic("~firmware-update");
                            break;
                          case false:
                            await _notificationProvider.unsubscribeFromTopic("~firmware-update");
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
                  ),

                  const EvieDivider(),

                  EvieSwitch(
                    text: "Offers",
                    value: true,
                    thumbColor: _thumbColor,
                    onChanged: (value) {

                    },
                  ),

                  const EvieDivider(),

                ],
              ),
            ),
          ],
        ),),
    );
  }

}
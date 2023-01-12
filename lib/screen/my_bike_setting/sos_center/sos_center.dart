import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';

import '../../my_account/my_account_widget.dart';
import '../my_bike_widget.dart';



class SOSCenter extends StatefulWidget{
  const SOSCenter({ Key? key }) : super(key: key);
  @override
  _SOSCentertState createState() => _SOSCentertState();
}

class _SOSCentertState extends State<SOSCenter> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

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
          title: 'SOS Center',
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
                      title: "Fall Detection",
                      text: "Fall Detection Alert will be trigger when bike fall without rider",
                      value:  currentNotificationSettings?.notificationSettings?.fallDetect ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("fallDetect", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~fall-detect");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~fall-detect");
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
                      title: "Crash Alert",
                      text: "Crash Alert will be trigger and be sent to sharing bike list when rider fall while cycling",
                      value:  currentNotificationSettings?.notificationSettings?.crash ?? false,
                      thumbColor: _thumbColor,
                      onChanged: (value) async {
                          SmartDialog.showLoading();
                          var result = await _bikeProvider.updateFirestoreNotification("crash", value!);
                          if(result == true){
                            SmartDialog.dismiss();
                            switch(value){
                              case true:
                                await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~crash");
                                break;
                              case false:
                                await _notificationProvider.unsubscribeFromTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}~crash");
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
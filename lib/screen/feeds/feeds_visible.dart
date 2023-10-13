import 'dart:async';
import 'dart:collection';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import 'package:evie_test/widgets/evie_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/model/notification_model.dart';
import '../../api/navigator.dart';
import '../../api/sheet.dart';
import '../../api/snackbar.dart';
import '../../bluetooth/modelResult.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_single_button_dialog.dart';

class FeedsVisible extends StatefulWidget {

  LinkedHashMap<String, NotificationModel> notificationList = LinkedHashMap<String, NotificationModel>();
  int index;

    FeedsVisible({Key? key,
      //required this.notificationList,
      required this.index,
    }) : super(key: key);

  @override
  _FeedsVisibleState createState() => _FeedsVisibleState();
}

class _FeedsVisibleState extends State<FeedsVisible> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;
  late SettingProvider _settingProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return  ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(6.h),
      shrinkWrap: true,
      children: [

        ///type == shareBike, status == pending
        Visibility(
          visible: _notificationProvider.notificationList.values.elementAt(widget.index).status == "userPending",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: EvieButton_ReversedColor(
                      onPressed: (){
                        decline(widget.index, _bikeProvider, _notificationProvider );
                      },
                      child: Text(
                        "Decline",
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: EvieColors.primaryColor,
                            fontWeight: FontWeight.w800
                        ),
                      ),
                      height: 36.h,
                      width: 169.w,
                  )
              ),

              Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: EvieButton(
                      onPressed: () async {
                        SmartDialog.show(
                            backDismiss: false,
                            widget: Container(
                                color: EvieColors.grayishWhite,
                                width: double.infinity,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 157.h,
                                      width: 279.h,
                                      child: Lottie.asset(
                                          'assets/animations/add-bike.json',
                                          repeat: true,
                                          height: 157.h,
                                          width: 279.h,
                                          fit: BoxFit.cover
                                      ),
                                    ),
                                    SizedBox(height: 60.h,),
                                    Text("Accepting invitation and adding bike...", style:EvieTextStyles.body16.copyWith(color: EvieColors.darkGray),)
                                  ],
                                )
                            ));

                        // for (var element in _bikeProvider.userBikeNotificationList) {
                        //   await _notificationProvider.subscribeToTopic("${_notificationProvider.notificationList.values.elementAt(widget.index).deviceIMEI!}$element");
                        // }
                        // SmartDialog.dismiss();
                        // _notificationProvider.updateUserNotificationSharedBikeStatus(_notificationProvider.notificationList.keys.elementAt(widget.index));
                        // changeToUserHomePageScreen2(context);


                        StreamSubscription? currentSubscription;
                        currentSubscription = _bikeProvider.acceptSharedBike(_notificationProvider.notificationList.values.elementAt(widget.index).deviceIMEI!, _currentUserProvider.currentUserModel!.uid).listen((uploadStatus) async {
                          if(uploadStatus == UploadFirestoreResult.success){
                            SmartDialog.dismiss();
                            _notificationProvider.updateUserNotificationSharedBikeStatus(_notificationProvider.notificationList.keys.elementAt(widget.index));
                            showBikeAddSuccessfulToast(context);
                            // for (var element in _bikeProvider.userBikeNotificationList) {
                            //   await _notificationProvider.subscribeToTopic("${_notificationProvider.notificationList.values.elementAt(widget.index).deviceIMEI!}$element");
                            // }
                            changeToUserHomePageScreen(context);
                            currentSubscription?.cancel();
                          }
                          else if(uploadStatus == UploadFirestoreResult.failed) {
                            SmartDialog.dismiss();
                            SmartDialog.show(
                                backDismiss: false,
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "OK",
                                    onPressedRight: () async {
                                      SmartDialog.dismiss();
                                    }));
                            }
                          else{}
                          },
                        );
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(fontSize: 17.sp,
                          color: EvieColors.grayishWhite,),
                      ),
                      height: 36.h,
                      width: 169.w)
              ),
            ],
          ),
        ),

        ///Action == find-out-more, general promotions
        Visibility(
          visible: _notificationProvider.notificationList.values.elementAt(widget.index).action == "find-out-more",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              EvieButton(
                  onPressed: () async {
                    ///Need http:// or https
                    final Uri url = Uri.parse('http://${_notificationProvider.notificationList.values.elementAt(widget.index).url}');

                    /// await launchUrl(url,mode: LaunchMode.externalApplication)  for open at external browser
                    if (await launchUrl(url)) {}else{
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: Text(
                    "Find Out More",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                  ),
                  height: 36.h,
                  width: 190.w),
            ],
          ),
        ),

        ///Action == update-now, firmware update
        Visibility(
          visible: _notificationProvider.notificationList.values.elementAt(widget.index).action == "update-now",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              EvieButton(
                  onPressed: () async {
                    if (_bluetoothProvider.deviceConnectResult == null
                        || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected
                        || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout
                        || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connectError
                        || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanError
                        || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                    ) {
                      // setState(() {
                      //   pageNavigate = 'registerEVKey';
                      // });
                      showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                      // showEvieActionableBarDialog(context, _bluetoothProvider, _bikeProvider);
                    }
                    else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected) {
                      _settingProvider.changeSheetElement(SheetList.firmwareInformation);
                      showSheetNavigate(context);
                    }
                  },
                  child: Text(
                    "Update Now",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                  ),
                  height: 36.h,
                  width: 190.w),
            ],
          ),
        ),
      ],
    );
  }
  }


import 'dart:async';

import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/model/user_bike_model.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/model/bike_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../bluetooth/modelResult.dart';

class BikeContainer extends StatefulWidget {
  final BikeModel bikeModel;
  const BikeContainer({Key? key, required this.bikeModel}) : super(key: key);

  @override
  State<BikeContainer> createState() => _BikeContainerState();
}

class _BikeContainerState extends State<BikeContainer> {

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  bool isSpecificDeviceConnected = false;

  @override
  Widget build(BuildContext context) {

    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    NotificationProvider _notificationProvider = Provider.of<NotificationProvider>(context);

    /// get bluetooth connection state and lock unlock to detect isConnected
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;


    ///Handle all data if bool isDeviceConnected is true
    if (deviceConnectResult == DeviceConnectResult.connected) {
      if (_bluetoothProvider.currentBikeModel?.deviceIMEI == widget.bikeModel.deviceIMEI) {
        setState(() {
          isSpecificDeviceConnected = true;
        });
      }
      else {
        setState(() {
          isSpecificDeviceConnected = false;
        });
      }
    } else {
      setState(() {
        isSpecificDeviceConnected = false;
      });
    }

    return Container(
      height: 98.h,
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 17.h, 0.w, 0.h),
          child: Image(
            image: AssetImage(getCurrentBikeStatusImage(widget.bikeModel, _bikeProvider)),
            height: 25.h,
            width: 39.59.w,
          ),
        ),
        title: Text(
            widget.bikeModel.deviceName!,
            style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  getCurrentBikeStatusIcon(widget.bikeModel, _bikeProvider),
                  height: 20.h,
                  width: 20.w,
                ),
                Text(getCurrentBikeStatusString(
                    deviceConnectResult == DeviceConnectResult.connected,
                    widget.bikeModel,
                    _bikeProvider), style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan)),
              ],
            ),


            Container(
              height: 33.h,
              width: 125.w,
              child: ElevatedButton(
                child: Text(
                  "Bike Setting",
                  style: EvieTextStyles.body14.copyWith(color: EvieColors.primaryColor,fontWeight: FontWeight.w900),),
                onPressed: () async {
                  ///Switch bike animation
                  await _bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
                  changeToBikeSetting(context, 'SwitchBike');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side:  BorderSide(color: EvieColors.primaryColor, width: 1.0.w)),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,

                ),
              ),
            ),
            Divider(),
          ],
        ),

        trailing: CupertinoSwitch(
          value: isSpecificDeviceConnected,
          activeColor: EvieColors.primaryColor,
          thumbColor: EvieColors.thumbColorTrue,
          trackColor: EvieColors.primaryColor.withOpacity(0.5),
          onChanged: (value) async {
            if (value) {
              await _bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
              StreamSubscription? subscription;
              subscription = _bikeProvider.switchBike().listen((result) {
                if(result == SwitchBikeResult.success){
                  ///set auto connect flag on bluetooth provider,
                  ///once bluetooth provider received new current bike model,
                  ///it will connect follow by the flag.
                  _bluetoothProvider.setAutoConnect();
                  subscription?.cancel();
                  _notificationProvider.compareActionableBarTime();
                  Navigator.pop(context);
                }
                else if(result == SwitchBikeResult.failure){
                  subscription?.cancel();
                  SmartDialog.show(
                      widget: EvieSingleButtonDialog(
                          title: "Error",
                          content: "Cannot change bike, please try again.",
                          rightContent: "OK",
                          onPressedRight: () {
                            SmartDialog.dismiss();
                          }));
                }else{};
              });

            } else {
              await _bluetoothProvider.disconnectDevice();
            }
          },
        ),
      ),
    );
  }

  getCurrentBikeStatusImage(BikeModel bikeModel, BikeProvider bikeProvider) {
    for(var index = 0; index < bikeProvider.userBikePlans.length; index++ ){
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null){
          final result = bikeProvider.calculateDateDifference(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate());
          if(result < 0){
            return "assets/images/bike_HPStatus/bike_normal.png";
          }else {
            if (bikeModel.location?.isConnected == false) {
              return "assets/images/bike_HPStatus/bike_warning.png";
            } else {
              switch (bikeModel.location!.status) {
                case 'safe':
                  {
                    if (cableLockState?.lockState == LockState.unlock) {
                      return "assets/images/bike_HPStatus/bike_safe.png";
                    } else {
                      return "assets/images/bike_HPStatus/bike_safe.png";
                    }
                  }
                case 'warning':
                  return "assets/images/bike_HPStatus/bike_warning.png";

                case 'danger':
                  return "assets/images/bike_HPStatus/bike_danger.png";
                case 'fall':
                  return "assets/images/bike_HPStatus/bike_warning.png";
                case 'crash':
                  return "assets/images/bike_HPStatus/bike_danger.png";

                default:
                  return "assets/images/bike_HPStatus/bike_safe.png";
              }
            }
          }
        }
      }
    }
  }

  getCurrentBikeStatusIcon(BikeModel bikeModel, BikeProvider bikeProvider) {

    for(var index = 0; index < bikeProvider.userBikePlans.length; index++ ){
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null){
          final result = bikeProvider.calculateDateDifference(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate());
          if(result < 0){
            return "assets/buttons/bike_security_not_available.svg";
          }else{
            if(bikeModel.location?.isConnected == false){
              return "assets/buttons/bike_security_warning.svg";
            }else {
              switch (bikeModel.location!.status) {
                case 'safe':
                  {
                    if (cableLockState?.lockState == LockState.unlock) {
                      return "assets/buttons/bike_security_unlock.svg";
                    } else {
                      return "assets/buttons/bike_security_lock_and_secure.svg";
                    }
                  }
                case 'warning':
                  return "assets/buttons/bike_security_warning.svg";
                case 'danger':
                  return "assets/buttons/bike_security_danger.svg";
                case 'fall':
                  return "assets/buttons/bike_security_warning.svg";
                case 'crash':
                  return "assets/buttons/bike_security_danger.svg";

                default:
                  return "assets/buttons/bike_security_lock_and_secure.svg";
              }
            }
          }
        }
      }
    }

  }

  getCurrentBikeStatusString(bool isLocked, BikeModel bikeModel, BikeProvider bikeProvider) {

    for(var index = 0; index < bikeProvider.userBikePlans.length; index++ ){
      if (bikeModel.deviceIMEI == bikeProvider.userBikePlans.keys.elementAt(index)) {
        if(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate() != null){
          final result = bikeProvider.calculateDateDifference(bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate());
          if(result < 0){
            return "-";
          }else{
            if(bikeModel.location?.isConnected == false){
              return "Connection Lost";
            }else{
              switch (isLocked) {
                case true:
                  if (bikeModel.location!.status == "safe") {
                    return "Locked & Secure";
                  } else if (bikeModel.location!.status == "warning") {
                    return "Movement Detected";
                  } else if (bikeModel.location!.status == "danger") {
                    return "Under Threat";
                  }else if (bikeModel.location!.status == "fall") {
                    return "Fall Detected";
                  }else if (bikeModel.location!.status == "crash") {
                    return "Crash Alert";
                  }
                  break;
                case false:
                  if (bikeModel.location!.status == "safe") {
                    return "Unlocked";
                  } else if (bikeModel.location!.status == "warning") {
                    return "Movement Detected";
                  } else if (bikeModel.location!.status == "danger") {
                    return "Under Threat";
                  }else if (bikeModel.location!.status == "fall") {
                    return "Fall Detected";
                  }else if (bikeModel.location!.status == "crash") {
                    return "Crash Alert";
                  }
                  break;
              }
            }

          }
        }
      }
    }


  }
}

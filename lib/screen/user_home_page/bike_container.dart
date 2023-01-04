import 'dart:async';

import 'package:evie_test/api/model/user_bike_model.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/model/bike_model.dart';
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


    // Future.delayed(Duration.zero, () {
    //   if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanError ) {
    //     SmartDialog.show(
    //         keepSingle: true,
    //         widget: EvieSingleButtonDialogCupertino(
    //             title: "Cannot connect bike",
    //             content: "Move your device near the bike and try again",
    //             rightContent: "OK",
    //             onPressedRight: () {
    //               SmartDialog.dismiss();
    //             }));
    //   } else if(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout){
    //     SmartDialog.show(
    //         keepSingle: true,
    //         widget: EvieSingleButtonDialogCupertino(
    //             title: "Cannot connect bike",
    //             content: "Scan timeout",
    //             rightContent: "OK",
    //             onPressedRight: () {
    //               SmartDialog.dismiss();
    //             }));
    //   }else if(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connectError){
    //     SmartDialog.show(
    //         keepSingle: true,
    //         widget: EvieSingleButtonDialogCupertino(
    //             title: "Cannot connect bike",
    //             content: "Connection Error",
    //             rightContent: "OK",
    //             onPressedRight: () {
    //               SmartDialog.dismiss();
    //             }));
    //   }
    // });


    return Container(
      height: 59.h,
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 17.h, 0.w, 0.h),
          child: Image(
            image: AssetImage(getCurrentBikeStatusImage(widget.bikeModel.location!.status)),
            height: 25.h,
            width: 39.59.w,
          ),
        ),
        title: Text(
            widget.bikeModel.deviceName!,
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.w900),
        ),
        subtitle: Row(
          children: [
            SvgPicture.asset(
              getCurrentBikeStatusIcon(widget.bikeModel.location!.status),
              height: 20.h,
              width: 20.w,
            ),
            Text(getCurrentBikeStatusString(
                deviceConnectResult == DeviceConnectResult.connected,
                widget.bikeModel.location!.status), style: TextStyle(
              fontSize: 16.sp, fontWeight: FontWeight.w400
            ),),
          ],
        ),
        trailing: CupertinoSwitch(
          value: isSpecificDeviceConnected,
          activeColor: const Color(0xff6A51CA),
          thumbColor: EvieColors.ThumbColorTrue,
          trackColor: const Color(0xff6A51CA).withOpacity(0.5),
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
                  Navigator.pop(context);
                }else if(result == SwitchBikeResult.failure){
                  subscription?.cancel();
                  SmartDialog.show(
                      widget: EvieSingleButtonDialog(
                          title: "Error",
                          content: "Cannot change bike, please try again.",
                          rightContent: "OK",
                          onPressedRight: () {
                            SmartDialog.dismiss();
                          }));
                }
              });

            } else {
              await _bluetoothProvider.disconnectDevice();
            }
          },
        ),
      ),
    );
  }

  getCurrentBikeStatusImage(String dangerStatus) {
    switch (dangerStatus) {
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

  getCurrentBikeStatusIcon(String dangerStatus) {
    switch (dangerStatus) {
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

  getCurrentBikeStatusString(bool isLocked, String status) {
    switch (isLocked) {
      case true:
        if (status == "safe") {
          return "Locked & Secure";
        } else if (status == "warning") {
          return "Movement Detected";
        } else if (status == "danger") {
          return "Under Threat";
        }else if (status == "fall") {
          return "Fall Detected";
        }else if (status == "crash") {
          return "Crash Alert";
        }
        break;
      case false:
        if (status == "safe") {
          return "Unlocked";
        } else if (status == "warning") {
          return "Movement Detected";
        } else if (status == "danger") {
          return "Under Threat";
        }else if (status == "fall") {
          return "Fall Detected";
        }else if (status == "crash") {
          return "Crash Alert";
        }
        break;
    }
    return "Locked & Secure";
  }
}

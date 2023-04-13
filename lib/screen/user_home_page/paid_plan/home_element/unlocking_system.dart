import 'dart:async';

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/snackbar.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_single_button_dialog.dart';

import 'package:lottie/lottie.dart' as lottie;

class UnlockingSystem extends StatefulWidget {

  UnlockingSystem({
    Key? key
  }) : super(key: key);

  @override
  State<UnlockingSystem> createState() => _UnlockingSystemState();
}

class _UnlockingSystemState extends State<UnlockingSystem> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;

  Widget? buttonImage;
  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    cableLockState = _bluetoothProvider.cableLockState;

    setButtonImage();

    return EvieCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr)...{

            SizedBox(
              height: 96.h,
              width: 96.w,
              child:
              FloatingActionButton(
                elevation: 0,
                backgroundColor: cableLockState?.lockState == LockState.lock
                    ?  EvieColors.primaryColor : EvieColors.softPurple,
                onPressed: cableLockState
                    ?.lockState == LockState.lock
                    ? () {
                  ///Check is connected

                  _bluetoothProvider.setIsUnlocking(true);
                  showUnlockingToast(context);

                  StreamSubscription?
                  subscription;
                  subscription = _bluetoothProvider
                      .cableUnlock()
                      .listen(
                          (unlockResult) {
                        SmartDialog.dismiss(
                            status:
                            SmartStatus.loading);
                        subscription
                            ?.cancel();
                        if (unlockResult.result ==
                            CommandResult.success) {

                          //  showToLockBikeInstructionToast(context);

                        } else {
                          SmartDialog.dismiss(
                              status: SmartStatus.loading);
                          subscription?.cancel();
                          //  showToLockBikeInstructionToast(context);
                        }
                      }, onError: (error) {
                    SmartDialog.dismiss(
                        status:
                        SmartStatus.loading);
                    subscription
                        ?.cancel();
                    SmartDialog.show(
                        widget: EvieSingleButtonDialog(
                            title: "Error",
                            content: "Cannot unlock bike, please place the phone near the bike and try again.",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  });
                }
                    : (){
                  showToLockBikeInstructionToast(context);
                },
                //icon inside button
                child: buttonImage,
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
              Text(
                "Connecting bike",
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),
            } else if (deviceConnectResult == DeviceConnectResult.connected) ...{
              Text(
                "Tap to unlock bike",
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),
            } else ...{
              Text(
                "",
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),
            },

            ///If device is not connected
          }
          else...{
            SizedBox(
                height: 96.h,
                width: 96.w,
                child:
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor:
                  EvieColors.primaryColor,
                  onPressed: () {
                    checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
                  },
                  //icon inside button
                  child: buttonImage,
                )),
            SizedBox(
              height: 12.h,
            ),
            if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning) ...{
              Text(
                "Connecting bike",
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),
            }
            else ...{
              Text(
                "Tap to connect bike",
                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
              ),
            },
          }
        ],
      ),
    );
  }


  void setButtonImage() {
    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      if (cableLockState?.lockState == LockState.unlock) {
        if(_bluetoothProvider.isUnlocking == true){
          Future.delayed(Duration.zero, () {
            _bluetoothProvider.setIsUnlocking(false);
          });
        }
        buttonImage = SvgPicture.asset(
          "assets/buttons/lock_unlock.svg",
          width: 52.w,
          height: 50.h,
        );
      }else if(_bluetoothProvider.isUnlocking){
        buttonImage =  lottie.Lottie.asset('assets/animations/unlock_button.json', repeat: false);
      } else if (cableLockState?.lockState == LockState.lock) {

        buttonImage = SvgPicture.asset(
          "assets/buttons/lock_lock.svg",
          width: 52.w,
          height: 50.h,);
      }
    }
    else if (cableLockState?.lockState == LockState.unknown) {
      buttonImage =  lottie.Lottie.asset('assets/animations/loading_button.json');
    }
    else if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning || deviceConnectResult == DeviceConnectResult.partialConnected) {
      buttonImage =  lottie.Lottie.asset('assets/animations/loading_button.json');
    }
    else if (deviceConnectResult == DeviceConnectResult.disconnected) {
      buttonImage = SvgPicture.asset(
        "assets/buttons/bluetooth_not_connected.svg",
        width: 52.w,
        height: 50.h,
      );
    }
    else {
      buttonImage = SvgPicture.asset(
        "assets/buttons/bluetooth_not_connected.svg",
        width: 52.w,
        height: 50.h,
      );
    }
  }


}



import 'dart:async';

import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart' as lottie;
import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/function.dart';
import '../api/snackbar.dart';
import 'evie_single_button_dialog.dart';

class UnlockingButton extends StatefulWidget {
  const UnlockingButton({Key? key}) : super(key: key);

  @override
  State<UnlockingButton> createState() => _UnlockingButtonState();
}

class _UnlockingButtonState extends State<UnlockingButton> {

  late BluetoothProvider bluetoothProvider;
  late BikeProvider bikeProvider;
  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  StreamSubscription? unlockSub;
  Widget? buttonImage;

  @override
  void initState() {
    bluetoothProvider = context.read<BluetoothProvider>();
    bikeProvider = context.read<BikeProvider>();
    super.initState();
  }

  @override
  void dispose() {
    unlockSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bluetoothProvider = context.watch<BluetoothProvider>();
    bikeProvider = context.watch<BikeProvider>();
    deviceConnectResult = bluetoothProvider.deviceConnectResult;
    cableLockState = bluetoothProvider.cableLockState;
    setButtonImage();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
        height: 106.h,
        width: 106.w,
        child:
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(cableLockState
                ?.lockState == LockState.unlock ? EvieColors.softPurple : EvieColors.primaryColor,),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(55.w), // Adjust the border radius as needed
              ),
            ),
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(EdgeInsets.zero), // This removes padding
          ),
          onPressed:() {
            if (deviceConnectResult == DeviceConnectResult.connected && bluetoothProvider.currentConnectedDevice == bikeProvider.currentBikeModel?.macAddr) {
              if (cableLockState?.lockState == LockState.lock) {
                bluetoothProvider.setIsUnlocking(true);
                unlockSub =
                    bluetoothProvider.cableUnlock().listen((unlockResult) {
                      unlockSub?.cancel();
                    }, onError: (error) {
                      unlockSub?.cancel();
                      SmartDialog.show(
                          widget: EvieSingleButtonDialog(
                              title: "Error",
                              content: "Unable to unlock bike, Please place the phone near to the bike and try again.",
                              rightContent: "Retry",
                              onPressedRight: () {
                                SmartDialog.dismiss();
                              }));
                    });
              }
              else {
                showToLockBikeInstructionToast(context);
              }
            }
            else {
              checkBleStatusAndConnectDevice(bluetoothProvider, bikeProvider);
            }
          },
          //icon inside button
          child: Stack(
            children: [
              buttonImage!,
            ],
          ),
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
        }
        else if (deviceConnectResult == DeviceConnectResult.connected) ...{
          cableLockState?.lockState == LockState.lock ?
          Text(
          "Tap to unlock bike",
          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
          ) :
          Text(
          "Bike unlocked",
          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
          )
        }
        else ...{
            Text(
              "Tap to connect bike",
              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            )
        },
      ],
    );
  }

  void setButtonImage() {
    if (deviceConnectResult == DeviceConnectResult.connected && bluetoothProvider.currentConnectedDevice == bikeProvider.currentBikeModel?.macAddr) {
      if (cableLockState?.lockState == LockState.unlock) {
        if(bluetoothProvider.isUnlocking == true){
          Future.delayed(Duration.zero, () {
            bluetoothProvider.setIsUnlocking(false);
          });
        }
        buttonImage = Padding(
          padding: EdgeInsets.fromLTRB(8.w, 0, 0, 3.h),
          child: SvgPicture.asset(
            "assets/buttons/lock_unlock.svg",
            width: 52.w,
            height: 50.h,
          ),
        );
      }
      else if(bluetoothProvider.isUnlocking){
        buttonImage = Container(
          color: Colors.transparent,
          child: lottie.Lottie.asset('assets/animations/unlock_button.json', repeat: false),
          width: 600,
          height: 300,
        );
      }
      else if (cableLockState?.lockState == LockState.lock) {

        buttonImage = SvgPicture.asset(
          "assets/buttons/lock_lock.svg",
          width: 52.w,
          height: 50.h,);
      }
    }
    else if (cableLockState?.lockState == LockState.unknown) {
      buttonImage =  lottie.Lottie.asset('assets/animations/loading_button.json', repeat: true);
    }
    else if (deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning || deviceConnectResult == DeviceConnectResult.partialConnected) {
      buttonImage =  Container(
        padding: EdgeInsets.all(8),
        //color: Colors.red,
        child: lottie.Lottie.asset('assets/animations/loading_button.json', repeat: true),
      );
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

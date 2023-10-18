import 'dart:async';

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/fonts.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/snackbar.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_button.dart';
import '../../../../widgets/evie_double_button_dialog.dart';
import '../../../../widgets/evie_slider_button.dart';

class ThreatContainer extends StatefulWidget {
  final BuildContext context;
  const ThreatContainer({Key? key, required this.context}) : super(key: key);

  @override
  State<ThreatContainer> createState() => _ThreatContainerState();
}

class _ThreatContainerState extends State<ThreatContainer> {

  late BluetoothProvider _bluetoothProvider;
  late BikeProvider _bikeProvider;
  bool isSlided = false;
  Widget slideToUnlock = SvgPicture.asset(
    "assets/images/slide_lock.svg",
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bluetoothProvider = context.read<BluetoothProvider>();
    _bikeProvider = context.read<BikeProvider>();

    Future.delayed(Duration.zero).then((value) {
      if (_bluetoothProvider.deviceConnectResult == null ||
          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected ||
          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanError ||
          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connectError ||
          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout ||
          _bluetoothProvider.deviceConnectResult == DeviceConnectResult.deviceFound
      ) {
        _bluetoothProvider.startScanRSSI();
      }
      else {
        print('AAAAAAA: ' + _bluetoothProvider.deviceConnectResult.toString());
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bluetoothProvider = context.watch<BluetoothProvider>();
    _bikeProvider = context.watch<BikeProvider>();
    print('Hello : ' + _bluetoothProvider.deviceConnectResult.toString());

    if (_bluetoothProvider.bleStatus == BleStatus.poweredOff || _bluetoothProvider.bleStatus == BleStatus.unauthorized) {
      SmartDialog.dismiss(tag: "threat");
    }

    switch (_bluetoothProvider.deviceConnectResult) {
      case DeviceConnectResult.scanning:
      case DeviceConnectResult.disconnected:
      case DeviceConnectResult.scanError:
      case null:
      // Code to execute when deviceConnectResult is scanning
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text("Scanning Your Bike.", style: EvieTextStyles.h2.copyWith(
                color: EvieColors.mediumBlack)),

            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
              child:
              Lottie.asset("assets/icons/security/scanning-for-bike.json"),
            ),
            Center(
              child: Text(
                "Hold tight, we're searching for your bike within a 10m range.",
                style: EvieTextStyles.body18.copyWith(
                    color: EvieColors.lightBlack),
              ),
            ),
            SizedBox(
              height: 140.h,
            ),

            EvieButton_ReversedColor(
                width: double.infinity,
                height: 48.h,
                child: Text(
                  "Stop Scan",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                ),
                onPressed: () async {
                  await _bluetoothProvider.stopScan();
                  SmartDialog.dismiss();
                }
            ),
          ],
        );

      case DeviceConnectResult.scanTimeout:
      // Code to execute when deviceConnectResult is scanTimeout
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text("No Bike Found.", style: EvieTextStyles.h2.copyWith(
                color: EvieColors.mediumBlack)),

            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/no_bike.svg",
                  ),

                  Positioned(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: EvieColors.grayishWhite,
                        ),
                        height: 48.h,
                        width: 48.w,
                      )
                  ),
                ],
              ),
            ),

            Center(
              child:
              Text(
                "You're still too far away from your bike."
                    " Try getting closer to your bike location before scanning again.",
                style: EvieTextStyles.body18.copyWith(
                    color: EvieColors.lightBlack),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              height: 62.h,
            ),

            EvieButton(
                width: double.infinity,
                height: 48.h,
                child: Text("Scan Again", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),),
                onPressed: (){
                  if (_bluetoothProvider.bleStatus == BleStatus.ready) {
                    _bluetoothProvider.startScanRSSI();
                  }
                  else if (_bluetoothProvider.bleStatus == BleStatus.poweredOff || _bluetoothProvider.bleStatus == BleStatus.unauthorized) {
                    showBluetoothNotTurnOn();
                  }
                }
            ),

            SizedBox(height: 8.h,),

            EvieButton_ReversedColor(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Close",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: () {
                SmartDialog.dismiss();
              },
            ),
          ],
        );

      case DeviceConnectResult.deviceFound:
      // Code to execute when deviceConnectResult is deviceFound
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Your Bike Is Nearby!", style: EvieTextStyles.h2.copyWith(
                color: EvieColors.mediumBlack)),
            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _bluetoothProvider.deviceRssi >= 70 ?
                  Lottie.asset("assets/icons/security/scanning-proximity-color-light.json", repeat: false) :
                  _bluetoothProvider.deviceRssi >= 50 && _bluetoothProvider.deviceRssi <= 69 ?
                  Lottie.asset("assets/icons/security/scanning-proximity-color-light-to-medium.json", repeat: false) :
                  Lottie.asset("assets/icons/security/scanning-proximity-color-medium-to-dark.json", repeat: false),
                  Lottie.asset("assets/icons/security/scanning-proximity-V2-R0.json", repeat: true),
                  Text(
                    _bluetoothProvider.deviceRssi.toString(), style: EvieTextStyles.batteryPercent.copyWith(color: EvieColors.darkGrayishCyan),
                  ),
                ],
              ),
            ),

            // Center(
            //   child: Text(
            //     "Real RSSI: " + _bluetoothProvider.realRssi.toString(), style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
            //   ),
            // ),

            Center(
              child:
              Text(
                "The number indicates your proximity to the bike. Lower numbers are closer while higher numbers are further. "
                    "Do note that continuous scanning will drain your battery.",
                style: EvieTextStyles.body18.copyWith(
                    color: EvieColors.lightBlack),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              height: 18.h,
            ),

            EvieButton(
                backgroundColor: EvieColors.primaryColor,
                width: double.infinity,
                height: 48.h,
                child: Text(
                  'Connect Bike',
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                ),
                onPressed: (){
                  _bluetoothProvider.connectDevice(_bluetoothProvider.discoverDevice!.id);
                }
            ),

            SizedBox(height: 8.h,),

            EvieButton_ReversedColor(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Stop Scan",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: () async {
                await _bluetoothProvider.stopScan();
                SmartDialog.dismiss();
              },
            ),

          ],
        );

      case DeviceConnectResult.connecting:
      case DeviceConnectResult.partialConnected:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Connecting Bike", style: EvieTextStyles.h2.copyWith(
                color: EvieColors.mediumBlack)),
            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset("assets/icons/security/scanning-connecting-bike.json"),
                  // Positioned(
                  //     child: Container(
                  //       decoration: const BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: EvieColors.grayishWhite,
                  //       ),
                  //       height: 55.h,
                  //       width: 55.w,
                  //     )
                  // ),
                ],
              ),
            ),

            Center(
              child:
              Text(
                "Attempting to connect your bike...",
                style: EvieTextStyles.body18.copyWith(
                    color: EvieColors.lightBlack),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              height: 106.h,
            ),

            EvieButton(
                backgroundColor: EvieColors.primaryColor.withOpacity(0.3),
                width: double.infinity,
                height: 48.h,
                child: Text(
                  'Connecting Bike',
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                ),
                onPressed: (){
                  //_bluetoothProvider.connectDevice(_bluetoothProvider.discoverDevice!.id);
                }
            ),

            SizedBox(height: 8.h,),

            EvieButton_ReversedColor(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Cancel",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: () async {
                showDontConnectBike(context, _bikeProvider, _bluetoothProvider);
              },
            ),

          ],
        );

      case DeviceConnectResult.connected:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Slide to Unlock", style: EvieTextStyles.h2.copyWith(
                color: EvieColors.mediumBlack)),

            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 25.h),
              child: slideToUnlock,
            ),

            Center(
              child: Text(
                "Slide to unlock your bike. "
                    "By unlocking your bike, your bike status will return back to secure status.",
                style: EvieTextStyles.body18.copyWith(
                    color: EvieColors.lightBlack),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(
              height: 38.h,
            ),

            isSlided ?
            SlideAction(
              reversed: true,
              enabled: false,
              animationDuration: Duration.zero,
              outerColor: EvieColors.primaryColor,
              innerColor: EvieColors.white,
                sliderButtonIcon: Icon(
                  Icons.arrow_back,
                  color: EvieColors.primaryColor,
                ),
              text: "Unlocking My Bike",
                textStyle: TextStyle(
                    color: EvieColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp
                )
            ) :
            SlideAction(
              outerColor: EvieColors.pastelPurple,
              innerColor: EvieColors.primaryColor,
              text: "Unlock My Bike",
              animationDuration: Duration.zero,
              textColor: EvieColors.primaryColor,
              textStyle: TextStyle(
                  color: EvieColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp
              ),
              sliderRotate: false,
              onSubmit: () {
                setState(() {
                  isSlided = true;
                  slideToUnlock = Stack(
                    children: [
                        SvgPicture.asset(
                        "assets/images/slide_unlock.svg",
                      ),
                    ],
                  );
                });

                _bluetoothProvider.setIsUnlocking(true);
                StreamSubscription? subscription;

                subscription = _bluetoothProvider.cableUnlock().listen((unlockResult) {
                  if (unlockResult.lockState == LockState.unlock) {
                    subscription?.cancel();
                    ///Change to page
                    changeToThreatBikeRecovered(widget.context);
                    SmartDialog.dismiss();
                  }
                  else {
                    setState(() {
                      isSlided = false;
                    });
                  }
                }, onError: (error) {
                  setState(() {
                    isSlided = false;
                  });
                });
              },
                sliderButtonIcon: Icon(
                    Icons.arrow_forward,
                  color: Colors.white,
                )
            ),

            SizedBox(
              height: 16.h,
            ),

            EvieButton_ReversedColor(
              width: double.infinity,
              height: 48.h,
              child: Text( "Exit",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: ()async {
                //SmartDialog.dismiss(tag:'threat');
                showNoLockExit(context, _bikeProvider, _bluetoothProvider);
              },
            ),
          ],
        );

      default:
        print('YAHOOOOOOOO: ' + _bluetoothProvider.deviceConnectResult.toString());
        return Container(color: Colors.red,);
    }
  }
}

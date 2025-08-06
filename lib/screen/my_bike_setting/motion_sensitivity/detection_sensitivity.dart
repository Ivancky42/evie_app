import 'dart:async';
import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_slider.dart';


enum PlayBuzzerSound { low, medium, high }

class DetectionSensitivity extends StatefulWidget {
  const DetectionSensitivity({super.key});

  @override
  _DetectionSensitivityState createState() => _DetectionSensitivityState();
}

class _DetectionSensitivityState extends State<DetectionSensitivity> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  late double currentSliderValue;

  bool getSliderValue = false;


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    if(!getSliderValue){
      currentSliderValue = getCurrentSliderValue(_bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "medium");
      getSliderValue = true;
    }

    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.motionSensitivity);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Motion Sensitivity',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.motionSensitivity);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 35.5.h, 16.w, 0),
                  child: Text(
                    "The bike alarm will be triggered when motion is detected.",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    SizedBox(
                    width: 300.w,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        overlayShape: SliderComponentShape.noThumb,
                      ),
                      child: EvieSlider(
                        value: currentSliderValue,
                        min: 0,
                        max: 1,
                          label: _bikeProvider.currentBikeModel!.movementSetting?.sensitivity ?? "medium",
                          onChanged: (value) {
                            setState(() {
                              currentSliderValue = value!;
                            }
                            );
                          },
                          onChangedEnd: (value)async{
                            if(value == 0 || value == 1 || value == 2){
                              MovementSensitivity sensitivity = MovementSensitivity.medium;
                              MovementSensitivity firebaseSensitivity = MovementSensitivity.medium;

                              if(value == 0 ){
                                sensitivity = MovementSensitivity.low;
                                firebaseSensitivity = MovementSensitivity.low;
                              }else if(value == 1){
                                sensitivity = MovementSensitivity.medium;
                                firebaseSensitivity = MovementSensitivity.high;
                              }

                              showCustomLightLoading("Changing...");
                              final uploadResult = await _bikeProvider.updateMotionSensitivity(true, firebaseSensitivity.toString().split(".").last);
                              if(uploadResult == true){

                                StreamSubscription? subscription;
                                subscription = _bluetoothProvider.changeMovementSetting(true, sensitivity).listen((changeMovementResult) {
                                  if (changeMovementResult.result == CommandResult.success) {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();
                                    showSuccessUpdateMotionSetting(context, firebaseSensitivity.toString().split(".").last);
                                  } else {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();

                                    showFailUpdateMotionSetting(context);
                                  }
                                }
                                );
                              }else{
                                showFailUpdateMotionSetting(context);
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    Text(
                      capitalizeFirstCharacter(_bikeProvider.currentBikeModel!.movementSetting?.sensitivity ?? "High"),
                      style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayish),
                    ),
                    ],
                  ),
                ),



                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      child: Text("Give your bike a push to test on the motion sensor sensitivity level.",
                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                    ),
                  ],
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: 142.h),
              child: Align(
                alignment: Alignment.center,
                child: Lottie.asset('assets/animations/motion-sensitivity-R1.json'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCurrentSliderValue(String sensitivity) {
    if(sensitivity == "low" ){
      return 0.0;
    }else if(sensitivity == "high"){
      return 1.0;
    }else{
      return 1.0;
    }
  }
}

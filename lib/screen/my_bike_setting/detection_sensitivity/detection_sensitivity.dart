import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_slider.dart';


enum PlayBuzzerSound { low, medium, high }

class DetectionSensitivity extends StatefulWidget {
  const DetectionSensitivity({Key? key}) : super(key: key);

  @override
  _DetectionSensitivityState createState() => _DetectionSensitivityState();
}

class _DetectionSensitivityState extends State<DetectionSensitivity> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  late double currentSliderValue;

  bool getSliderValue = false;


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    if(!getSliderValue){
      currentSliderValue = getCurrentSliderValue(_bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "medium");
      getSliderValue = true;
    }

    return WillPopScope(
      onWillPop: () async {
        changeToMotionSensitivityScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Detection Sensitivity',
          onPressed: () {
            changeToMotionSensitivityScreen(context);
          },
        ),
        body: Stack(
          children: [

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 27.h),
                  child: Text(
                    "Alarm in bike will be trigger when motion is detected.",
                    style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                  ),
                ),

                Padding(
                  padding:  EdgeInsets.only(right: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 300.w,
                        child: EvieSlider(
                          value: currentSliderValue,
                          division: 2,
                          max: 2,
                          label: _bikeProvider.currentBikeModel!.movementSetting?.sensitivity ?? "medium",
                          onChanged: (value) {
                            setState(() {
                              currentSliderValue = value!;
                            });
                          },
                          onChangedEnd: (value)async{
                            if(value == 0 || value == 1 || value == 2){
                              MovementSensitivity sensitivity = MovementSensitivity.medium;

                              if(value == 0 ){
                                sensitivity = MovementSensitivity.low;
                              }else if(value == 1){
                                sensitivity = MovementSensitivity.medium;
                              }else if(value == 2){
                                sensitivity = MovementSensitivity.high;
                              }

                              SmartDialog.showLoading(msg: "Changing");
                              final uploadResult = await _bikeProvider.updateMotionSensitivity(true, sensitivity.toString().split(".").last);
                              if(uploadResult == true){

                                StreamSubscription? subscription;
                                subscription = _bluetoothProvider.changeMovementSetting(true, sensitivity).listen((changeMovementResult) {
                                  if (changeMovementResult.result == CommandResult.success) {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();
                                  } else {
                                    SmartDialog.dismiss(status: SmartStatus.loading);
                                    subscription?.cancel();
                                    SmartDialog.show(widget: EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Error change motion sensitivity",
                                        rightContent: "Ok",
                                        onPressedRight: (){SmartDialog.dismiss();}));
                                  }
                                });
                              }else{
                                SmartDialog.show(widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Error update motion sensitivity",
                                    rightContent: "Ok",
                                    onPressedRight: (){SmartDialog.dismiss();}));
                              }
                            }
                          },
                        ),
                      ),

                      Text(
                        _bikeProvider.currentBikeModel!.movementSetting?.sensitivity ?? "medium",
                        style: TextStyle(fontSize:16.sp, color: Color(0xff7A7A79)),
                      ),

                    ],
                  ),
                ),



                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15.w),
                      child: Divider(
                        thickness: 38.h,
                        color: const Color(0xffF4F4F4),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text("Give your bike a push to test on the motion sensor sensitivity level.",
                        style: TextStyle(fontSize: 12.sp, color: Color(0xff5F6060)),),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),),
    );
  }

  getCurrentSliderValue(String sensitivity) {
    if(sensitivity == "low" ){
      return 0.0;
    }else if(sensitivity == "medium"){
      return 1.0;
    }else if(sensitivity == "high"){
      return 2.0;
    }else{
      return 1.0;
    }
  }
}

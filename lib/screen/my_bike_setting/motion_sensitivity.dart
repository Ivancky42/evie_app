import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_switch.dart';
import '../../widgets/evie_textform.dart';
import '../user_home_page/user_home_page.dart';
import 'my_bike_widget.dart';

///User profile page with user account information

class MotionSensitivity extends StatefulWidget {
  const MotionSensitivity({Key? key}) : super(key: key);

  @override
  _MotionSensitivityState createState() => _MotionSensitivityState();
}

class _MotionSensitivityState extends State<MotionSensitivity> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Motion Sensitivity',
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
                  padding: EdgeInsets.fromLTRB(16.w, 11.h, 16.w, 10.h),
                  child: Container(
                      child: EvieSwitch(
                        text: "Motion Sensitivity",
                        value: _bikeProvider.currentBikeModel?.movementSetting?.enabled ?? false,
                        thumbColor: _thumbColor,
                        onChanged: (value) async {
                          SmartDialog.showLoading(msg: "Changing");
                          final uploadResult = await _bikeProvider.updateMotionSensitivity(value!,
                              _bikeProvider.currentBikeModel?.movementSetting?.sensitivity.toString() ?? MovementSensitivity.medium.toString());
                          if(uploadResult == true){
                            StreamSubscription? subscription;
                            subscription = _bluetoothProvider.changeMovementSetting(value,
                                _bikeProvider.currentBikeModel?.movementSetting?.sensitivity == "low" ? MovementSensitivity.low : _bikeProvider.currentBikeModel?.movementSetting?.sensitivity == "medium" ? MovementSensitivity.medium : MovementSensitivity.high).listen((changeMovementResult) {
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


                        },
                      )
                  ),
                ),

                Stack(
                  children: [
                    Divider(
                      thickness: 23.h,
                      color: const Color(0xffF4F4F4),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text("Motion Sensitivity will trigger the theft alarm on the bike.", style: TextStyle(fontSize: 12.sp, color: Color(0xff5F6060)),),
                    ),

                  ],
                ),

                _bikeProvider.currentBikeModel?.movementSetting?.enabled == true ? Padding(
        padding:EdgeInsets.only(top: 5.h,bottom: 5.h,),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            changeToDetectionSensitivityScreen(context);
          },
          child: Container(
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                    "Level Detection Sensitivity",
                    style: TextStyle(fontSize: 16.sp),
                  ),

                  Row(
                    children: [
                      Text(
                        _bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None",
                        style: TextStyle(fontSize: 16.sp, color: Color(0xff7A7A79)),
                      ),
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ): Opacity(
                  opacity: 0.3,
        child: Padding(
                    padding:EdgeInsets.only(top: 5.h,bottom: 5.h,),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: (){
                      },
                      child: Container(
                        height: 44.h,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Level Detection Sensitivity",
                                style: TextStyle(fontSize: 16.sp),
                              ),

                              Row(
                                children: [
                                  Text(
                                    _bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None",
                                    style: TextStyle(fontSize: 16.sp, color: Color(0xff7A7A79)),
                                  ),
                                  SvgPicture.asset(
                                    "assets/buttons/next.svg",
                                    height: 24.h,
                                    width: 24.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
                BikePageDivider(),

              ],
            ),
          ],
        ),),
    );
  }
}

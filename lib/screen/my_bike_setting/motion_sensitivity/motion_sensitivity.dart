import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';
import '../../../widgets/evie_textform.dart';
import '../../user_home_page/user_home_page.dart';


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
        changeToBikeSetting(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Motion Sensitivity',
          onPressed: () {
            changeToBikeSetting(context);
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
                    // Divider(
                    //   thickness: 23.h,
                    //   color: const Color(0xffF4F4F4),
                    // ),

                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text("Alarm on bike will be triggered when it senses movement.", style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),
                    ),

                  ],
                ),

                const EvieDivider(),

                _bikeProvider.currentBikeModel?.movementSetting?.enabled == true ? Padding(
                  padding:EdgeInsets.only(top: 5.h,bottom: 5.h,),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      changeToDetectionSensitivityScreen(context);
                    },
                    child: Container(
                      height: 54.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             Text(
                              "Level Detection Sensitivity",
                              style: EvieTextStyles.body18,
                            ),

                            Row(
                              children: [
                                Text(
                                  capitalizeFirstCharacter(_bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None"),
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayish),
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
                                style: EvieTextStyles.body18,
                              ),

                              Row(
                                children: [
                                  Text(
                                    _bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None",
                                    style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayish),
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
                const EvieDivider(),

              ],
            ),
          ],
        ),),
    );
  }
}

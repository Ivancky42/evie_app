import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';
import '../../../widgets/evie_textform.dart';
import '../../user_home_page/user_home_page.dart';

// import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/detection_sensitivity.dart';
// import 'package:evie_test/screen/my_bike_setting/sheet_navigator.dart';


///User profile page with user account information

class MotionSensitivity extends StatefulWidget {
  const MotionSensitivity({Key? key}) : super(key: key);

  @override
  _MotionSensitivityState createState() => _MotionSensitivityState();
}

class _MotionSensitivityState extends State<MotionSensitivity> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
    _bluetoothProvider = context.read<BluetoothProvider>();
    _settingProvider = context.read<SettingProvider>();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = context.watch<BikeProvider>();
    _bluetoothProvider =  context.watch<BluetoothProvider>();
    _settingProvider =  context.watch<SettingProvider>();


    return WillPopScope(
      onWillPop: () async {
       //_settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Motion Sensitivity',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 82.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Container(
                     width: 280.w,
                     child:  Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           "Motion Sensitivity",
                           style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, fontWeight: FontWeight.w400),
                         ),

                         Text(
                           'Alarm on bike will be triggered when it senses movement.',
                           style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                         ),
                       ],
                     ),
                   ),

                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: CupertinoSwitch(
                        value: _bikeProvider.currentBikeModel!.movementSetting?.enabled ?? false,
                        activeColor:  EvieColors.primaryColor,
                        thumbColor: _thumbColor,
                        trackColor: EvieColors.lightGrayishCyan,
                        onChanged: (value) async {
                          if (value) {
                            showCustomLightLoading('Changing...');
                            final uploadResult = await _bikeProvider
                                .updateMotionSensitivity(value!,
                                _bikeProvider.currentBikeModel?.movementSetting
                                    ?.sensitivity.toString() ??
                                    MovementSensitivity.medium.toString());
                            if (uploadResult == true) {
                              StreamSubscription? subscription;
                              subscription =
                                  _bluetoothProvider.changeMovementSetting(
                                      value,
                                      _bikeProvider.currentBikeModel
                                          ?.movementSetting?.sensitivity ==
                                          "low"
                                          ? MovementSensitivity.low
                                          : _bikeProvider.currentBikeModel
                                          ?.movementSetting?.sensitivity ==
                                          "medium"
                                          ? MovementSensitivity.medium
                                          : MovementSensitivity.high).listen((
                                      changeMovementResult) {
                                    if (changeMovementResult.result ==
                                        CommandResult.success) {
                                      SmartDialog.dismiss(
                                          status: SmartStatus.loading);
                                      subscription?.cancel();
                                    } else {
                                      SmartDialog.dismiss(
                                          status: SmartStatus.loading);
                                      subscription?.cancel();
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialog(
                                              title: "Error",
                                              content: "Error occurred when changing motion sensitivity level.",
                                              rightContent: "Retry",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    }
                                  });
                            } else {
                              SmartDialog.show(widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: "Error occurred when changing motion sensitivity level.",
                                  rightContent: "Ok",
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }));
                            }
                          }
                          else {
                            showOffMotionSensitivity(context, _bikeProvider, value!, _bluetoothProvider);
                          }
                      },
                      ),
                    ),
                  ],
                ),
              ),

              const EvieDivider(),

              _bikeProvider.currentBikeModel?.movementSetting?.enabled == true ? Padding(
                padding:EdgeInsets.only(top: 5.h,bottom: 5.h,),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    _settingProvider.changeSheetElement(SheetList.detectionSensitivity);
                  },
                  child: Container(
                    height: 54.h,
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
              ): Opacity(
                opacity: 0.3,
                child: Padding(
                  padding:EdgeInsets.only(top: 5.h,bottom: 5.h,),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                    },
                    child: Container(
                      height: 54.h,
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
                                capitalizeFirstCharacter(_bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None") ,
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
              const EvieDivider(),
            ],
          ),
        )
      ),
    );
  }
}

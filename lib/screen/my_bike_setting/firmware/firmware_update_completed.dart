import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/setting_provider.dart';



class FirmwareUpdateCompleted extends StatefulWidget{
  const FirmwareUpdateCompleted({ Key? key }) : super(key: key);
  @override
  _FirmwareUpdateCompletedState createState() => _FirmwareUpdateCompletedState();
}

class _FirmwareUpdateCompletedState extends State<FirmwareUpdateCompleted> {

  late SettingProvider _settingProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return WillPopScope(
        onWillPop: () async {
          return true;
        },

        child: Scaffold(
          body: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,76.h,16.w,4.h),
                        child: Text(
                          "Upgrade completed!",
                          style: EvieTextStyles.h2,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                        child: Container(
                          child: Text(
                            "WooHoo! You should now be able to enjoy improved performance, bug fixes, and new features. "
                                "If you encounter any issues, please reach out to our support team for assistance. Thank you for upgrading your device!",
                            style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                          ),
                        ),
                      ),


                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w,98.h,16.w,127.84.h),
                          child: SvgPicture.asset(
                            "assets/images/bike_champion.svg",
                          ),
                        ),
                      ),
                    ]),


                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () async {
                        await _bluetoothProvider.disconnectDevice();
                       _settingProvider.changeSheetElement(SheetList.bikeSetting);
                      },
                    ),
                  ),
                ),
              ]),
        ));
  }

}
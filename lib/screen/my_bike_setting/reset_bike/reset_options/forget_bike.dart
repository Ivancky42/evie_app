import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/length.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../widgets/evie_appbar.dart';
import '../../../../widgets/evie_button.dart';



class ForgetBike extends StatefulWidget{
  const ForgetBike({ super.key });
  @override
  _ForgetBikeState createState() => _ForgetBikeState();
}

class _ForgetBikeState extends State<ForgetBike> {

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

//v comment:this is how back button is written now

    return WillPopScope(
      onWillPop: () async {
        _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Reset Bike',
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: Text(
                    "Reset bike to original state",
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 106.h),
                  child: Text(
                    "Getting your bike back to square one. In development stage "
                        "this function is use to clear bike user to empty list. Press reset to continue.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Reset Bike",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    showResetBike(context, _bikeProvider);
                  },
                ),
              ),
            ),
          ],
        ),),
    );
  }

}
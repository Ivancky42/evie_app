import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class LeaveSuccessful extends StatefulWidget{
  const LeaveSuccessful({Key?key}) : super(key:key);
  @override
  _LeaveSuccessfulState createState() => _LeaveSuccessfulState();
}

class _LeaveSuccessfulState extends State<LeaveSuccessful>{

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return Stack(
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 82.h, 16.w, 2.h),
                child: Text("You Left the Team",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 300.h),
                child: Text("You've successfully left the bike-sharing team. "
                    "Your access to the bike and its related settings has been removed. "
                    "We hope you had a great experience and are always here to help with any future needs.",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),

                ),
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,97.h,16.w,EvieLength.buttonWord_ButtonBottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              child: Text(
                  "Add Bike",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
              ),
              onPressed: () async {

                if(_bikeProvider.userBikeDetails.isNotEmpty){
                  await _bikeProvider.changeBikeUsingIMEI(_bikeProvider.userBikeDetails.keys.first);
                }else{
                  await _bikeProvider.changeSharedPreference('currentBikeImei', '');
                }

                Navigator.of(context, rootNavigator: true).pop();
                changeToBeforeYouStart(context);
              },
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,8.h,16.w, EvieLength.button_Bottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              backgroundColor: EvieColors.lightGrayishCyan,
              child: Text(
                "Done",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: () async {

                if(_bikeProvider.userBikeDetails.isNotEmpty){
                  await _bikeProvider.changeBikeUsingIMEI(_bikeProvider.userBikeDetails.keys.first);
                }else{
                  await _bikeProvider.changeSharedPreference('currentBikeImei', '');
                }

                Navigator.of(context, rootNavigator: true).pop();
                changeToUserHomePageScreen(context);
              },
            ),
          ),
        ),

      ],
    );
  }
}
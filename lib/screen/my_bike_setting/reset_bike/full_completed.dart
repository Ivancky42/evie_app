import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_button.dart';

class FullCompleted extends StatefulWidget{
  const FullCompleted ({super.key});
  @override
  _FullCompletedState createState() => _FullCompletedState();
}

class _FullCompletedState extends State<FullCompleted>{

  late BikeProvider  _bikeProvider;
  late SettingProvider  _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 72.h, 16.w, 2.h),
                child: Text(
                  "Full Reset Completed!!",
                  style: EvieTextStyles.h2,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 300.h),
                child: Text(
                  "Great news! Your bike has been successfully reset. "
                      "Get ready for a revitalised ride with \nall-fresh settings."
                      " Have a fantastic ride!",
                  style: EvieTextStyles.body18.copyWith(height: 1.4),
                  ),
                ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, EvieLength.target_reference_button_a),
          child: Column(
            children: [
              EvieButton(
                width: double.infinity,
                height: 48.h,
                child: Text(
                  "Add Bike",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
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
              SizedBox(
                height: 8.h,
              ),

              EvieButton(
                width: double.infinity,
                height: 48.h,
                backgroundColor: EvieColors.lightGrayishCyan,
                child: Text(
                  "Done",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                ),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();

                  if(_bikeProvider.userBikeDetails.isNotEmpty){
                    await _bikeProvider.changeBikeUsingIMEI(_bikeProvider.userBikeDetails.keys.first);
                  }else{
                    await _bikeProvider.changeSharedPreference('currentBikeImei', '');
                  }

                  changeToUserHomePageScreen(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

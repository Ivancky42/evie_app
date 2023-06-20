import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class ForgetCompleted extends StatefulWidget{
  const ForgetCompleted({Key?key}) : super(key:key);
  @override
  _ForgetCompletedState createState() => _ForgetCompletedState();
}

class _ForgetCompletedState extends State<ForgetCompleted>{

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
                child: Text("Bike forgotten completed",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 300.h),
                child: Text("You've officially said goodbye to this bike. All its connected settings have been removed and it's ready for its next adventure. Have a great day ahead!",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
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
              onPressed: () {
                showResetBike(context, _bikeProvider); //CHANGE
              },
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,4.h,16.w, EvieLength.button_Bottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              backgroundColor: EvieColors.lightGrayishCyan,
              child: Text(
                "Done",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
              ),
              onPressed: () {
                showResetBike(context, _bikeProvider); //CHANGE
              },
            ),
          ),
        ),

      ],
    );
  }
}
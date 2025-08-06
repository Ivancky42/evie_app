import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class RestoreCompleted extends StatefulWidget{
  const RestoreCompleted({super.key});
  @override
  _RestoreCompletedState createState() => _RestoreCompletedState();
}

class _RestoreCompletedState extends State<RestoreCompleted>{

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
                child: Text("Bike reset completed!",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 80.h),
                child: Text("Great news! Your bike has been successfully reset. Get ready to ride and experience all the fresh and revitalized settings. Have a fantastic ride!",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
                ),
              ),

              Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/images/reset_completed.svg",
                    height: 211.65.h,
                    width: 319.6.w,
                  ),
                ),

            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,161.35.h,16.w, EvieLength.button_Bottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Done",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
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
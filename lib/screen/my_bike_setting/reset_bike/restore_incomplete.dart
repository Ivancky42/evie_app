import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class RestoreIncomplete extends StatefulWidget{
  const RestoreIncomplete({super.key});
  @override
  _RestoreIncompleteState createState() => _RestoreIncompleteState();
}

class _RestoreIncompleteState extends State<RestoreIncomplete>{

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
                child: Text("Reset Incomplete",
                  style: EvieTextStyles.h2,
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 66.h),
                child: Text("Oops! It looks like there was an issue with resetting your bike. "
                    "Please check out \"Get Help\" to reach out for assistance.",
                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
                ),
              ),


              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/images/bike_fix.svg",
                  height: 129.74.h,
                  width: 284.81.w,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,100.h,16.w, EvieLength.buttonButton_wordBottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              child: Text(
                "Try Again",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
              ),
              onPressed: () {
                // _settingProvider.changeSheetElement(SheetList.restoreBike);
              },
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w,4.h,16.w, EvieLength.buttonWord_ButtonBottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              backgroundColor: EvieColors.lightGrayishCyan,
              child: Text(
                "Get Help",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
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
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, EvieLength.buttonbutton_buttonBottom),
            child: EvieButton(
              width: double.infinity,
              height: 48.h,
              backgroundColor: EvieColors.grayishWhite,
              child: Text(
                "Cancel Reset Bike",
                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor,
                  decoration: TextDecoration.underline, // Add underline decoration
                ),
              ),
              onPressed: () {
                _settingProvider.changeSheetElement(SheetList.bikeSetting);
              },
            ),
          ),
        ),
      ],
    );
  }
}
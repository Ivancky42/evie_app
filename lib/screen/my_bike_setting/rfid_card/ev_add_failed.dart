import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/sheet_2.dart';

class EVAddFailed extends StatefulWidget {
  const EVAddFailed({Key? key}) : super(key: key);

  @override
  _EVAddFailedState createState() => _EVAddFailedState();
}

class _EVAddFailedState extends State<EVAddFailed> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.bikeSetting);
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
                  padding: EdgeInsets.fromLTRB(16.w, 82.h, 16.w,2.h),
                  child: Text(
                    "Whoops! There's an issue.",
                    style: EvieTextStyles.h2.copyWith(color:EvieColors.mediumBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 0.h),
                  child: Text(
                    "We're sorry, but there was an error registering your EV-Key. \n\n"
                        "Make sure your RFID tag is working properly and is within range. (some instruction on what can be done more correctly)",
                    style: EvieTextStyles.body18.copyWith(color:EvieColors.lightBlack),
                  ),
                ),

                  Center(
                      child: Container(
                        width: 291.15.w,
                         height: 300.h,
                        child: Lottie.asset('assets/animations/error-animate.json' ,width:
                        291.15.w, height:
                        182.04.h),
                      ),
                    ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,41.96.h,16.w, EvieLength.buttonButton_wordBottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                      "Try Again",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {
                    _settingProvider.changeSheetElement(SheetList.evKey);
                  },
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child:Padding(
                  padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonWord_ButtonBottom),
                  child: EvieButton_ReversedColor(
                      width: double.infinity,
                      onPressed: (){

                      },
                      child: Text("Get Help", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)))
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonbutton_buttonBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Cancel register EV-Key",
                      softWrap: false,
                      style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      if(_bikeProvider.rfidList.length >0){
                        _settingProvider.changeSheetElement(SheetList.evKeyList);
                      }else{
                        showBikeSettingSheet(context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),),
    );
  }
}

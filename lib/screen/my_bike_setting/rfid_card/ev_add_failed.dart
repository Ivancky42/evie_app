import 'dart:io';
import 'package:evie_bike/api/provider/auth_provider.dart';
import 'package:evie_bike/api/provider/bike_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_bike/api/provider/current_user_provider.dart';
import 'package:evie_bike/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/sheet.dart';

class EVAddFailed extends StatefulWidget {
  const EVAddFailed({Key? key}) : super(key: key);

  @override
  _EVAddFailedState createState() => _EVAddFailedState();
}

class _EVAddFailedState extends State<EVAddFailed> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        showBikeSettingSheet(context);
        return false;
      },
      child: Scaffold(

        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 76.h, 16.w,4.h),
                  child: Text(
                    "Whoops! There's an issue.",
                    style: EvieTextStyles.h2,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 50.h),
                  child: Text(
                    "We're sorry, but there was an error registering your EV-Key. \n\n"
                        "Make sure your RFID tag is working properly and is within range. (some instruction on what can be done more correctly)",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w,221.h),
                    child: Center(
                      child:  Lottie.asset('assets/animations/error-animate.json'),
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom+60.h),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                      "Try Again",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {
                    changeToEVKey(context);
                  },
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child:Padding(
                  padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonbutton_buttonBottom+60.h),
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
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
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
                        changeToEVKeyList(context);
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

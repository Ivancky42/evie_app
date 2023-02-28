import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';


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
        changeToBikeSetting(context);
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
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 106.h),
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
                        changeToBikeSetting(context);
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

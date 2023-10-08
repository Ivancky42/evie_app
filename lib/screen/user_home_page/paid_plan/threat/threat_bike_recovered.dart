import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/navigator.dart';

class ThreatBikeRecovered extends StatefulWidget {
  const ThreatBikeRecovered({Key? key}) : super(key: key);

  @override
  _ThreatBikeRecoveredState createState() => _ThreatBikeRecoveredState();
}

class _ThreatBikeRecoveredState extends State<ThreatBikeRecovered> {

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 67.h, 16.w,4.h),
                      child: Text(
                        "Bike Recovered!",
                        style: EvieTextStyles.h2,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 87.h),
                      child: Text(
                        "Your bike in back in your possession after a theft attempt. "
                            "Ensure ${_bikeProvider.currentBikeModel!.deviceName}'s security and enjoy it once again.",
                        style: EvieTextStyles.body18,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 0.h, 45.2.w,0.h),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/bike_champion.svg",
                          height: 242.34.h,
                          width: 252.17.w,
                        ),
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Hooray!",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),

                      onPressed: (){

                        changeToUserHomePageScreen(context);
                      },
                    ),
                  ),
                ),
              ]
          )
      ),
    );
  }
}

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

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_progress_indicator.dart';


class CongratsBikeAdded extends StatefulWidget {

  final String? bikeName;
  const CongratsBikeAdded(this.bikeName,{Key? key}) : super(key: key);

  @override
  _CongratsBikeAddedState createState() => _CongratsBikeAddedState();
}

class _CongratsBikeAddedState extends State<CongratsBikeAdded> {

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

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

                    const EvieProgressIndicator(currentPageNumber: 4, totalSteps: 5,),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                      child: Text(
                        "Congrats!",
                        style: EvieTextStyles.h2,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 87.h),
                      child: Text(
                        "You have successfully added ${widget.bikeName.toString().trim() ?? ""}. Get ready to track your rides, access all the fun features, and have an amazing time. \n \n"
                            "If there's anything we can help with, just let us know. Happy riding!",
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
                        "Let's Get Started",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),

                      onPressed: (){

                        _authProvider.setIsFirstLogin(false);
                        _bikeProvider.setIsAddBike(false);

                        ///show sync
                        showSyncRideThrive(context, _bluetoothProvider, _bikeProvider);

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

import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/auth_provider.dart';

class BeforeYouStart extends StatefulWidget {
  const BeforeYouStart({Key? key}) : super(key: key);

  @override
  _BeforeYouStartState createState() => _BeforeYouStartState();
}

class _BeforeYouStartState extends State<BeforeYouStart> {
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
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 120.h, 16.w, 36.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                              "Things you'll need before you start",
                              style: EvieTextStyles.h2,
                            ),
                            SizedBox(height: 4.h,),
                            Text(
                              "1. Assemble your bike fully.",
                              style: EvieTextStyles.body18,
                            ),
                            SizedBox(height: 5.h,),
                            GestureDetector(
                              onTap: (){
                                const url = 'https://support.eviebikes.com/en-US/how-to-assemble-evie-s1-and-t1-174422';
                                final Uri _url = Uri.parse(url);
                                launch(_url);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 20.w),
                                child: Row(
                                  children: [
                                    Text("How to assemble my bike?",
                                      style: EvieTextStyles.body18.copyWith(fontWeight:FontWeight.w400, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                                    ),
                                    SvgPicture.asset(
                                      "assets/buttons/external_link_purple.svg",
                                    ),
                                  ],
                                ),
                              )
                            ),
                            SizedBox(height: 25.h,),
                            Text(
                              "2. Get ownership card ready.",
                              style: EvieTextStyles.body18,
                            ),
                            SizedBox(height: 108.h,),
                            Center(
                              child: SvgPicture.asset(
                                "assets/images/assemble_bike.svg", width: 268.w, height: 195.h,
                              ),
                            )
                        ]
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 48.h,
                            width: double.infinity,
                            child: EvieButton(
                              width: double.infinity,
                              child:Text(
                                "I'm Ready",
                                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                              ),
                              onPressed: () async {
                                changeToTurnOnQRScannerScreen(context);
                              },
                            ),
                          ),
                          SizedBox(height: 17.h,),
                          _bikeProvider.isAddBike ?
                          EvieButton_ReversedColor(
                              width: double.infinity,
                              onPressed: (){
                                _bikeProvider.setIsAddBike(false);
                                changeToUserHomePageScreen(context);
                              },
                              child: Text("Cancel", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor))) :
                          GestureDetector(
                            child: Text(
                              "I'm not ready",
                              softWrap: false,
                              style: EvieTextStyles.body18_underline,
                            ),
                            onTap: () {
                              _authProvider.setIsFirstLogin(false);
                              changeToUserHomePageScreen(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Align(
                //   alignment: Alignment.center,
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(78.w,307.h,78.w,127.84.h),
                //     child: SvgPicture.asset(
                //       "assets/images/ride_bike_see_phone.svg",
                //     ),
                //   ),
                // ),
      ])),
    );
  }
}

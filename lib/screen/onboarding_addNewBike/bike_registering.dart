
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';

class BikeRegistering extends StatefulWidget {
  final bool isSuccess;
  const BikeRegistering({Key? key, required this.isSuccess}) : super(key: key);

  @override
  _BikeRegisteringState createState() => _BikeRegisteringState();
}

class _BikeRegisteringState extends State<BikeRegistering> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), (){
      if (widget.isSuccess) {
        changeToBikeConnectSuccessScreen(context);
      }
      else {
        changeToBikeConnectFailedScreen(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

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

                      const EvieProgressIndicator(currentPageNumber: 1, totalSteps: 5,),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                        child: Text(
                          "Registering bike",
                          style: EvieTextStyles.h2,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 57.h),
                        child: Text(
                          "Please wait while EVIE app registering bike to your account. This may take a few moments.",
                          style: EvieTextStyles.body18,
                        ),
                      ),
                    ],
                  ),


                Padding(
                  padding: EdgeInsets.only(top: 127.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Lottie.asset("assets/animations/registering-bike.json", repeat: true),
                  ),
                )
              ]
          )
      ),
    );
  }



}

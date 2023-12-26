
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

class BikeConnectSuccess extends StatefulWidget {
  const BikeConnectSuccess({Key? key}) : super(key: key);

  @override
  _BikeConnectSuccessState createState() => _BikeConnectSuccessState();
}

class _BikeConnectSuccessState extends State<BikeConnectSuccess> {

  late BikeProvider _bikeProvider;
  bool isNext = true;



  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    if(isNext == true){
      Future.delayed(const Duration(seconds: 5), (){
        changeToNameBikeScreen(context);
        setState(() {
          isNext = false;
        });
      });
      setState(() {
        isNext = false;
      });
    }

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

                      const EvieProgressIndicator(currentPageNumber: 2, totalSteps: 5,),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                        child: Text(
                          "Yay! Bike is registered!",
                          style: EvieTextStyles.h2,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 57.h),
                        child: Text(
                          "Woohoo! Your bike has been successfully registered to your account.",
                          style: EvieTextStyles.body18,
                        ),
                      ),

                     Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(32.w, 0.h, 32.w, 4.h),
                        child: Text(
                          "EVIE " + _bikeProvider.currentBikeModel!.model!.toUpperCase(),
                          style:  EvieTextStyles.body20,
                        ),
                      ),
                     ),

                  Center(
                     child: Padding(
                       padding: EdgeInsets.fromLTRB(32.w, 4.h, 32.w, 32.h),
                       child:
                       Text(_bikeProvider.currentBikeModel?.serialNumber ?? '',
                         style : EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),),
                     ),
                  ),

                    ],
                  ),


                Padding(
                  padding: EdgeInsets.only(top: 200.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Lottie.asset("assets/animations/register_bike_success.json", repeat: false),
                  ),
                ),

                // Padding(
                //     padding: EdgeInsets.fromLTRB(19.w, 386.h, 19.w, 288.h),
                //     child: Container(
                //       height: 220.h,
                //       width: 352.18.w,
                //       child:Stack(
                //         alignment: Alignment.center,
                //         children: <Widget>[
                //       Lottie.asset("assets/animations/register_bike_success.json",),
                //
                //           // IconButton(
                //           //   iconSize: 100.h,
                //           //   icon: Image.asset("assets/icons/connect_success.png"),
                //           //   onPressed: () {
                //           //
                //           //   },
                //           // ),
                //
                //         ],
                //       ),
                //     ),
                // ),
              ]
          )
      ),
    );
  }



}


import 'package:evie_test/api/navigator.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/colours.dart';
import '../../widgets/evie_button.dart';

class BikeConnectFailed extends StatefulWidget {
  const BikeConnectFailed({Key? key}) : super(key: key);

  @override
  _BikeConnectFailedState createState() => _BikeConnectFailedState();
}

class _BikeConnectFailedState extends State<BikeConnectFailed> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Stack(
            children:[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child:StepProgressIndicator(
                        totalSteps: 10,
                        currentStep: 4,
                        selectedColor: Color(0xffCECFCF),
                        selectedSize: 4,
                        unselectedColor: Color(0xffDFE0E0),
                        unselectedSize: 3,
                        padding: 0.0,
                        roundedEdges: Radius.circular(16),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      "Bike Connected Failed",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text("Opos! Looks like some error happen.", style: TextStyle(fontSize: 11.5.sp),),
                    SizedBox(
                      height: 10.h,
                    ),

                    Center(
                      child: Text(
                        "Bluetooth Name",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Center(
                      child: Text("Not Connected", style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w400),),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                  ],
                ),
              ),


              Align(
                alignment: Alignment.center,
                child:  Container(
                  height: 40.h,
                  child:Stack(
                    alignment: Alignment.center,
                    children: <Widget>[


                      const Image(
                        fit: BoxFit.fitWidth,
                        image: AssetImage("assets/images/bike_HPStatus/bike_normal.png"),
                      ),
                      IconButton(
                        iconSize: 12.h,
                        icon: Image.asset("assets/icons/connect_failed.png"),
                        onPressed: () {

                        },
                      ),

                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, right: 16, bottom: 64.0),
                  child: EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Try Again",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                    onPressed: () {
                      changeToBikeScanningScreen(context);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RawMaterialButton(
                      elevation: 0.0,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      onPressed: () {
                        changeToTurnOnNotificationsScreen(context);
                      },
                      child: Text(
                        "Maybe Later",
                        style: TextStyle(
                          color: EvieColors.PrimaryColor,
                          fontSize: 10.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }



}

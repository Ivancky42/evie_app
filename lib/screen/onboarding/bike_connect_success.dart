
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';

class BikeConnectSuccess extends StatefulWidget {
  const BikeConnectSuccess({Key? key}) : super(key: key);

  @override
  _BikeConnectSuccessState createState() => _BikeConnectSuccessState();
}

class _BikeConnectSuccessState extends State<BikeConnectSuccess> {


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
                      "Bike Connected Successfully",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text("Hooray! You have successfully connected #Bike Name#", style: TextStyle(fontSize: 11.5.sp),),
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
                   child: Text("Connected", style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w400),),
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
                        icon: Image.asset("assets/icons/connect_success.png"),
                        onPressed: () {

                        },
                      ),

                    ],
                  ),
                ),
              ),
            ]
        )
    );
  }



}

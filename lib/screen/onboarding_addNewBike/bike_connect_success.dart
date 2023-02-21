
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';

class BikeConnectSuccess extends StatefulWidget {
  const BikeConnectSuccess({Key? key}) : super(key: key);

  @override
  _BikeConnectSuccessState createState() => _BikeConnectSuccessState();
}

class _BikeConnectSuccessState extends State<BikeConnectSuccess> {

  late BikeProvider _bikeProvider;


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

     Future.delayed(const Duration(seconds: 8), (){
       changeToNameBikeScreen(context);
     });

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

                      const EvieProgressIndicator(currentPageNumber: 4),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                        child: Text(
                          "Bike registration successfully",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 63.h),
                        child: Text(
                          "Hooray! You have successfully register your Bike Serial Number.",
                          style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                        ),
                      ),

                     Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(32.w, 0.h, 32.w, 4.h),
                        child: Text(
                          _bikeProvider.currentBikeModel?.deviceIMEI ?? "",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                     ),

                  Center(
                     child: Padding(
                       padding: EdgeInsets.fromLTRB(32.w, 4.h, 32.w, 32.h),
                       child:
                       Text("Registered", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
                     ),
                  ),

                    ],
                  ),


          Padding(
                    padding: EdgeInsets.fromLTRB(19.w, 336.h, 19.w, 288.h),
                    child: Container(
                      height: 220.h,
                      width: 352.18.w,
                      child:Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            ///Animation
                            "assets/images/bike_fall.svg",
                          ),
                          // const Image(
                          //   fit: BoxFit.fitWidth,
                          //   image: AssetImage("assets/images/bike_HPStatus/bike_normal.png"),
                          // ),
                          IconButton(
                            iconSize: 100.h,
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
      ),
    );
  }



}

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

class DisplayControl extends StatefulWidget {
  const DisplayControl({Key? key}) : super(key: key);

  @override
  _DisplayControlState createState() => _DisplayControlState();
}

enum Display { defaultMode, lightMode, darkMode }

class _DisplayControlState extends State<DisplayControl> {

  Display? _display = Display.defaultMode;


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

                  Padding(
                    padding: EdgeInsets.fromLTRB(70.w, 66.h, 70.w,50.h),
                    child:const StepProgressIndicator(
                      totalSteps: 10,
                      currentStep: 9,
                      selectedColor: Color(0xffCECFCF),
                      selectedSize: 4,
                      unselectedColor: Color(0xffDFE0E0),
                      unselectedSize: 3,
                      padding: 0.0,
                      roundedEdges: Radius.circular(16),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                    child: Text(
                      "Display control on your hand",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
                    child: Text(
                      "EVIE come with default (similar with your phone system/light mode during day time, "
                          "dark mode during night time) mode, light mode and dark mode. "
                          "You can update display mode in Setting anytime.",
                      style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                    ),
                  ),


      Padding(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0.h),
        child: Container(
            child: Column(
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Default",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Radio<Display>(
                        fillColor: MaterialStateColor.resolveWith(
                                (states) => EvieColors.primaryColor),
                        value: Display.defaultMode,
                        groupValue: _display,
                        onChanged: (Display? value) {
                          setState(() {
                            _display = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Light Mode",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Radio<Display>(
                        fillColor: MaterialStateColor.resolveWith(
                                (states) => EvieColors.primaryColor),
                        value: Display.lightMode,
                        groupValue: _display,
                        onChanged: (Display? value) {
                          setState(() {
                            _display = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Radio<Display>(
                        fillColor: MaterialStateColor.resolveWith(
                                (states) => EvieColors.primaryColor),
                        value: Display.darkMode,
                        groupValue: _display,
                        onChanged: (Display? value) {
                          setState(() {
                            _display = value;
                          });
                        },
                      ),
                    ],
                  )


              ],
            )
        ),
      ),


                ],
              ),



              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                  EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                  child:  EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    onPressed: () {
                     changeToCongratulationScreen(context);
                    },
                  ),
                ),
              ),




            ]
        ),
      ),
    );
  }
}

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
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
                        currentStep: 9,
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
                      "Display control on your hand",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text(
                      "EVIE come with default (similar with your phone system/light mode during day time, "
                          "dark mode during night time) mode, light mode and dark mode. "
                            "You can update display mode in Setting anytime.",
                      style: TextStyle(fontSize: 12.sp ,height: 0.17.h),
                    ),
                    SizedBox(height: 1.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Default",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Radio<Display>(
                          fillColor: MaterialStateColor.resolveWith(
                                  (states) => EvieColors.PrimaryColor),
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
                                  (states) => EvieColors.PrimaryColor),
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
                                  (states) => EvieColors.PrimaryColor),
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
                ),
              ),


              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                  EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                  child:  EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
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

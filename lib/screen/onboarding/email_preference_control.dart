import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../widgets/evie_switch.dart';

class EmailPreferenceControl extends StatefulWidget {
  const EmailPreferenceControl({Key? key}) : super(key: key);

  @override
  _EmailPreferenceControlState createState() => _EmailPreferenceControlState();
}

class _EmailPreferenceControlState extends State<EmailPreferenceControl> {

  bool _switchValue1 = true;
  bool _switchValue2 = true;
  bool _switchValue3 = true;

  final Color _thumbColor = EvieColors.thumbColorTrue;

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child:  Scaffold(
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
                      currentStep: 8,
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
                      "Get more with EVIE",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
                    child: Text(
                      "We write about EVIE. Would you like to keep up to date with EVIE Mail emails? "
                          "You can always manage your Email categories in Setting anytime.",
                      style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0.h),
                    child: Container(
                        child: Column(
                          children: [
                            EvieSwitch(
                              text: "General",
                              value: _switchValue1,
                              thumbColor: _thumbColor,
                              onChanged: (value) {
                                setState(() {
                                  _switchValue1 = value!;
                                  if (value == true) {
                                    //
                                  } else if (value == false) {
                                    //
                                  }
                                });
                              },
                            ),

                            EvieSwitch(
                              text: "Sales & Promotion",
                              value: _switchValue2,
                              thumbColor: _thumbColor,
                              onChanged: (value) {
                                setState(() {
                                  _switchValue2 = value!;
                                  if (value == true) {
                                    //
                                  } else if (value == false) {
                                    //
                                  }
                                });
                              },
                            ),

                            EvieSwitch(
                              text: "Product Services & Guide",
                              value: _switchValue3,
                              thumbColor: _thumbColor,
                              onChanged: (value) {
                                setState(() {
                                  _switchValue3 = value!;
                                  if (value == true) {
                                    //
                                  } else if (value == false) {
                                    //
                                  }
                                });
                              },
                            ),



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
                  changeToDisplayControlScreen(context);
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

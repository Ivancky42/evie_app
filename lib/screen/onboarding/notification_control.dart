import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../widgets/evie_switch.dart';

class NotificationsControl extends StatefulWidget {
  const NotificationsControl({Key? key}) : super(key: key);

  @override
  _NotificationsControlState createState() => _NotificationsControlState();
}

class _NotificationsControlState extends State<NotificationsControl> {

  bool _switchValue1 = true;
  bool _switchValue2 = true;
  bool _switchValue3 = true;
  bool _switchValue4 = true;
  bool _switchValue5 = true;

  final Color _thumbColor = EvieColors.ThumbColorTrue;

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
                      currentStep: 7,
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
                    "Notification at your control",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "Choose the type of notification you would like to receive. "
                        "You can always manage your notification categories in Setting anytime.",
                    style: TextStyle(fontSize: 12.sp,height: 0.17.h),
                  ),
                  SizedBox(height: 1.h,),
                EvieSwitch(
                  text: "Low Battery Alert",
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
                  SizedBox(height: 1.h,),
                  EvieSwitch(
                    text: "Plan Reminder",
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
                  SizedBox(height: 1.h,),
                  EvieSwitch(
                    text: "App Update",
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
                  SizedBox(height: 1.h,),
                  EvieSwitch(
                    text: "Firmware Update",
                    value: _switchValue4,
                    thumbColor: _thumbColor,
                    onChanged: (value) {
                      setState(() {
                        _switchValue4 = value!;
                        if (value == true) {
                          //
                        } else if (value == false) {
                          //
                        }
                      });
                    },
                  ),
                  SizedBox(height: 1.h,),
                  EvieSwitch(
                    text: "Theft Alert",
                    value: _switchValue5,
                    thumbColor: _thumbColor,
                    onChanged: (value) {
                      setState(() {
                        _switchValue5 = value!;
                        if (value == true) {
                          //
                        } else if (value == false) {
                          //
                        }
                      });
                    },
                  ),

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
                    changeToEmailPreferenceControlScreen(context);
                  },
                ),
              ),
            ),


          ]
      ),
    );
  }
}

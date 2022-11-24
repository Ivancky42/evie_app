import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:evie_test/widgets/evie_button.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../api/length.dart';

class Congratulation extends StatefulWidget {
  const Congratulation({Key? key}) : super(key: key);

  @override
  _CongratulationState createState() => _CongratulationState();
}

class _CongratulationState extends State<Congratulation> {

  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
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
                  currentStep: 10,
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
                "Congrats!",
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                "You have completed your account setup! Let's enjoy...",
                style: TextStyle(fontSize: 11.5.sp,height: 0.17.h),
              ),
            ],
          ),
        ),

            const Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage("assets/images/account_verified.png"),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: EvieLength.button_Bottom),
                child: SizedBox(
                  width: double.infinity,
                  child:    EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Let's Go",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                    onPressed: (){
                      _authProvider.setIsFirstLogin(false);
                      changeToUserHomePageScreen(context);
                    },
                  ),
                ),
              ),
            ),
         ]
        )
      ),
    );
  }
}

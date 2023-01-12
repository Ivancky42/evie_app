import 'dart:io';

import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import '../api/colours.dart';
import '../widgets/evie_button.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
     bool? exitApp = await SmartDialog.show(
         widget:
     EvieDoubleButtonDialogCupertino(
         title: "Close this app?",
         content: "Are you sure you want to close this App?",
         leftContent: "No",
         rightContent: "Yes",
         onPressedLeft: (){SmartDialog.dismiss();},
         onPressedRight: (){SystemNavigator.pop();})) as bool?;
    return exitApp ?? false;
    },

    child:  Scaffold(
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 142.h,
            ),

            SvgPicture.asset(
              "assets/logo/evie_logo.svg",
              width: 191.w,
              height: 42.h,
            ),

            SizedBox(
              height: 99.h,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 395.92.w,
                height: 279.62.h,
                alignment: Alignment.bottomRight,
                child: const Image(
                  image: AssetImage("assets/images/evie_bike_shadow.png"),
                ),
              ),
            ),
            SizedBox(
              height:93.38.h,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: EvieButton(
                height: 48.h,
                width: double.infinity,
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onPressed: () async {
                  changeToInputNameScreen(context);
                  //changeToLetsGoScreen(context);
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                elevation: 0.0,
                padding: EdgeInsets.fromLTRB(0, 23.5.h, 0, 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () {
                  changeToSignInMethodScreen(context);
                },
                child: Text(
                  "I already have an account",
                  style: TextStyle(
                    color: EvieColors.primaryColor,
                    fontSize: 12.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

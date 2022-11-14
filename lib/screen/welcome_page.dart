import 'package:evie_test/api/navigator.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 18.h,
            ),
            const Image(
              image: AssetImage("assets/icons/evie_logo.png"),
            ),
            SizedBox(
              height: 8.h,
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: const Image(
                image: AssetImage("assets/images/evie_bike_shadow.png"),
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EvieButton(
                width: double.infinity,
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
                onPressed: () async {
                  //changeToInputNameScreen(context);
                  changeToLetsGoScreen(context);
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () {
                  changeToSignInMethodScreen(context);
                },
                child: Text(
                  "I already have an account",
                  style: TextStyle(
                    color: EvieColors.PrimaryColor,
                    fontSize: 10.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //        ),
    );
  }
}

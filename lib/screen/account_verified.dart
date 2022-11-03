import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:sizer/sizer.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

class AccountVerified extends StatefulWidget {
  const AccountVerified({Key? key}) : super(key: key);

  @override
  _AccountVerifiedState createState() => _AccountVerifiedState();
}

class _AccountVerifiedState extends State<AccountVerified> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){ changeToWelcomeScreen(context);}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 1.h,
            ),
            Text(
              "Account Verified!",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              "You are all set.",
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(
              height: 12.h,
            ),
            const Center(
              child: Image(
                image: AssetImage("assets/images/account_verified.png"),
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            EvieButton(
              width: double.infinity,
              child: Text(
                "Let's Get Started",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
              onPressed: () async {
            changeToUserHomePageScreen(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  const VerifyEmail(this.email, {Key? key}) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? timer;
  bool isEmailVerified = false;

  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();

    ///Loop timer 5 every 5 second and detect isVerified condition
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      AuthProvider().checkIsVerify().then((value) {
        setState(() {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });

        if (value == true) {
          timer?.cancel();
          changeToAccountVerifiedScreen(context);
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

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
              "Verify your email address",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              "To keep your account secure, we've sent an email to ${widget.email}. Please follow the instruction to verify your account.",
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(
              height: 12.h,
            ),
            const Center(
              child: Image(
                image: AssetImage("assets/images/sent_message.png"),
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            EvieButton(
              width: double.infinity,
              child: Text(
                "Open Email Inbox",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
              onPressed: () async {
                await OpenMailApp.openMailApp();
              },
            ),
            SizedBox(
              height: 1.h,
            ),

        Stack(
          children:[

            Center(
              child: Text(
                    "Did not receive the email? Check your spam filter, or try",
                    style: TextStyle(fontSize: 9.sp),
                  ),
            ),


            Center(
              child:
            SizedBox(
              height: 30,
              width: 100,
              child:
            TextButton(
                  child: Text(
                    "resend email.",
                    style: TextStyle(fontSize: 9.sp),
                  ),
                  onPressed: () {
                    ///TODO: 30 seconds countdown
                    _authProvider.sendFirestoreVerifyEmail();
                  },
                ),
            ),),
])

          ],
        ),
      ),
    );
  }
}

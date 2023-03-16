import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';

import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../api/snackbar.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

class VerifyEmail extends StatefulWidget {

  const VerifyEmail({Key? key}) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? timer;
  Timer? countdownTimer;
  bool isCountDownOver = false;
  bool isEmailVerified = false;

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late CurrentUserProvider _currentUserProvider;

  Duration myDuration = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    startCountDownTimer();

    ///Loop timer 5 every 5 second and detect isVerified condition
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      AuthProvider().checkIsVerify().then((value) {
        setState(() {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });

        if (value == true) {
          timer?.cancel();
          changeToAccountVerifiedScreen(context);

      }});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void startCountDownTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(seconds: 30));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
          isCountDownOver = true;
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showBackToHome(context, _bikeProvider, _authProvider)  as bool?;
        return exitApp ?? false;
      },

      child:  Scaffold(

        appBar: EvieAppbar_Back(onPressed: () {
          showBackToHome(context, _bikeProvider, _authProvider) as bool?;
        }),


        body: Stack(children: [
          Padding(
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
                    style: EvieTextStyles.h2,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "To keep your account secure, we've sent an email to ${_authProvider.getEmail}. Please follow the instruction to verify your account.",
                    style: EvieTextStyles.body18,
                  ),
                ]),
          ),
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/images/send_email.svg",
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 84.0),
              child: EvieButton(
                width: double.infinity,
                child: Text(
                  "Open Email Inbox",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                ),
                onPressed: () async {
                  await OpenMailApp.openMailApp();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:EdgeInsets.only(left: 16, right: 16, bottom: EvieLength.buttonWord_WordBottom),
              child: Text(
                "Did not receive the email? Check your spam filter, or try",
                style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w400, color: EvieColors.lightBlack,),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom:  EvieLength.buttonWord_WordBottom-20.h),
              child: SizedBox(
                height: 35,
                width: 100,
                child: TextButton(
                  child: Text(
                    "resend email.",
                    style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w400, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                  ),
                  onPressed: () async {
                    if(isCountDownOver == false){

                      showResentEmailFailedToast(context);

                    }else if(isCountDownOver == true){
                      _authProvider.sendFirestoreVerifyEmail();
                     showResentEmailSuccess(_currentUserProvider);
                        setState(() {
                          isCountDownOver = false;
                          resetTimer();
                          startCountDownTimer();
                        });
                    }
                  },
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

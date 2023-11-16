import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/welcome_page.dart';
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
  bool isEmailVerified = false;

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late CurrentUserProvider _currentUserProvider;
  String? counting;

  @override
  void initState() {
    super.initState();

    _authProvider = context.read<AuthProvider>();
    _currentUserProvider = context.read<CurrentUserProvider>();
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
    _authProvider.sendFirestoreVerifyEmail();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (timer.tick == 30) {
        setState(() {
          counting = null;
        });
        countdownTimer?.cancel();
      }
      else {
        //print('Timer tick: ${timer.tick}');
        setState(() {
          counting = (30 - timer.tick).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showBackToLogin(context, _bikeProvider, _authProvider)  as bool?;
        return exitApp ?? false;
      },
      child:  Scaffold(
        appBar: EvieAppbar_Back(onPressed: () {showBackToLogin(context, _bikeProvider, _authProvider) as bool?;}),
        body: Stack(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, EvieLength.screen_bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verify your email address",
                        style: EvieTextStyles.h2,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text.rich(
                        TextSpan(
                          text: "To keep your account secure, we've sent an email to ",
                          style: EvieTextStyles.body18,
                          children: [
                            TextSpan(
                              text: _authProvider.getEmail,
                              style: TextStyle(
                                color: EvieColors.primaryColor, // Set your desired color
                                // Other styles if needed
                              ),
                            ),
                            TextSpan(
                              text: ". Please follow the instruction to verify your account.",
                              style: EvieTextStyles.body18,
                            ),
                          ],
                        ),
                      ),
                    ]),
                Column(
                  children: [
                    EvieButton(
                      width: double.infinity,
                      child: Text(
                        "Open Email Inbox",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () async {
                        await OpenMailApp.openMailApp();
                      },
                    ),
                    SizedBox(height: 8.h,),
                    EvieButton_ReversedColor(
                      width: double.infinity,
                      child: Text(
                        "Return to Log In",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                      ),
                      onPressed: () async {
                        changeToWelcomeScreen(context);
                      },
                    ),
                    SizedBox(
                      height: 11.h,
                    ),
                    Column(
                      children: [
                        Text(
                          "Did not receive the email? Check your spam filter,",
                          style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w400, color: EvieColors.lightBlack,),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "or try ",
                              style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w400, color: EvieColors.lightBlack,),
                            ),

                            countdownTimer != null ?
                            counting != null ?
                            Text(
                              "resend email after " + counting! + 's.',
                              style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w800, color: EvieColors.lightGrayish,),
                            ) :
                            GestureDetector(
                              child: Text(
                                "resend email.",
                                style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w800, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                              ),
                              onTap: () async {
                                startCountDownTimer();
                                showResentEmailSuccess(_currentUserProvider);
                              },
                            ) :
                            GestureDetector(
                              child: Text(
                                "resend email.",
                                style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w800, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                              ),
                              onTap: () async {
                                startCountDownTimer();
                                showResentEmailSuccess(_currentUserProvider);
                              },
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            )
          ),
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/images/send_email.svg",
            ),
          ),
        ]),
      ),
    );
  }
}

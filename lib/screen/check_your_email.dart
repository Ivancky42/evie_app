import 'dart:async';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../api/snackbar.dart';
import '../widgets/evie_appbar.dart';
import 'package:evie_test/widgets/evie_button.dart';

class CheckYourEmail extends StatefulWidget {
  const CheckYourEmail({super.key});

  @override
  _CheckYourEmailState createState() => _CheckYourEmailState();
}

class _CheckYourEmailState extends State<CheckYourEmail> {

  Timer? timer;
  Timer? countdownTimer;
  bool isCountDownOver = false;
  bool isEmailVerified = false;

  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  Duration myDuration = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    startCountDownTimer();

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
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    return Scaffold(
        appBar: EvieAppbar_Back(onPressed: (){ changeToWelcomeScreen(context);}),
        body: Stack (
            children:[
              Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, EvieLength.target_reference_button_c),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Check your mail",
                            style: EvieTextStyles.h2,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            "We have sent a password recover instruction to your email.",
                            style: EvieTextStyles.body18,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child:   EvieButton(
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
                          SizedBox(height: 8.h,),
                          EvieButton_ReversedColor(
                            width: double.infinity,
                            child: Text(
                              "Return to Login",
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
                                  GestureDetector(
                                    child: Text(
                                      "resending the email.",
                                      style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w800, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                                    ),
                                    onTap: () async {
                                      if(isCountDownOver == false){
                                        showResentEmailFailedToast(context);
                                      }
                                      else if(isCountDownOver == true){
                                        await _authProvider.resetPassword(_authProvider.getEmail);
                                        showEvieResendDialog(context, _currentUserProvider.currentUserModel!.email);
                                        setState(() {
                                          isCountDownOver = false;
                                          resetTimer();
                                          startCountDownTimer();
                                        });
                                      }
                                    },
                                  ),
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
            ]
        )
    );
  }
}

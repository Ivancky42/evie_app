import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../api/colours.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_double_button_dialog.dart';
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

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await SmartDialog.show(
            widget:
            EvieDoubleButtonDialogCupertino(
                title: "Back to Home Page?",
                content: "Are you sure you want to sign out and back to home page?",
                leftContent: "No",
                rightContent: "Yes",
                onPressedLeft: (){SmartDialog.dismiss();},
                onPressedRight: (){
                  _authProvider.signOut(context).then((result){
                    if(result == true){

                      // _authProvider.clear();

                      changeToWelcomeScreen(context);
                      SmartDialog.dismiss();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('Signed out'),
                          duration: Duration(
                              seconds: 2),),
                      );
                    }else{
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('Error, Try Again'),
                          duration: Duration(
                              seconds: 4),),
                      );
                    }
                  });
                })) as bool?;
        return exitApp ?? false;
      },

      child:  Scaffold(

        appBar: EvieAppbar_Back(onPressed: () {
          SmartDialog.show(
              widget:
              EvieDoubleButtonDialogCupertino(
                  title: "Back to Home Page?",
                  content: "Are you sure you want to sign out and back to home page?",
                  leftContent: "No",
                  rightContent: "Yes",
                  onPressedLeft: (){SmartDialog.dismiss();},
                  onPressedRight: (){
                    _authProvider.signOut(context).then((result){
                      if(result == true){

                        // _authProvider.clear();

                        changeToWelcomeScreen(context);
                        SmartDialog.dismiss();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text('Signed out'),
                            duration: Duration(
                                seconds: 2),),
                        );
                      }else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text('Error, Try Again'),
                            duration: Duration(
                                seconds: 4),),
                        );
                      }
                    });
                  })) as bool?;
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
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "To keep your account secure, we've sent an email to ${widget.email}. Please follow the instruction to verify your account.",
                    style: TextStyle(fontSize: 12.sp, height: 0.17.h),
                  ),
                ]),
          ),
          const Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage("assets/images/sent_message.png"),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 64.0),
              child: Text(
                "Did not receive the email? Check your spam filter, or try",
                style: TextStyle(fontSize: 9.sp),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 42.0),
              child: SizedBox(
                height: 30,
                width: 100,
                child: TextButton(
                  child: Text(
                    "resend email.",
                    style:
                        TextStyle(fontSize: 9.sp, color: EvieColors.PrimaryColor),
                  ),
                  onPressed: () async {
                    if(isCountDownOver == false){
                      SmartDialog.show(
                        widget: EvieSingleButtonDialogCupertino(
                            title: "Error",
                            content: "You need to wait 30 seconds before sending another email",
                            rightContent: "Ok",
                            onPressedRight:(){SmartDialog.dismiss();})
                      );
                    }else if(isCountDownOver == true){
                      _authProvider.sendFirestoreVerifyEmail();
                        SmartDialog.show(
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Success",
                                content: "We have send another verify email to your account",
                                rightContent: "Ok",
                                onPressedRight:(){SmartDialog.dismiss();})
                        );
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

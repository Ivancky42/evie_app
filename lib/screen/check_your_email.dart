import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

class CheckYourEmail extends StatefulWidget {
  const CheckYourEmail({Key? key}) : super(key: key);

  @override
  _CheckYourEmailState createState() => _CheckYourEmailState();
}

class _CheckYourEmailState extends State<CheckYourEmail> {

  late AuthProvider _authProvider;
  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },

      child: Scaffold(
          appBar: EvieAppbar_Back(onPressed: (){ changeToWelcomeScreen(context);}),
          body:
          Stack(
              children:[Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                    padding: EdgeInsets.only(
                        left: 16, right: 16, bottom: EvieLength.buttonWord_ButtonBottom+60.h),
                    child: SizedBox(
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
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child:Padding(
                      padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonbutton_buttonBottom+60.h),
                      child: EvieButton_ReversedColor(
                          width: double.infinity,
                          onPressed: (){
                            changeToSignInScreen(context);
                          },
                          child: Text("Log In with Email", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)))
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                    child: Row(
                      children: [
                        TextButton(
                          child: Text(
                            "Did not receive the email? Check your spam filter, \nor try resend email",
                            softWrap: true,
                            style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                          ),
                          onPressed: () {

                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ]
          )
      ),
    );
  }
}

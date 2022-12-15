import 'dart:async';

import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

class AccountVerified extends StatefulWidget {
  const AccountVerified({Key? key}) : super(key: key);

  @override
  _AccountVerifiedState createState() => _AccountVerifiedState();
}

class _AccountVerifiedState extends State<AccountVerified> {

  late AuthProvider _authProvider;
  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
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

            ],
          ),

      ),


        Align(
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "account_verified.svg",
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                left: 16, right: 16, bottom: EvieLength.button_Bottom),
            child: SizedBox(
              width: double.infinity,
              child:   EvieButton(
                width: double.infinity,
                child: Text(
                  "Let's Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
                onPressed: () async {
                  _authProvider.setIsFirstLogin(true);
                  changeToLetsGoScreen(context);
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

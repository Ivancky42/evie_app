
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../widgets/evie_appbar.dart';
import 'package:evie_test/widgets/evie_button.dart';

class AccountVerified extends StatefulWidget {
  const AccountVerified({super.key});

  @override
  _AccountVerifiedState createState() => _AccountVerifiedState();
}

class _AccountVerifiedState extends State<AccountVerified> {

  late AuthProvider _authProvider;
  late CurrentUserProvider _userProvider;
  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _userProvider = Provider.of<CurrentUserProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
        appBar: EvieAppbar_Back(enabled: false, onPressed: (){ showQuitApp();}),
        body: Stack(
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
                        "Account Verified!",
                        style: EvieTextStyles.h2,
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        "Awesome ${_userProvider.currentUserModel!.name}! You're ready to go. Let's start by registering your bike so you can have a smooth and seamless riding experience.",
                        style: EvieTextStyles.body18,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      EvieButton(
                        width: double.infinity,
                        child: Text(
                          "Register My Bike",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          _authProvider.setIsFirstLogin(true);
                          changeToBeforeYouStart(context);
                        },
                      ),
                      SizedBox(height: 11.h,),
                      GestureDetector (
                        child: Text(
                          "Maybe Later",
                          softWrap: false,
                          style: EvieTextStyles.body18_underline,
                        ),
                        onTap: () {
                          _authProvider.setIsFirstLogin(false);
                          changeToUserHomePageScreen(context);
                        },
                      ),
                    ],
                  )
                ],
              )
          ),
            Align(
              alignment: Alignment.center,
              child: Lottie.asset('assets/animations/account-verify.json', repeat: false),
            ),
          ]
        )
      ),
    );
  }
}

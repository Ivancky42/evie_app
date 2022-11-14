import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/screen/onboarding/turn_on_bluetooth.dart';
import 'package:evie_test/screen/onboarding/turn_on_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/location_provider.dart';

class LetsGo extends StatefulWidget {
  const LetsGo({Key? key}) : super(key: key);

  @override
  _LetsGoState createState() => _LetsGoState();
}

class _LetsGoState extends State<LetsGo> {
  late CurrentUserProvider _currentUserProvider;
  late LocationProvider _locationProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    var currentName = _currentUserProvider.currentUserModel?.name;

    return Scaffold(
        body: Stack(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.h,
            ),
            Text(
              //  "Hi ${_currentUserProvider.currentUserModel!.name}, thanks for choosing EVIE!",
              "Hi $currentName, thanks for choosing EVIE!",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              "Let's connect to your bike and personalize your account.",
              style: TextStyle(fontSize: 11.5.sp,height: 0.17.h),
            ),
          ],
        ),
      ),
      const Align(
        alignment: Alignment.center,
        child: Image(
          image: AssetImage("assets/images/setup_account.png"),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, bottom: EvieLength.button_Bottom),
          child: SizedBox(
            width: double.infinity,
            child: EvieButton(
              width: double.infinity,
              child: Text(
                "Let's Go",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
              onPressed: () {
                changeToTurnOnLocationScreen(context);
              },
            ),
          ),
        ),
      ),
    ]));
  }
}

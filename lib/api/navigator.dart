import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_account/my_account.dart';
import 'package:evie_test/screen/onboarding/email_preference_control.dart';
import 'package:evie_test/screen/onboarding/lets_go.dart';
import 'package:evie_test/screen/onboarding/name_bike.dart';
import 'package:evie_test/screen/onboarding/qr_add_manually.dart';
import 'package:evie_test/screen/onboarding/turn_on_QRScanner.dart';
import 'package:evie_test/screen/onboarding/turn_on_bluetooth.dart';
import 'package:evie_test/screen/onboarding/turn_on_location.dart';
import 'package:evie_test/screen/onboarding/turn_on_notifications.dart';
import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screen/onboarding/bike_connect_failed.dart';
import '../screen/onboarding/bike_connect_success.dart';
import '../screen/onboarding/congratulation.dart';
import '../screen/onboarding/display_control.dart';
import '../screen/onboarding/notification_control.dart';
import '../screen/onboarding/qr_scanning.dart';
import '../screen/signup_method.dart';
import '../screen/signup_page.dart';
import '../screen/user_notification_details.dart';
import 'model/bike_model.dart';
import 'model/plan_model.dart';
import 'model/price_model.dart';

void changeToWelcomeScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/welcome", (route) => false);
}

void changeToInputNameScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/inputName", (route) => false);
}

void changeToSignUpMethodScreen(BuildContext context, name) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SignUpMethod(name))
  );
}

void changeToSignUpScreen(BuildContext context, name) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => SignUp(name))
  );
}

void changeToCheckYourEmailScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/checkMail", (route) => false);
}

void changeToAccountVerifiedScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/accountVerified", (route) => false);
}

void changeToVerifyEmailScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => VerifyEmail())
  );
}

changeToSignInMethodScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/signInMethod", (route) => false);
}

void changeToSignInScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/signIn", (route) => false);
}

void changeToForgetPasswordScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/forgetPassword", (route) => false);
}

void changeToUserProfileScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/userProfile", (route) => false);
}

void changeToUserHomePageScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/userHomePage", (route) => false);
}

void changeToUserBluetoothScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/userBluetooth", (route) => false);
}

void changeToChangePasswordScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/userChangePassword", (route) => false);
}

void changeToShareBikeScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/shareBike", (route) => false);
}

void changeToNotificationScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/notification", (route) => false);
}

void changeToTestBLEScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => const TestBle()),
  );
}

void changeToRFIDScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/rfid", (route) => false);
}

void changeToLetsGoScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const LetsGo())
  );
}

void changeToCongratulationScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const Congratulation(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToNameBikeScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const NameBike(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToTurnOnBluetoothScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const TurnOnBluetooth(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToTurnOnLocationScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const TurnOnLocation(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToTurnOnQRScannerScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const TurnOnQRScanner(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToQRScanningScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const QRScanning(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}
void changeToQRAddManuallyScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const QRAddManually(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToTurnOnNotificationsScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const TurnOnNotifications(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToBikeConnectSuccessScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const BikeConnectSuccess(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToBikeConnectFailedScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const BikeConnectFailed(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToNotificationsControlScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const NotificationsControl(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToEmailPreferenceControlScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const EmailPreferenceControl(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}
void changeToDisplayControlScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const DisplayControl(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}


void changeToEditProfile(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil("/editProfile", (route) => false);
  }

void changeToVerifyPassword(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/verifyPassword", (route) => false);
}

void changeToEnterNewPassword(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/enterNewPassword", (route) => false);
}


void changeToMyAccount(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/myAccount", (route) => false);
}


///Future builder
void changeToNotificationDetailsScreen(BuildContext context, key, value) {
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => UserNotificationDetails(key, value)),
  );
}

void changeToStripeCheckoutScreen(
    BuildContext context,
    String value,
    BikeModel bikeModel,
    PlanModel planModel,
    PriceModel priceModel) {
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => StripeCheckoutScreen(
      sessionId: value,
      bikeModel: bikeModel,
      planModel: planModel,
      priceModel: priceModel,
    )),
  );
}


void changeToTestScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const NameBike())
  );
}

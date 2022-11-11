import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screen/signup_method.dart';
import '../screen/signup_page.dart';
import '../screen/user_notification_details.dart';

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

void changeToVerifyEmailScreen(BuildContext context, email) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => VerifyEmail(email))
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
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => const TestBle()),
  );
}

void changeToRFIDScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/rfid", (route) => false);
}


///Future builder
void changeToNotificationDetailsScreen(BuildContext context, key, value) {
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => UserNotificationDetails(key, value)),
  );
}

void changeToStripeCheckoutScreen(BuildContext context, value) {
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => StripeCheckoutScreen(sessionId: value,)),
  );
}



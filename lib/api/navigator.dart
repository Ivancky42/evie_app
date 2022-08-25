import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

changeToSignInScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/signIn", (route) => false);
}

void changeToSignUpScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/signUp", (route) => false);
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

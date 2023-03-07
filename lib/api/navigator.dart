import 'package:evie_test/screen/my_account/my_garage/my_garage.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/detection_sensitivity.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_information.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_update_failed.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/motion_sensitivity.dart';

import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_set_colour_code.dart';


import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/user_home_page/user_home_page.dart';
import 'package:evie_test/screen/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screen/check_your_email.dart';
import '../screen/feeds/feeds.dart';
import '../screen/forget_your_password.dart';
import '../screen/my_account/account/my_account.dart';
import '../screen/my_account/push_notification/push_notification.dart';
import '../screen/my_bike_setting/about_bike/about_bike.dart';
import '../screen/my_bike_setting/bike_setting/bike_setting.dart';
import '../screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import '../screen/my_bike_setting/firmware/firmware_update_completed.dart';
import '../screen/my_bike_setting/reset_bike/reset_bike.dart';
import '../screen/my_bike_setting/rfid_card/register_ev_key.dart';
import '../screen/my_bike_setting/rfid_card/name_ev.dart';
import '../screen/my_bike_setting/rfid_card/ev_add_failed.dart';
import '../screen/my_bike_setting/rfid_card/ev_key.dart';
import '../screen/my_bike_setting/rfid_card/ev_key_list.dart';
import '../screen/my_bike_setting/share_bike/invitation_sent.dart';
import '../screen/my_bike_setting/share_bike/share_bike.dart';
import '../screen/my_bike_setting/share_bike/share_bike_invitation.dart';
import '../screen/my_bike_setting/share_bike/share_bike_user_list.dart';
import '../screen/my_bike_setting/share_bike/user_not_found.dart';
import '../screen/my_bike_setting/sos_center/sos_center.dart';
import '../screen/my_bike_setting/subscription/current_plan.dart';
import '../screen/my_bike_setting/subscription/manage_plan.dart';

import '../screen/onboarding_addNewBike/bike_connect_failed.dart';
import '../screen/onboarding_addNewBike/bike_connect_success.dart';
import '../screen/onboarding_addNewBike/congrats_bike_added.dart';
import '../screen/onboarding_addNewBike/email_preference_control.dart';
import '../screen/onboarding_addNewBike/stay_close_to_bike.dart';
import '../screen/onboarding_addNewBike/name_bike.dart';
import '../screen/onboarding_addNewBike/qr_add_manually.dart';
import '../screen/onboarding_addNewBike/qr_scanning.dart';
import '../screen/onboarding_addNewBike/turn_on_QRScanner.dart';
import '../screen/onboarding_addNewBike/turn_on_bluetooth.dart';
import '../screen/onboarding_addNewBike/turn_on_location.dart';
import '../screen/onboarding_addNewBike/turn_on_notifications.dart';
import '../screen/signup_method.dart';
import '../screen/signup_page.dart';

import '../abandon/user_notification_details.dart';
import '../test/test.dart';
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

void changeToChangePasswordScreen(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/userChangePassword", (route) => false);
}

void changeToSharesBikeScreen(BuildContext context) {
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


void changeToUserHomePageScreen(BuildContext context ) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      child: const UserHomePage(0),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToCheckYourEmail(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const CheckYourEmail(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToTripHistory(BuildContext context){
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      child: const UserHomePage(1),
      duration: const Duration(milliseconds: 300),
    ),
  );
}
void changeToStayCloseToBike(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const StayCloseToBike())
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


void changeToEmailPreferenceControlScreen(BuildContext context) {
  Navigator.pushReplacement(context,
  PageTransition(
    type: PageTransitionType.rightToLeft,
    child: const EmailPreferenceControl(),
    duration: const Duration(milliseconds: 300),
  ),
  );
}

void changeToCongratsBikeAdded(BuildContext context, String bikeName) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: CongratsBikeAdded(bikeName),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToMyGarageScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const MyGarage(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToBikeSetting(BuildContext context, [String? source]) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child:  BikeSetting(source),
      duration: const Duration(milliseconds: 300),
    ),
  );
}



void changeToEVKey(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const EVKey(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToAddNewEVKey(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const RegisterEVKey(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToNameEVKey(BuildContext context, String rfidNumber) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: NameEV(rfidNumber),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

// void changeToEVColourCode(BuildContext context, String rfidNumber) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: EVColourCode(rfidNumber),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }

void changeToEVKeyList(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const EVKeyList(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToEVAddFailed(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const EVAddFailed(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToMotionSensitivityScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const MotionSensitivity(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToDetectionSensitivityScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const DetectionSensitivity(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToBikeStatusAlertScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const BikeStatusAlert(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToResetBike(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ResetBike(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToSOSCenterScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const SOSCenter(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToCurrentPlanScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const CurrentPlan(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToManagePlanScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ManagePlan(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToMyAccount(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const UserHomePage(3),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToPushNotification(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const PushNotification(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

// void changeToEmailNewsletter(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const EmailNewsletter(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }

void changeToAboutBike(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const AboutBike(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToFirmwareInformation(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const FirmwareInformation(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToFirmwareUpdateCompleted(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const FirmwareUpdateCompleted(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToFirmwareUpdateFailed(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const FirmwareUpdateFailed(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}



void changeToShareBikeScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ShareBike(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToShareBikeInvitationScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ShareBikeInvitation(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToInvitationSentScreen(BuildContext context, String email) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child:  InvitationSent(email),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToUserNotFoundScreen(BuildContext context, String email) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: UserNotFound(email),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToShareBikeUserListScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ShareBikeUserList(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToFeedsScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const UserHomePage(2),
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


///Future builder
// void changeToNotificationDetailsScreen(BuildContext context, key, value) {
//   Navigator.push(context,
//     MaterialPageRoute(builder: (context) => UserNotificationDetails(key, value)),
//   );
// }

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
      builder: (context) => const Test())
  );
}

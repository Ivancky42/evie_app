import 'dart:collection';

import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/screen/feeds/accepting_invitation.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/screen/my_account/my_garage/my_garage.dart';
import 'package:evie_test/screen/my_account/revoke_account/revoke_account.dart';
import 'package:evie_test/screen/my_account/verify_password.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/detection_sensitivity.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_information.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_update_failed.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/motion_sensitivity.dart';

import 'package:evie_test/screen/my_account/edit_profile.dart';
//import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_set_colour_code.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/pro_plan/pro_plan.dart';

import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/trip_history/ride_history.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_bike_recovered.dart';
import 'package:evie_test/screen/user_home_page/user_home_page.dart';
import 'package:evie_test/screen/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';

import '../screen/account_verified.dart';
import '../screen/check_your_email.dart';
import '../screen/feeds/feeds.dart';
import '../screen/forget_your_password.dart';
import '../screen/input_name.dart';
import '../screen/login_method.dart';
import '../screen/my_account/account/my_account.dart';
import '../screen/my_account/display_setting/display_setting.dart';
import '../screen/my_account/enter_new_password.dart';
import '../screen/my_account/push_notification/push_notification.dart';
import '../screen/my_account/revoke_account/revoked_account.dart';
import '../screen/my_account/revoke_account/revoking_account.dart';
import '../screen/my_bike_setting/about_bike/about_bike.dart';
import '../screen/my_bike_setting/bike_setting/bike_setting.dart';
import '../screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import '../screen/my_bike_setting/firmware/firmware_update_completed.dart';
import '../screen/my_bike_setting/pedal_pals/invitation_sent.dart';
import '../screen/my_bike_setting/pedal_pals/pedal_pals.dart';
import '../screen/my_bike_setting/pedal_pals/pedal_pals_list.dart';
import '../screen/my_bike_setting/pedal_pals/share_bike_invitation.dart';
import '../screen/my_bike_setting/pedal_pals/user_not_found.dart';
import '../screen/my_bike_setting/reset_bike/reset_bike.dart';
import '../screen/my_bike_setting/rfid_card/register_ev_key.dart';
import '../screen/my_bike_setting/rfid_card/name_ev.dart';
import '../screen/my_bike_setting/rfid_card/ev_add_failed.dart';
import '../screen/my_bike_setting/rfid_card/ev_key.dart';
import '../screen/my_bike_setting/rfid_card/ev_key_list.dart';
import '../screen/my_bike_setting/sos_center/sos_center.dart';

import '../screen/onboarding_addNewBike/bike_connect_failed.dart';
import '../screen/onboarding_addNewBike/bike_connect_success.dart';
import '../screen/onboarding_addNewBike/congrats_bike_added.dart';
import '../screen/onboarding_addNewBike/email_preference_control.dart';
import '../screen/onboarding_addNewBike/before_you_start.dart';
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
import '../screen/signup_password.dart';
import '../screen/user_home_page/paid_plan/threat/threat_map.dart';
import '../screen/user_home_page/paid_plan/threat/threat_map.dart';
import '../screen/user_home_page/paid_plan/threat/threat_timeline.dart';
import '../test/test.dart';
import 'model/bike_model.dart';
import 'model/plan_model.dart';
import 'model/price_model.dart';

void changeToWelcomeScreen(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil("/welcome", (route) => false);
}

void changeToInputNameScreen(BuildContext context) {
  //Navigator.of(context).pushNamedAndRemoveUntil("/inputName", (route) => false);

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return InputName();
    },
  ));
}

void changeToSignUpMethodScreen(BuildContext context, name) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //         builder: (context) => SignUpMethod(name))
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return SignUpMethod(name);
    },
  ));
}


void changeToSignUpScreen(BuildContext context, name) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => SignUp(name))
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return SignUp(name);
    },
  ));
}

void changeToSignUpPasswordScreen(BuildContext context, name, email) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => SignUpPassword(name, email))
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return SignUpPassword(name, email);
    },
  ));
}
void changeToAccountVerifiedScreen(BuildContext context) {
  //Navigator.of(context).pushNamedAndRemoveUntil("/accountVerified", (route) => false);

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return AccountVerified();
    },
  ));
}

void changeToVerifyEmailScreen(BuildContext context) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => VerifyEmail())
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return VerifyEmail();
    },
  ));
}

changeToSignInMethodScreen(BuildContext context) {
  //Navigator.of(context).pushNamedAndRemoveUntil("/signInMethod", (route) => false);

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return SignInMethod();
    },
  ));
}

// void changeToSignUpPasswordScreen(BuildContext context) {
//   Navigator.of(context).pushNamedAndRemoveUntil("/signUpPassword", (route) => false);
// }


void changeToSignInScreen(BuildContext context) {
  //Navigator.of(context).pushNamedAndRemoveUntil("/signIn", (route) => false);
  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return SignIn();
    },
  ));
}

void changeToForgetPasswordScreen(BuildContext context) {
  //Navigator.of(context).pushNamedAndRemoveUntil("/forgetPassword", (route) => false);

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return ForgetYourPassword();
    },
  ));
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
  Navigator.of(context).pushNamedAndRemoveUntil("/notification", (route) => false);
}

void changeToTestBLEScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    MaterialWithModalsPageRoute(builder: (context) => const TestBle()),
  );
}

void changeToUserHomePageScreen(BuildContext context ) {
  // Navigator.of(context).pushReplacement(
  //     MaterialWithModalsPageRoute(builder: (context) => UserHomePage(0)));
  Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
}

void changeToUserHomePageScreen2(BuildContext context) {

  Navigator.of(context).pushReplacement(
      MaterialWithModalsPageRoute(builder: (context) => UserHomePage(0)));

  // Navigator.pushReplacement(context,
  //   PageTransition(
  //     type: PageTransitionType.bottomToTop,
  //     child: const UserHomePage(0),
  //     duration: const Duration(milliseconds: 300),
  //   ),
  // );

  //Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);

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
      child: const TripHistory(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToFeedsScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
      builder: (context) => const UserHomePage(1))
  );
  // Navigator.of(context).pushNamedAndRemoveUntil("/feeds", (route) => false);
}


void changeToRideHistory(BuildContext context, String tripId, TripHistoryModel currentTripHistoryList){
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      child:  RideHistory(tripId, currentTripHistoryList),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToBeforeYouStart(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
      builder: (context) => const BeforeYouStart())
  );

  // Navigator.of(context).push(CupertinoPageRoute(
  //   builder: (context) {
  //     return BeforeYouStart();
  //   },
  // ));
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

void changeToThreatBikeRecovered(BuildContext context) {
  // Navigator.pushReplacement(context,
  //   PageTransition(
  //     type: PageTransitionType.rightToLeft,
  //     child: const ThreatBikeRecovered(),
  //     duration: const Duration(milliseconds: 300),
  //   ),
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return ThreatBikeRecovered();
    },
  ));
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


// void changeToBikeSetting(BuildContext context, [String? source]) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child:  BikeSetting(source),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }



// void changeToEVKey(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const EVKey(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }
//
// void changeToAddNewEVKey(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const RegisterEVKey(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }
//
// void changeToNameEVKey(BuildContext context, String rfidNumber) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: NameEV(rfidNumber),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }
//
// void changeToEVKeyList(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const EVKeyList(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }
//
// void changeToEVAddFailed(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const EVAddFailed(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }

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

// void changeToCurrentPlanScreen(BuildContext context) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: const CurrentPlan(),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }



void changeToProPlanScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const ProPlan(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToMyAccount(BuildContext context, Widget child) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.leftToRight,
      child: UserHomePage(2),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToEditProfile(BuildContext context) {
  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return EditProfile();
    },
  ));
}


void changeToPushNotification(BuildContext context) {
  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return PushNotification();
    },
  ));
}

void changeToDisplaySetting(BuildContext context) {
  // Navigator.pushReplacement(context,
  //   PageTransition(
  //     type: PageTransitionType.rightToLeft,
  //     child: const DisplaySetting(),
  //     duration: const Duration(milliseconds: 300),
  //   ),
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return DisplaySetting();
    },
  ));
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
      child: const PedalPals(),
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

void changeToAcceptingInvitationScreen(BuildContext context, deviceIMEI, currentUid, notificationId) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: AcceptingInvitation(deviceIMEI: deviceIMEI, currentUid: currentUid, notificationId: notificationId),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

// void changeToInvitationSentScreen(BuildContext context, String email) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child:  InvitationSent(email),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }

// void changeToUserNotFoundScreen(BuildContext context, String email) {
//   Navigator.pushReplacement(context,
//     PageTransition(
//       type: PageTransitionType.rightToLeft,
//       child: UserNotFound(email),
//       duration: const Duration(milliseconds: 300),
//     ),
//   );
// }

void changeToShareBikeUserListScreen(BuildContext context) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: const PedalPalsList(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToThreatMap(BuildContext context, isTriggerConnect, [PageTransitionType? pageTransitionType]) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: pageTransitionType ?? PageTransitionType.bottomToTop,
      child: ThreatMap(isTriggerConnect),
      duration: const Duration(milliseconds: 300),
    ),
  );
}


void changeToThreatTimeLine(BuildContext context, [PageTransitionType? pageTransitionType]) {
  Navigator.pushReplacement(context,
    PageTransition(
      type: pageTransitionType ?? PageTransitionType.bottomToTop,
      child: ThreatTimeLine(),
      duration: const Duration(milliseconds: 300),
    ),
  );
}

void changeToVerifyPassword(BuildContext context) {
  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return VerifyPassword();
    },
  ));
}

void changeToEnterNewPassword(BuildContext context) {
  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return EnterNewPassword();
    },
  ));
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
    MaterialWithModalsPageRoute(builder: (context) => StripeCheckoutScreen(
      sessionId: value,
      bikeModel: bikeModel,
      planModel: planModel,
      priceModel: priceModel,
    )),
  );
}


void changeToTestScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
      builder: (context) => const BorderPaint())
  );
}

void changeToRevokeAccount(BuildContext context) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => const RevokeAccount())
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return RevokeAccount();
    },
  ));
}

void changeToRevokingAccount(BuildContext context) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => const RevokingAccount())
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return RevokingAccount();
    },
  ));
}

void changeToRevokedAccount(BuildContext context) {
  // Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(
  //     builder: (context) => const RevokedAccount())
  // );

  Navigator.of(context).push(CupertinoPageRoute(
    builder: (context) {
      return RevokedAccount();
    },
  ));
}

void back(context, child) {
  Navigator.pop(context,
    PageTransition(
      type: PageTransitionType.leftToRight,
      child: child,
      duration: const Duration(milliseconds: 300),
    ),
  );
}

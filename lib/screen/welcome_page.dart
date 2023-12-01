import 'dart:io';

import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/length.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/current_user_provider.dart';
import '../widgets/evie_button.dart';
import '../widgets/evie_single_button_dialog.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _currentUserProvider = context.read<CurrentUserProvider>();
    _authProvider.init();
  }

  @override
  Widget build(BuildContext context) {

    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },

    child:  Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 136.h,
                ),
                Image(
                  image: AssetImage("assets/logo/evie_logo_2.png",),
                  width: 203.w,
                  height: 50.h,),
                //
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  'Ride Smarter',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: Container(
                //     width: 364.1.w,
                //     height: 218.04.h,
                //     alignment: Alignment.bottomRight,
                //     child: const Image(
                //       image: AssetImage("assets/images/evie_bike_shadow_2.png"),
                //     ),
                //   ),
                // ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 435.w,
                    height: 245.h,
                    alignment: Alignment.bottomRight,
                    child: Image.asset('assets/images/evie_bike_shadow_3.png'),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                  child: Column(
                    children: [
                      EvieButton(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage("assets/icons/logo_email.png"),
                              height: 24.0,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              "Sign Up with Email",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          changeToInputNameScreen(context);
                        },
                      ),
                      Platform.isIOS ?
                      Column(
                        children: [
                          SizedBox(
                            height: 8.h,
                          ),
                          EvieButton(
                              backgroundColor: Color(0xffDFE0E0),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // const Image(
                                  //   image: AssetImage("assets/icons/logo_apple.png"),
                                  //   height: 20.0,
                                  // ),
                                  SvgPicture.asset("assets/icons/logo_apple.svg"),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    "Continue with Apple",
                                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                _authProvider.signInWithAppleID("").then((result) async {
                                  if (result.containsKey(SignInStatus.isNewUser)) {
                                    _currentUserProvider.getDeviceInfo();
                                    changeToAccountRegisterScreen(context);
                                  }
                                  else if (result.containsKey(SignInStatus.registeredUser)) {
                                    _currentUserProvider.getDeviceInfo();
                                    final hasBike = await _bikeProvider.checkHasBike(_authProvider.getUid);
                                    if (!hasBike) {
                                      changeToBeforeYouStart(context);
                                    }
                                    else {
                                      final hasBike = await _bikeProvider.checkHasBike(_authProvider.getUid);
                                      if (!hasBike) {
                                        changeToBeforeYouStart(context);
                                      }
                                      else {
                                        changeToUserHomePageScreen(context);
                                      }
                                    }
                                  }
                                  else if (result.containsKey(SignInStatus.error)) {
                                    SmartDialog.show(
                                        widget: EvieSingleButtonDialog(
                                            title: "Error",
                                            content: result[SignInStatus.error],
                                            rightContent: "Retry",
                                            onPressedRight: () {
                                              SmartDialog.dismiss();
                                            }));
                                  }
                                  else if (result.containsKey(SignInStatus.failed)) {
                                    SmartDialog.show(
                                        widget: EvieSingleButtonDialog(
                                            title: "Error",
                                            content: result[SignInStatus.failed],
                                            rightContent: "Retry",
                                            onPressedRight: () {
                                              SmartDialog.dismiss();
                                            }));
                                  }
                                });
                              }),
                        ],
                      ) : Container(),
                      SizedBox(
                        height: 8.h,
                      ),
                      EvieButton(
                          backgroundColor: EvieColors.lightGrayishCyan,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Image(
                              //   image: AssetImage("assets/icons/logo_facebook.png"),
                              //   height: 24.0,
                              // ),
                              SvgPicture.asset("assets/icons/logo_facebook.svg"),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                "Continue with Facebook",
                                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            _authProvider.signInWithFacebook("").then((loginStatus) async {
                              if (loginStatus.containsKey(SignInStatus.isNewUser)) {
                                _currentUserProvider.getDeviceInfo();
                                changeToAccountRegisterScreen(context);
                              }
                              else if (loginStatus.containsKey(SignInStatus.registeredUser)) {
                                _currentUserProvider.getDeviceInfo();
                                final hasBike = await _bikeProvider.checkHasBike(_authProvider.getUid);
                                if (!hasBike) {
                                  changeToBeforeYouStart(context);
                                }
                                else {
                                  changeToUserHomePageScreen(context);
                                }
                              }
                              else if (loginStatus.containsKey(SignInStatus.error)) {
                                SmartDialog.show(
                                    widget: EvieSingleButtonDialog(
                                        title: "Error",
                                        content: loginStatus[SignInStatus.error],
                                        rightContent: "Retry",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                              else if (loginStatus.containsKey(SignInStatus.failed)) {
                                SmartDialog.show(
                                    widget: EvieSingleButtonDialog(
                                        title: "Error",
                                        content: loginStatus[SignInStatus.failed],
                                        rightContent: "Retry",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                            });
                          }),
                      SizedBox(
                        height: 8.h,
                      ),
                      EvieButton(
                          backgroundColor: EvieColors.lightGrayishCyan,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Image(
                              //   image: AssetImage("assets/icons/logo_google.png"),
                              //   height: 24.0,
                              // ),
                              SvgPicture.asset("assets/icons/logo_google.svg"),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                "Continue with Google",
                                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            _authProvider.signInWithGoogle("").then((result) async {
                              if (result.containsKey(SignInStatus.isNewUser)) {
                                _currentUserProvider.getDeviceInfo();
                                changeToAccountRegisterScreen(context);
                              }
                              else if (result.containsKey(SignInStatus.registeredUser)) {
                                _currentUserProvider.getDeviceInfo();
                                final hasBike = await _bikeProvider.checkHasBike(_authProvider.getUid);
                                if (!hasBike) {
                                  changeToBeforeYouStart(context);
                                }
                                else {
                                  changeToUserHomePageScreen(context);
                                }
                              }
                              else if (result.containsKey(SignInStatus.error)) {
                                    SmartDialog.show(
                                        widget: EvieSingleButtonDialog(
                                            title: "Error",
                                            content: result[SignInStatus.error],
                                            rightContent: "Retry",
                                            onPressedRight: () {
                                              SmartDialog.dismiss();
                                            }));
                              }
                              else if (result.containsKey(SignInStatus.failed)) {
                                SmartDialog.show(
                                    widget: EvieSingleButtonDialog(
                                        title: "Error",
                                        content: result[SignInStatus.failed],
                                        rightContent: "Retry",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }
                            });
                          }),
                      Container(
                        width: double.infinity,
                        child: RawMaterialButton(
                          elevation: 0.0,
                          padding: EdgeInsets.fromLTRB(0, 23.5.h, 0, 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          onPressed: () {
                            changeToSignInScreen(context);
                          },
                          child: Text(
                              "Log in with Email",
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w800, decoration: TextDecoration.underline,)),
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

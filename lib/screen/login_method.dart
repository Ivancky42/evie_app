import 'dart:io';

import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_button.dart';
import '../widgets/evie_single_button_dialog.dart';

class SignInMethod extends StatefulWidget {
  const SignInMethod({Key? key}) : super(key: key);

  @override
  _SignInMethodState createState() => _SignInMethodState();
}

class _SignInMethodState extends State<SignInMethod> {
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late CurrentUserProvider _currentUserProvider;

  @override
  Widget build(BuildContext context) {

    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToWelcomeScreen(context);
        return true;
      },

      child:Scaffold(
        appBar: EvieAppbar_Back(onPressed: (){
          changeToWelcomeScreen(context);}),

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                Text("Welcome Back!",
                  style: EvieTextStyles.h2,),

                SizedBox(
                  height: 4.h,
                ),

                Text("Choose a method to log in to your account",
                  style: EvieTextStyles.body18,),

                SizedBox(
                  height: 2.h,
                ),

                EvieButton(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage("assets/icons/logo_email.png"),
                        height: 20.0,
                      ),
                      SizedBox(
                        width: 1.5.w,
                      ),
                      Text(
                        "Login with Email",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    changeToSignInScreen(context);
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
                            const Image(
                              image: AssetImage("assets/icons/logo_apple.png"),
                              height: 20.0,
                            ),
                            SizedBox(
                              width: 1.5.w,
                            ),
                            Text(
                              "Login with Apple",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          _authProvider.signInWithAppleID("").then((result) {
                            if (result.containsKey(SignInStatus.isNewUser)) {
                              _currentUserProvider.getDeviceInfo();
                              changeToAccountRegisterScreen(context);
                            }
                            else if (result.containsKey(SignInStatus.registeredUser)) {
                              _currentUserProvider.getDeviceInfo();
                              changeToUserHomePageScreen(context);
                            }
                            else if (result.containsKey(SignInStatus.error)) {
                              SmartDialog.show(
                                  widget: EvieSingleButtonDialog(
                                      title: "Error",
                                      content: result[SignInStatus.error],
                                      rightContent: "Ok",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }));
                            }
                            else if (result.containsKey(SignInStatus.failed)) {
                              SmartDialog.show(
                                  widget: EvieSingleButtonDialog(
                                      title: "Error",
                                      content: result[SignInStatus.failed],
                                      rightContent: "Ok",
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
                        const Image(
                          image: AssetImage("assets/icons/logo_google.png"),
                          height: 20.0,
                        ),
                        SizedBox(
                          width: 1.5.w,
                        ),
                        Text(
                          "Login with Google",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      _authProvider.signInWithGoogle("").then((result) {
                        if (result.containsKey(SignInStatus.isNewUser)) {
                          _currentUserProvider.getDeviceInfo();
                          changeToAccountRegisterScreen(context);
                        }
                        else if (result.containsKey(SignInStatus.registeredUser)) {
                          _currentUserProvider.getDeviceInfo();
                          changeToUserHomePageScreen(context);
                        }
                        else if (result.containsKey(SignInStatus.error)) {
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: result[SignInStatus.error],
                                  rightContent: "Ok",
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }));
                        }
                        else if (result.containsKey(SignInStatus.failed)) {
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: result[SignInStatus.failed],
                                  rightContent: "Ok",
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
                        const Image(
                          image: AssetImage("assets/icons/logo_facebook.png"),
                          height: 20.0,
                        ),
                        SizedBox(
                          width: 1.5.w,
                        ),
                        Text(
                          "Login with Facebook",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      _authProvider.signInWithFacebook("").then((loginStatus) {
                        if (loginStatus.containsKey(SignInStatus.isNewUser)) {
                          _currentUserProvider.getDeviceInfo();
                          changeToAccountRegisterScreen(context);
                        }
                        else if (loginStatus.containsKey(SignInStatus.registeredUser)) {
                          _currentUserProvider.getDeviceInfo();
                          changeToUserHomePageScreen(context);
                        }
                        else if (loginStatus.containsKey(SignInStatus.error)) {
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: loginStatus[SignInStatus.error],
                                  rightContent: "Ok",
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }));
                        }
                        else if (loginStatus.containsKey(SignInStatus.failed)) {
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: loginStatus[SignInStatus.failed],
                                  rightContent: "Ok",
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }));
                        }
                      });
                    }),


              ],
            ),
          ),
        ),
        //        ),
      ),
    );
  }
}

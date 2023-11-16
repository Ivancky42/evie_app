import 'dart:io';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/input_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/provider/auth_provider.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_button.dart';
import '../widgets/evie_single_button_dialog.dart';

class SignUpMethod extends StatefulWidget {
  final String name;

  const SignUpMethod(this.name, {Key? key}) : super(key: key);

  @override
  _SignUpMethodState createState() => _SignUpMethodState();
}

class _SignUpMethodState extends State<SignUpMethod> {

  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){ back(context, InputName());}),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top:16.h, bottom: EvieLength.screen_bottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.name}, let's setup your account",
                style: EvieTextStyles.h2,),
              SizedBox(
                height: 2.h,
              ),
              Text("Enter your email address",
                style: EvieTextStyles.body18,),
              SizedBox(
                height: 16.h,
              ),

              EvieButton(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(
                          "assets/icons/logo_email.png"),
                      height: 20.0,
                    ),
                    SizedBox(width: 1.5.w,),
                    Text(
                      "Continue with Email",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                    ),
                  ],
                ),
                onPressed: () async {
                  changeToSignUpScreen(context, widget.name);
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
                            image: AssetImage(
                                "assets/icons/logo_apple.png"),
                            height: 20.0,
                          ),
                          SizedBox(width: 1.5.w,),
                          Text(
                            "Continue with Apple",
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        _authProvider
                            .signInWithAppleID(widget.name)
                            .then((result) {
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
                      }
                  ),
                ],
              ) : Container(),
              SizedBox(height: 8.h,),
              EvieButton(
                  backgroundColor: EvieColors.lightGrayishCyan,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(
                            "assets/icons/logo_google.png"),
                        height: 20.0,
                      ),
                      SizedBox(width: 1.5.w,),
                      Text(
                        "Continue with Google",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithGoogle(widget.name)
                        .then((result) {
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
                  }
              ),
              SizedBox(height: 8.h,),
              EvieButton(
                  backgroundColor: EvieColors.lightGrayishCyan,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(
                            "assets/icons/logo_facebook.png"),
                        height: 20.0,
                      ),
                      SizedBox(width: 1.5.w,),
                      Text(
                        "Continue with Facebook",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithFacebook(widget.name)
                        .then((loginStatus) {
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
                  }
              ),


            ],
          ),
        ),
      ),
      //        ),
    );
  }
}

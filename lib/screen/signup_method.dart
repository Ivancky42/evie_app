import 'dart:io';

import 'package:evie_test/api/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../api/colours.dart';
import '../api/provider/auth_provider.dart';
import '../theme/ThemeChangeNotifier.dart';
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

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){ changeToInputNameScreen(context);}),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2.h,
              ),
              Text("${widget.name}, let's setup your account",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  )),

              SizedBox(
                height: 1.h,
              ),
              Text("Choose a method you would like to setup your account",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                  )),

              SizedBox(
                height: 2.h,
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
                      style: TextStyle(
                        color: Color(0xffECEDEB),
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  changeToSignUpScreen(context, widget.name);
                },
              ),


              Platform.isIOS ?
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
                        style: TextStyle(
                          color: Color(0xff7A7A79),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithAppleID(widget.name)
                        .then((result) {
                      if (result == true) {
                        changeToUserHomePageScreen(context);
                      } else {
                        SmartDialog.show(
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: result,
                                rightContent: "Ok",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                      }
                    });
                  }
              ) : Container(),

              EvieButton(
                  backgroundColor: Color(0xffDFE0E0),
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
                        style: TextStyle(
                          color: Color(0xff7A7A79),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithGoogle(widget.name)
                        .then((result) {
                      if (result == true) {
                        changeToUserHomePageScreen(context);
                      } else {
                        SmartDialog.show(
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: result,
                                rightContent: "Ok",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                      }
                    });
                  }
              ),
              EvieButton(
                  backgroundColor: Color(0xffDFE0E0),
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
                        style: TextStyle(
                          color: Color(0xff7A7A79),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithFacebook(widget.name)
                        .then((result) {
                      if (result == true) {
                        changeToUserHomePageScreen(context);
                      } else {
                        SmartDialog.show(
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: result,
                                rightContent: "Ok",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                      }
                    });
                  }
              ),
              EvieButton(
                  backgroundColor: Color(0xffDFE0E0),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(
                            "assets/icons/logo_twitter.png"),
                        height: 20.0,
                      ),
                      SizedBox(width: 1.5.w,),
                      Text(
                        "Continue with Twitter",
                        style: TextStyle(
                          color: Color(0xff7A7A79),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    _authProvider
                        .signInWithTwitter(widget.name)
                        .then((result) {
                      if (result == true) {
                        changeToUserHomePageScreen(context);
                      } else {
                        SmartDialog.show(
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: result,
                                rightContent: "Ok",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                      }
                    });
                  }
              ),

              Container(
                width: double.infinity,
                child: RawMaterialButton(
                  elevation: 0.0,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  onPressed: () {
                    changeToSignInMethodScreen(context);
                  },
                  child: Text(
                    "I already have an account",
                    style: TextStyle(
                      color: EvieColors.PrimaryColor,
                      fontSize: 10.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      //        ),
    );
  }
}

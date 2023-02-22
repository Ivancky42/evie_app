import 'dart:io';

import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import '../api/colours.dart';
import '../api/fonts.dart';
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
    return WillPopScope(
      onWillPop: () async {
        changeToInputNameScreen(context);
        return true;
      },

      child:  Scaffold(
        appBar: EvieAppbar_Back(onPressed: (){ changeToInputNameScreen(context);}),

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("${widget.name}, let's setup your account",
                  style: EvieTextStyles.h2,),

                SizedBox(
                  height: 4.h,
                ),
                Text("Choose a method you would like to setup your account",
                  style: EvieTextStyles.body18,),

                SizedBox(
                  height: 9.h,
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


              ],
            ),
          ),
        ),
        //        ),
      ),
    );
  }
}

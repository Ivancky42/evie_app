import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/navigator.dart';
import '../api/provider/notification_provider.dart';
import '../widgets/evie_single_button_dialog.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    ///Disable phone rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return const Scaffold(
      body: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthProvider _authProvider;
  late NotificationProvider _notificationProvider;

  //For user input password visibility true/false
  bool _isObscure = true;

  //Create form for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Center(
                        child: Text("Welcome Back",
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),

                    SizedBox(
                      height: 1.h,
                    ),

                    Container(
                      child: Center(
                        child: Text(
                          "Please sign in to your account",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 6.h,
                    ),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle:
                            TextStyle(fontSize: 10.sp, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0.1,
                              color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 1.6.h,
                    ),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle:
                              TextStyle(fontSize: 10.sp, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 0.1,
                                color: const Color(0xFFFFFFFF)
                                    .withOpacity(0.2)), //<-- SEE HERE
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              })),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 0.5.h,
                    ),

                    Container(
                      alignment: const Alignment(1, 0),
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: TextButton(
                          child: const Text('Forgot Password?'),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                                fontSize: 10.sp, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            changeToForgetPasswordScreen(context);
                          }),
                    ),

                    SizedBox(
                      height: 1.8.h,
                    ),

                    EvieButton_DarkBlue(
                      width: double.infinity,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar.
                        }
                        //Save to provider
                        _authProvider
                            .login(_emailController.text.trim(),
                                _passwordController.text.trim(), context)
                            .then((result) {
                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Success'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            ///Quit loading and go to user home page
                            changeToUserHomePageScreen(context);
                          } else {
                            SmartDialog.show(
                              ///put in front end
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: result.toString(),
                                  rightContent: "Ok",
                                  image: Image.asset(
                                    "assets/images/error.png",
                                    width: 36,
                                    height: 36,
                                  ),
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }),
                            );
                          }
                        });
                      },
                    ),

                    SizedBox(
                      height: 3.h,
                    ),

                    ///IOS
                    Platform.isIOS
                        ? Center(
                            child: ButtonBar(
                              mainAxisSize: MainAxisSize.min,
                              // this will take space as minimum as possible(to center)
                              children: <Widget>[
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/facebook_icon_black.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithFacebook()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                                SizedBox(
                                  height: 1.h,
                                ),
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/google_icon_colour.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithGoogle()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                                SizedBox(
                                  height: 1.h,
                                ),
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/apple_icon_black.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithAppleID()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                                SizedBox(
                                  height: 1.h,
                                ),
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/twitter_icon_black.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithTwitter()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                              ],
                            ),
                          )
                        :

                        ///Android
                        Center(
                            child: ButtonBar(
                              mainAxisSize: MainAxisSize.min,
                              // this will take space as minimum as possible(to center)
                              children: <Widget>[
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/facebook_icon_black.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithFacebook()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                                SizedBox(
                                  height: 1.h,
                                ),
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/google_icon_colour.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithGoogle()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });
                                    }),
                                SizedBox(
                                  height: 1.h,
                                ),
                                EvieButton_Square(
                                    width: 7.4.h,
                                    height: 7.4.h,
                                    child: const Image(
                                      image: AssetImage(
                                          "assets/icons/twitter_icon_black.png"),
                                      height: 20.0,
                                    ),
                                    onPressed: () async {
                                      _authProvider
                                          .signInWithTwitter()
                                          .then((result) {
                                        if (result == true) {
                                          changeToUserHomePageScreen(context);
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: result,
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

                    SizedBox(
                      height: 2.h,
                    ),

                    Container(
                      child: Center(
                        child: Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RawMaterialButton(
                        elevation: 0.0,
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        onPressed: () {
                          changeToSignUpScreen(context);
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF00B6F1),
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ]),
            ))));
  }
}

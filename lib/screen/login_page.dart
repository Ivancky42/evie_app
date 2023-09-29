import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/welcome_page.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/navigator.dart';
import '../api/provider/notification_provider.dart';
import '../widgets/evie_double_button_dialog.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  Widget? twoButton;

  //For user input password visibility true/false
  bool _isObscure = true;

  //Create form for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){ back(context, Welcome());}),
      body: Stack(children: [
        Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    //  mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Back!",
                        style: EvieTextStyles.h2,),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text("Enter your email address",
                        style: EvieTextStyles.body18,),
                      SizedBox(
                        height: 7.h,
                      ),
                      EvieTextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        labelText: "Email Address",
                        hintText: "Enter your email address",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }else if(!value.contains("@")){
                            return 'Looks like you entered the wrong email. The correct format for email address ad follow "sample@youremail.com". ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      EvieTextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        labelText: "Password",
                        hintText: "Enter your password",
                        suffixIcon:  IconButton(
                            icon:   _isObscure ?
                            const Image(
                              image: AssetImage("assets/buttons/view_off.png"),
                            ):
                            const Image(
                              image: AssetImage("assets/buttons/view_on.png"),
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            }),
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
                        padding: const EdgeInsets.only(left: 20),
                        child: TextButton(
                            child: Text(
                                "Forgot Password?",
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w900, decoration: TextDecoration.underline,)
                            ),
                            onPressed: () {
                              changeToForgetPasswordScreen(context);
                            }),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      EvieButton(
                        width: double.infinity,
                        child: Text(
                          "Log In",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            ///For keyboard un focus
                            FocusManager.instance.primaryFocus?.unfocus();

                            _authProvider
                                .login(_emailController.text.trim(),
                                _passwordController.text.trim())
                                .then((result) {

                              if (result.toString() == "Verified") {
                                _currentUserProvider.getDeviceInfo();
                                ///Quit loading and go to user home page
                                if(_authProvider.isFirstLogin == true){
                                  changeToBeforeYouStart(context);
                                }else{
                                  changeToUserHomePageScreen(context);
                                }

                              } else if (result.toString() == "Not yet verify") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verify your account'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                _currentUserProvider.getDeviceInfo();
                                changeToVerifyEmailScreen(context);
                              } else {

                                showErrorLoginDialog(context);
                              }
                            });
                          }

                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RawMaterialButton(
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          onPressed: () {
                            changeToInputNameScreen(context);
                          },
                          child: Text(
                            "I don't have an account yet",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
          ),
        ),
      ]),
    );
  }

}

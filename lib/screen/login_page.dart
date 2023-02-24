import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/navigator.dart';
import '../api/provider/notification_provider.dart';
import '../theme/ThemeChangeNotifier.dart';
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

  //For user input password visibility true/false
  bool _isObscure = true;

  //Create form for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToSignInMethodScreen(context);
        return true;
      },

      child:Scaffold(
        appBar: EvieAppbar_Back(onPressed: (){ changeToSignInMethodScreen(context);}),

        body: Stack(children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                //  mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Text("Welcome Back!",
                    style: EvieTextStyles.h2,),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text("Enter your email address",
                    style: EvieTextStyles.body18,),
                  SizedBox(
                    height: 1.h,
                  ),

                  EvieTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    labelText: "Email Address",
                    hintText: "enter your email address",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
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
                    hintText: "enter your password",
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
                    padding: const EdgeInsets.only(top: 10, left: 20),
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
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16, bottom: 64.0),
              child: EvieButton(
                width: double.infinity,
                child: Text(
                  "Log In",
                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar.
                  }
                  //Save to provider
                  _authProvider
                      .login(_emailController.text.trim(),
                          _passwordController.text.trim())
                      .then((result) {
                    if (result.toString() == "Verified") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Success'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      ///Quit loading and go to user home page
                      if(_authProvider.isFirstLogin == true){
                        changeToStayCloseToBike(context);
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
                      changeToVerifyEmailScreen(context);
                    } else {
                      SmartDialog.show(
                        widget: EvieSingleButtonDialogCupertino(
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
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16.0),
              child: SizedBox(
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
                    style: TextStyle(
                      color: EvieColors.primaryColor,
                      fontSize: 10.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

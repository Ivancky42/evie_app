import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/welcome_page.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/fonts.dart';
import '../api/navigator.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

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
  const Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;

  Widget? twoButton;

  //For user input password visibility true/false
  bool _isObscure = true;
  bool isFirst = true;

  //Create form for form validation
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordValid = false;

  bool containsLettersAndNumbers(String value) {
    ///check for letters and numbers
    final RegExp alphanumeric = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');
    return alphanumeric.hasMatch(value);
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){
        back(context, Welcome());
        //changeToWelcomeScreen(context);
      }),
      body: Form(
        key: _formKey,
        child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, EvieLength.target_reference_button_b),
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
                        setState(() {
                          isFirst = false;
                        });
                        if (value == null || value.isEmpty) {
                          return '';
                        }else if(!value.contains("@")){
                          return '';
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
                          SvgPicture.asset(
                            "assets/buttons/view_off.svg",
                          ):
                          SvgPicture.asset(
                            "assets/buttons/view_on.svg",
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                      validator: (value) {
                        setState(() {
                          isFirst = false;
                        });
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        if (value.length < 8) {
                          return '';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4.h,
                    ),

                    Text("Password must include:",
                        style: EvieTextStyles.body14),

                    SizedBox(
                      height: 7.5.h,
                    ),

                    /// Change image in real time if length is more than 8
                    Container(
                      //color: Colors.green,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // if (isFirst) ... {
                          //   SvgPicture.asset(
                          //     "assets/icons/grey_tick.svg",
                          //   ),
                          // }
                          // else ...{
                          //   if (_passwordController.text.length >= 8) ...{
                          //     SvgPicture.asset(
                          //       "assets/icons/check.svg",
                          //     ),
                          //   }
                          //   else ...{
                          //     SvgPicture.asset(
                          //       "assets/icons/fail.svg",
                          //     ),
                          //   },
                          // },

                          if (_passwordController.text.length >= 8) ...{
                            SvgPicture.asset(
                              "assets/icons/check.svg",
                            ),
                          }
                          else ...{
                            SvgPicture.asset(
                              "assets/icons/fail.svg",
                            ),
                          },

                          Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              "At least 8 characters.",
                              style: EvieTextStyles.body14,
                            ),
                          )
                        ],
                      ),
                    ),

                    /// Change image in real time if password has letters and numbers
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //
                        // if (isFirst) ... {
                        //   SvgPicture.asset(
                        //     "assets/icons/grey_tick.svg",
                        //   ),
                        // }
                        // else ...{
                        //   if (containsLettersAndNumbers(_passwordController.text))...{
                        //     SvgPicture.asset(
                        //       "assets/icons/check.svg",
                        //     ),
                        //   }
                        //   else ...{
                        //     SvgPicture.asset(
                        //       "assets/icons/fail.svg",
                        //     ),
                        //   },
                        // },

                        if (containsLettersAndNumbers(_passwordController.text))...{
                          SvgPicture.asset(
                            "assets/icons/check.svg",
                          ),
                        }
                        else ...{
                          SvgPicture.asset(
                            "assets/icons/fail.svg",
                          ),
                        },

                        // if (containsLettersAndNumbers(_passwordController.text))...{
                        //   SvgPicture.asset(
                        //     "assets/icons/check.svg",
                        //   ),
                        // }
                        // else if (isFirst)... {
                        //   SvgPicture.asset(
                        //     "assets/icons/grey_tick.svg",
                        //   ),
                        // }
                        // else...{
                        //   SvgPicture.asset(
                        //     "assets/icons/fail.svg",
                        //   ),
                        // },
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            "Contain letters and numbers.",
                            style: EvieTextStyles.body14,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: RichText(
                        text: TextSpan(
                          text: "Forgot Password?",
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: EvieColors.primaryColor, decoration: TextDecoration.underline, fontFamily: 'Avenir'),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              changeToForgetPasswordScreen(context);
                            },
                        ),
                      ),
                    )
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
                        setState(() {
                          isFirst = false;
                        });
                        if (_formKey.currentState!.validate()) {

                          ///For keyboard un focus
                          FocusManager.instance.primaryFocus?.unfocus();

                          _authProvider
                              .login(_emailController.text.trim(),
                              _passwordController.text.trim())
                              .then((result) async {

                            if (result.toString() == "Verified") {
                              _currentUserProvider.getDeviceInfo();
                              final hasBike = await _bikeProvider.checkHasBike(_authProvider.getUid);
                              changeToUserHomePageScreen(context);

                            } else if (result.toString() == "Not yet verify") {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text('Verify your account'),
                              //     duration: Duration(seconds: 2),
                              //   ),
                              // );
                              _currentUserProvider.getDeviceInfo();
                              changeToVerifyEmailScreen(context);
                            }
                            else if (result.toString() == 'wrong-password'){
                              showWrongPasswordDialog(context);
                            }
                            else if (result.toString() == 'user-not-found') {
                              showErrorLoginDialog(context);
                            }
                          });
                        }

                      },
                    ),
                    // SizedBox(height: 12.h,),
                    // RichText(
                    //   text: TextSpan(
                    //     text: "I don't have an account yet",
                    //     style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: EvieColors.primaryColor, decoration: TextDecoration.underline, fontFamily: 'Avenir'),
                    //     recognizer: TapGestureRecognizer()
                    //       ..onTap = () {
                    //         changeToInputNameScreen(context);
                    //       },
                    //   ),
                    // ),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }

}

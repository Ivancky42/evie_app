import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/signup_page.dart';
import 'package:evie_test/widgets/evie_checkbox.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/fonts.dart';
import '../api/function.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_single_button_dialog.dart';

///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUpPassword extends StatefulWidget {
  final String name;
  final String email;

  const SignUpPassword(this.name, this.email, {Key? key}) : super(key: key);

  @override
  _SignUpPasswordState createState() => _SignUpPasswordState();
}

class _SignUpPasswordState extends State<SignUpPassword> {
  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  //For user input password visibility true/false
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool isCheckTermsCondition = false;
  bool _isPasswordValid = false;


  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

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

    return Scaffold(
      ///ensure words do not collide when keyboard activated
      resizeToAvoidBottomInset: false,
      appBar: EvieAppbar_Back(onPressed: (){ back(context, SignUp(widget.name));}),
      ///on tap closes keyboard
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: EvieLength.screen_bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Create a password",
                              style: EvieTextStyles.h2,),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text("Try to create a password that’s not easy to guess.",
                              style: EvieTextStyles.body18,),
                            SizedBox(
                              height: 16.h,
                            ),
                            ///text field to prompt user to key in password
                            EvieTextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              labelText: "Password",
                              hintText: "Enter a password",
                              suffixIcon: IconButton(
                                icon: _isObscure ? SvgPicture.asset(
                                  "assets/buttons/view_off.svg",
                                ):
                                SvgPicture.asset(
                                  "assets/buttons/view_on.svg",
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),

                              ///red words under text field
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must have at least 8 characters';
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
                            Row(
                              children: [
                                if (_passwordController.text.length >= 8) ...{
                                  SvgPicture.asset(
                                    "assets/icons/check.svg",
                                  ),
                                } else ...{
                                  SvgPicture.asset(
                                    "assets/icons/grey_tick.svg",
                                  ),
                                },

                                Text(
                                  "At least 8 characters.",
                                  style: EvieTextStyles.body14,
                                ),
                              ],
                            ),

                            /// Change image in real time if password has letters and numbers
                            Row(
                              children: [
                                if (containsLettersAndNumbers(_passwordController.text))...{
                                  SvgPicture.asset(
                                    "assets/icons/check.svg",
                                  ),
                                } else...{
                                  SvgPicture.asset(
                                    "assets/icons/grey_tick.svg",
                                  ),
                                },
                                Text(
                                  "Contain letters and numbers.",
                                  style: EvieTextStyles.body14,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                                children: [
                                  EvieCheckBox(
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isCheckTermsCondition = value!;
                                        });
                                      },
                                      value: isCheckTermsCondition),
                                  Expanded(
                                    child: Container(
                                        child: RichText(
                                          text: TextSpan(
                                            text: "By creating an account, I accept EVIE's ",
                                            style: EvieTextStyles.body14.copyWith(color: Colors.black, fontFamily: 'Avenir'),
                                            children: [
                                              TextSpan(
                                                text: "terms of use",
                                                style: TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color: EvieColors.primaryColor, // Change to your desired color
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    const url = 'https://eviebikes.com/policies/terms-of-service';
                                                    final Uri _url = Uri.parse(url);
                                                    launch(_url);
                                                  },
                                              ),
                                              TextSpan(
                                                text: " and ",
                                                style: EvieTextStyles.body14.copyWith(color: Colors.black, fontFamily: 'Avenir'),
                                              ),
                                              TextSpan(
                                                text: "privacy policy",
                                                style: TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color: EvieColors.primaryColor, // Change to your desired color
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    const url = 'https://eviebikes.com/policies/privacy-policy';
                                                    final Uri _url = Uri.parse(url);
                                                    launch(_url);
                                                  },
                                              ),
                                            ],
                                          ),
                                        ),
                                    ),
                                  ),
                                ]),
                            SizedBox(height: 12.h,),
                            EvieButton(
                              width: double.infinity,
                              child: Text(
                                "Create Account",
                                style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                              ),
                              ///conditions for button to be active
                              onPressed: isCheckTermsCondition == true && _passwordController.text.length >= 8 && containsLettersAndNumbers(_passwordController.text) ? () async {
                                if (_formKey.currentState!.validate()) {
                                  ///For keyboard un focus
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  String? result = await _authProvider.signUp(widget.email, _passwordController.text.trim(), widget.name, "empty");
                                  if (result == 'Success') {
                                    _authProvider.setIsFirstLogin(true);
                                    await _authProvider.login(widget.email,_passwordController.text.trim()).then((result) {
                                      if (result.toString() == "Verified") {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Success'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        ///Quit loading and go to user home page
                                        changeToBeforeYouStart(context);
                                      }
                                      else if (result.toString() == "Not yet verify") {
                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(
                                        //     content: Text('Verify your account'),
                                        //     duration: Duration(seconds: 2),
                                        //   ),
                                        // );
                                        changeToVerifyEmailScreen(context);

                                        _currentUserProvider.getDeviceInfo();
                                      }
                                    });
                                  }
                                  else if (result == 'email-already-in-use') {
                                    SmartDialog.show(
                                      widget: EvieSingleButtonDialog(
                                          title: "Error",
                                          content: 'The email address is already in use by another account.',
                                          rightContent: "Login Now",
                                          onPressedRight: () {
                                            SmartDialog.dismiss();
                                            changeToSignInScreen(context);
                                          }),
                                    );
                                  }
                                  else {
                                    SmartDialog.show(
                                      widget: EvieSingleButtonDialogOld(
                                          title: "Error",
                                          content: "Try again",
                                          rightContent: "Ok",
                                          widget: Image.asset(
                                            "assets/images/error.png",
                                            width: 36,
                                            height: 36,
                                          ),
                                          onPressedRight: () {
                                            SmartDialog.dismiss();
                                          }),
                                    );
                                  }
                                }
                                ///null to disable button when conditions are not met
                              } : null
                            ),
                          ],
                        )
                      ],
                    )
                ),
              ),
            ],
          )),
    );
  }
}

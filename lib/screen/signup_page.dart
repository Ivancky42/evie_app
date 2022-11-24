import 'package:evie_test/api/colours.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_single_button_dialog.dart';

///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUp extends StatefulWidget {
  final String name;

  const SignUp(this.name, {Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  //For user input password visibility true/false
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool isCheckTermsCondition = false;

  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToInputNameScreen(context);
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: ThemeChangeNotifier().isDarkMode(context) == true
                  ? Image.asset('assets/buttons/back_darkMode.png')
                  : Image.asset('assets/buttons/back.png'),
              onPressed: () {
                changeToInputNameScreen(context);
              }),
        ),
        body: SingleChildScrollView(child:Column(children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Text("${widget.name}, let's finish your setup",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text("Enter your email address and password",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                      )),
                  SizedBox(
                    height: 1.h,
                  ),
                  EvieTextFormField(
                    controller: _emailController,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    labelText: "Email Address",
                    hintText: "enter your email address",
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
                    height: 1.h,
                  ),
                  EvieTextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    labelText: "Password",
                    hintText: "enter your password",
                    suffixIcon: IconButton(
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
                      if (value.length < 8) {
                        return 'Password must have at least 8 character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  EvieTextFormField(
                    controller: _passwordConfirmController,
                    obscureText: _isObscure2,
                    labelText: "Confirm your password",
                    hintText: "confirm your password",
                    suffixIcon: IconButton(
                        icon:   _isObscure2 ?
                        const Image(
                          image: AssetImage("assets/buttons/view_off.png"),
                        ):
                        const Image(
                          image: AssetImage("assets/buttons/view_on.png"),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure2 = !_isObscure2;
                          });
                        }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }else if (_passwordController.value.text !=
                          _passwordConfirmController.value.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25.h,),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16, bottom: 10),
              child: Row(
                  children: [
                Checkbox(
                  value: isCheckTermsCondition,
                  activeColor: EvieColors.PrimaryColor,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckTermsCondition = value!;
                    });
                  },
                ),

                Container(
                  width: 75.w,
                  child:Text("By creating an account, I accept EVIE's terms of use and privacy policy.",
                  style: TextStyle(fontSize: 9.sp),)
                ),


              ]),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 10.0),
              child: EvieButton(
                height: 12,
                width: double.infinity,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
                onPressed: isCheckTermsCondition == true ? () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      if (await _authProvider.signUp(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              widget.name,
                              "empty") ?? true) {

                        _authProvider.setIsFirstLogin(true);

                        await _authProvider
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
                            changeToUserHomePageScreen(context);
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

                        /*
                                //Last value field is phone number
                                SmartDialog.show(
                                  widget: EvieSingleButtonDialogCupertino(
                                      title: "Success",
                                      content: "Registration success",
                                      rightContent: "Ok",
                                      //image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                                      onPressedRight: (){
                                        changeToSignInScreen(context);
                                        SmartDialog.dismiss();
                                      }),
                                );

                                 */
                      } else {
                        debugPrint("Sign Up Error");
                        SmartDialog.show(
                          widget: EvieSingleButtonDialogCupertino(
                              title: "Error",
                              content: "Try again",
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
                    } catch (error) {
                      debugPrint(error.toString());
                    }
                  }
                } : null,
              ),
            ),
          ),
        ]),
      )),
    );
  }
}

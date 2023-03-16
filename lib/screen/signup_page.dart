import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../widgets/evie_appbar.dart';
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
          appBar: EvieAppbar_Back(onPressed: (){  changeToInputNameScreen(context);}),

        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("${widget.name}, let's finish your setup",
                          style: EvieTextStyles.h2,),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text("Enter your email address and password",
                          style: EvieTextStyles.body18,),
                        SizedBox(
                          height: 9.h,
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
                          height: 8.h,
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
                          height: 8.h,
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

                      ],
                    ),
                  ),
                ),
              ]),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:  EdgeInsets.only(left: 16.w, right: 16.w, bottom: EvieLength.buttonWord_ButtonBottom),
                child: Row(
                    children: [
                      Checkbox(
                        value: isCheckTermsCondition,
                        activeColor: EvieColors.primaryColor,
                        fillColor:  MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return EvieColors.primaryColor; // color of the checkbox when it's checked
                          } else {
                            return Colors.green; // color of the checkbox when it's unchecked
                          }
                        },
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckTermsCondition = value!;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => BorderSide(width: 1.w, color:EvieColors.lightGrayishCyan),
                        ),


                      ),

                      Expanded(
                        child: Container(

                            child:Text("By creating an account, I accept EVIE's terms of use and privacy policy.",
                              style: EvieTextStyles.body14)
                        ),
                      ),


                    ]),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:  EdgeInsets.only(left: 16.w, right: 16.w, bottom: EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  child: Text(
                    "Create Account",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
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
                              changeToStayCloseToBike(context);
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
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: result.toString(),
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
                          });

                        } else {
                          debugPrint("Sign Up Error");
                          SmartDialog.show(
                            widget: EvieSingleButtonDialog(
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
                      } catch (error) {
                        debugPrint(error.toString());
                      }
                    }
                  } : null,
                ),
              ),
            ),
          ],
        )),
    );
  }
}

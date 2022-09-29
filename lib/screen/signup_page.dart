import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../widgets/evie_single_button_dialog.dart';

///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late AuthProvider _authProvider;

  //For user input password visibility true/false
  bool _isObscure = true;
  bool _isObscure2 = true;

  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);

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
                        child: Text("Create Account",
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
                          "Please fill in the following info",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Full Name",
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
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 1.6.h,
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle:
                        TextStyle(fontSize: 10.sp, color: Colors.grey),
                        filled: true,
                        //<-- SEE HERE
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
                                color:
                                    const Color(0xFFFFFFFF).withOpacity(0.2)),
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
                        if (value.length < 8) {
                          return 'Password must have at least 8 character';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 1.6.h,
                    ),
                    TextFormField(
                      controller: _passwordConfirmController,
                      obscureText: _isObscure2,
                      decoration: InputDecoration(
                          hintText: "Confirm your password",
                          hintStyle:
                          TextStyle(fontSize: 10.sp, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 0.1,
                                color:
                                    const Color(0xFFFFFFFF).withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure2 = !_isObscure2;
                                });
                              })),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (_passwordController.value.text !=
                            _passwordConfirmController.value.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 6.h
                    ),
                    EvieButton_DarkBlue(height: 12,
                      width: double.infinity,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            if (await _authProvider.signUp(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                _nameController.value.text,
                                "empty")?? true) {
                              //Last value field is phone number
                              SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Success",
                                    content: "Registration success",
                                    rightContent: "Ok",
                                    //image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                                    onPressedRight: (){
                                      changeToSignInScreen(context);
                                      SmartDialog.dismiss();
                                    }),
                              );
                            } else {
                              debugPrint("Sign Up Error");
                              SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Try again",
                                    rightContent: "Ok",
                                    image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                                    onPressedRight: (){
                                      SmartDialog.dismiss();
                                    }),
                              );
                            }
                          } catch (error) {
                            debugPrint(error.toString());
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    Container(
                      child: Center(
                        child: Text(
                          "Already have an account?",
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
                          changeToSignInScreen(context);
                        },
                        child: Text(
                          "Login",
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

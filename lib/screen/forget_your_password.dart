import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_textform.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

///Forget your password? Send an email using firebase api to reset it.
/// >>>> Try to remember it this time <<<<

class ForgetYourPassword extends StatefulWidget {
  const ForgetYourPassword({Key? key}) : super(key: key);

  @override
  _ForgetYourPasswordState createState() => _ForgetYourPasswordState();
}

class _ForgetYourPasswordState extends State<ForgetYourPassword> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ForgetYourPasswordScreen(),
    );
  }
}

class ForgetYourPasswordScreen extends StatefulWidget {
  const ForgetYourPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetYourPasswordScreenState createState() =>
      _ForgetYourPasswordScreenState();
}

class _ForgetYourPasswordScreenState extends State<ForgetYourPasswordScreen> {
  //Read user input email address
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        changeToSignInScreen(context);
        return false;
      },
      child: Scaffold(
          appBar: EvieAppbar_Back(onPressed: (){  changeToSignInScreen(context);}),
          body:
          Form(
            key: _formKey,
            child: Stack(
                children:[
                    Padding(
                      padding:  EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lost your password?",
                                style: EvieTextStyles.h2,
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Text(
                                "That's okay, it happens! Enter the email address you used for creating your account and we'll send you a password recover instruction.",
                                style: EvieTextStyles.body18,
                              ),
                              SizedBox(height: 16.h,),
                              EvieTextFormField(
                                controller: _emailController,
                                obscureText: false,
                                keyboardType: TextInputType.emailAddress,
                                hintText: "Enter your email address",
                                labelText: "Email Address",
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      !value.contains("@")) {
                                    return 'Please enter a valid email address';
                                  }
                                  //Check if email is in database
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              EvieButton(
                                width: double.infinity,
                                child: Text(
                                  "Recover Password",
                                  style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {

                                    ///For keyboard un focus
                                    FocusManager.instance.primaryFocus?.unfocus();

                                    //auth provider check if fire store user exist if no pop up if yes change to check your email screen
                                    AuthProvider().resetPassword(_emailController.text.trim());

                                    changeToCheckYourEmail(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Instruction Sent')),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 13.h,),
                              GestureDetector(
                                child: Text(
                                  "I don't have an account yet",
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                                ),
                                onTap: () {
                                  changeToInputNameScreen(context);
                                },
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                ]
            ),
          )
      ),
    );
  }
}

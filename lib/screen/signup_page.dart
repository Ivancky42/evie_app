import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_checkbox.dart';
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
  // final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _passwordConfirmController = TextEditingController();
  // final TextEditingController _nameController = TextEditingController();
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

                        Text("${widget.name}, let's setup your account",
                          style: EvieTextStyles.h2,),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text("Enter your email address",
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
                              return 'Looks like you entered the wrong email. '
                                  'The correct format for email address ad follow "sample@youremail.com". ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 8.h,
                        ),

                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 200.h,
                )
              ]),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:  EdgeInsets.only(left: 16.w, right: 16.w, bottom: EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,

                  child: Text(
                    "Next",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                  ),

                  onPressed: ()  {
                    if (_formKey.currentState!.validate()){
                    changeToSignUpPasswordScreen(context, widget.name, _emailController.text.trim());
                  }
                  }

                ),
              ),
            ),
          ],
        )),
    );
  }
}

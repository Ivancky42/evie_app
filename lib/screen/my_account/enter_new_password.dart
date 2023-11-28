import 'dart:io';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/screen/my_account/verify_password.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../api/snackbar.dart';
import '../../widgets/evie_appbar.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_textform.dart';

///User profile page with user account information

class EnterNewPassword extends StatefulWidget {
  const EnterNewPassword({Key? key}) : super(key: key);

  @override
  _EnterNewPasswordState createState() => _EnterNewPasswordState();
}

class _EnterNewPasswordState extends State<EnterNewPassword> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;

  //For user input password visibility true/false
  bool _isObscure = true;

  //Create form for form validation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordValid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 8;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool containsLettersAndNumbers(String value) {
    ///check for letters and numbers
    final RegExp alphanumeric = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');
    return alphanumeric.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: PageAppbar(
        title: 'Create New Password',
        onPressed: () {
          back(context, VerifyPassword());
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: _formKey,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 1.h),
                  child: Text(
                    "Create New Password",
                    style: EvieTextStyles.h2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Text(
                    "Password must contain at least 8 characters, with letters and numbers.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 17.h, 16.w, 0.h),
                  child: EvieTextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    hintText: "Type in new password",
                    labelText: "Password",
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must have at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                )
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(16.w,0,16.w,32.h),
              child: Column(
                children: [
                  SizedBox(
                    height: 48.h,
                    width: double.infinity,
                    child: EvieButton(
                      width: double.infinity,
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {

                          final result = await _authProvider.changeUserPassword(
                              _passwordController.text.trim()); //

                          result == true ?
                          {
                            changeToEditProfileReplace(context),
                            showUpdatedPasswordToast(context),
                          } :
                          SmartDialog.show(
                              widget: EvieSingleButtonDialog(
                                  title: "Error",
                                  content: "Try again",
                                  rightContent: "OK",
                                  onPressedRight: (){
                                    SmartDialog.dismiss();
                                  }));
                        }
                      },
                    ),
                  ),
                ],
              )
          ),
        ],
      ),);
  }
}

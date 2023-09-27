import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../api/dialog.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../widgets/evie_appbar.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_textform.dart';

///User profile page with user account information

class VerifyPassword extends StatefulWidget {
  const VerifyPassword({Key? key}) : super(key: key);

  @override
  _VerifyPasswordState createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final TextEditingController _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: PageAppbar(
        title: 'Update Password',
        onPressed: () {
          back(context, EditProfile());
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 1.h),
                  child: Text(
                    "Verify Password",
                    style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Text(
                    "Keep your account safe, please verify your identity by entering your password.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 17.h, 16.w, 0.h),
                  child: EvieTextFormField(
                    controller: _passwordController,
                    obscureText: false,
                    hintText: "Your login password",
                    labelText: "Password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(16.w,0,16.w,32.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48.h,
                    width: double.infinity,
                    child: EvieButton(
                      width: double.infinity,
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final result = await _authProvider.reauthentication(_passwordController.text.trim());
                          result == true ?
                          changeToEnterNewPassword(context)
                              :
                          SmartDialog.show(widget: EvieSingleButtonDialog(
                              title: "Error",
                              content: "Wrong password",
                              rightContent: "OK",
                              onPressedRight: (){
                                SmartDialog.dismiss();
                              }));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: GestureDetector(
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(fontSize: 14.sp, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                      ),
                      onTap: () {
                        showResetPasswordDialog(context, _authProvider);
                      },
                    ),
                  )
                ],
              )
          ),
        ],
      ),);
  }
}

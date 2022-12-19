import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
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
import '../../api/length.dart';
import '../../api/navigator.dart';
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

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final TextEditingController _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        changeToEditProfile(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Update Password',
          onPressed: () {
            changeToEditProfile(context);
          },
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                    child: Text(
                      "Enter New Password",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
                    child: Text(
                      "Enter your new password",
                      style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: EvieTextFormField(
                      controller: _passwordController,
                      obscureText: false,
                      //     keyboardType: TextInputType.name,
                      hintText: "your new password",
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
                child: SizedBox(
                  height: 48.h,
                  width: double.infinity,
                  child: EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Save",
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
                        changeToEditProfile(context),
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(content: Text(
                              'Password update success!')),
                        )
                            }
                        :
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
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Skip",
                      softWrap: false,
                      style: TextStyle(fontSize: 12.sp,color: EvieColors.PrimaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {

                    },
                  ),
                ),
              ),
            ),
          ],
        ),),
    );
  }
}

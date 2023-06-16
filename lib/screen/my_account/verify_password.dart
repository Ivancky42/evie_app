import 'dart:io';
import 'package:evie_bike/api/provider/auth_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_bike/widgets/widgets.dart';
import 'package:evie_bike/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_bike/widgets/evie_double_button_dialog.dart';
import 'package:evie_bike/widgets/evie_button.dart';

import '../../api/colours.dart';
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

    return WillPopScope(
      onWillPop: () async {
        changeToEditProfile(context);
        return false;
      },
      child: Scaffold(
          appBar: PageAppbar(
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
                        "Verify Password",
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
                      child: Text(
                        "Keep your account safe, please verify your identity by entering your password.",
                        style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: EvieTextFormField(
                        controller: _passwordController,
                        obscureText: false,
                   //     keyboardType: TextInputType.name,
                        hintText: "your account login password",
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
                        "Forgot Password",
                        softWrap: false,
                        style: TextStyle(fontSize: 12.sp,color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
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

import 'dart:io';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
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
  late FocusNode _nameFocusNode;
  //For user input password visibility true/false
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _nameFocusNode = FocusNode();
    _nameFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    //_nameFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordFormField() {
    return EvieTextFormField(
      controller: _passwordController,
      obscureText: _isObscure,
      focusNode: _nameFocusNode,
      hintText: "Your login password",
      labelText: "Password",
      suffixIcon: IconButton(
        icon: _isObscure
            ? SvgPicture.asset("assets/buttons/view_off.svg")
            : SvgPicture.asset("assets/buttons/view_on.svg"),
        onPressed: _toggleObscure,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }


  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;


    return Scaffold (
      appBar: PageAppbar(
        title: 'Update Password',
        onPressed: () {
          //back(context, EditProfile());
          //_nameFocusNode.dispose();
          changeToEditProfileReplace(context);
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
                    style: EvieTextStyles.h2,
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
                  child: _buildPasswordFormField(),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, isKeyboardVisible ? 12.h : EvieLength.target_reference_button_c),
            child: Column(
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

                SizedBox(height: 15.h,),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Forget Password",
                      softWrap: false,
                      style: EvieTextStyles.body18_underline,
                    ),
                    onPressed: () {
                      showResetPasswordDialog(context, _authProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),);
  }
}

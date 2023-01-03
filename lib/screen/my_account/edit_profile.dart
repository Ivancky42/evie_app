import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/screen/my_account/switch_profile_image.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/navigator.dart';
import '../../widgets/evie_textform.dart';

///User profile page with user account information

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final TextEditingController _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    bool _isEmail = false;
    if(_currentUserProvider.currentUserModel!.credentialProvider == "email"){
      _isEmail = true;
    }else {
      _isEmail = false;
    }

    return WillPopScope(
      onWillPop: () async {
        changeToMyAccount(context);
        return false;
      },
      child: Scaffold(
          appBar: AccountPageAppbar(
            title: 'Edit My Profile',
            onPressed: () {
     changeToMyAccount(context);
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 96.h,
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(27.7.w, 14.67.h, 18.67.w, 13.16.h),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        //imageUrl: document['profileIMG'],
                        imageUrl:
                            _currentUserProvider.currentUserModel!.profileIMG,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 66.67.h,
                        height: 66.67.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {

                  showMaterialModalBottomSheet(
                      expand: false,
                      context: context,
                      builder: (context) {
                        return SwitchProfileImage();
                      });

                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/buttons/pen_edit.svg", height: 16.h, width: 16.w,),
                    const Text(
                      "Edit Picture",
                      style: TextStyle(color: Color(0xff6A51CA)),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 0.5.h,
                color: const Color(0xff8E8E8E),
                height: 0,
              ),
              EditProfileContainer(
                subtitle: 'Name',
                content: _currentUserProvider.currentUserModel?.name ?? "",
                  trailingImage:  "assets/buttons/pen_edit.svg",
                onPress: (){
                  SmartDialog.show(
                      widget: Form(
                        key: _formKey,
                        child: EvieDoubleButtonDialog(
                        title: "Your Name",
                        childContent: Container(
                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nickname or first name are all welcome", style: TextStyle(fontSize: 16.sp, color: Color(0xff252526)),),
                              Padding(
                                padding:  EdgeInsets.fromLTRB(0.h, 12.h, 0.h, 8.h),
                                child: EvieTextFormField(
                                  controller: _nameController,
                                  obscureText: false,
                                  keyboardType: TextInputType.name,
                                  hintText: "Your first name or nickname",
                                  labelText: "Your Name",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Text("100 Maximum Character", style: TextStyle(fontSize: 12.sp, color: Color(0xff252526)),),
                            ],
                          ),
                        ),
                        leftContent: "Cancel",
                        rightContent: "Save",
                        onPressedLeft: (){SmartDialog.dismiss();},
                        onPressedRight: () async {
                          if (_formKey.currentState!.validate()) {
                            SmartDialog.dismiss();
                            final result = await _currentUserProvider.updateUserName(_nameController.text.trim());

                            result == true ?
                            SmartDialog.show(widget: EvieSingleButtonDialog(
                                title: "Success",
                                content: "Uploaded",
                                rightContent: "OK",
                                onPressedRight: (){SmartDialog.dismiss();}))
                                :
                            SmartDialog.show(widget: EvieSingleButtonDialog(
                                title: "Error",
                                content: "Please try again",
                                rightContent: "OK",
                                onPressedRight: (){
                                  SmartDialog.dismiss();
                                }));
                          }
                        }),
                      ));
                },
              ),
              const AccountPageDivider(),
              EditProfileContainer(
                subtitle: 'Email',
                content: _currentUserProvider.currentUserModel?.email ?? "",
              ),
              const AccountPageDivider(),

              Visibility(
                visible: _isEmail,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    changeToVerifyPassword(context);
                  },
                  child: Container(
                    height: 59.h,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Update Password",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const AccountPageDivider(),
            ],
          )),
    );
  }
}

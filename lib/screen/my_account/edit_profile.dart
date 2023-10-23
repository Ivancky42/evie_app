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

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../widgets/evie_appbar.dart';
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

    return Scaffold(
        appBar: PageAppbar(
          title: 'Personal Information',
          onPressed: () {
            back(context, EditProfile());
          },
        ),
        body: Column(
          children: [
            Center(
              child: Container(
                height: 96.h,
                child: Padding(
                    padding:
                    EdgeInsets.fromLTRB(0, 15.h, 0, 14.34.h),
                    child: Stack(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _currentUserProvider.currentUserModel!.profileIMG,
                            placeholder: (context, url) =>
                            const CircularProgressIndicator(color: EvieColors.primaryColor,),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            width: 66.67.h,
                            height: 66.67.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            //onTap camera pic
                            child: GestureDetector(
                              onTap: () {
                                showCupertinoModalBottomSheet(
                                  expand: false,
                                  useRootNavigator: true,
                                  context: context,
                                  builder: (context) {
                                    return SwitchProfileImage();
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/buttons/camera_bike_pic.svg",
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
            Divider(
              thickness: 0.5.h,
              color: const Color(0xff8E8E8E),
              height: 0,
            ),
            EditProfileContainer(
              subtitle: 'Your Name',
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
            Divider(
              thickness: 0.2.h,
              color: EvieColors.darkWhite,
              height: 0,
            ),
            EditProfileContainer(
              subtitle: 'Email Address',
              content: _currentUserProvider.currentUserModel?.email ?? "",
            ),
            Divider(
              thickness: 0.2.h,
              color: EvieColors.darkWhite,
              height: 0,
            ),

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
            Divider(
              thickness: 0.2.h,
              color: EvieColors.darkWhite,
              height: 0,
            ),
          ],
        ));
  }
}

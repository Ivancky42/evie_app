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
import '../../api/fonts.dart';
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
  TextEditingController _nameController = TextEditingController(text: "Initial Value");
  bool isFirst = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserProvider = context.read<CurrentUserProvider>();
    _nameController = TextEditingController(text: _currentUserProvider.currentUserModel?.name);
    _nameController.addListener(() {
      if (_nameController.selection.baseOffset != _nameController.selection.extentOffset) {
        // Text is selected
        print('Text selected: ${_nameController.text.substring(_nameController.selection.baseOffset, _nameController.selection.extentOffset)}');
      } else {
        // Cursor is moved
        if (isFirst) {
          setState(() {
            isFirst = false;
          });
          _nameController.selection = TextSelection(
              baseOffset: 0, extentOffset: _nameController.text.length);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    //final TextEditingController _nameController = TextEditingController();
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
            //changeToMyAccount(context, EditProfile());
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

            Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      isFirst = true;
                    });

                    FocusNode _nameFocusNode = FocusNode();
                    _nameFocusNode.requestFocus();

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
                                        focusNode: _nameFocusNode,
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
                              onPressedLeft: (){
                                _nameController = TextEditingController(text: _currentUserProvider.currentUserModel?.name);
                                SmartDialog.dismiss();
                                },
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

                    // Set the text and selection after the widget has been built
                    // Set the text and selection after the widget has been built
                    Future.delayed(Duration(milliseconds: 200), () {
                      _nameController.selection = TextSelection(baseOffset: 0, extentOffset: _nameController.text.length);
                    });
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Your Name',
                                    style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _currentUserProvider.currentUserModel?.name ?? "",
                                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/buttons/pen_edit.svg",
                            height: 24.h,
                            width: 24.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                      child: Divider(
                        thickness: 0.2.h,
                        color: EvieColors.darkWhite,
                        height: 0,
                      ),
                    )
                ),
              ],
            ),

            Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {

                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Email Address',
                                    style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _currentUserProvider.currentUserModel?.email ?? "",
                                    style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                      child: Divider(
                        thickness: 0.2.h,
                        color: EvieColors.darkWhite,
                        height: 0,
                      ),
                    )
                ),
              ],
            ),

            _isEmail ?
            Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    changeToVerifyPassword(context);
                  },
                  child: Container(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Update Password',
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                ),
                              ],
                            ),
                            SvgPicture.asset(
                              "assets/buttons/next.svg",
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                      child: Divider(
                        thickness: 0.2.h,
                        color: EvieColors.darkWhite,
                        height: 0,
                      ),
                    )
                ),
              ],
            ) :
            Container(),
          ],
        ));
  }
}

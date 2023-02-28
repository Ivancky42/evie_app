import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_textform.dart';
import '../../my_account/my_account_widget.dart';





///User profile page with user account information

class ShareBikeInvitation extends StatefulWidget{
  const ShareBikeInvitation({ Key? key }) : super(key: key);
  @override
  _ShareBikeInvitationState createState() => _ShareBikeInvitationState();
}

class _ShareBikeInvitationState extends State<ShareBikeInvitation> {

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToBikeSetting(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Share Bike',
          onPressed: () {
            changeToBikeSetting(context);
          },
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 4.h),
                    child: Text(
                      "Send bike sharing invitation",
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
                    child: Text(
                      "Enter the email address of sharee?",
                      style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: EvieTextFormField(
                      controller: _emailController,
                      obscureText: false,
//     keyboardType: TextInputType.name,
                      hintText: "Email Address",
                      labelText: "Email Address",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
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
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Share Bike",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700),
                  ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                                await _authProvider.checkIfFirestoreUserExist(_emailController.text.trim(),).then((
                                    result) async {
                                  if (result == null) {
                                    SmartDialog.show(
                                        backDismiss: false,
                                        widget: EvieSingleButtonDialog(
                                            title: "User not found",
                                            content: "Email not register in database",
                                            rightContent: "Close",
                                            onPressedRight: () {
                                              SmartDialog.dismiss();
                                              changeToUserNotFoundScreen(
                                                  context,
                                                  _emailController.text.trim());
                                            }
                                        ));
                                    return;
                                  }
                                  else {
                                    ///check bike user list if the user already own this bike
                                    var existResult = await _bikeProvider.checkIsUserExist(
                                        _emailController.text.trim());

                                    if (existResult == false) {
                                      SmartDialog.show(
                                          widget: EvieDoubleButtonDialog(
                                            title: "Share Bike",
                                            childContent: Text("Share ${_bikeProvider
                                                .currentBikeModel!.deviceName}"
                                                " with ${_emailController.text
                                                .trim()} ?"),
                                            
                                            leftContent: "Cancel",
                                            onPressedLeft: () =>
                                                SmartDialog.dismiss(),
                                            rightContent: "Share",
                                            onPressedRight: () async {
                                              SmartDialog.dismiss();

                                              await _bikeProvider.updateSharedBike(result).
                                              then((update) {
                                                if (update == true) {
                                                  SmartDialog.show(
                                                      widget: EvieSingleButtonDialog(
                                                          title: "Success",
                                                          content: "Shared bike with ${_emailController
                                                              .text.trim()}",
                                                          rightContent: "Close",
                                                          onPressedRight: () {
                                                            SmartDialog.dismiss();
                                                            changeToInvitationSentScreen(
                                                                context,
                                                                _emailController
                                                                    .text
                                                                    .trim());
                                                          }
                                                      ));
                                                }
                                                else {
                                                  SmartDialog.show(
                                                      widget: EvieSingleButtonDialog(
                                                          title: "Not success",
                                                          content: "Try again",
                                                          rightContent: "Close",
                                                          onPressedRight: () =>
                                                              SmartDialog
                                                                  .dismiss()
                                                      ));
                                                }
                                              });
                                            },
                                          ));
                                    } else {
                                      SmartDialog.show(
                                          backDismiss: false,
                                          widget: EvieSingleButtonDialog(
                                              title: "User already exist",
                                              content: "The target user owned the bike",
                                              rightContent: "Close",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }
                                          ));
                                    }
                                  }
                                });
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      }
                    }
                    )
                ),
              ),

          ],
        ),
      ),
    );
  }

}
import 'dart:io';

import 'package:evie_bike/api/provider/current_user_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/screen/user_home_page/bike_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/widgets.dart';
import 'my_account_widget.dart';

class SwitchProfileImage extends StatefulWidget {
  const SwitchProfileImage({Key? key}) : super(key: key);

  @override
  State<SwitchProfileImage> createState() => _SwitchProfileImageState();
}

class _SwitchProfileImageState extends State<SwitchProfileImage> {
  @override
  Widget build(BuildContext context) {
    CurrentUserProvider _currentUserProvider =
        Provider.of<CurrentUserProvider>(context);

    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECEDEB),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 11.h, bottom: 29.h),
                child: Image.asset(
                  "assets/buttons/home_indicator.png",
                  width: 40.w,
                  height: 4.h,
                ),
              ),
              ChangeImageContainer(
                onPress: () async {
                  final result = await pickImage(
                      _currentUserProvider.currentUserModel!.email,
                      _currentUserProvider);
                  if (result == false) {
                    SmartDialog.show(
                        widget: EvieSingleButtonDialog(
                            title: "Error",
                            content: "Please try again",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo upload success!')),
                    );
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                image: "assets/buttons/upload.svg",
                content: "Upload from Photo Gallery",),

              const AccountPageDivider(),
              ChangeImageContainer(
                onPress: () async {
                  final result = await snapImage(
                      _currentUserProvider.currentUserModel!.email,
                      _currentUserProvider);
                  if (result == false) {
                    SmartDialog.show(
                        widget: EvieSingleButtonDialog(
                            title: "Error",
                            content: "Please try again",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo upload success!')),
                    );
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                image: "assets/buttons/camera.svg",
                content: "Take a Photo",),
              const AccountPageDivider(),
              ChangeImageContainer(
                onPress: () async {
                  final result = await deleteImage(
                      _currentUserProvider.currentUserModel!.email,
                      _currentUserProvider);
                  if (result == false) {
                    SmartDialog.show(
                        widget: EvieSingleButtonDialog(
                            title: "Error",
                            content: "Please try again",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deleted')),
                    );
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                image: "assets/buttons/delete.svg",
                content: "Remove Current Picture",),
              const AccountPageDivider(),
              SizedBox(height: 50.h)
            ],
          ),
        ),
      ],
    );
  }

  //Image picker from phone gallery
  Future pickImage(
      String email, CurrentUserProvider currentUserProvider) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    try {
      ///From widget function, show loading dialog screen
      SmartDialog.showLoading(backDismiss: false);
      var picName = email;
      Reference ref =
          FirebaseStorage.instance.ref().child("UserProfilePic/" + picName);

      //Upload to firebase storage
      await ref.putFile(File(image!.path));

      ref.getDownloadURL().then((value) {
        currentUserProvider.updateUserProfileImage(value);

        setState(() {});

        ///Quit loading dialog
        Navigator.pop(context);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  //Image picker from camera
  Future snapImage(
      String email, CurrentUserProvider currentUserProvider) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    try {
      ///From widget function, show loading dialog screen
      SmartDialog.showLoading(backDismiss: false);
      var picName = email;
      Reference ref =
          FirebaseStorage.instance.ref().child("UserProfilePic/" + picName);

      //Upload to firebase storage
      await ref.putFile(File(image!.path));

      ref.getDownloadURL().then((value) {
        currentUserProvider.updateUserProfileImage(value);

        setState(() {});

        ///Quit loading dialog
        Navigator.pop(context);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  //Image picker from phone gallery
  Future deleteImage(
      String email, CurrentUserProvider currentUserProvider) async {
    try {
      ///From widget function, show loading dialog screen
      SmartDialog.showLoading(backDismiss: false);
      String profileIMG = dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found';
      currentUserProvider.updateUserProfileImage(profileIMG);

      setState(() {});

      ///Quit loading dialog
      Navigator.pop(context);

      return true;
    } catch (e) {
      return false;
    }
  }
}

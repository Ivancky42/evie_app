import 'dart:io';

import 'package:sizer/sizer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../my_account/my_account_widget.dart';


class SwitchBikeImage extends StatefulWidget {
  const SwitchBikeImage({super.key});

  @override
  State<SwitchBikeImage> createState() => _SwitchBikeImageState();
}

class _SwitchBikeImageState extends State<SwitchBikeImage> {
  @override
  Widget build(BuildContext context) {

    BikeProvider bikeProvider =
    Provider.of<BikeProvider>(context);

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
                      bikeProvider.currentBikeModel!.deviceIMEI!,
                      bikeProvider);
                  if (result == false) {
                    SmartDialog.show(
                        builder: (_) => EvieSingleButtonDialog(
                            title: "Error",
                            content: "Please try again",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  } else {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Photo upload success!')),
                    // );
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                image: "assets/buttons/upload.svg",
                content: "Upload from Photo Gallery",),

              const AccountPageDivider(),
              ChangeImageContainer(
                onPress: () async {
                  final result = await snapImage(
                      bikeProvider.currentBikeModel!.deviceIMEI!,
                      bikeProvider);
                  if (result == false) {
                    SmartDialog.show(
                        builder: (_) => EvieSingleButtonDialog(
                            title: "Error",
                            content: "Please try again",
                            rightContent: "OK",
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  } else {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Photo upload success!')),
                    // );
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                image: "assets/buttons/camera.svg",
                content: "Take a Photo",),
              const AccountPageDivider(),
              ChangeImageContainer(
                onPress: () async {
                  final result = await deleteImage(
                      bikeProvider.currentBikeModel!.deviceIMEI!,
                      bikeProvider);
                  if (result == false) {
                    SmartDialog.show(
                        builder: (_) => EvieSingleButtonDialog(
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
      String deviceIMEI, BikeProvider bikeProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null){
      try {
        ///From widget function, show loading dialog screen
        showCustomLightLoading('Loading...', false);
        var picName = deviceIMEI;
        Reference ref =
        FirebaseStorage.instance.ref().child("BikePic/$picName");

        //Upload to firebase storage
        await ref.putFile(File(image.path));

        ref.getDownloadURL().then((value) {
          bikeProvider.updateUserBikeImage(value);

          setState(() {});

          ///Quit loading dialog
          Navigator.pop(context);
        });

        return true;
      } catch (e) {
        return false;
      }
    }
  }

  //Image picker from camera
  Future snapImage(
      String deviceIMEI, BikeProvider bikeProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if(image != null){
      try {
        ///From widget function, show loading dialog screen
        showCustomLightLoading('Loading...', false);
        var picName = deviceIMEI;
        Reference ref =
        FirebaseStorage.instance.ref().child("BikePic/$picName");

        //Upload to firebase storage
        await ref.putFile(File(image.path));

        ref.getDownloadURL().then((value) {
          bikeProvider.updateUserBikeImage(value);

          setState(() {});

          ///Quit loading dialog
          Navigator.pop(context);
        });

        return true;
      } catch (e) {
        return false;
      }
    }
  }

  //Image picker from phone gallery
  Future deleteImage(
      String deviceIMEI, BikeProvider bikeProvider) async {
    try {
      ///From widget function, show loading dialog screen
      showCustomLightLoading('Loading...', false);
      String bikeIMG = dotenv.env['DEFAULT_BIKE_IMG'] ?? 'DBI not found';
      String? model = bikeProvider.currentBikeModel?.serialNumber?.substring(0, 2) ?? 'S1';
      if (model == 'S1') {
        bikeIMG = dotenv.env['DEFAULT_S1_BIKE_IMG'] ?? 'DBI not found';
      }
      else if (model == 'T1') {
        bikeIMG = dotenv.env['DEFAULT_T1_BIKE_IMG'] ?? 'DBI not found';
      }
      bikeProvider.updateUserBikeImage(bikeIMG);

      setState(() {});

      ///Quit loading dialog
      Navigator.pop(context);

      return true;
    } catch (e) {
      return false;
    }
  }
}

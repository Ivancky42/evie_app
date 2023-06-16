import 'dart:io';
import 'package:evie_bike/api/provider/auth_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_bike/widgets/widgets.dart';
import 'package:evie_bike/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_bike/widgets/evie_double_button_dialog.dart';
import 'package:evie_bike/widgets/evie_button.dart';

import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/setting_provider.dart';

///User profile page with user account information

class UserProfile extends StatefulWidget{
  const UserProfile({ Key? key }) : super(key: key);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  late CurrentUserProvider _currentUser;
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  //Create string for image
  String uploadimageUrl = " ";

  bool _isInputEnable = false;

  //Image picker from phone gallery
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    ///From widget function, show loading dialog screen
    showAlertDialog(context);
    var picName = _currentUser.currentUserModel!.email;
    Reference ref = FirebaseStorage.instance.ref().child(
        "UserProfilePic/" + picName);

   //Upload to firebase storage
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      uploadimageUrl = value;
      setState(() {
        uploadimageUrl = value;
        debugPrint(uploadimageUrl);
      });

      ///Quit loading dialog
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    //Set image url
    if (uploadimageUrl == " "){
      uploadimageUrl = _currentUser.currentUserModel!.profileIMG;
    }

    bool _isEmail = false;
    if(_currentUser.currentUserModel!.credentialProvider == "email"){
      _isEmail = true;
    }else {
      _isEmail = false;
    }



    return WillPopScope(
      onWillPop: () async {
        changeToUserHomePageScreen(context);
        return true;
      },

      child:Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Row(
              children: <Widget>[
                IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      changeToUserHomePageScreen(context);
                    }
                ),

                const Text('Profile'),

              ],
            ),
            actions: <Widget>[

          Visibility(
            visible: _isEmail,
              child:IconButton(
                  tooltip: 'Change Password',
                  icon: const Icon(Icons.key),
                  onPressed: () {
                    changeToChangePasswordScreen(context);
                  }
              ),
          ),


              IconButton(
                  tooltip: 'Edit',
                  icon: Icon(
                    _isInputEnable ? Icons.edit_off : Icons.edit,
                  ),
                  onPressed: () {
                    setState(() {
                      _isInputEnable = !_isInputEnable;
                    });}
              ),
              IconButton(
                iconSize: 25,
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () {
                      _currentUser.updateUserProfile(uploadimageUrl, _nameController.text.trim(), _phoneNoController.text.trim());

                      setState(() {
                        _isInputEnable = false;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Update Successful'),
                            actions:[
                              TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }
                              ),
                            ],
                          ),
                        );
                      });
                }),
            ],
          ),

          body: Scaffold(
              body: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: SingleChildScrollView(
                              child: Column(

                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: <Widget>[
                                    SizedBox(
                                      height: 2.h,
                                    ),

                                    Stack(
                                      children: [
                                        Center(child: ClipOval(
                                          child: CachedNetworkImage(
                                            //imageUrl: document['profileIMG'],
                                            imageUrl: uploadimageUrl,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) =>
                                                Icon(Icons.error),
                                            width: 15.h,
                                            height: 15.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        ),

                                        Positioned(
                                            bottom: 0,
                                            right: 110,
                                            child: Container(
                                              height: 5.h,
                                              width: 5.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.white,
                                                ),
                                                color: Colors.green,
                                              ),
                                              child: IconButton(
                                                color: Colors.white70,
                                                iconSize: 20,
                                                icon: const Icon(
                                                    Icons.camera_alt_outlined),
                                                tooltip: 'Upload Image',
                                                onPressed: () async {
                                                  pickImage();
                                                  //Image
                                                },
                                              ),
                                            )
                                        )
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 30.0,
                                    ),
                                    TextFormField(
                                      enabled: false,
                                      initialValue: _currentUser.currentUserModel!.email,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        labelStyle: TextStyle(
                                            color: SettingProvider().isDarkMode(context)
                                                == true ? Colors.white70 : Colors.black,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFFFFFFF)
                                            .withOpacity(0.2),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(
                                              width: 0.1,
                                              color: const Color(0xFFFFFFFF)
                                                  .withOpacity(0.2)),
                                          borderRadius: BorderRadius.circular(
                                              20.0),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 20.0,
                                    ),

                                    TextFormField(
                                      //controller: _nameController..text = document['name'],
                                      controller: _nameController..text = _currentUser.currentUserModel?.name ?? "",
                                      enabled: _isInputEnable,
                                      //initialValue: document['name'],
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: TextStyle(
                                          color: SettingProvider().isDarkMode(context)
                                              == true ? Colors.white70 : Colors.black,
                                        ),
                                        hintText: 'Type your name here',
                                        filled: true,
                                        fillColor: const Color(0xFFFFFFFF)
                                            .withOpacity(0.2),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(
                                              width: 0.1,
                                              color: const Color(0xFFFFFFFF)
                                                  .withOpacity(0.2)),
                                          borderRadius: BorderRadius.circular(
                                              20.0),
                                        ),
                                      ),

                                    ),

                                    const SizedBox(
                                      height: 20.0,
                                    ),


                                    TextFormField(
                                      controller: _phoneNoController..text = _currentUser.currentUserModel!.phoneNumber!,
                                      enabled: _isInputEnable,
                                      //initialValue: document['phoneNumber'],
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        labelStyle: TextStyle(
                                          color: SettingProvider().isDarkMode(context)
                                              == true ? Colors.white70 : Colors.black,
                                        ),
                                        hintText: 'Type your phone number here',
                                        filled: true,
                                        fillColor: const Color(0xFFFFFFFF)
                                            .withOpacity(0.2),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(
                                              width: 0.1,
                                              color: const Color(0xFFFFFFFF)
                                                  .withOpacity(0.2)),
                                          borderRadius: BorderRadius.circular(
                                              20.0),
                                        ),
                                      ),
                                    ),


                                    SizedBox(
                                      height: 10.h,
                                    ),

                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: EvieButton(height: 12,
                                            width: double.infinity,
                                            onPressed: () async {
                                          SmartDialog.showLoading();
                                              try {
                                                await _authProvider.signOut(context).then((result) async {
                                                  if(result == true){
                                                    await _bikeProvider.clear();
                                                    SmartDialog.dismiss();
                                                   // _authProvider.clear();

                                                    changeToWelcomeScreen(context);
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Signed out'),
                                                        duration: Duration(
                                                            seconds: 2),),
                                                    );
                                                  }else{
                                                    SmartDialog.dismiss();
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Error, Try Again'),
                                                        duration: Duration(
                                                            seconds: 4),),
                                                    );

                                                  }

                                                });
                                              }
                                              catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            },
                                            child: const Text("Sign Out",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                )
                                            )
                                        )
                                    )
                                  ])
                          )
                      )
                  )
              )
          )
      ),
    );
  }
}
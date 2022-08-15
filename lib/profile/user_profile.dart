import 'dart:io';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

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

  //Create string for image
  String uploadimageUrl = " ";

  bool _isInputEnable = false;

  //Image picker from phone gallery
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    ///From widget function, show loading dialog screen
    showAlertDialog(context);
    var picName = _currentUser.getEmail;
    Reference ref = FirebaseStorage.instance.ref().child(
        "UserProfilePic/" + picName!);

   //Upload to firebase storage
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      uploadimageUrl = value;
      setState(() {
        uploadimageUrl = value;
        print(uploadimageUrl);
      });

      ///Quit loading dialog
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);

    //Set image url
    if (uploadimageUrl == " "){
      uploadimageUrl = _currentUser.getProfileImageURL;
    }

    return Scaffold(
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
                    Navigator.pushReplacementNamed(context, '/userHomePage');
                  }
              ),

              const Text('Profile'),

            ],
          ),
          actions: <Widget>[
            IconButton(
                tooltip: 'Change Password',
                icon: const Icon(Icons.key),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/userChangePassword');
                }
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
                    _currentUser.updateUserProfile(uploadimageUrl,
                        _nameController.text.trim(), _phoneNoController.text.trim());

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
                                  const SizedBox(
                                    height: 20.0,
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
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      ),

                                      Positioned(
                                          bottom: 0,
                                          right: 110,
                                          child: Container(
                                            height: 40,
                                            width: 40,
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
                                          ))
                                    ],
                                  ),


                                  const SizedBox(
                                    height: 30.0,
                                  ),

                                  TextFormField(
                                    enabled: false,
                                    initialValue: _currentUser.getEmail,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
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
                                    controller: _nameController..text = _currentUser.getName,
                                    enabled: _isInputEnable,
                                    //initialValue: document['name'],
                                    decoration: InputDecoration(
                                      labelText: 'Username',
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
                                    controller: _phoneNoController..text = _currentUser.getPhoneNo,
                                    enabled: _isInputEnable,
                                    //initialValue: document['phoneNumber'],
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
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


                                  const SizedBox(
                                    height: 60.0,
                                  ),

                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: EvieButton_DarkBlue(
                                          width: double.infinity,
                                          onPressed: () async {
                                            try {
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                              _currentUser.signOut();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('Signed out'),
                                                  duration: Duration(
                                                      seconds: 2),),

                                              );
                                              //await Provider.of(context).auth.signOut();
                                            }
                                            catch (e) {
                                              print(e);
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
    );
  }
}
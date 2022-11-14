import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/model/bike_user_model.dart';
import '../api/model/user_model.dart';
import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_double_button_dialog.dart';

///User profile page with user account information

class ShareBike extends StatefulWidget{
  const ShareBike({ Key? key }) : super(key: key);
  @override
  _ShareBikeState createState() => _ShareBikeState();
}

class _ShareBikeState extends State<ShareBike> {

  final TextEditingController _emailController = TextEditingController();

  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  bool isOwner = false;


  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    if(_bikeProvider.checkIsOwner()){
      isOwner = true;
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
                    changeToUserHomePageScreen(context);
                  }
              ),
              const Text('Share Bike'),
            ],
          ),
        ),

        body: Scaffold(
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
             //       child: Center(
                        child: SingleChildScrollView(
                            child: Column(

                               // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: <Widget>[

                                  SizedBox(
                                    height: 5.h,
                                  ),

                                  ///Check the length of the bike user from firestore bike user collection
                                  ///If bike user already reach 5 do not allow write and share

                                  TextFormField(
                                    enabled: isOwner,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: isOwner == true ? 'Email Address': 'You need to be owner to share bike',
                                      labelStyle: TextStyle(
                                        color: ThemeChangeNotifier().isDarkMode(context)
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


                                  SizedBox(
                                    height: 3.h,
                                  ),

                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: EvieButton_Dark(
                                          height: 5.h,
                                          width: 40.w,
                                          onPressed: isOwner ?() async {
                                            try {

                                              _authProvider.checkIfFirestoreUserExist(
                                                _emailController.text.trim(),
                                              ).then((result){

                                                switch(result){
                                                  case "false":
                                                    SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                                                        title: "User not found",
                                                        content: "Email not register in database",
                                                        rightContent: "Close",
                                                        onPressedRight: ()=>SmartDialog.dismiss()
                                                    ));
                                                    break;
                                                  default:
                                                    SmartDialog.show(widget: EvieDoubleButtonDialogCupertino(
                                                      title: "Share Bike",
                                                      content: "Share ${_bikeProvider.currentBikeModel!.bikeName}"
                                                          " with ${_emailController.text.trim()} ?",
                                                      leftContent: "Cancel",
                                                      onPressedLeft: () => SmartDialog.dismiss(),
                                                      rightContent: "Share",
                                                      onPressedRight: () async {
                                                        SmartDialog.dismiss();
                                                        _bikeProvider.updateSharedBikeStatus(result).
                                                        then((update){
                                                          if(update == true){
                                                            SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                                                                title: "Success",
                                                                content: "Shared bike with ${_emailController.text.trim()}",
                                                                rightContent: "Close",
                                                                onPressedRight: ()=>SmartDialog.dismiss()
                                                            ));
                                                          }
                                                          else {
                                                            SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                                                                title: "Not success",
                                                                content: "Try again",
                                                                rightContent: "Close",
                                                                onPressedRight: ()=>SmartDialog.dismiss()
                                                            ));
                                                          }
                                                        });
                                                        ///TODO: Share Bike
                                                        ///Display Shared successful
                                                        ///justInvited: true
                                                        ///userId (see she is the how many in the bike user list, 0-4)

                                                      },
                                                    ));
                                                    break;
                                                }
                                              });
                                            }
                                            catch (e) {
                                              debugPrint(e.toString());
                                            }
                                          }:null,
                                          child: Text("Share",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                              )
                                          )
                                      )
                                  ),

                                  SizedBox(
                                    height: 2.h,
                                  ),

                                  const Divider(
                                      color: Colors.grey
                                  ),
                                  
                                  const Text("User List"),

                                  Container(
                                      height: 45.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: ThemeChangeNotifier().isDarkMode(context)
                                            == true ? const Color(0xFF0F191D): const Color(0xffD7E9EF),

                                      ),
                                      child: Center(
                                        child: ListView.separated(
                                          itemCount:
                                          _bikeProvider.bikeUserList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                                onTap: () {
                                                  showUserInfoTile(
                                                      _bikeProvider.bikeUserList.values.elementAt(index), 
                                                      _bikeProvider.bikeUserDetails.values.elementAt(index)
                                                  );
                                                //  showUserInfoTile(_bikeProvider.bikeUserList.values.elementAt(index)

                                                    /*
                                                      _notificationProvider
                                                      .notificationList.values
                                                      .elementAt(index)
                                                      );
                                                     */
                                                  },
                                                child: ListTile(

                                                  ///Put user profile image here
                                                    leading: ClipOval(

                                                      child: CachedNetworkImage(
                                                        //imageUrl: document['profileIMG'],
                                                        imageUrl: _bikeProvider.bikeUserDetails.values.elementAt(index).profileIMG,
                                                        placeholder: (context, url) =>
                                                        const CircularProgressIndicator(),
                                                        errorWidget: (context, url, error) =>
                                                            Icon(Icons.error),
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    title: Text(
                                                        _bikeProvider.bikeUserDetails.values.elementAt(index).name),
                                                    subtitle: Text(
                                                        "${_bikeProvider.bikeUserDetails.values.elementAt(index).email}\n"
                                                      "${_bikeProvider.bikeUserList.values.elementAt(index).role}",
                                                      style: TextStyle(color: ThemeChangeNotifier().isDarkMode(context)
                                                          == true ? Colors.white70: Colors.black54,),
                                                      /*
                                                    trailing: IconButton(
                                                      iconSize: 25,
                                                      icon: const Image(
                                                        image: AssetImage("assets/buttons/arrow_right.png"),
                                                        height: 20.0,
                                                      ),
                                                      tooltip: '',
                                                      onPressed: () {
                                                        ///Display Tile
                                                        showNotificationTile(_notificationProvider.notificationList.values.elementAt(index));
                                                      },
                                                      ),
                                                     */
                                                    )));
                                          },
                                          separatorBuilder:
                                              (BuildContext context, int index) {
                                            return const Divider();
                                          },
                                        ),
                                      )),
                                ])
                        )
                   // )
                )
        )
    );
  }

  showUserInfoTile(BikeUserModel bikeUserModel, UserModel bikeUserModelDetails){
    SmartDialog.show(
      widget: EvieDoubleButtonDialogCupertino(
          title: "Name: ${bikeUserModelDetails.name}",
          content: bikeUserModel.status!.isEmpty ?
                     "Email: ${bikeUserModelDetails.email} \n"
                     "Role: ${bikeUserModel.role}":
                    "Email: ${bikeUserModelDetails.email} \n"
                    "Status: ${bikeUserModel.status}",


        leftContent: isOwner&&bikeUserModel.status == "pending"? "Delete User" : "Cancel",
        onPressedLeft: isOwner&&bikeUserModel.status == "pending" ? () async {
            _bikeProvider.cancelSharedBikeStatus(bikeUserModel.uid, bikeUserModel.notificationId!).then((result){
              ///Update user notification id status == removed
              if(result == true){
                SmartDialog.dismiss();
                SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                    title: "Success",
                    content: "Cancelled",
                    rightContent: "Close",
                    onPressedRight: ()=>SmartDialog.dismiss()
                ));
              }
              else {
                SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                    title: "Not success",
                    content: "Try again",
                    rightContent: "Close",
                    onPressedRight: ()=>SmartDialog.dismiss()
                ));
              }

            });
        }:(){
            SmartDialog.dismiss();
            },
          rightContent: "Ok",
          onPressedRight: (){SmartDialog.dismiss();}, )
    );

  }
}
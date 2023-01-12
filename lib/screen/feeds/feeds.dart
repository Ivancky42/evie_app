import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';


import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/navigator.dart';
import '../../theme/ThemeChangeNotifier.dart';
import '../../widgets/evie_single_button_dialog.dart';

///User profile page with user account information

class Feeds extends StatefulWidget {
  const Feeds({Key? key}) : super(key: key);

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
                child: Container(
                  child: Text(
                    "Feeds",
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _notificationProvider.notificationList.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: UniqueKey(),
                      endActionPane:  ActionPane(
                        extentRatio: 0.3,
                        motion: const StretchMotion(),
                        dismissible: DismissiblePane(

                          ///Confirm dismiss only when decline
                            // confirmDismiss: () async {
                            //   return await showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //           return EvieDoubleButtonDialog(
                            //               title: "Are you sure",
                            //               childContent: const Text("sure ma"),
                            //               leftContent: "Cancel",
                            //               rightContent: "ok",
                            //               onPressedLeft: (){Navigator.of(context).pop(false);},
                            //               onPressedRight: (){Navigator.of(context).pop(true);});
                            //     },
                            //   );
                            // },
                          onDismissed: () async {

                            if(_notificationProvider.notificationList.values.elementAt(index).status == "pending"){
                              decline();
                            }else{
                              var result = await _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                              if(!result){
                                showDeleteNotificationFailed();
                              }
                            }
                          },
                        ),
                        children: [
                          SlidableAction(
                            spacing:10,
                            onPressed: (context) async{
                              if(_notificationProvider.notificationList.values.elementAt(index).status == "pending"){
                                decline();
                              }else {
                                var result = await _notificationProvider
                                    .deleteNotification(
                                    _notificationProvider.notificationList.keys
                                        .elementAt(index));
                                if (result) {
                                  showDeleteNotificationSuccess();
                                } else {
                                  showDeleteNotificationFailed();
                                }
                              }
                            },
                            backgroundColor: EvieColors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),

                      child: GestureDetector(
                          onTap: () async {
                             _notificationProvider.updateIsReadStatus(_notificationProvider
                                    .notificationList.keys
                                    .elementAt(index));
                          },

                          child: Container(
                            color: _notificationProvider
                                .notificationList.values
                                .elementAt(index)
                                .isRead! == false ? Color(0xffE6E2F6) : Colors.transparent,
                            child: Padding(
                              padding:  EdgeInsets.only(top: 14.h, bottom: 14.h),
                              child: ListTile(
                                  title: Text(_notificationProvider
                                      .notificationList.values
                                      .elementAt(index)
                                      .title!, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),),
                                  subtitle: Column(
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          "${_notificationProvider.notificationList.values.elementAt(index).body!}",
                //                  "\n\n${_notificationProvider.notificationList.values.elementAt(index).created!.toDate()}",
                                          style: TextStyle(
                                            color: ThemeChangeNotifier()
                                                .isDarkMode(context) ==
                                                true
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),


                                        ),
                                      ),

                                      Visibility(
                                        ///type == shareBike, status == pending
                                        visible: _notificationProvider.notificationList.values.elementAt(index).status == "pending",
                                        child: Row(
                                          children: [
                                            Align(
                                                alignment: AlignmentDirectional.bottomStart,
                                                child: EvieButton_ReversedColor(
                                                    onPressed: (){

                                                      decline();

                                                    },
                                                    child: Text(
                                                      "Decline",
                                                      style: TextStyle(fontSize: 17.sp,
                                                          color: EvieColors.primaryColor),
                                                    ),
                                                    height: 36.h,
                                                    width: 169.w)
                                            ),

                                            Align(
                                                alignment: AlignmentDirectional.bottomEnd,
                                                child: EvieButton(
                                                    onPressed: () async {
                                                      SmartDialog.show(
                                                        backDismiss: false,
                                                          widget: Container(
                                                            color: EvieColors.grayishWhite,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/icons/loading.svg",
                                                              height: 48.h,
                                                              width: 48.w,
                                                            ),
                                                            Text("Accepting invitation and adding bike...", style: TextStyle(fontSize: 16.sp, color: Color(0xff3F3F3F)),)
                                                          ],

                                                        )
                                                      ));
                                                      await _bikeProvider
                                                          .updateAcceptSharedBikeStatus(_notificationProvider.notificationList.values.elementAt(index).deviceIMEI!, _currentUserProvider.currentUserModel!.uid)
                                                          .then((result) async {
                                                        if (result == true) {
                                                          SmartDialog.dismiss();
                                                          _notificationProvider.updateUserNotificationSharedBikeStatus(_notificationProvider.notificationList.keys.elementAt(index));

                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Bike added successfully!'),
                                                              duration: Duration(
                                                                  seconds: 3),),
                                                          );

                                                          changeToUserHomePageScreen(context);
                                                          for (var element in _bikeProvider.userBikeNotificationList) {
                                                            await _notificationProvider.subscribeToTopic("${_bikeProvider.currentBikeModel!.deviceIMEI}$element");
                                                          }


                                                        }else{
                                                          SmartDialog.show(
                                                              backDismiss: false,
                                                              widget: EvieSingleButtonDialogCupertino(
                                                                  title: "Error",
                                                                  content: "Try again",
                                                                  rightContent: "OK",
                                                                  onPressedRight: () async {
                                                                    SmartDialog.dismiss();
                                                                  }));
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(fontSize: 17.sp,
                                                        color: EvieColors.grayishWhite,),
                                                    ),
                                                    height: 36.h,
                                                    width: 169.w)
                                            ),

                                          ],
                                        ),
                                      ),

                                    ],
                                  )),
                            ),
                          )),
                    );
                  },
                  separatorBuilder:
                      (BuildContext context, int index) {
                    return Divider(height: 1.5.h,);
                  },
                ),
              ),
            ],
          )),
    );
  }

  decline(){
    SmartDialog.show(
        widget: EvieDoubleButtonDialogCupertino(
          title: "Are you sure you want to decline?",
          content: 'Are you sure you want to decline?',
          leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
          rightContent: "Yes",
          onPressedRight: () async {
            await _bikeProvider.cancelSharedBikeStatus(
                _bikeProvider.bikeUserList.values.firstWhere((element) => element.uid == _currentUserProvider.currentUserModel!.uid).uid!,
                _bikeProvider.bikeUserList.values.firstWhere((element) => element.uid == _currentUserProvider.currentUserModel!.uid).notificationId!).then((result){
              ///Update user notification id status == removed
              if(result == true){
                SmartDialog.dismiss();
                SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                    title: "Success",
                    content: "You deleted the bike",
                    rightContent: "Close",
                    onPressedRight: ()=> SmartDialog.dismiss()
                ));
              }
              else {
                SmartDialog.show(
                    widget: EvieSingleButtonDialogCupertino(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }
            });

          },
        ));
  }
}

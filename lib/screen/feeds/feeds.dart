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
                  itemCount:
                  _notificationProvider.notificationList.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      endActionPane:  ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context){
                              print("slide");
                            },
                            backgroundColor: Color(0xFFFE4A49),
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

                            //     .then((result) {
                            //   if (result == true) {
                            //     changeToNotificationDetailsScreen(
                            //         context,
                            //         _notificationProvider
                            //             .notificationList.keys
                            //             .elementAt(index),
                            //         _notificationProvider
                            //             .notificationList.values
                            //             .elementAt(index));
                            //   } else {
                            //     SmartDialog.show(
                            //         widget: EvieSingleButtonDialogCupertino(
                            //             title: "Error",
                            //             content: "Try again",
                            //             rightContent: "Ok",
                            //             onPressedRight: () {
                            //               SmartDialog.dismiss();
                            //             }));
                            //   }
                            // });

                            ///Change to notification details page
                            ///Pass notification id then get details;
                            ///Notification = read id, compare with list, if match then send the key and value
                            /*
                                            showNotificationTile(
                                                _notificationProvider
                                                    .notificationList.keys
                                                    .elementAt(index),
                                                _notificationProvider
                                                .notificationList.values
                                                .elementAt(index));

                                             */
                          },
                          child: Padding(
                            padding:  EdgeInsets.only(top: 14.h, bottom: 14.h),
                            child: ListTile(
                                /// leading: CircleAvatar(
                                //   ///If mail unread then icon mailunread
                                //   child: _notificationProvider
                                //       .notificationList.values
                                //       .elementAt(index)
                                //       .isRead!
                                //       ? const Icon(
                                //     Icons.mail,
                                //     color: Colors.white,
                                //   )
                                //       : const Icon(
                                //     Icons.mark_email_unread,
                                //     color: Colors.white,
                                //   ),
                                //   backgroundColor: Color(0xff69489D),
                                // ),
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
                                      ),
                                    ),

                                    Visibility(
                                      visible: true,
                                      child: Row(
                                        children: [
                                          Align(
                                              alignment: AlignmentDirectional.bottomStart,
                                              child: EvieButton_ReversedColor(
                                                  onPressed: (){

                                                  },
                                                  child: Text(
                                                    "Decline",
                                                    style: TextStyle(fontSize: 17.sp,
                                                        color: EvieColors.PrimaryColor),
                                                  ),
                                                  height: 36.h,
                                                  width: 169.w)
                                          ),

                                          Align(
                                              alignment: AlignmentDirectional.bottomEnd,
                                              child: EvieButton(
                                                  onPressed: (){

                                                  },
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(fontSize: 17.sp,
                                                    color: Color(0xffECEDEB)),
                                                  ),
                                                  height: 36.h,
                                                  width: 169.w)
                                          ),

                                        ],
                                      ),
                                    ),

                                  ],
                                )),
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
}

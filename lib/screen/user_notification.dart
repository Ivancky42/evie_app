import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
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
import '../api/model/notification_model.dart';
import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_notification_dialog.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({Key? key}) : super(key: key);

  @override
  _UserNotificationState createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  late NotificationProvider _notificationProvider;
  late BikeProvider _bikeProvider;



  @override
  Widget build(BuildContext context) {
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);



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
                  }),
              const Text('Notification'),
            ],
          ),
        ),
        body: Scaffold(
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          "Dev-There are ${_notificationProvider.notificationList.length} "
                          "notifications in firestore"),
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                          height: 76.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ThemeChangeNotifier().isDarkMode(context) ==
                                    true
                                ? const Color(0xFF0F191D)
                                : const Color(0xffD7E9EF),
                          ),
                          child: Center(
                            child: ListView.separated(
                              itemCount:
                                  _notificationProvider.notificationList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () async {
                                      _notificationProvider
                                          .updateIsReadStatus(
                                              _notificationProvider
                                                  .notificationList.keys
                                                  .elementAt(index))
                                          .then((result) {
                                        if (result == true) {
                                          changeToNotificationDetailsScreen(
                                              context,
                                              _notificationProvider
                                                  .notificationList.keys
                                                  .elementAt(index),
                                              _notificationProvider
                                                  .notificationList.values
                                                  .elementAt(index));
                                        } else {
                                          SmartDialog.show(
                                              widget: EvieSingleButtonDialog(
                                                  title: "Error",
                                                  content: "Try again",
                                                  rightContent: "Ok",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                        }
                                      });

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
                                    child: ListTile(
                                        leading: CircleAvatar(
                                          ///If mail unread then icon mailunread
                                          child: _notificationProvider
                                                  .notificationList.values
                                                  .elementAt(index)
                                                  .isRead!
                                              ? const Icon(
                                                  Icons.mail,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Icons.mark_email_unread,
                                                  color: Colors.white,
                                                ),
                                          backgroundColor: Colors.cyan,
                                        ),
                                        title: Text(_notificationProvider
                                            .notificationList.values
                                            .elementAt(index)
                                            .title!),
                                        subtitle: Text(
                                          "${_notificationProvider.notificationList.values.elementAt(index).body!}\n\n${_notificationProvider.notificationList.values.elementAt(index).created!.toDate()}",
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
                                        )));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                          )),
                    ]))));
  }

  showNotificationTile(String key, NotificationModel notificationModel) {
    switch (notificationModel.type) {
      case "shareBike":
        {
          SmartDialog.show(
              widget: EvieNotificationDialog(
            title: notificationModel!.title!,
            content:
                "${notificationModel!.body!} \n\n ${notificationModel!.created?.toDate()}",

            ///Only available when status == pending
            rightContent: "Accept",

            leftContent: "Cancel",
            image: Image.asset(
              "assets/evieBike.png",
              width: 36,
              height: 36,
            ),
            onPressedLeft: () {
              SmartDialog.dismiss();
            },
            onPressedRight:

                ///No real time update
                notificationModel.status == "pending" ||
                        notificationModel.status == null
                    ? () async {
                        _bikeProvider
                            .updateAcceptSharedBikeStatus(
                                notificationModel!.deviceIMEI!)
                            .then((result) {
                          if (result == true) {
                            SmartDialog.dismiss();
                            _notificationProvider
                                .updateUserNotificationSharedBikeStatus(key);
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Success",
                                    content: "Bike added",
                                    rightContent: "OK",
                                    onPressedRight: () {
                                      SmartDialog.dismiss();
                                    }));
                          } else {
                            SmartDialog.dismiss();
                            SmartDialog.show(
                                widget: EvieSingleButtonDialog(
                                    title: "Error",
                                    content: "Bike not added, try again",
                                    rightContent: "OK",
                                    onPressedRight: () {
                                      SmartDialog.dismiss();
                                    }));
                          }
                        });
                      }
                    : null,
          ));
        }
        break;

      default:
        SmartDialog.show(
            widget: EvieSingleButtonDialog(
          //buttonNumber: "2",
          title: notificationModel!.title!,
          content:
              "${notificationModel!.body!} \n\n ${notificationModel!.created?.toDate()}",
          rightContent: "OK",
          onPressedRight: () {
            SmartDialog.dismiss();
          },
        ));
        break;
    }
  }
}

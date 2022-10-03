import 'dart:collection';
import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:sizer/sizer.dart';
import '../api/backend/stripe_api_caller.dart';
import '../api/constants.dart';
import '../api/model/notification_model.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/notification_provider.dart';
import '../main.dart';


///Default user home page if login is true(display bicycle info)
class UserHomeGeneral extends StatefulWidget {
  const UserHomeGeneral({Key? key}) : super(key: key);
  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  final FocusNode _textFocus = FocusNode();

  final TextEditingController _bikeNameController = TextEditingController();
  final TextEditingController _bikeIMEIController = TextEditingController();
  final CarouselController _pageController = CarouselController();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  bool isScroll = false;

  @override
  void initState() {
    _textFocus.addListener(() {
      onNameChange();
    });


    ///BG message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      String data = message.data["id"].toString();
      ///Pass notification id to get body and key
      await _notificationProvider.getNotificationFromNotificationId(data);

        Future.delayed(const Duration(milliseconds: 800), () {
          changeToNotificationDetailsScreen(
              context,
              _notificationProvider.singleNotificationList.keys.first,
              _notificationProvider.singleNotificationList.values.first);
        });
    });

    foreNotificationSetting();

    ///FG message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification!.hashCode,
          notification!.title,
          notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
            ),
          ),
          payload : message.data["id"].toString(),
        );
      }
    });
    super.initState();
  }

  ///Foreground notification setting
  Future foreNotificationSetting() async {

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(requestSoundPermission: false, onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification
    );
  }

  ///Foreground select Notification
  Future<void> onSelectNotification(String? payload) async {
    ///Pass notification id to get body and key
    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){

      Future.delayed(const Duration(milliseconds: 800), () {
        changeToNotificationDetailsScreen(
            context,
            _notificationProvider.singleNotificationList.keys.first,
            _notificationProvider.singleNotificationList.values.first);
      });
    });
  }


  ///IOS foreground message handler
  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    ///Pass notification id to get body and key
    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){

      Future.delayed(const Duration(milliseconds: 800), () {
        changeToNotificationDetailsScreen(
            context,
            _notificationProvider.singleNotificationList.keys.first,
            _notificationProvider.singleNotificationList.values.first);
      });
    });
  }


  @override
  void dispose() {
    _textFocus.dispose();
    super.dispose();
  }

  ///Update bike name in firebase once !focus
  void onNameChange() {
    if (!_textFocus.hasFocus) {
      String text = _bikeNameController.text.trim();

      _bikeProvider.updateBikeName(text);
    }
  }

  late List<String> imgList = [
    'assets/images/evie_bike_modelA.png',
    'assets/images/evie_bike_modelA.png',
  ];

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    LinkedHashMap userBikeList = _bikeProvider.userBikeList;

    ///Display "next", "back" button
    if (userBikeList.length > 1) {
      setState(() {
        isScroll = true;
      });
    } else {
      setState(() {
        isScroll = false;
      });
    }


    return Scaffold(
        //Body should change when bottom navigation bar state change
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          _textFocus.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: isScroll,
                      child: IconButton(
                        icon: const Image(
                          image:
                              AssetImage("assets/buttons/chg_to_left_bttn.png"),
                        ),
                        onPressed: () {
                          _bikeProvider.controlBikeList("back");
                        },
                      ),
                    ),
                    SizedBox(
                      height: 150,
                    width: 180,
                    child: CarouselSlider(
                      carouselController: _pageController,
                      items: imgList.map((item)=> Container(
                        child:Center(
                          child: Image.asset(
                            item,
                            fit: BoxFit.cover,
                            width: 800,
                            height: 100,
                          ),
                        ),
                      )).toList(),
                      options: CarouselOptions(
                        onPageChanged: (index, reason){
                          var _currentCarouIndex = 0;

                          if(index >= _currentCarouIndex) {
                            _bikeProvider.controlBikeList("next");
                          }
                          else{
                            _bikeProvider.controlBikeList("back");
                          }
                        },

                        enableInfiniteScroll: true,
                        autoPlay: false,
                        enlargeCenterPage: true,
                      )
                    ),
                  ),

                    Visibility(
                      visible: isScroll,
                      child: IconButton(
                        icon: const Image(
                          image: AssetImage(
                              "assets/buttons/chg_to_right_bttn.png"),
                        ),
                        onPressed: () {
                          _bikeProvider.controlBikeList("next");
                        },
                      ),
                    ),
                  ],
                ),

                TextFormField(
                  enabled: true,
                  focusNode: _textFocus,
                  controller: _bikeNameController
                    ..text =
                        _bikeProvider.currentBikeModel?.bikeName.trim() ?? 'Empty',
                  style: const TextStyle(
                      fontFamily: 'Raleway-Bold', fontSize: 18.0),
                  decoration: const InputDecoration.collapsed(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(
                  height: 30.0,
                ),

                TextFormField(
                  enabled: false,
                  controller: _bikeIMEIController
                    ..text =
                        _bikeProvider.currentBikeModel?.deviceIMEI ?? 'Empty',
                  style: const TextStyle(
                      fontFamily: 'Raleway-Bold', fontSize: 18.0),
                  decoration: const InputDecoration.collapsed(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(
                  height: 50.0,
                ),

                EvieButton_LightBlue(
                  height: 12.2.h,
                  width: double.infinity,
                  child: const Text(
                    "Connect To Bike",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
                            //buttonNumber: "2",
                            title: "Connect",
                            content: "In progress",
                            leftContent: "Cancel",
                            rightContent: "Ok",
                            image: Image.asset(
                              "assets/evieBike.png",
                              width: 36,
                              height: 36,
                            ),
                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  },
                ),

                ///Delete bike for development purpose
                EvieButton_LightBlue(
                  height: 12.2.h,
                  width: double.infinity,
                  child: const Text(
                    "Delete Bike_Development",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
                            //buttonNumber: "2",
                            title: "Delete bike",
                            content:
                                "Are you sure you want to delete this bike?",
                            leftContent: "Cancel",
                            rightContent: "Delete",
                            image: Image.asset(
                              "assets/evieBike.png",
                              width: 36,
                              height: 36,
                            ),
                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              try {
                                SmartDialog.dismiss();
                                bool result = _bikeProvider
                                    .deleteBike(_bikeProvider.currentBikeModel!.deviceIMEI.trim());
                                if(result == true) {
                                  SmartDialog.show(
                                      widget:EvieSingleButtonDialog(
                                          title: "Success",
                                          content: "Successfully delete bike",
                                          rightContent: "OK",
                                          onPressedRight: () {
                                            SmartDialog.dismiss();
                                          }
                                      )
                                  );
                                }else{
                                  SmartDialog.show(
                                    widget:EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Error delete bike, try again",
                                        rightContent: "OK",
                                        onPressedRight: () {SmartDialog.dismiss();}
                                        )
                                  );
                                }
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                            }));
                  },
                ),


                EvieButton_LightBlue(
                  height: 12.2.h,
                  width: double.infinity,
                  child: const Text(
                    "Share Bike",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    changeToShareBikeScreen(context);
                  },
                ),


                ///Sign out for development purpose
                /*
              EvieButton_LightBlue(
                width: double.infinity,
                child: const Text("Sign Out",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                onPressed: () {
                  _currentUser.signOut();
                },
              ),
               */

                 SizedBox(
                  height: 1.h,
                ),
              ]),
        ),
      ),
    ));
  }




}

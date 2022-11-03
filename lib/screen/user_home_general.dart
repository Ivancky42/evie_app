import 'dart:collection';
import 'dart:math';
import 'package:evie_test/screen/stripe_checkout.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/widgets/evie_oval.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:sizer/sizer.dart';
import '../api/backend/stripe_api_caller.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/current_user_provider.dart';
import '../api/provider/notification_provider.dart';
import '../api/todays_quote.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../main.dart';
import '../profile/user_home_page.dart';
import 'login_page.dart';

///Default user home page if login is true(display bicycle info)
class UserHomeGeneral extends StatefulWidget {
  const UserHomeGeneral({Key? key}) : super(key: key);

  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;

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

      FutureBuilder(
          future: _notificationProvider.getNotificationFromNotificationId(data),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              changeToNotificationDetailsScreen(
                context,
                _notificationProvider.currentSingleNotification?.notificationId,
                _notificationProvider.currentSingleNotification,

                //   _notificationProvider.singleNotificationList.keys.first,
                //   _notificationProvider.singleNotificationList.values.first
              );
              return const Text("");
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          });

      /*
      ///Future builder
        Future.delayed(const Duration(milliseconds: 800), () {
          changeToNotificationDetailsScreen(
              context,
              _notificationProvider.currentSingleNotification?.notificationId,
              _notificationProvider.currentSingleNotification,

           //   _notificationProvider.singleNotificationList.keys.first,
           //   _notificationProvider.singleNotificationList.values.first
              );
        });


       */
    });

    foreNotificationSetting();

    ///android FG message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
            ),
          ),
          payload: message.data["id"].toString(),
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
        IOSInitializationSettings(
            requestSoundPermission: false,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  ///Foreground select Notification android
  Future<void> onSelectNotification(String? payload) async {
    ///Pass notification id to get body and key

    FutureBuilder(
        future:
            _notificationProvider.getNotificationFromNotificationId(payload),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            changeToNotificationDetailsScreen(
              context,
              _notificationProvider.currentSingleNotification?.notificationId,
              _notificationProvider.currentSingleNotification,

              //   _notificationProvider.singleNotificationList.keys.first,
              //   _notificationProvider.singleNotificationList.values.first
            );
            return const Text("");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });

    /*
    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){

      ///Future builder
      Future.delayed(const Duration(milliseconds: 800), () {
        changeToNotificationDetailsScreen(
          context,
          _notificationProvider.currentSingleNotification?.notificationId,
          _notificationProvider.currentSingleNotification,

          //   _notificationProvider.singleNotificationList.keys.first,
          //   _notificationProvider.singleNotificationList.values.first
        );
      });

    });


     */
  }

  ///IOS foreground message handler
  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    ///Pass notification id to get body and key
    _notificationProvider.getNotificationFromNotificationId(payload);

    if (_notificationProvider.currentSingleNotification?.notificationId !=
        null) {
      changeToNotificationDetailsScreen(
        context,
        _notificationProvider.currentSingleNotification?.notificationId,
        _notificationProvider.currentSingleNotification,

        //   _notificationProvider.singleNotificationList.keys.first,
        //   _notificationProvider.singleNotificationList.values.first
      );
    }

    /*
    FutureBuilder(
        future: _notificationProvider.getNotificationFromNotificationId(payload),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            changeToNotificationDetailsScreen(
              context,
              _notificationProvider.currentSingleNotification?.notificationId,
              _notificationProvider.currentSingleNotification,

              //   _notificationProvider.singleNotificationList.keys.first,
              //   _notificationProvider.singleNotificationList.values.first
            );
            return const Text("");
          }
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );

     */
    /*
    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){


      ///Future builder
      Future.delayed(const Duration(milliseconds: 800), () {
        changeToNotificationDetailsScreen(
          context,
          _notificationProvider.currentSingleNotification?.notificationId,
          _notificationProvider.currentSingleNotification,

          //   _notificationProvider.singleNotificationList.keys.first,
          //   _notificationProvider.singleNotificationList.values.first
        );
      });
    });

     */
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
    'assets/images/bike_HPStatus/bike_normal.png',
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

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

    return Scaffold(body: _buildChild(userBikeList));
  }

  Widget _buildChild(LinkedHashMap userBikeList) {
    bool _unlock = false;

    Color lockColour = const Color(0xff6A51CA);

    Image addBikeImage = Image(
      image: const AssetImage("assets/buttons/plus.png"),
      height: 3.h,
      fit: BoxFit.fitWidth,
    );

    Image lockImage = Image(
      image: const AssetImage("assets/buttons/lock_unlock.png"),
      height: 2.5.h,
      fit: BoxFit.fitWidth,
    );

    if (_unlock == false) {
      lockImage = Image(
        image: const AssetImage("assets/buttons/lock_lock.png"),
        height: 2.5.h,
        fit: BoxFit.fitWidth,
      );
      lockColour = const Color(0xff6A51CA);
    } else if (_unlock == true) {
      lockImage = Image(
        image: AssetImage("assets/buttons/lock_unlock.png"),
        height: 2.5.h,
        fit: BoxFit.fitWidth,
      );
      lockColour = const Color(0xff404E53);
    }

    if (!userBikeList.isNotEmpty) {
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          height: 5.h,
                          child: FutureBuilder(
                              future:
                                  _currentUserProvider.fetchCurrentUserModel,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return AnimatedTextKit(
                                      repeatForever: true,
                                      animatedTexts: [
                                        FadeAnimatedText(
                                            "Good Morning ${_currentUserProvider.currentUserModel!.name}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                        FadeAnimatedText(
                                            "${_currentUserProvider.randomQuote}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            textStyle: TextStyle(
                                                fontSize: 9.sp,
                                                fontFamily: "Avenir-Light",
                                                fontWeight: FontWeight.w200),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                      ]);
                                } else {
                                  return const Center(
                                    child: Text("Good Morning"),
                                  );
                                }
                              }),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 2.h,
                    ),

                    TextFormField(
                      textAlign: TextAlign.center,
                      enabled: false,
                      focusNode: _textFocus,
                      controller: _bikeNameController..text = 'Add New Bike',
                      style: const TextStyle(
                          fontFamily: 'Avenir-SemiBold', fontSize: 16.0),
                      decoration: const InputDecoration.collapsed(
                        hintText: "",
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(
                              "assets/icons/battery_empty.png"),
                          height: 1.h,
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        const Text("0%"),
                      ],
                    ),

                    SizedBox(
                      height: 4.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20.h,
                          width: 90.w,
                          child: Image(
                            image: const AssetImage(
                                "assets/images/bike_HPStatus/bike_empty.png"),
                            height: 200.h,
                            colorBlendMode: BlendMode.overlay,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30.0,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 10.w,
                          child: const Image(
                            image: AssetImage("assets/buttons/bike_unlock.png"),
                            height: 24.0,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Security Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              "NOT AVAILABLE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            child: const Image(
                              image:
                                  AssetImage("assets/buttons/carbon_seed.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Carbon Foorprint",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "0g",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const VerticalDivider(
                            thickness: 1,
                          ),
                          Container(
                            width: 10.w,
                            child: const Image(
                              image: AssetImage("assets/buttons/calories.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Calories",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "0kcal",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 500,
                    ),

                    EvieButton(
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
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Delete Bike_Development",
                        style: TextStyle(
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
                                    bool result = _bikeProvider.deleteBike(
                                        _bikeProvider
                                            .currentBikeModel!.deviceIMEI
                                            .trim());
                                    if (result == true) {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialog(
                                              title: "Success",
                                              content:
                                                  "Successfully delete bike",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    } else {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialog(
                                              title: "Error",
                                              content:
                                                  "Error delete bike, try again",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }));
                      },
                    ),

                    EvieButton(
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

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Checkout plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        // StripeApiCaller.redirectToCheckout("price_1Lp0yCBjvoM881zMsahs6rkP", customerId).then((sessionId) {
                        //   changeToCheckoutScreen(context, sessionId);
                        // });
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Change Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.changeSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l", "price_1Lp11KBjvoM881zM7rIdanjj", "si_MY7fGJWs01DGF5");
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Cancel Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.cancelSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l");
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "RFID card",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        changeToRFIDScreen(context);
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Sign out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () async {
                        try {

                          _authProvider.signOut(context).then((result){
                            if(result == true){

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
                    ),

                    SizedBox(
                      height: 1.h,
                    ),
                  ]),
            ),
          ),
        ),

        floatingActionButton: SizedBox(
          height: 10.8.h,
          width: 10.8.h,
          child: FittedBox(
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: lockColour,
              onPressed: () {

                changeToUserBluetoothScreen(context);
              },

              //icon inside button
              child: addBikeImage,
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    } else {
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          height: 5.h,
                          child: FutureBuilder(
                              future:
                                  _currentUserProvider.fetchCurrentUserModel,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return AnimatedTextKit(
                                      repeatForever: true,
                                      animatedTexts: [
                                        FadeAnimatedText(
                                            "Good Morning ${_currentUserProvider.currentUserModel!.name}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                        FadeAnimatedText(
                                            "${_currentUserProvider.randomQuote}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            textStyle: TextStyle(
                                                fontSize: 9.sp,
                                                fontFamily: "Avenir-Light",
                                                fontWeight: FontWeight.w200),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                      ]);
                                } else {
                                  return const Center(
                                    child: Text("Good Morning"),
                                  );
                                }
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),

                    TextFormField(
                      textAlign: TextAlign.center,
                      enabled: true,
                      focusNode: _textFocus,
                      controller: _bikeNameController
                        ..text =
                            _bikeProvider.currentBikeModel?.bikeName.trim() ??
                                'Empty',
                      style: const TextStyle(
                          fontFamily: 'Avenir-SemiBold', fontSize: 16.0),
                      decoration: const InputDecoration.collapsed(
                        hintText: "",
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image:
                              const AssetImage("assets/icons/battery_full.png"),
                          height: 1.h,
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        const Text("100%"),
                        SizedBox(
                          width: 1.w,
                        ),
                        EvieOvalGray(
                            height: 3.h, width: 20.w, text: "Est. 50km"),
                      ],
                    ),

                    SizedBox(
                      height: 4.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        /*
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

                     */

                        SizedBox(
                          height: 20.h,
                          width: 90.w,
                          child: CarouselSlider(
                              carouselController: _pageController,
                              items: imgList
                                  .map((item) => Container(
                                        child: Center(
                                          child: Image.asset(
                                            item,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 200.h,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  var _currentCarouIndex = 0;

                                  if (index >= _currentCarouIndex) {
                                    _bikeProvider.controlBikeList("next");
                                  } else {
                                    _bikeProvider.controlBikeList("back");
                                  }
                                },
                                enableInfiniteScroll: true,
                                autoPlay: false,
                                enlargeCenterPage: true,
                              )),
                        ),

                        /*
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

                     */
                      ],
                    ),

                    const SizedBox(
                      height: 30.0,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 10.w,
                          child: const Image(
                            image: AssetImage("assets/buttons/bike_unlock.png"),
                            height: 24.0,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Security Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            const Text(
                              "UNLOCKED & READY TO GO",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            child: const Image(
                              image:
                                  AssetImage("assets/buttons/carbon_seed.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Carbon Foorprint",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "12g",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  EvieOvalGray(
                                      height: 3.h, width: 15.w, text: "Today"),
                                ],
                              ),
                            ],
                          ),
                          const VerticalDivider(
                            thickness: 1,
                          ),
                          Container(
                            width: 10.w,
                            child: const Image(
                              image: AssetImage("assets/buttons/calories.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Calories",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "12kcal",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  EvieOvalGray(
                                      height: 3.h, width: 15.w, text: "Today"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 500.0,
                    ),

                    EvieButton(
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
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Delete Bike",
                        style: TextStyle(
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
                                    bool result = _bikeProvider.deleteBike(
                                        _bikeProvider
                                            .currentBikeModel!.deviceIMEI
                                            .trim());
                                    if (result == true) {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialog(
                                              title: "Success",
                                              content:
                                                  "Successfully delete bike",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    } else {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialog(
                                              title: "Error",
                                              content:
                                                  "Error delete bike, try again",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }));
                      },
                    ),

                    EvieButton(
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

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Checkout plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        // StripeApiCaller.redirectToCheckout("price_1Lp0yCBjvoM881zMsahs6rkP", customerId).then((sessionId) {
                        //   changeToCheckoutScreen(context, sessionId);
                        // });
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Change Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.changeSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l", "price_1Lp11KBjvoM881zM7rIdanjj", "si_MY7fGJWs01DGF5");
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Cancel Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.cancelSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l");
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "RFID card",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        changeToRFIDScreen(context);
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Sign out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () async {
                        try {

                          _authProvider.signOut(context).then((result){
                            if(result == true){

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
                    ),

                    SizedBox(
                      height: 1.h,
                    ),
                  ]),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          height: 10.8.h,
          width: 10.8.h,
          child: FittedBox(
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: lockColour,
              onPressed: () {
                setState(() {
                  _unlock = !_unlock;
                });
              },

              //icon inside button
              child: lockImage,
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }
}

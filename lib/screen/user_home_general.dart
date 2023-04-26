import 'dart:collection';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/screen/user_home_page/add_new_bike/add_new_bike.dart';
import 'package:evie_test/screen/user_home_page/free_plan/free_plan.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/paid_plan.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/paid_plan2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import '../api/dialog.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/current_user_provider.dart';
import '../api/provider/notification_provider.dart';
import '../api/snackbar.dart';
import '../bluetooth/modelResult.dart';
import '../main.dart';

///Default user home page if login is true(display bicycle info)
class UserHomeGeneral extends StatefulWidget {
  const UserHomeGeneral({Key? key}) : super(key: key);

  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late NotificationProvider _notificationProvider;
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;
  DeviceConnectResult? deviceConnectResult;
  bool isFirstTimeConnected = false;

  final FocusNode _textFocus = FocusNode();

  final TextEditingController _bikeNameController = TextEditingController();
  final TextEditingController _bikeIMEIController = TextEditingController();
  final CarouselController _pageController = CarouselController();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  bool isScroll = false;
  late ScaffoldMessengerState _navigator;

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

      Future.delayed(Duration.zero, () {
        changeToFeedsScreen(context);
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

    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){
      changeToFeedsScreen(context);
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

    await _notificationProvider.getNotificationFromNotificationId(payload).then((result){
      changeToFeedsScreen(context);
    });

    // if (_notificationProvider.currentSingleNotification?.notificationId !=
    //     null) {
    //
    //   changeToNotificationScreen(context);
    //   // changeToNotificationDetailsScreen(
    //   //   context,
    //   //   _notificationProvider.currentSingleNotification?.notificationId,
    //   //   _notificationProvider.currentSingleNotification,
    //   //
    //   //   //   _notificationProvider.singleNotificationList.keys.first,
    //   //   //   _notificationProvider.singleNotificationList.values.first
    //   // );
    // }

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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _navigator = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    hideCurrentSnackBar(_navigator);
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
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
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

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      if (!isFirstTimeConnected) {
        showConnectionStatusToast(_bluetoothProvider, isFirstTimeConnected, context, _navigator);
        isFirstTimeConnected = true;
      }
    }
    else if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice != _bikeProvider.currentBikeModel?.macAddr) {
      isFirstTimeConnected = false;
    }
    else {
      isFirstTimeConnected = false;
      showConnectionStatusToast(_bluetoothProvider, isFirstTimeConnected, context, _navigator);
    }

    return WillPopScope(
        onWillPop: () async {
          bool? exitApp = await showQuitApp() as bool?;
          return exitApp ?? false;
        },

        child: Scaffold(
            body: _buildChild(userBikeList),
        )
    );
  }

  Widget _buildChild(LinkedHashMap userBikeList) {
    if (_bikeProvider.isReadBike && _bikeProvider.currentBikeModel == null && !userBikeList.isNotEmpty) {
      return const AddNewBike();
    } else {
        if (_bikeProvider.currentBikeModel != null && _bikeProvider.isPlanSubscript == true) {
          return const PaidPlan2();
        } else if (_bikeProvider.currentBikeModel != null && _bikeProvider.isPlanSubscript == false) {
          return const FreePlan();
        }else{

          ///For not become unlimited Circular
           //if(_bikeProvider.userBikeList.isNotEmpty) _bikeProvider.controlBikeList("first");
          return const Center(child: CircularProgressIndicator());
        }
    }
  }

}

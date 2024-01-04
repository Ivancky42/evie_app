import 'dart:collection';
import 'dart:convert';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/shared_pref_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/screen/user_home_page/add_new_bike/add_new_bike.dart';
import 'package:evie_test/screen/user_home_page/bike_loading.dart';
import 'package:evie_test/screen/user_home_page/free_plan/free_plan.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/paid_plan.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/paid_plan.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import '../api/colours.dart';
import '../api/dialog.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/current_user_provider.dart';
import '../api/provider/notification_provider.dart';
import '../api/snackbar.dart';
import '../bluetooth/modelResult.dart';
import '../main.dart';
import '../widgets/evie_appbar.dart';

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
  late SharedPreferenceProvider _sharedPreferenceProvider;
  DeviceConnectResult? deviceConnectResult;
  bool isFirstTimeConnected = false;
  bool isLoading = true;

  final FocusNode _textFocus = FocusNode();

  final TextEditingController _bikeNameController = TextEditingController();
  final TextEditingController _bikeIMEIController = TextEditingController();
  final CarouselController _pageController = CarouselController();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  bool isScroll = false;
  late ScaffoldMessengerState _navigator;

  @override
  void initState() {
    _authProvider = context.read<AuthProvider>();
    _currentUserProvider = context.read<CurrentUserProvider>();
    _sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    fetchData(_authProvider, _currentUserProvider, context);
    _textFocus.addListener(() {
      onNameChange();
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        Map<String, dynamic> payloadData = {
          'title': notification?.title,
          'body': notification?.body,
          'data': message.data,
          // Include any other fields you need
        };

        // Convert the map to a JSON string
        String payloadJson = jsonEncode(payloadData);
        onSelectNotification(payloadJson);
      }
    });

    ///Background message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      // String data = message.data["id"].toString();
      //
      // print("aaaaaaaaaaaaaa");
      // print(message.notification?.title);
      // print(message.notification?.body);
      // print(message.data['deviceIMEI']);
      // print(message.data["id"]);
      //
      // Future.delayed(Duration.zero, () {
      //   changeToFeedsScreen(context);
      // });

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> payloadData = {
        'title': notification?.title,
        'body': notification?.body,
        'data': message.data,
        // Include any other fields you need
      };

      // Convert the map to a JSON string
      String payloadJson = jsonEncode(payloadData);
      onSelectNotification(payloadJson);

    });

    foreNotificationSetting();


    ///android Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        // Convert the message to JSON string
        Map<String, dynamic> payloadData = {
          'title': notification.title,
          'body': notification.body,
          'data': message.data,
          // Include any other fields you need
        };

        // Convert the map to a JSON string
        String payloadJson = jsonEncode(payloadData);

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'test_notification',
            ),
          ),
          payload: payloadJson,
        );
      }
    });
    super.initState();
  }

  Future<void> fetchData(_authProvider, _currentUserProvider, context) async {
    final result = await _currentUserProvider.checkUserAccount(_authProvider.getUid);
    if (result == 'INVALID_USER') {
      await _authProvider.signOut(context);
      changeToWelcomeScreen(context);
    }
    else if (result == 'VALID_USER'){
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    hideCurrentSnackBar(_navigator);
    _textFocus.dispose();
    super.dispose();
  }



  ///Foreground notification setting
  Future foreNotificationSetting() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('test_notification');
    //const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

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

  ///Android foreground message handler
  Future<void> onSelectNotification(String? payload) async {

    if (payload != null) {
      // Convert JSON string to Dart map
      Map<String, dynamic> payloadMap = jsonDecode(payload);
      // Access the fields in the map
      String title = payloadMap['title'];
      String body = payloadMap['body'];
      Map<String, dynamic> data = payloadMap['data'];

      String action = data['action'];
      String deviceIMEI = data['deviceIMEI'];
      if (action == 'unlock' || action == 'lock' || action == 'connection-lost' || action == 'movement-detect' || action == 'fall-detect' || action == 'theft-attempt') {
        await _bikeProvider.changeBikeUsingIMEI(deviceIMEI);
      }
      else {
        Future.delayed(Duration.zero, () {
          changeToFeedsScreen(context);
        });
      }
    }
  }

  ///IOS foreground message handler
  void onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {
      Future.delayed(Duration.zero, () {
        changeToFeedsScreen(context);
      });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _navigator = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  ///Update bike name in firebase once !focus
  void onNameChange() {
    if (!_textFocus.hasFocus) {
      String text = _bikeNameController.text.trim();
      _bikeProvider.updateBikeName(text);
    }
  }


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
        if (!_bikeProvider.isBlockToast) {
          showConnectionStatusToast(
              _bluetoothProvider, isFirstTimeConnected, context, _navigator);
          isFirstTimeConnected = true;
        }
      }
    }
    else if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice != _bikeProvider.currentBikeModel?.macAddr) {
      isFirstTimeConnected = false;
    }
    else {
      if (!_bikeProvider.isBlockToast) {
        isFirstTimeConnected = false;
        showConnectionStatusToast(
            _bluetoothProvider, isFirstTimeConnected, context, _navigator);
      }
    }

    return WillPopScope(
        onWillPop: () async {
          bool? exitApp = await showQuitApp() as bool?;
          return exitApp ?? false;
        },

        child: Scaffold(
            //backgroundColor: EvieColors.lightBlack,
            appBar: EmptyAppbar(),
            body: isLoading ? Center(child: BikeLoading()) :
            _buildChild(userBikeList),
        )
    );
  }

  Widget _buildChild(LinkedHashMap userBikeList) {
    if (_bikeProvider.isReadBike && !userBikeList.isNotEmpty) {
      return const AddNewBike();
    }
    else {
      if (_bikeProvider.currentBikeModel != null && _bikeProvider.isPlanSubscript == true && _bikeProvider.userBikeList.isNotEmpty) {
        return const PaidPlan();
      }
      else if (_bikeProvider.currentBikeModel != null && _bikeProvider.isPlanSubscript == false && _bikeProvider.userBikeList.isNotEmpty) {
        return const FreePlan();
      }
      else{
        ///For not become unlimited Circular
        return Center(child: BikeLoading());
      }
    }
  }

}

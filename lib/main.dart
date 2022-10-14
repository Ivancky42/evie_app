import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/share_bike.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/user_notification.dart';
import 'package:evie_test/screen/user_notification_details.dart';
import 'package:evie_test/theme/ThemeChangeNotifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evie_test/screen/signup_page.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/forget_your_password.dart';
import 'package:evie_test/theme/AppTheme.dart';
import 'package:evie_test/api/routes.dart';
import 'package:evie_test/profile/user_home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:evie_test/profile/user_change_password.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/theme/ThemeChangeNotifier.dart';
import 'package:evie_test/screen/connect_bluetooth_device_page.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:sizer/sizer.dart';

import 'api/model/user_model.dart';
import 'api/provider/auth_provider.dart';
import 'api/provider/bike_provider.dart';
import 'api/provider/location_provider.dart';
import 'api/provider/notification_provider.dart';


///Main function execution
Future main() async {
  ///Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ///Dotnet file loading
  await dotenv.load(fileName: "env");

  ///Handle firebase cloud message
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      playSound: true,
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  ///Provider
  runApp(const AppProviders(
    child: MyApp(),
  )
  );
}

///Multi provider setup
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(),
          ),
          ChangeNotifierProvider<ThemeChangeNotifier>(
            create: (context) => ThemeChangeNotifier(),
          ),
      ///    ChangeNotifierProvider<LocationProvider>(
      ///      create: (context) => LocationProvider(),
      ///    ),
          ChangeNotifierProxyProvider<AuthProvider, CurrentUserProvider>(
              lazy: false,
              create: (_) => CurrentUserProvider(),
              update: (_, authProvider, currentUserProvider) {
                return currentUserProvider!
                  ..init(authProvider.getUid);
              }
          ),
          ChangeNotifierProxyProvider<CurrentUserProvider, BikeProvider>(
              lazy: true,
              create: (_) => BikeProvider(),
              update: (_, currentUserProvider, bikeProvider) {
                return bikeProvider!
                  ..init(currentUserProvider.getCurrentUserModel);
              }
          ),
          ChangeNotifierProxyProvider<CurrentUserProvider, BluetoothProvider>(
              lazy: true,
              create: (_) => BluetoothProvider(),
              update: (_, currentUserProvider, bluetoothProvider) {
                return bluetoothProvider!
                  ..init(currentUserProvider.getCurrentUserModel);
              }
          ),
          ChangeNotifierProxyProvider<CurrentUserProvider, NotificationProvider>(
              lazy: true,
              create: (_) => NotificationProvider(),
              update: (_, currentUserProvider, notificationProvider) {
                return notificationProvider!
                  ..init(currentUserProvider.getCurrentUserModel);
              }
          ),
          ChangeNotifierProxyProvider<BikeProvider, LocationProvider>(
              lazy: true,
              create: (_) => LocationProvider(),
              update: (_, bikeProvider, locationProvider) {
                return locationProvider!
                  ..init(bikeProvider.currentBikeModel?.location);
              }
          ),
        ],
        child: child
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = Provider.of<AuthProvider>(context);

    return Sizer(builder: (context, orientation, deviceType) {

      return MaterialApp(
        title: 'Evie',

        themeMode: ThemeMode.system,

        //Light theme data
        theme: AppTheme.lightTheme,

        //Change the app to dark theme when user's phone is set to dark mode
        darkTheme: AppTheme.darkTheme,

        initialRoute:
        _authProvider.isLogin == true ? '/userHomePage' : '/signIn',

        ///Routes setting for page navigation
        routes: {
          "/signIn": (context) => const SignIn(),
          "/signUp": (context) => const SignUp(),
          "/forgetPassword": (context) => const ForgetYourPassword(),
          "/userProfile": (context) => const UserProfile(),
          "/userHomePage": (context) => const UserHomePage(),
          "/userBluetooth": (context) => const UserHomeBluetooth(),
          "/userChangePassword": (context) => const UserChangePassword(),
          "/testBle": (context) => const TestBle(),
          "/shareBike": (context) => const ShareBike(),
          "/notification": (context) => const UserNotification(),
        },

        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      );
    });
  }
}

/// CREATE A [AndroidNotificationChannel] FOR HEADS UP NOTIFICATIONS
late AndroidNotificationChannel channel;

/// INITIALIZE THE [FlutterLocalNotificationsPlugin] PACKAGE
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// ANDROID BACKGROUND MESSAGE HANDLER
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message : ${message.messageId}');
  debugPrint('Background message data: ${message.data["id"]}');

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
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
      payload : channel.id,
    );
  }
}




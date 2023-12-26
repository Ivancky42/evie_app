import 'dart:convert';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/provider/ride_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/provider/shared_pref_provider.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/account_verified.dart';
import 'package:evie_test/screen/input_name.dart';
import 'package:evie_test/screen/my_account/edit_profile.dart';
import 'package:evie_test/screen/my_account/enter_new_password.dart';
import 'package:evie_test/screen/my_account/verify_password.dart';
import 'package:evie_test/screen/onboarding_addNewBike/before_you_start.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/user_change_password.dart';
import 'package:evie_test/screen/verify_email.dart';
import 'package:evie_test/screen/welcome_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/screen/forget_your_password.dart';
import 'package:evie_test/theme/AppTheme.dart';
import 'package:evie_test/screen/user_home_page/user_home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'api/colours.dart';
import 'api/provider/auth_provider.dart';
import 'api/provider/bike_provider.dart';
import 'api/provider/firmware_provider.dart';
import 'api/provider/location_provider.dart';
import 'api/provider/notification_provider.dart';


///Main function execution
Future main() async {
  ///Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ///Dotnet file loading
  await dotenv.load(fileName: "env");

  // Upgrader
  // Only call clearSavedSettings() during testing to reset internal values.
  await Upgrader.clearSavedSettings();

  ///Handle firebase cloud message
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      playSound: true,
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
      ///Setting lazy to true delays the creation of the provider's instance until it is first accessed,
      ///while setting it to false creates the instance immediately when the Provider widget is built.
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            lazy: true,
            create: (context) => AuthProvider(),
          ),
          ChangeNotifierProvider<SettingProvider>(
            lazy: true,
            create: (context) => SettingProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, CurrentUserProvider>(
              lazy: true,
              create: (_) => CurrentUserProvider(),
              update: (_, authProvider, currentUserProvider) {
                return currentUserProvider!
                  ..update(authProvider.getUid);
              }
          ),
          ChangeNotifierProxyProvider<CurrentUserProvider, BikeProvider>(
              lazy: true,
              create: (_) => BikeProvider(),
              update: (_, currentUserProvider, bikeProvider) {
                return bikeProvider!
                  ..update(currentUserProvider.getCurrentUserModel);
              }
          ),
          ChangeNotifierProxyProvider< BikeProvider, BluetoothProvider>(
              lazy: true,
              create: (_) => BluetoothProvider(),
              update: (_, bikeProvider, bluetoothProvider) {
                return bluetoothProvider!
                  ..update(bikeProvider.currentBikeModel);
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
              lazy: false,
              create: (_) => LocationProvider(),
              update: (_, bikeProvider, locationProvider) {
                return locationProvider!
                  ..update(bikeProvider.currentBikeModel?.location, bikeProvider.getThreatRoutesLists);
              }
          ),
          ChangeNotifierProxyProvider<BikeProvider, FirmwareProvider>(
              lazy: false,
              create: (_) => FirmwareProvider(),
              update: (_, bikeProvider, firmwareProvider) {
                return firmwareProvider!
                  ..update(bikeProvider.currentBikeModel);
              }
          ),
          // ChangeNotifierProxyProvider<BikeProvider, TripProvider>(
          //     lazy: true,
          //     create: (_) => TripProvider(),
          //     update: (_, bikeProvider, tripProvider) {
          //       return tripProvider!
          //         ..update(bikeProvider.currentBikeModel);
          //     }
          // ),
          ChangeNotifierProxyProvider2<BikeProvider, SettingProvider, RideProvider>(
              lazy: true,
              create: (_) => RideProvider(),
              update: (_, bikeProvider, settingProvider, rideProvider) {
                return rideProvider!
                  ..update(bikeProvider.currentBikeModel, settingProvider.currentMeasurementSetting);
              }
          ),
          ChangeNotifierProxyProvider2<CurrentUserProvider, BikeProvider, PlanProvider>(
              lazy: true,
              create: (context) => PlanProvider(),
              update: (_, currentUserProvider, bikeProvider, planProvider) {
                return planProvider!..update(currentUserProvider.getCurrentUserModel, bikeProvider.currentBikeModel);
              }
          ),
          ChangeNotifierProxyProvider2<CurrentUserProvider, BikeProvider, SharedPreferenceProvider>(
            lazy: true,
            create: (_) => SharedPreferenceProvider(),
            update: (_, currentUserProvider, bikeProvider, sharedPreferenceProvider) {
              return sharedPreferenceProvider!..update(
                  currentUserProvider.getCurrentUserModel,
                  currentUserProvider.currentUserModel?.notificationSettings,
                  bikeProvider.userBikeDetails,
              );
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
    SettingProvider _settingProvider = Provider.of<SettingProvider>(context);
    //_settingProvider.init();

    // // Call the version check when the app starts
    // WidgetsBinding.instance?.addPostFrameCallback((_) => checkAppVersion(context, _settingProvider.minRequiredVersion));

    decideMainPage() {
      if (_authProvider.isLogin == true) {
        if (_authProvider.isEmailVerified == true) {
          if (_authProvider.isFirstLogin == false) {
            return '/';
          } else {
            return '/letsGo';
          }
        } else {
          return '/verifyEmail';
        }
      } else {
        return '/welcome';
      }
    }


    return Sizer(builder: (context, orientation, deviceType) {

      return AnnotatedRegion<SystemUiOverlayStyle>(

        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: EvieColors.transparent,
        ),

        child: MaterialApp(
          title: 'Evie Bike',
          themeMode: _settingProvider.currentThemeMode,

          //Light theme data
          theme: AppTheme.lightTheme,

          //Change the app to dark theme when user's phone is set to dark mode
          darkTheme: AppTheme.lightTheme,
          initialRoute: decideMainPage(),
          // _authProvider.isLogin == true ? '/userHomePage' : '/welcome',

          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/':
                return MaterialWithModalsPageRoute(
                    builder: (_) => UserHomePage(0),
                    settings: settings);
              case '/feed':
                return MaterialWithModalsPageRoute(
                    builder: (_) => UserHomePage(1),
                    settings: settings);
              case '/account':
                return MaterialWithModalsPageRoute(
                    builder: (_) => UserHomePage(2),
                    settings: settings);
            }
            return null;
          },

          ///Routes setting for page navigation
          routes: {
            "/welcome": (context) => const Welcome(),
            "/inputName": (context) => const InputName(),
            // "/signInMethod": (context) => const SignInMethod(),
            "/verifyEmail": (context) => const VerifyEmail(),
            "/accountVerified": (context) => const AccountVerified(),
            "/letsGo": (context) => const BeforeYouStart(),
            "/signIn": (context) => const SignIn(),
            "/forgetPassword": (context) => const ForgetYourPassword(),
            "/userProfile": (context) => const UserProfile(),
            "/userHomePage": (context) => const UserHomePage(0),
            "/account": (context) => const UserHomePage(2),
            "/userChangePassword": (context) => const UserChangePassword(),
            "/testBle": (context) => const TestBle(),
            //    "/notification": (context) => const UserNotification(),
            "/editProfile": (context) => const EditProfile(),
            "/verifyPassword": (context) => const VerifyPassword(),
            "/enterNewPassword": (context) => const EnterNewPassword(),
            //"/signUpPassword": (context, name, email) => SignUpPassword(),

          },

          navigatorObservers: [FlutterSmartDialog.observer],
          builder: FlutterSmartDialog.init(),

          ///For user version update
        ),
      );
    });
  }

  // Future<void> checkAppVersion(context, String? minRequiredVersion) async {
  //   final packageInfo = await PackageInfo.fromPlatform();
  //   final currentVersion = packageInfo.version;
  //
  //   if (minRequiredVersion != null) {
  //     if (currentVersion.compareTo(minRequiredVersion) < 0) {
  //       // Show a dialog or take appropriate action for an update required
  //       SmartDialog.show(
  //           widget: EvieDoubleButtonDialog(
  //               title: "Update Required",
  //               childContent: Text('Please update the app to the latest version.'),
  //               leftContent: 'Cancel',
  //               rightContent: 'Update Now',
  //               onPressedLeft: () {},
  //               onPressedRight: () {}
  //           ),
  //           clickBgDismissTemp: false,
  //           backDismiss: false,
  //       );
  //     }
  //   }
  // }
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
}



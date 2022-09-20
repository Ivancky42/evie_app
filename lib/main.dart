import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/theme/ThemeChangeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evie_test/screen/signup_page.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/forget_your_password.dart';
import 'package:evie_test/theme/AppTheme.dart';
import 'package:evie_test/api/routes.dart';
import 'package:evie_test/profile/user_home_page.dart';
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

///Main function execution
Future main() async {
  ///Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ///Dotnet file loading
  await dotenv.load(fileName: "env");

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
                ///Get current user model
                  ..init(currentUserProvider.getCurrentUserModel);
              }
          ),
          ChangeNotifierProxyProvider<CurrentUserProvider, BluetoothProvider>(
              lazy: true,
              create: (_) => BluetoothProvider(),
              update: (_, currentUserProvider, bluetoothProvider) {
                return bluetoothProvider!
                ///Get current user model
                  ..init(currentUserProvider.getCurrentUserModel);
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

        //Routes setting for page navigation
        routes: {
          "/signIn": (context) => const SignIn(),
          "/signUp": (context) => const SignUp(),
          "/forgetPassword": (context) => const ForgetYourPassword(),
          "/userProfile": (context) => const UserProfile(),
          "/userHomePage": (context) => const UserHomePage(),
          "/userBluetooth": (context) => const UserHomeBluetooth(),
          "/userChangePassword": (context) => const UserChangePassword(),
          "/testBle": (context) => const TestBle(),
        },

        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      );
    });
  }
}

import 'package:evie_test/profile/user_profile.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evie_test/screen/signup_page.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/forget_your_password.dart';
import 'package:evie_test/theme/AppTheme.dart';
import 'package:evie_test/api/routes.dart';
import 'package:evie_test/profile/user_home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:evie_test/profile/user_change_password.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/screen/connect_bluetooth_device_page.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';


///Main function execution
Future main() async {

  ///Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ///Dotnet file loading
  await dotenv.load(fileName: ".env");

  ///Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrentUserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    CurrentUserProvider _currentUser = Provider.of<CurrentUserProvider>(context);
    String checkCurrentUserID = _currentUser.getUid;


    return MaterialApp(
      title: 'Evie',
      //Light theme data
      theme: AppTheme.lightTheme,

      //Change the app to dark theme when user's phone is set to dark mode
      darkTheme: AppTheme.darkTheme,

      onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(builder: (context) {
        if(checkCurrentUserID == "nullValue") {
          return const HomePage();
        } else if(checkCurrentUserID != "") {
          return const UserHomePage();
        } else {
          return const HomePage();
        }
        });
      },

      //Routes setting for page navigation
      routes: {
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpPage(),
        "/forgetPassword": (context) => const ForgetYourPasswordPage(),
        "/userProfile": (context) => const UserProfile(),
        "/userHomePage": (context) => const UserHomePage(),
        "/userBluetooth": (context) => const UserHomeBluetooth(),
        "/userChangePassword": (context) => const UserChangePassword(),
        "/connectBTDevice": (context) => const ConnectBluetoothDevice(),
      },
    );
  }
}

class HomePage extends StatefulWidget{
  const HomePage({ Key? key }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  @override
  Widget build(BuildContext context) {

    ///Disable phone rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return const Scaffold(
      body:LoginScreen(),
    );
  }
}



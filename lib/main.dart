import 'package:evie_test/profile/user_profile.dart';
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
import 'package:evie_test/api/current_user_provider.dart';


///Main function execution
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

    String checkCurrentUserEmail = _currentUser.getUid;


    return MaterialApp(
      title: 'Evie_Test',
      //Theme data are store in lib/screen/theme.AppTheme.dart
      theme: AppTheme.lightTheme,
      //Change the app to dark theme when user's phone is set to dark mode
      darkTheme: AppTheme.darkTheme,

      //initialRoute: "/home",

      //initialRoute:
      //currentUserUID != "" ? '/userHomePage' : '/home',

      onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(builder: (context) {
        if(checkCurrentUserEmail == "nullValue") return HomePage();
        if(checkCurrentUserEmail != "") return UserHomePage();
        else return HomePage();
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

    return const Scaffold(
      body:LoginScreen(),
    );
  }
}



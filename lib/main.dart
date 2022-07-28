import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evie_test/screen/signup_page.dart';
import 'package:evie_test/screen/login_page.dart';
import 'package:evie_test/screen/forget_your_password.dart';
import 'package:evie_test/theme/AppTheme.dart';
import 'package:evie_test/api/routes.dart';


///Main function execution
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evie_Test',
      //Theme data are store in lib/screen/theme.AppTheme.dart
      theme: AppTheme.lightTheme,
      //Change the app to dark theme when user's phone is set to dark mode
      darkTheme: AppTheme.darkTheme,
      initialRoute: "/home",
      //Routes setting for page navigation
      routes: {
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpPage(),
        "/forgetPassword": (context) => const ForgetYourPasswordPage(),
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

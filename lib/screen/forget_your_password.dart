import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import '../api/navigator.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';

///Forget your password? Send an email using firebase api to reset it.
/// >>>> Try to remember it this time <<<<

class ForgetYourPassword extends StatefulWidget {
  const ForgetYourPassword({Key? key}) : super(key: key);

  @override
  _ForgetYourPasswordState createState() => _ForgetYourPasswordState();
}

class _ForgetYourPasswordState extends State<ForgetYourPassword> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ForgetYourPasswordScreen(),
    );
  }
}

class ForgetYourPasswordScreen extends StatefulWidget {
  const ForgetYourPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetYourPasswordScreenState createState() =>
      _ForgetYourPasswordScreenState();
}

class _ForgetYourPasswordScreenState extends State<ForgetYourPasswordScreen> {
  //Read user input email address
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        changeToSignInScreen(context);
        return true;
      },

      child:Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: ThemeChangeNotifier().isDarkMode(context) == true ?  Image.asset('assets/buttons/back_darkMode.png'): Image.asset('assets/buttons/back.png'),
                onPressed: () {
                  changeToSignInScreen(context);
                }),
          ),
          body: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        child: Text("Lost your password?",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                )),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Container(
                        child:  Center(
                          child: Text(
                            "That's okay, it happens! Enter the email address you used for creating your account and we'll send you a password recover instruction.",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 44.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          hintStyle:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 0.1,
                                color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains("@")) {
                            return 'Please entera valid email address';
                          }
                          //Check if email is in database

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 70.0,
                      ),
                      Container(
                        child: EvieButton(
                          width: double.infinity,
                          height: 12,
                          child: const Text(
                            "Recover",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              //auth provider check if fire store user exist if no pop up if yes change to check your email screen
                              AuthProvider()
                                  .resetPassword(_emailController.text.trim());
                              changeToSignInScreen(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sent')),
                              );
                            }
                          },
                        ),
                      ),
                    ])),
              ))),
    );
  }
}

class CheckYourEmail extends StatelessWidget {
  const CheckYourEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  changeToWelcomeScreen(context);
                }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 1.h,
            ),
            Text(
              "Check your mail",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              "We have sent a password recover instruction to your email.",
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(
              height: 12.h,
            ),
            Center(
              child: SvgPicture.asset(
                  "assets/images/sent_message.svg",
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            EvieButton(
              width: double.infinity,
              child: Text(
                "Open Email Inbox",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                ),
              ),
              onPressed: () async {},
            ),
            SizedBox(
              height: 2.h,
            ),
            Center(
              child:
                  Text("Did not received the email? Check your spam filter,"),
            ),
            Center(
              child: Text("or try resend instruction."),
            ),
          ],
        ),
      ),
    );
  }
}

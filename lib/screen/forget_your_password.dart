import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import '../widgets/widgets.dart';
import 'package:evie_test/widgets/evie_button.dart';


///Forget your password? Send an email using firebase api to reset it.
/// >>>> Try to remember it this time <<<<

class ForgetYourPasswordPage extends StatefulWidget{
  const ForgetYourPasswordPage({ Key? key }) : super(key: key);
  @override
  _ForgetYourPasswordState createState() => _ForgetYourPasswordState();
}

class _ForgetYourPasswordState extends State<ForgetYourPasswordPage>{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:ForgetYourPasswordScreen(),
    );
  }
}

class ForgetYourPasswordScreen extends StatefulWidget{
  const ForgetYourPasswordScreen({ Key? key }) : super(key: key);
  @override
  _ForgetYourPasswordScreenState createState() => _ForgetYourPasswordScreenState();
}

class _ForgetYourPasswordScreenState extends State<ForgetYourPasswordScreen> {

  //Read user input email address
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
      child:Padding(
      padding: const EdgeInsets.all(16.0),

      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                  }
            ),

            Container(
              child: const Center(
                  child: Text(
                      "Forget Password?",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      )
                  )
              ),
            ),

            const SizedBox(
              height: 8.0,
            ),

            Container(
              child: const Center(
                child: Text(
                  "Enter your Email Address to recover",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
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
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(width: 0.1,
                      color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains("@") ) {
                  return 'Please enter your email';
                }
                //Check if email is in database

                return null;
              },
            ),

            const SizedBox(
              height: 100.0,
            ),

            Container(
              child: EvieButton_DarkBlue(
                width: double.infinity,
                child: const Text("Recover",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),

                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    CurrentUserProvider().resetPassword(_emailController.text.trim());
                    Navigator.pushReplacementNamed(context, '/home');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sent')),
                    );
                  }
                },
              ),
            )
          ]
       ),
      )
    );
  }
}



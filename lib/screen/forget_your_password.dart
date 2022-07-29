import 'package:flutter/material.dart';

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

  //Read user input phone number
  final TextEditingController _phoneNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  "Enter your Phone Number to recover",
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
              controller: _phoneNoController,
              decoration: InputDecoration(
                hintText: "Phone Number",
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
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),

            const SizedBox(
              height: 100.0,
            ),

            Container(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Recover",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),

                onPressed: () {
                  print("null");
                },
              ),
            )
          ]
      ),
    );
  }
}



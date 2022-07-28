import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUpPage extends StatefulWidget{
  const SignUpPage({ Key? key }) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage>{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({ Key? key }) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();

  late bool _success;

  //For user input password visibility rue/false
  bool _isObscure = true;

  ///Register user account on firebase and save data in firestore while sign up
  void _signUp() async {
    User? firebaseUser;

    await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),

    ).then((auth) {
      firebaseUser = auth.user!;
      if (firebaseUser != null) {
        saveToFirestore(firebaseUser!).then((value) {
          FirebaseFirestore.instance.collection('UserData')
              .doc(value.user.uid)
              .set({"email": value.user.email});
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    }).catchError((error) => print(error));
  }


  ///Upload the registered data to firestore
  saveToFirestore(User fireBaseUser) async {
    FirebaseFirestore.instance.collection('users').doc(fireBaseUser.uid).set(
        {
          'uid': fireBaseUser.uid,
          'email': fireBaseUser.email,
          "name": _nameController.value.text,
          "phoneNumber": _phoneNoController.value.text,
          "timeStamp": Timestamp.now(),
        }
    );}

  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

    @override
    Widget build(BuildContext context) {
      return Form(
        key: _formKey,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
        child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: const Center(
                  child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),
              ),

              const SizedBox(
                height:8.0,
              ),

              Container(
                child: const Center(
                  child: Text(
                    "Please fill in the following info",
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
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Full Name",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(
                        width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 15.0,
              ),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email Address",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  filled: true,
                  //<-- SEE HERE
                  fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(
                        width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 15.0,
              ),

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(
                        width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                      setState(() {
                      _isObscure = !_isObscure;
                      });}
                    )
                  ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 15.0,
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
                    BorderSide(
                        width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)),
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
                height: 50.0,
              ),

              Container(
                width: double.infinity,
                child: ElevatedButton(
                    child: const Text("Sign Up",
                    style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                    ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                      primary: const Color(0xFF00B6F1),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),

                  onPressed: () {
                      if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration success!')),
                    );
                    }
                    _signUp();
                  },
                ),
              ),

              const SizedBox(
                height: 10.0,
              ),

              Container(
                child: const Center(
                  child: Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: RawMaterialButton(
                  elevation: 0.0,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text("Login",
                    style: TextStyle(color: Color(0xFF00B6F1),
                      fontSize: 12.0,),
                  ),
                ),
              ),
            ]
        ),
        ))
      ));
    }
  }

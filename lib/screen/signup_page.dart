import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

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
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();

  //For user input password visibility true/false
  bool _isObscure = true;

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
                  if (value.length < 8 ) {
                    return 'Password must have at least 8 character';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 15.0,
              ),

              TextFormField(
                controller: _passwordConfirmController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Confirm your password",
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
                  if (_passwordController.value.text != _passwordConfirmController.value.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 50.0,
              ),

              EvieButton_DarkBlue(
                  width: double.infinity,
                  child: const Text("Sign Up",
                    style: TextStyle(color: Colors.white,
                       fontSize: 12.0,),
                  ),
                onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try{
                      CurrentUserProvider().signUp(_emailController.text.trim(),_passwordController.text.trim(),
                      _nameController.value.text, "empty");  //Last value field is phone number
                      Navigator.pushReplacementNamed(context, '/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration success!')),
                  );}catch(signUpError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email already in use!')),
                            );
                      }
                  }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration not success!')),
                      );
                    }
                },
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/firebase.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/main.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';


///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget{
  const LoginScreen({ Key? key }) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{


  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late CurrentUserProvider _currentUser;

  //For user input password visibility true/false
  bool _isObscure = true;

  ///Login function, login if user exists in firebase



    /*
    User? firebaseUser;

    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    ).then((auth) {
      firebaseUser = auth.user!;

      //If user input not equal to empty, proceed
      if (firebaseUser != null) {

        //Provider save data


        //Should navigate to bluetooth pairing first if no bike detect


        //Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()),);
        Navigator.pushReplacementNamed(context, '/userHomePage');
      }
    }).catchError((error) => print(error));

    */


  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    _currentUser = Provider.of<CurrentUserProvider>(context);

    return Form(
      key: _formKey,
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
            Container(
              child:  const Center(
                child: Text(
                  "Hello ",
                  //    +_currentUser.getEmail,
                    style:TextStyle(
                      fontFamily: 'Raleway',
                      fontSize:24.0,
                      fontWeight: FontWeight.w600,
                    )
                ),
              ),
            ),

            const SizedBox(
              height:8.0,
            ),

            Container(
              child:const Center(
                child: Text(
                  "Please sign in to your account",
                  style:TextStyle(
                    color:Colors.grey,
                    fontSize:14.0,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height:44.0,
            ),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email Address",
                hintStyle: const TextStyle(fontSize: 12,color:Colors.grey),
                filled: true,
                fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)),
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
              height:15.0,
            ),

            TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: const TextStyle(fontSize: 12,color:Colors.grey),
                filled: true,
                fillColor: const Color(0xFFFFFFFF).withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(width: 0.1, color: const Color(0xFFFFFFFF).withOpacity(0.2)), //<-- SEE HERE
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
              height:1.0,
            ),

            Container(
              alignment: const Alignment(1,0),
              padding: const EdgeInsets.only(top:10, left:20),
                child:  TextButton(
                  child: const Text('Forgot Password?'),
                  style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/forgetPassword');
                  }
                ),
            ),

            const SizedBox(
              height:20.0,
            ),

            EvieButton_DarkBlue(
              width: double.infinity,
              child: const Text("Login",
                style: TextStyle(color: Colors.white,
                  fontSize: 12.0,),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar.
                }

                //Save to provider
                _currentUser.login(_emailController.text.trim(),
                    _passwordController.text.trim(),
                    context, _currentUser);
              },
            ),

            const SizedBox(
              height:20.0,
            ),


              ///IOS
              Platform.isIOS ?
              Center(
            child:ButtonBar(
            mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
            children: <Widget>[
              Spacer(),
              EvieButton_Square(
                width: 60,
                height: 60,
                icon: const Icon(
                  Icons.facebook,
                  color: Colors.black54,
                ),
                  onPressed: (){

                  }
              ),
              Spacer(),
              EvieButton_Square(
                  width: 60,
                  height: 60,
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: Colors.black54,
                ),
                onPressed: (){
                  _currentUser.signInWithGoogle(context);
                }
              ),
              Spacer(),
              EvieButton_Square(
                  width: 60,
                  height: 60,
                  icon: const Icon(
                    Icons.apple,
                    color: Colors.black54,
                  ),
                  onPressed: (){

                  }
              ),
              Spacer(),
              EvieButton_Square(
                  width: 60,
                  height: 60,
                  icon: const Icon(
                    Icons.adb,
                    color: Colors.black54,
                  ),
                  onPressed: (){

                  }
              ),
            ],
        ),
              ):

                  ///Android
              Center(
                child:ButtonBar(
                  mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    Spacer(),
                    EvieButton_Square(
                        width: 60,
                        height: 60,
                        icon: const Icon(
                          Icons.facebook,
                          color: Colors.black54,
                        ),
                        onPressed: (){

                        }
                    ),
                    Spacer(),Spacer(),
                    EvieButton_Square(
                        width: 60,
                        height: 60,
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.black54,
                        ),
                        onPressed: (){
                          _currentUser.signInWithGoogle(context);
                        }
                    ),
                    Spacer(),Spacer(),
                    EvieButton_Square(
                        width: 60,
                        height: 60,
                        icon: const Icon(
                          Icons.adb,
                          color: Colors.black54,
                        ),
                        onPressed: (){

                        }
                    ),
                  ],
                ),
              ),



            const SizedBox(
              height:20.0,
            ),

            Container(
              child:const Center(
                child: Text(
                  "Don't have an account yet?",
                  style:TextStyle(
                    color:Colors.grey,
                    fontSize:12.0,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical:20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child:const Text("Sign Up",
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

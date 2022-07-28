import 'package:flutter/material.dart';
import 'package:evie_test/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  //For user input password visibility rue/false
  bool _isObscure = true;

  ///Login function, login if user exists in firebase
  void _login() async{
    User? firebaseUser;

    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    ).then((auth) {
      firebaseUser = auth.user!;

      //If user input not equal to empty, proceed
      if (firebaseUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginSuccessful()),
        );
      }
    }).catchError((error) => print(error));
  }

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
          children:[
            Container(
              child: const Center(
                child: Text(
                    "Welcome Back",
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
              height:20.0,
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
              height:40.0,
            ),

            Container(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Login",
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
                    // you'd often call a server or save the information in a database
                  }
                  _login();
                },
              ),
            ),

            const SizedBox(
              height:40.0,
            ),

            ///For button, facebook, apple, twitter login
           /* const Text(
              "Facebook...........apple...........bird",
              style:TextStyle(
                color:Colors.grey,
                fontSize:12.0,
              ),
            ), */

            const SizedBox(
              height:40.0,
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


class LoginSuccessful extends StatelessWidget {


  const LoginSuccessful({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Welcome!"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return
                Container(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                  Container(
                  child: Center(child: Text(document['name'])),
                  ),


                  Container(
                  child: Center(child: Text(document['email'])),
                  ),

                    Container(
                      child: Center(child: Text(document['phoneNumber'])),
                    ),
                  ])
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
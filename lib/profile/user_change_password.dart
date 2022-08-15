import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';



///User change password screen

class UserChangePassword extends StatefulWidget{
  const UserChangePassword({ Key? key }) : super(key: key);
  @override
  _UserChangePasswordState createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  late CurrentUserProvider _currentUser;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/userProfile');
                  }
              ),

              const Text('Change Password'),

            ],
          ),
        ),

        body: Scaffold(
            //body: Center(
            body: Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Container(
                                    child: const Center(
                                      child: Text(
                                          "New Password",
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
                                        "Update your new password",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 100.0,
                                  ),

                                  TextFormField(
                                    controller: _passwordController,
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
                                    child: const Text("Update Password",
                                      style: TextStyle(color: Colors.white,
                                        fontSize: 12.0,),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _currentUser.changeUserPassword(_passwordController.text.trim());  //Last value field is phone number
                                        Navigator.pushReplacementNamed(context, '/userProfile');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Passsword update success!')),
                                        );

                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Password update not success')),
                                        );
                                      }
                                    },
                                  ),
                                ])
                        )
                      )
                )
            )
        )
    );
  }
}
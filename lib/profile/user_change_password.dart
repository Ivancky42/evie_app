import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../widgets/evie_single_button_dialog.dart';

///User change password screen

class UserChangePassword extends StatefulWidget{
  const UserChangePassword({ Key? key }) : super(key: key);
  @override
  _UserChangePasswordState createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {

  final TextEditingController _passwordOriginalController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  late AuthProvider _authProvider;late CurrentUserProvider _currentUser;

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

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
                    changeToUserProfileScreen(context);
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
                                    controller: _passwordOriginalController,
                                    obscureText: _isObscure3,
                                    decoration: InputDecoration(
                                        hintText: "Original Password",
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
                                              _isObscure3 ? Icons.visibility_off : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure3 = !_isObscure3;
                                              });}
                                        )
                                    ),

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your original password';
                                      }
                                      if (value.length < 8 ) {
                                        return 'Please enter your original password';
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
                                        hintText: "New Password",
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
                                              _isObscure ? Icons.visibility_off : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure = !_isObscure;
                                              });}
                                        )
                                    ),

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your new password';
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
                                    obscureText: _isObscure2,
                                    decoration: InputDecoration(
                                        hintText: "Confirm New Password",
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
                                              _isObscure2 ? Icons.visibility_off : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure2 = !_isObscure2;
                                              });}
                                        )
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your new password';
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
                                    height: double.infinity,
                                    child: const Text("Update Password",
                                      style: TextStyle(color: Colors.white,
                                        fontSize: 12.0,),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {

                                  if (!await _authProvider.reauthentication(_passwordOriginalController.text.trim())) {
                                   /* SmartDialog.show(
                                      widget: EvieSingleButtonDialog(
                                          title: "Error",
                                          content: "Try again",
                                          rightContent: "Ok",
                                          image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                                          onPressedRight: (){
                                            SmartDialog.dismiss();
                                          }),
                                    );

                                    */

                                    debugPrint("authentication failed");
                                      }else{
                                        _authProvider.changeUserPassword(
                                        context,
                                        _passwordController.text.trim(),
                                        _passwordOriginalController.text.trim()); //Last value field is phone number
                                        changeToUserProfileScreen(context);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(content: Text(
                                          'Password update success!')),
                                    );

                                  }
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Password update not success')),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 100.0,
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
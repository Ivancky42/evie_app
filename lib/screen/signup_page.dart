import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/input_name.dart';
import 'package:evie_test/widgets/evie_checkbox.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';


import '../api/fonts.dart';
import '../api/length.dart';
import '../api/navigator.dart';
import '../api/provider/auth_provider.dart' as EvieAuthProvider;
import '../widgets/evie_appbar.dart';
import '../widgets/evie_single_button_dialog.dart';

///Firebase auth
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUp extends StatefulWidget {
  final String name;

  const SignUp(this.name, {Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //To read data from user input
  final TextEditingController _emailController = TextEditingController();
  late EvieAuthProvider.AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;
  bool isCheckTermsCondition = false;
  final FocusNode _nameFocusNode = FocusNode();

  ///Create form for later form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<EvieAuthProvider.AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){  back(context, InputName());}),
      body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: EvieLength.target_reference_button_b),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${widget.name}, let's setup your account",
                          style: EvieTextStyles.h2,),
                        SizedBox(
                          height: 1.h,
                        ),
                        Text("Enter your email address",
                          style: EvieTextStyles.body18,),
                        SizedBox(
                          height: 16.h,
                        ),
                        EvieTextFormField(
                          controller: _emailController,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          labelText: "Email Address",
                          hintText: "lyouremail@sample.com",
                          focusNode: _nameFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }else if(!value.contains("@")){
                              return 'Looks like you entered the wrong email. The correct format for email address as follow “sample@youremail.com”.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    EvieButton(
                        width: double.infinity,

                        child: Text(
                          "Next",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),

                        onPressed: ()  async {
                          if (_formKey.currentState!.validate()){
                            changeToSignUpPasswordScreen(context, widget.name, _emailController.text.replaceAll(" ", "").trim());
                          }
                        }

                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }
}

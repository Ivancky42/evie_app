import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../api/colours.dart';
import '../theme/ThemeChangeNotifier.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_button.dart';

class InputName extends StatefulWidget {
  const InputName({Key? key}) : super(key: key);

  @override
  _InputNameState createState() => _InputNameState();
}

class _InputNameState extends State<InputName> {
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        changeToWelcomeScreen(context);
        return true;
      },

      child:  Scaffold(
        appBar: EvieAppbar_Back(onPressed: (){ changeToWelcomeScreen(context);}),

        body: Stack(
          children: [
          Form(
          key: _formKey,
            child:Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    "Hi, what's your name?",
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text("Just your first name will do the trick", style: TextStyle(fontSize: 11.5.sp),),
                  SizedBox(
                    height: 1.h,
                  ),

                  EvieTextFormField(
                    controller: _nameController,
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    hintText: "enter your first name",
                    labelText: "First Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16, bottom: 64.0),
                child: EvieButton(
                  width: double.infinity,
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      changeToSignUpMethodScreen(
                          context, _nameController.text.trim());
                    }
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RawMaterialButton(
                    elevation: 0.0,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    onPressed: () {
                      changeToSignInMethodScreen(context);
                    },
                    child: Text(
                      "I already have an account",
                      style: TextStyle(
                        color: EvieColors.PrimaryColor,
                        fontSize: 10.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        //        ),
      ),
    );
  }
}

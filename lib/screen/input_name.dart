import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';
import '../api/length.dart';
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
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Hi, what's your name?",
                    style: EvieTextStyles.h2,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text("Just your first name or nickname will do the trick", style: EvieTextStyles.body18,),
                  SizedBox(
                    height: 9.h,
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
                     EdgeInsets.only(left: 16.w, right: 16.w, bottom: EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  child: Text(
                    "Next",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      ///For keyboard un focus
                      FocusManager.instance.primaryFocus?.unfocus();

                      changeToSignUpMethodScreen(
                          context, _nameController.text.trim());
                    }
                  },
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

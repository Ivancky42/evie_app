import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/welcome_page.dart';
import 'package:evie_test/widgets/evie_textform.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';
import '../api/length.dart';
import '../widgets/evie_appbar.dart';
import '../widgets/evie_button.dart';

class InputName extends StatefulWidget {
  const InputName({super.key});

  @override
  _InputNameState createState() => _InputNameState();
}

class _InputNameState extends State<InputName> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvieAppbar_Back(onPressed: (){ back(context, Welcome());}),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child:Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top:16.h, bottom: EvieLength.target_reference_button_b),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, what's your name?",
                          style: EvieTextStyles.h2,
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Text("This appears on your EVIE profile.", style: EvieTextStyles.body18,),
                        SizedBox(
                          height: 15.h,
                        ),
                        EvieTextFormField(
                          controller: _nameController,
                          obscureText: false,
                          keyboardType: TextInputType.name,
                          hintText: "Your first name or nickname",
                          labelText: "Name",
                          focusNode: _nameFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ///For keyboard un focus
                          FocusManager.instance.primaryFocus?.unfocus();
                          changeToSignUpScreen(context, _nameController.text.trim());
                        }
                      },
                    ),
                  ],
                )
            ),
          ),
        ],
      ),

      //        ),
    );
  }
}

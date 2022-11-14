
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/ThemeChangeNotifier.dart';

///Button Widget
class EvieTextFormField extends StatelessWidget {

  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const EvieTextFormField({
    Key? key,

    required this.controller,
    this.obscureText,
    this.keyboardType,
    this.hintText,
    this.labelText,
    this.suffixIcon,
    this.validator,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText!,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(fontSize: 10.sp, color: Color(0xff7A7A79)),
          labelStyle: TextStyle(fontSize: 13.sp, color: Color(0xff7A7A79)),
          filled: true,
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor, // or any other color
          ),
          fillColor: ThemeChangeNotifier().isDarkMode(context) ?  Color(0xff3F3F3F) : Color(0xffDFE0E0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 0.1,
                color: ThemeChangeNotifier().isDarkMode(context) ?  Color(0xff3F3F3F) : Color(0xffFAFAFA),), //<-- SEE HERE
            borderRadius: BorderRadius.circular(10.0),
          ),

          focusColor: ThemeChangeNotifier().isDarkMode(context) ?  Color(0xff3F3F3F) : Color(0xffFAFAFA),


          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Color(0xff6A51CA),), //<-- SEE HERE
            borderRadius: BorderRadius.circular(10.0),
          ),

          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Color(0xffF42525),), //<-- SEE HERE
            borderRadius: BorderRadius.circular(10.0),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Color(0xffF42525),), //<-- SEE HERE
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: suffixIcon),
      validator: validator,
    );
  }
}


///Button Widget
class EvieButton_TextForm_Constant extends StatelessWidget {

  final double width;
  final double height;
  final String hintText;

  const EvieButton_TextForm_Constant({
    Key? key,
    required this.width,
    required this.height,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        //height: height,
        //width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                enabled: false,
                hintText: hintText,
                hintStyle: TextStyle(
                    fontSize: 13,
                  color: ThemeChangeNotifier().isDarkMode(context) == true ? Colors.white70 : Colors.black,
                ),
                filled: true,
                //<-- SEE HERE
                fillColor: Color(0xFFFFFFFF).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
            ),
        )
    );
  }
}
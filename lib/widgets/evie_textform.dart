
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../api/colours.dart';
import '../api/provider/setting_provider.dart';

///Button Widget
class EvieTextFormField extends StatefulWidget {

  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatter;

  const EvieTextFormField({
    Key? key,

    required this.controller,
    this.obscureText,
    this.keyboardType,
    this.hintText,
    this.labelText,
    this.suffixIcon,
    this.validator,
    this.inputFormatter,

  }) : super(key: key);

  @override
  State<EvieTextFormField> createState() => _EvieTextFormFieldState();
}

class _EvieTextFormFieldState extends State<EvieTextFormField> {
  late FocusNode focusNode;
  Color borderColor = Colors.grey;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        borderColor = focusNode.hasFocus ? EvieColors.primaryColor : Colors.grey;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(

        child:Container(

          // decoration: BoxDecoration(
          //   border: Border.all(color: borderColor, width: 1.5,),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),

          child: TextFormField(
              inputFormatters: widget.inputFormatter,
              focusNode: focusNode,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText!,
              decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    hintText: widget.hintText,
                    labelText: widget.labelText,

                    hintStyle: EvieTextStyles.body14.copyWith(color:EvieColors.darkGrayish),
                    labelStyle:  EvieTextStyles.body18.copyWith(color:EvieColors.darkGrayish),
                    filled: true,
                    errorStyle: TextStyle(
                      color: Theme.of(context).errorColor, // or any other color
                    ),
                    //fillColor: widget.focusNode!.hasFocus ? Colors.red : ThemeChangeNotifier().isDarkMode(context) ?  Color(0xff3F3F3F) : Color(0xffDFE0E0),
                    fillColor: focusNode.hasFocus ? EvieColors.thumbColorTrue : SettingProvider().isDarkMode(context) ?  EvieColors.darkGray : EvieColors.lightGrayishCyan,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.1,
                          color: SettingProvider().isDarkMode(context) ?  EvieColors.darkGray : EvieColors.thumbColorTrue,), //<-- SEE HERE
                      borderRadius: BorderRadius.circular(10.0),
                    ),

                    focusColor: SettingProvider().isDarkMode(context) ?  EvieColors.darkGray: EvieColors.thumbColorTrue,

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
                    suffixIcon: widget.suffixIcon),
              validator: widget.validator,
            ),
        )
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
                  color: SettingProvider().isDarkMode(context) == true ? Colors.white70 : Colors.black,
                ),
                filled: true,
                //<-- SEE HERE
                fillColor: EvieColors.white.withOpacity(0.3),
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
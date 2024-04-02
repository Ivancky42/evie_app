
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


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
  final FocusNode? focusNode;
  final bool? enabled;
  final MaskTextInputFormatter? maskTextInputFormatter;

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
    this.focusNode,
    this.enabled,
    this.maskTextInputFormatter,

  }) : super(key: key);

  @override
  State<EvieTextFormField> createState() => _EvieTextFormFieldState();
}

class _EvieTextFormFieldState extends State<EvieTextFormField> {
  late FocusNode thisFocusNode;
  Color borderColor = Colors.grey;

  @override
  void initState() {
    //thisFocusNode = widget.focusNode!;
    if (widget.focusNode != null) {
      thisFocusNode = widget.focusNode!;
      thisFocusNode.addListener(() {
        if (mounted) {
          setState(() {
            borderColor =
            thisFocusNode.hasFocus ? EvieColors.primaryColor : Colors.grey;
          });
        }
      });
    }
    else {
      thisFocusNode = FocusNode();
      thisFocusNode.addListener(() {
        if (mounted) {
          setState(() {
            borderColor =
            thisFocusNode.hasFocus ? EvieColors.primaryColor : Colors.grey;
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // if (thisFocusNode != null) {
    //   thisFocusNode.dispose();
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child:Stack(
          children: [
            TextFormField(
              inputFormatters: widget.inputFormatter,
              focusNode: thisFocusNode,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText!,
              //cursorColor: EvieColors.primaryColor,
              textAlignVertical: TextAlignVertical.bottom,
              enabled: widget.enabled ?? true,
              //cursorHeight: 15,
              decoration: InputDecoration(
                  contentPadding:  EdgeInsets.only(left: 20.w, right: 20.w, top: 33.h, bottom: 10.h),
                  //hintText: widget.hintText,
                  //labelText: widget.labelText,
                  //hintStyle: EvieTextStyles.body14.copyWith(color:EvieColors.darkGrayish),
                  //labelStyle:  EvieTextStyles.body18.copyWith(color:EvieColors.darkGrayish),
                  filled: true,
                  errorMaxLines: 3,
                  alignLabelWithHint: false,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  //fillColor: widget.focusNode!.hasFocus ? Colors.red : ThemeChangeNotifier().isDarkMode(context) ?  Color(0xff3F3F3F) : Color(0xffDFE0E0),
                  fillColor: thisFocusNode.hasFocus ? EvieColors.thumbColorTrue : SettingProvider().isDarkMode(context) ?  EvieColors.darkGray : EvieColors.lightGrayishCyan,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.1,
                      color: SettingProvider().isDarkMode(context) ?  EvieColors.darkGray : EvieColors.thumbColorTrue,), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  focusColor: SettingProvider().isDarkMode(context) ?  EvieColors.darkGray: EvieColors.thumbColorTrue,

                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.5, color: Color(0xff6A51CA),), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.5,
                      color: Color(0xffF42525),), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorStyle: TextStyle(height: 0),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.5,
                      color: Color(0xffF42525),), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: widget.suffixIcon,
                  // prefixText: !(widget.enabled ?? true) ? widget.controller?.text ?? '' : '',

              ),
              validator: widget.validator,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w, top: 10.h),
                child: Text(
                  widget.labelText ?? '',
                  style: EvieTextStyles.body14.copyWith(color:EvieColors.darkGrayish),
                ),
              ),
            ),
            // Visibility(
            //   visible: !(widget.enabled ?? true),
            //   child: Positioned(
            //     left: 20.w,
            //     top: 33.h,
            //     child: Text(
            //       widget.controller!.text.trim(),
            //       style: TextStyle(color: Colors.black),
            //     ),
            //   ),
            // ),
          ],
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
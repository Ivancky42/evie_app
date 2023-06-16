import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evie_bike/api/fonts.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../api/colours.dart';
import '../api/provider/setting_provider.dart';

class EvieDropdown extends StatefulWidget {

  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String hintText;
  final Widget? suffixIcon;
  final FormFieldValidator<dynamic>? validator;
  final ValueChanged onChanged;
  final List<DropdownMenuItem>? listItems;
  final String? value;

  const EvieDropdown({
    Key? key,
    this.controller,
    this.obscureText,
    this.keyboardType,
    required this.hintText,
    this.suffixIcon,
    this.validator,
    required this.onChanged,
    required this.listItems,
    this.value,

  }) : super(key: key);

  @override
  State<EvieDropdown> createState() => _EvieDropdownState();
}

class _EvieDropdownState extends State<EvieDropdown> {
  late FocusNode focusNode;
  Color borderColor = Colors.grey;
  List<String>? listItem;

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

    return Container(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButtonFormField2(
            focusNode: focusNode,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: focusNode.hasFocus ?
            OutlineInputBorder(
              borderSide: const BorderSide(
                width: 1.5,
                color: EvieColors.primaryColor,),
              borderRadius: BorderRadius.circular(10.0),
            ): OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.1,
                color: SettingProvider().isDarkMode(context) ?  EvieColors.darkGray : EvieColors.thumbColorTrue,),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          value: widget.value,
          isExpanded: true,

          hint: Text(
            widget.hintText,
            style: TextStyle(fontSize: 18.sp),
          ),

            items: widget.listItems,
            validator: widget.validator,
            onChanged: widget.onChanged,

            buttonStyleData: ButtonStyleData(
              height: 72.h,
              width: 160.w,
              padding: EdgeInsets.only(left: 20.w, right: 32.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: EvieColors.lightGrayishCyan,
              ),

            ),
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset(
              "assets/buttons/down_mini.svg",
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(

              color: EvieColors.dividerWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [],
            ),
          ),
        ),

        ],
      ),
    );

  }
}

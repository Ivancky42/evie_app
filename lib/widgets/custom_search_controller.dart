import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../api/colours.dart';

class CustomSearchController extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;
  final Widget? suffixIcon;
  const CustomSearchController({Key? key, required this.searchController, required this.onChanged, this.suffixIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ThemeData().colorScheme.copyWith(
          primary: EvieColors.primaryColor,
        ),
      ),
      child: Container(
        height: 40.h,
        child: TextFormField(
          controller: searchController,
          onChanged: onChanged,
          style: EvieTextStyles.body16,
          cursorColor: EvieColors.primaryColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: EvieColors.greyFill.withOpacity(0.1),
            focusColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: EvieColors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: EvieColors.primaryColor)),
            prefixIcon: Container(
              width: 50.w,
              height: 50.w,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SvgPicture.asset(
                  "assets/icons/search.svg",
                  width: 24.w,
                  height: 24.w,
                ),
              )
            ),
            prefixIconColor: EvieColors.darkGrayish,
            suffixIcon: suffixIcon,
            suffixIconColor: EvieColors.darkGrayish,
            hintText: "Search",
            hintStyle: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayish),
          ),
        ),
      )
    );
  }
}


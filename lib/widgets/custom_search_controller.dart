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
          primary: EvieColors.PrimaryColor,
        ),
      ),
      child: TextFormField(
        controller: searchController,
        onChanged: onChanged,
        style: TextStyle(fontSize: 16.sp),
        cursorColor: EvieColors.PrimaryColor,
        decoration: InputDecoration(
            filled: true,
            fillColor: EvieColors.greyFill.withOpacity(0.1),
            focusColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: EvieColors.PrimaryColor)),
            prefixIcon: const Icon(Icons.search),
            prefixIconColor: EvieColors.greyFill,
            suffixIcon: suffixIcon,
            suffixIconColor: EvieColors.greyFill,
            hintText: "Search",
            hintStyle: TextStyle(
              fontSize: 16.sp,
            )),
      ),
    );
  }
}


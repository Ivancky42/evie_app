import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/utils.dart';


import '../api/colours.dart';

///Button widget
class EvieButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
      width: width ?? double.infinity,
      child: ElevatedButton(
        child: child,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.w)),
            elevation: 0.0,
            backgroundColor: backgroundColor ?? EvieColors.primaryColor,
        ),
      ),
    );
  }
}

///Button widget
class EvieButton_ReversedColor extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton_ReversedColor({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
        width: width ?? double.infinity,
        child: ElevatedButton(
          child: child,
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w)),
              elevation: 0.0,
            backgroundColor: EvieColors.lightGrayishCyan,

          ),
        )
    );
  }
}

///Button widget
class EvieButton_DropDown extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final ValueChanged? onChanged;
  final List<DropdownMenuItem> items;
  final String text;

  const EvieButton_DropDown({
    Key? key,
    this.width,
    this.height,
    this.backgroundColor,
    required this.onChanged,
    required this.items,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 48.h,
        width: width ?? double.infinity,
        child: Padding(
          padding:  EdgeInsets.only(left: 16.w, right:16.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              icon: SvgPicture.asset(
                  "assets/buttons/down_mini.svg",
                ),
              hint: Text(text, style: TextStyle( fontFamily: 'Avenir', color: EvieColors.primaryColor, fontSize: 17.sp, fontWeight: FontWeight.w900),),
              items: items,
              onChanged: onChanged,
              // buttonHeight: 40,
              // buttonWidth: 140,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                 //   offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
                dropdownMaxHeight: 120.h,
                dropdownWidth: 210.w,
                itemHeight: 40.h,

            ),
          ),

          // child: DropdownButton(
          //   isExpanded: true,
          //   underline: const SizedBox(),
          //   onChanged: onChanged,
          //   items: items,
          //   icon: SvgPicture.asset(
          //     "assets/buttons/down_mini.svg",
          //   ),
          //   style: const TextStyle(color: EvieColors.primaryColor),
          //   hint: Text(text, style: TextStyle(color: EvieColors.primaryColor, fontSize: 17.sp, fontWeight: FontWeight.w500),),
          // ),
        ),
      decoration: BoxDecoration(
        color: backgroundColor ?? EvieColors.lightGrayishCyan,
          borderRadius:  BorderRadius.all(Radius.circular(10.w)),
      ),
    );
  }

  List<DropdownMenuItem<String>> addDividersAfterItems(List<String> items) {
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16.sp,
                ),),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return _menuItems;
  }
}

class EvieButton_PickDate extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton_PickDate({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 32.h,
        width: width ?? double.infinity,
        child: Row(
          children: [
            ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w)),
                elevation: 0.0,
                backgroundColor: EvieColors.lightGrayishCyan,

              ),
            ),

          ],
        )
    );
  }
}

class EvieButton_Square extends StatelessWidget {

  final VoidCallback onPressed;
  final double width;
  final double height;
  final Widget child;

  const EvieButton_Square({
    Key? key,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Container(
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,

          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: child,
          ),
          //label: const Text(''),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              backgroundColor: Colors.white,
              textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

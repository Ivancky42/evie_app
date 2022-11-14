import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:sizer/sizer.dart';

import '../api/colours.dart';

///Button Widget
class EvieButton_Dark extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget? child;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton_Dark({
    Key? key,
    this.onPressed,
    this.child,
    this.width,
    this.height,
    this.backgroundColor,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width,
            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  backgroundColor: backgroundColor ?? EvieColors.PrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
            //          fontWeight: FontWeight.bold
                )
              ),
            ),
          ),
        )
    );
  }
}


///Button widget
class EvieButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width,
            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  elevation: 0.0,
                  backgroundColor: backgroundColor ?? EvieColors.PrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
            //          fontWeight: FontWeight.bold
                  )),
            ),
          ),
        )
    );
  }
}

///Button widget
class EvieButton_ReversedColor extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double? height;
  final Color? backgroundColor;

  const EvieButton_ReversedColor({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width,
            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  elevation: 0.0,
                  backgroundColor: const Color(0xffDFE0E0),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 30,
                    //          fontWeight: FontWeight.bold
                  )),
            ),
          ),
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




///Button widget
class EvieButton_White extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;

  const EvieButton_White({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  elevation: 0.0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),

        )
    );
  }
}
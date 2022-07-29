import 'package:flutter/material.dart';


///Button Widget
class EvieButton_DarkBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;

  const EvieButton_DarkBlue({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
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
                  backgroundColor: const Color(0xFF00B6F1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        )
    );
  }
}



class EvieButton_LightBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;

  const EvieButton_LightBlue({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
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
                  backgroundColor: const Color(0xFF00B6F1).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        )
    );
  }
}



import 'package:flutter/material.dart';

///Button Widget
class EvieButton_DarkBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;

  const EvieButton_DarkBlue({
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
class EvieButton_LightBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;

  const EvieButton_LightBlue({
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
          child: Container(
            width: width,
            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  elevation: 0.0,
                  backgroundColor: const Color(0xFF00B6F1).withOpacity(0.4),
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
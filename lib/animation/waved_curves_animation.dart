import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/utils.dart';

import '../api/colours.dart';

//set this class to home of material app in main.dart
class WavedCurvesAnimation extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _MyAnimatedWavesCurves();
  }
}

class _MyAnimatedWavesCurves extends State<WavedCurvesAnimation> with SingleTickerProviderStateMixin {
  //use "with SingleThickerProviderStateMixin" at last of class declaration
  //where you have to pass "vsync" argument, add this

  late Animation<double> animationTop;
  late Animation<double> animationBottom;
  late AnimationController _controller; //controller for animation

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 3), vsync: this);
    _controller.repeat(reverse: true);
    //we set animation duration, and repeat for infinity

    animationTop = Tween<double>(begin: -140, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    animationBottom = Tween<double>(begin: -140, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    //we have set begin to -600 and end to 0, it will provide the value for
    //left or right position for Positioned() widget to creat movement from left to right
    animationTop.addListener(() {
      setState(() {}); //update UI on every animation value update
    });

    animationBottom.addListener(() {
      setState(() {}); //update UI on every animation value update
    });
  }

  @override
  void dispose() {
    _controller.dispose(); //destory anmiation to free memory on last
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack( //stack helps to overlaps widgets
            children: [
              // Positioned( //helps to position widget where ever we want
              //   //bottom: 0, // position at the bottom
              //   top:0, //position at the top
              //   right: animationTop.value, //value of right from animation controller
              //   child: ClipPath(
              //     clipper: MyWaveClipper2(), //applying our custom clipper
              //     child: Opacity(
              //       opacity: 0.5,
              //       child: Container(
              //         decoration: BoxDecoration(
              //           gradient: LinearGradient(
              //               begin: Alignment.topCenter,
              //               end: Alignment.bottomCenter,
              //               colors: [EvieColors.primaryColor,EvieColors.primaryColor.withOpacity(0.8), EvieColors.primaryColor.withOpacity(0.5),EvieColors.primaryColor.withOpacity(0.3), EvieColors.grayishWhite]
              //           ),
              //         ),
              //
              //         width: 900.w,
              //         height: EvieLength.battery_curved_bottom,
              //       ),
              //     ),
              //   ),
              // ),

              Positioned( //helps to position widget where ever we want
                top:0, //position at the top
                left: animationTop.value, //value of left from animation controller
                child: Container(
                  width: 600.w,
                  child: Image.asset("assets/images/battery_wave.png", height: 180.h),
                )
              ),

              Positioned( //helps to position widget where ever we want
                top:0, //position at the top
                right: animationBottom.value, //value of left from animation controller
                child: Container(
                  width: 600.w,
                  child: Image.asset("assets/images/battery_wave.png", height: 180.h),
                )
              ),

            ]),
      ),
    );
  }
}

class MyWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, 40.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40.0);

    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            0.0,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
      else {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            size.height - 120,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
    }

    path.lineTo(0.0, 40.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}


//our custom clipper with Path class
class MyWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, 40.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40.0);

    //see my previous post to understand about Bezier Curve waves
    // https://www.hellohpc.com/flutter-how-to-make-bezier-curve-waves-using-custom-clippath/


    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            0.0,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      } else {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            size.height - 120,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
    }

    path.lineTo(0.0, 40.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
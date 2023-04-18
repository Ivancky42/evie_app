import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:get/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';
import '../../widgets/evie_textform.dart';


class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);
  @override
  State<Test> createState() => _TestState();
}
class _TestState extends State<Test>  {


  int _currentIndex = 0;
  List<Widget> _widgets = [
    Container(
    child: Text("1"),
  ), Container(
      child: Text("2"),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carousel Slider'),
      ),
      body: Column(
        children: [
          CarouselSlider(
            items: _widgets,
            options: CarouselOptions(
              height: 400.0,
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 16/9,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
              viewportFraction: 0.8,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _widgets.map((item) {
              int index = _widgets.indexOf(item);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}




class BorderPaint extends StatefulWidget {
  const BorderPaint({Key? key}) : super(key: key);

  @override
  _BorderPaintState createState() => _BorderPaintState();
}

class _BorderPaintState extends State<BorderPaint> with SingleTickerProviderStateMixin{
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2500,
      ),
    );
    animation = controller
      ?..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller?.reset();
        } else if (status == AnimationStatus.dismissed) {
          controller?.forward();
        }
      });
    controller?.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: animation!,
          builder: (context, child) {
            return CustomPaint(
              foregroundPainter: BorderPainter(controller!.value),
              child: Container(
                color: EvieColors.primaryColor,
                width: 150,
                height: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final double controller;

  BorderPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    double _sh = size.height; // For path shortage
    double _sw = size.width;  // For path shortage
    double _line = 30.0;  // Length of the animated line
    double _c1 = controller * 2;
    double _c2 = controller >= 0.5 ? (controller - 0.5) * 2 : 0;

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path _top = Path()
      ..moveTo(_sw * _c1 > _sw ? _sw : _sw * _c1, 0)
      ..lineTo(_sw * _c1 + _line >= _sw ? _sw : _sw * _c1 + _line, 0);

    Path _right = Path()
      ..moveTo(_sw, _sh * _c2)
      ..lineTo(_sw, _sh * _c2 + _line > _sh ? _sh : _sw * _c1 + _line >= _sw ? _sw * _c1 + _line - _sw : _sh * _c2);


    Path _bottom = Path()
      ..moveTo(_sw - (_sw * _c1 > _sw ? _sw : _sw * _c1), _sh)
      ..lineTo(_sw - (_sw * _c1 + _line >= _sw ? _sw : _sw * _c1 + _line), _sh);

    Path _left = Path()
      ..moveTo(0, _sh * (1 - _c2))
      ..lineTo(0, _sh * (1 - _c2) - _line < 0 ? 0 : _sh * (1 - _c2) - _line);


    canvas.drawPath(_left, paint);
    canvas.drawPath(_top, paint);
    canvas.drawPath(_bottom, paint);
    canvas.drawPath(_right, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}






class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({Key? key}) : super(key: key);
  @override
  State<Test> createState() => _TestState();
}
class _AnimatedGradientBorderState extends State<Test> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 3000));
    _animationController..addStatusListener((status) {
      if(status == AnimationStatus.completed) _animationController.forward(from: 0);
    });
    _animationController.addListener(() {
      setState(() {
      });
    });
    _animationController.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 180,
          height: 150,
          decoration: BoxDecoration(
              // boxShadow: const[
              //   BoxShadow(offset: Offset(0,0),blurRadius: 10,color: Colors.black)
              // ],
              gradient: SweepGradient(
                  startAngle: 0,
                  colors: [Colors.white,Colors.yellow,Colors.white,Colors.yellow],
                  transform: GradientRotation(_animationController.value*6)
              )
          ),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text("Hi, i am warning"),
            ),
          ),
        ),
      ),
    );
  }
}

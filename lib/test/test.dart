import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../api/colours.dart';




class Test extends StatefulWidget {
  const Test({super.key});
  @override
  State<Test> createState() => _TestState();
}
class _TestState extends State<Test>  {


  int _currentIndex = 0;
  final List<Widget> _widgets = [
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
  const BorderPaint({super.key});

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
    double sh = size.height; // For path shortage
    double sw = size.width;  // For path shortage
    double line = 30.0;  // Length of the animated line
    double c1 = controller * 2;
    double c2 = controller >= 0.5 ? (controller - 0.5) * 2 : 0;

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path top = Path()
      ..moveTo(sw * c1 > sw ? sw : sw * c1, 0)
      ..lineTo(sw * c1 + line >= sw ? sw : sw * c1 + line, 0);

    Path right = Path()
      ..moveTo(sw, sh * c2)
      ..lineTo(sw, sh * c2 + line > sh ? sh : sw * c1 + line >= sw ? sw * c1 + line - sw : sh * c2);


    Path bottom = Path()
      ..moveTo(sw - (sw * c1 > sw ? sw : sw * c1), sh)
      ..lineTo(sw - (sw * c1 + line >= sw ? sw : sw * c1 + line), sh);

    Path left = Path()
      ..moveTo(0, sh * (1 - c2))
      ..lineTo(0, sh * (1 - c2) - line < 0 ? 0 : sh * (1 - c2) - line);


    canvas.drawPath(left, paint);
    canvas.drawPath(top, paint);
    canvas.drawPath(bottom, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}






class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({super.key});
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
    _animationController.addStatusListener((status) {
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

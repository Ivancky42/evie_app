import 'package:flutter/material.dart';

///Animation page for ripple pulse

class RipplePulseAnimation extends StatefulWidget{
  const RipplePulseAnimation({ super.key });
  @override
  _RipplePulseAnimationState createState() => _RipplePulseAnimationState();
}

class _RipplePulseAnimationState extends State<RipplePulseAnimation>
    with TickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,

      //Duration of the animation, then repeat
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //_buildContainer(150 * _controller.value),
            //_buildContainer(200 * _controller.value),
            _buildContainer(270 * _controller.value),
            //_buildContainer(300 * _controller.value),
            //_buildContainer(350 * _controller.value),
            _buildContainer(400 * _controller.value),
            const Align(),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

        //Colour of the ripple pulse
        color: const Color(0xff6A51CA).withOpacity(1 - _controller.value),
      ),
    );
  }


}
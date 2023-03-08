import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';



class EvieOvalGray extends StatefulWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const EvieOvalGray({Key? key,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  _EvieOvalGrayState createState() => _EvieOvalGrayState();
}

class _EvieOvalGrayState extends State<EvieOvalGray> {
  double buttonWidth = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        buttonWidth = getTextWidth(widget.buttonText);
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: buttonWidth > constraints.maxWidth ? constraints.maxWidth : buttonWidth,
            height: 35.h,
            decoration: BoxDecoration(
              color: EvieColors.lightGrayishCyan,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(widget.buttonText),
            ),
          ),
        );
      },
    );
  }

  double getTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: EvieTextStyles.body14),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width + 50.w; // add some padding to the width
  }
}
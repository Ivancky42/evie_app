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
            height: 30.h,
            decoration: BoxDecoration(
              color: EvieColors.lightGrayishCyan,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(widget.buttonText, style: EvieTextStyles.body14,),
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




class EvieOvalBlack extends StatefulWidget {
  final String buttonText;

  const EvieOvalBlack({Key? key,
    required this.buttonText,
  }) : super(key: key);

  @override
  _EvieOvalBlackState createState() => _EvieOvalBlackState();
}

class _EvieOvalBlackState extends State<EvieOvalBlack> {
  double buttonWidth = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        buttonWidth = getTextWidth(widget.buttonText);
        return GestureDetector(
          child: Container(
            width: buttonWidth > constraints.maxWidth ? constraints.maxWidth : buttonWidth,
            height: 35.h,
            decoration: BoxDecoration(
              color: EvieColors.mediumLightBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(widget.buttonText, style: EvieTextStyles.body14.copyWith(color: EvieColors.grayishWhite)),
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
import 'package:flutter/material.dart';

import '../theme/ThemeChangeNotifier.dart';

///Button Widget
class EvieButton_TextForm_Constant extends StatelessWidget {

  final double width;
  final double height;
  final String hintText;

  const EvieButton_TextForm_Constant({
    Key? key,
    required this.width,
    required this.height,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        //height: height,
        //width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                enabled: false,
                hintText: hintText,
                hintStyle: TextStyle(
                    fontSize: 13,
                  color: ThemeChangeNotifier().isDarkMode(context) == true ? Colors.white70 : Colors.black,
                ),
                filled: true,
                //<-- SEE HERE
                fillColor: Color(0xFFFFFFFF).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
            ),
        )
    );
  }
}
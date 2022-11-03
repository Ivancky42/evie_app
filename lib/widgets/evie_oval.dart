import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


///Double button dialog
class EvieOvalGray extends StatelessWidget{
  String text;
  double? width;
  double? height;

  EvieOvalGray({
    Key? key,
    required this.text,
    this.height,
    this.width,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
        height: height,
        width:width,
        decoration: BoxDecoration(
          color: Color(0xffDFE0E0),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Center(child:Text(text,style: TextStyle(fontSize: 12),)),
      );
    }
}
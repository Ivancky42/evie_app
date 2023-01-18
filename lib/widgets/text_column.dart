import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_oval.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

///Cupertino switch widget
class TextColumn extends StatelessWidget {
  final String title;
  final String body;

  const TextColumn({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color:EvieColors.darkGrayishCyan),),
        Text(body,style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: EvieColors.lightBlack),),
      ],
    );

  }
}

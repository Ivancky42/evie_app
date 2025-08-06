import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/colours.dart';

///Cupertino switch widget
class TextColumn extends StatelessWidget {
  final String title;
  final String body;

  const TextColumn({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan)),
        SizedBox(height: 2.h,),
        Text(body,style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),
      ],
    );

  }
}



import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class PlanPageElementRow extends StatelessWidget {
  final String content;

  const PlanPageElementRow({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/tick.svg",
          height: 24.h,
          width: 24.w,
        ),

        SizedBox(width: 4.w,),
        Text(content, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Color(0xff383838)),)

      ],
    );
  }
}
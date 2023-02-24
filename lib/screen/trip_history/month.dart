import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/navigator.dart';


class TripMonth extends StatelessWidget{

  const TripMonth({Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return   Padding(
        padding: EdgeInsets.only(left: 32.w, right: 32.w),
        child: Column(children: [
          SvgPicture.asset(
            "assets/images/send_email.svg",
          ),
          GestureDetector(
              onTap: (){
                changeToTestBLEScreen(context);
              },
              child: Text("You do not have permission to view this data")
          ),

        ],)
    );
  }
}

import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';

class BikeLoading extends StatefulWidget {
  const BikeLoading({Key? key}) : super(key: key);

  @override
  State<BikeLoading> createState() => _BikeLoadingState();
}

class _BikeLoadingState extends State<BikeLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: EvieColors.grayishWhite,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //color: Colors.red,
              child: LottieBuilder.asset(
                'assets/animations/loading.json',
                height: 260.h, // Adjust the height to your desired value
                width: 400.w,  // Adjust the width to your desired value
                repeat: true,
                fit: BoxFit.cover,
              ),
            ),
            //SizedBox(height: 32.h,),
            Text(
              "Loading...",
              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack)),
          ],
        ),
      ),
    );
  }
}

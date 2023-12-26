import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/colours.dart';

class EvieProgressIndicator extends StatelessWidget {

  final int currentPageNumber;
  final int totalSteps;
  final EdgeInsetsGeometry;

  const EvieProgressIndicator({
    Key? key,
    required this.currentPageNumber,
    required this.totalSteps,
    this.EdgeInsetsGeometry,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: totalSteps == 8 ? EdgeInsets.fromLTRB(70.w, 66.h, 70.w,50.h) : totalSteps == 3 ? EdgeInsets.fromLTRB(151.w, 36.h, 151.w,0.h) : totalSteps == 2 ? EdgeInsets.fromLTRB(151.w, 18.h, 151.w,0.h) : EdgeInsets.fromLTRB(102.w, 66.h, 102.w,42.h),
      child: StepProgressIndicator(
        customColor: (index) => index < currentPageNumber ? EvieColors.lightPurple : index > currentPageNumber ? EvieColors.progressBarGrey : EvieColors.primaryColor,
        totalSteps: totalSteps,
        currentStep: currentPageNumber,
        selectedSize: 4,
        unselectedSize: 4,
        //    padding: 0.0,
        //roundedEdges: Radius.circular(20),
        customStep: (index, color, double) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed.
              color: index < currentPageNumber ? EvieColors.lightPurple : index > currentPageNumber ? EvieColors.progressBarGrey : EvieColors.primaryColor
            ),
          );
        },
      ),
    );
  }
}

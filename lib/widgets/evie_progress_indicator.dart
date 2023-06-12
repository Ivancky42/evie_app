import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/colours.dart';

class EvieProgressIndicator extends StatelessWidget {

  final int currentPageNumber;
  final int totalSteps;

  const EvieProgressIndicator({
    Key? key,
    required this.currentPageNumber,
    required this.totalSteps,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: totalSteps == 8 ? EdgeInsets.fromLTRB(70.w, 66.h, 70.w,50.h) : EdgeInsets.fromLTRB(151.w, 36.h, 151.w,0.h),
    child: StepProgressIndicator(
    customColor: (index) => index < currentPageNumber ? EvieColors.lightPurple : index > currentPageNumber ? EvieColors.progressBarGrey : EvieColors.primaryColor,
    totalSteps: totalSteps,
    currentStep: currentPageNumber,
    selectedSize: 4,
    unselectedSize: 4,
    //    padding: 0.0,
    roundedEdges: Radius.circular(20),
    ),
    );
  }
}

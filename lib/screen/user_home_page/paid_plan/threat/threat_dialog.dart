import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_container.dart';
import 'package:flutter/material.dart';
import '../../../../api/colours.dart';

class ThreatDialog extends StatefulWidget {
  final BuildContext contextS;
  const ThreatDialog({Key? key, required this.contextS}) : super(key: key);

  @override
  State<ThreatDialog> createState() => _ThreatDialogState();
}

class _ThreatDialogState extends State<ThreatDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.only(left: 16.w, right: 16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: EvieColors.grayishWhite,
        child: Container(
          height: 700.h,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
            child: ThreatContainer(context: widget.contextS,),
          ),
        )
    );
  }
}


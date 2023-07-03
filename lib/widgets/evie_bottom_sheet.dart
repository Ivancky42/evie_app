import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';

class EvieBottomSheet extends StatefulWidget {

  Widget? leftChild;
  Widget? rightChild;
  Widget? childContext;
  String? title;

  EvieBottomSheet({
    this.leftChild,
    this.rightChild,
    this.childContext,
    this.title,
    Key? key
  }) : super(key: key);

  @override
  State<EvieBottomSheet> createState() => _EvieBottomSheetState();
}

class _EvieBottomSheetState extends State<EvieBottomSheet> {

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/');
          return false;
        },
        child:  Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: CupertinoPageScaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              child:  Container(
                decoration: const BoxDecoration(
                  color: EvieColors.grayishWhite,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    /// home indicator
                    Padding(
                      padding: EdgeInsets.only(top: 11.h),
                      child: Image.asset(
                        "assets/buttons/home_indicator.png",
                        width: 40.w,
                        height: 4.h,
                      ),
                    ),

                    Expanded(
                      child: widget.childContext ?? Container(),
                    ),

                  ],
                ),
              ),
          )
        ),
    );
  }
}


class EvieBottomSheetDanger extends StatefulWidget {

  Widget? leftChild;
  Widget? rightChild;
  Widget? childContext;
  String? title;

  EvieBottomSheetDanger({
    this.leftChild,
    this.rightChild,
    this.childContext,
    this.title,
    Key? key
  }) : super(key: key);

  @override
  _EvieBottomSheetDangerState createState() => _EvieBottomSheetDangerState();
}

class _EvieBottomSheetDangerState extends State<EvieBottomSheetDanger> {

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
      ),
      child: Column(
        children: [
          /// home indicator
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: Image.asset(
              "assets/buttons/home_indicator.png",
              width: 40.w,
              height: 4.h,
            ),
          ),

          Expanded(
            child: widget.childContext ?? Container(),
          ),

        ],
      ),
    );
  }
}
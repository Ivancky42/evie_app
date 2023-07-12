import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../api/provider/setting_provider.dart';

class EvieBottomSheet extends StatefulWidget {
  final Widget? widget;
  const EvieBottomSheet({super.key, this.widget});

  @override
  State<EvieBottomSheet> createState() => _EvieBottomSheetState();
}

class _EvieBottomSheetState extends State<EvieBottomSheet> {

  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return Material(
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (BuildContext newContext) =>
              GestureDetector(
                ///To prevent sheet drag dismiss
                // onVerticalDragStart: (details) {
                //
                // },
                child: WillPopScope(
                  onWillPop: () async {

                    return false;
                  },
                  child: CupertinoPageScaffold(
                    child: Padding(
                        padding: EdgeInsets.only(top: 0.h),
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
                                  padding: EdgeInsets.only(top: 11.h, bottom:10.h),
                                  child: Image.asset(
                                    "assets/buttons/home_indicator.png",
                                    width: 40.w,
                                    height: 4.h,
                                  ),
                                ),

                                Expanded(
                                  child: widget.widget ?? Container(),
                                ),

                              ],
                            ),
                          ),
                        )
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  void pushRoute(BuildContext context, BuildContext modalContext) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('New Page'),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(modalContext).pop(),
                child: const Text('touch here'),
              )
            ],
          ),
        ),
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
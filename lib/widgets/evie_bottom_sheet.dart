import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/action_list/deactivate_theft_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../api/enumerate.dart';
import '../api/provider/setting_provider.dart';
import 'evie_double_button_dialog.dart';

class EvieBottomSheet extends StatefulWidget {
  final Widget? widget;
  const EvieBottomSheet({super.key, this.widget});

  @override
  State<EvieBottomSheet> createState() => _EvieBottomSheet();
}

class _EvieBottomSheet extends State<EvieBottomSheet> {

  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return Material(
      /// child: Navigator(
      ///  onGenerateRoute: (_) => MaterialPageRoute<void>(
      ///    builder: (BuildContext newContext) =>
              child: GestureDetector(
                ///To prevent sheet drag dismiss
                // onVerticalDragStart: (details) {
                //
                // },
             ///  child: WillPopScope(
                 ///Place will pop scope on every individual page.
             ///     onWillPop: () async {
              ///      return false;
                    // bool shouldClose = true;
                    // await showCupertinoDialog<void>(
                    //     context: context,
                    //     builder: (BuildContext context) => CupertinoAlertDialog(
                    //       title: const Text('Close Sheet?'),
                    //       actions: <Widget>[
                    //         CupertinoButton(
                    //           child: const Text('Yes'),
                    //           onPressed: () {
                    //             shouldClose = true;
                    //             Navigator.of(context).pop();
                    //           },
                    //
                    //         ),
                    //         CupertinoButton(
                    //           child: const Text('No'),
                    //           onPressed: () {
                    //             shouldClose = false;
                    //             Navigator.of(context).pop();
                    //           },
                    //         ),
                    //       ],
                    //     ));
                    // return shouldClose;
              ///    },
                  child: CupertinoPageScaffold(
                    child: Padding(
                        padding: EdgeInsets.only(top: 0.h),
                        child: CupertinoPageScaffold(
                          backgroundColor: EvieColors.transparent,
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
          ///      ),
      ///        ),
      ///   ),
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

class EvieBottomSheetAction extends StatefulWidget {
  final List<ActionList> lists;
  EvieBottomSheetAction({super.key, required this.lists});

  @override
  State<EvieBottomSheetAction> createState() => _EvieBottomSheetAction();
}

class _EvieBottomSheetAction extends State<EvieBottomSheetAction> {

  late SettingProvider _settingProvider;

  List<Widget> actionWidgets = [];

  @override
  void initState() {
    super.initState();
    for (ActionList list in widget.lists) {
      if (list == ActionList.deactivateTheftAlert) {
        actionWidgets.add(DeactivateTheftAlert());
      }
  }

  // else if (fruit == 'apple') {
  //   actionWidgets.add(DeactivateTheftAlert());
  // }
  // Add more conditions for other fruits if needed
  }
  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return Material(
      child: GestureDetector(
                ///To prevent sheet drag dismiss
                // onVerticalDragStart: (details) {
                //
                // }

                 ///Working cannot dismiss
        child: WillPopScope(
          onWillPop: () async {
            // bool shouldClose = true;
            // await showDialog<void>(
            //     context: context,
            //     builder: (BuildContext context) =>
            //         EvieDoubleButtonDialog(
            //             title: "Close this sheet?",
            //             childContent: Text("Are you sure you want to close this sheet?",
            //               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
            //             leftContent: "No",
            //             rightContent: "Yes",
            //             onPressedLeft: () {
            //               shouldClose = false;
            //               Navigator.of(context).pop();
            //             },
            //             onPressedRight: () {
            //               shouldClose = true;
            //               Navigator.of(context).pop();
            //             }));
            // return shouldClose;
            return true;
          },
                  child: CupertinoPageScaffold(
                    child: Padding(
                        padding: EdgeInsets.only(top: 0.h, bottom:64.h),
                        child: CupertinoPageScaffold(
                          backgroundColor: EvieColors.transparent,
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

                                ListView(
                                  shrinkWrap: true,
                                  children: actionWidgets,
                                ),
                                // Column(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [Container(
                                //     height: 100.h,
                                //     child: Text("hiii"),
                                //   ),]
                                // ),

                              ],
                            ),
                          ),
                        )
                    ),
                  ),
                ),
              ),

    );
  }

}
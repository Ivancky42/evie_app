import 'dart:async';

import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';
import '../../../widgets/evie_single_button_dialog.dart';

class BikeEraseLeave extends StatefulWidget{
  const BikeEraseLeave({Key?key}) : super(key:key);
  @override
  _BikeEraseLeaveState createState() => _BikeEraseLeaveState();
}

class _BikeEraseLeaveState extends State<BikeEraseLeave>{

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      ///Listen provider data in init state
      //_bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      _bikeProvider = context.read<BikeProvider>();

      StreamSubscription? currentSubscription;

      currentSubscription = _bikeProvider.leaveSharedBike(
          _bikeProvider.currentUserModel!.uid, '').listen((uploadStatus) {

        if(uploadStatus == UploadFirestoreResult.success){

          _settingProvider.changeSheetElement(SheetList.leaveSuccessful);

          currentSubscription?.cancel();
        } else if(uploadStatus == UploadFirestoreResult.failed) {
          SmartDialog.dismiss();
          SmartDialog.show(
              widget: EvieSingleButtonDialog(
                  title: "Not success",
                  content: "Try again",
                  rightContent: "Close",
                  onPressedRight: ()=>SmartDialog.dismiss()
              ));
        }else{};
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showCannotClose() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
        body: Container(
          color: EvieColors.grayishWhite,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Lottie.asset('assets/animations/account-verify.json'),
              Lottie.asset('assets/animations/erase_bike.json',

                height: 157.64.h,
                width: 279.49.w,

              ),
            ],
          ),
        ),
      ),
    );

  }
}
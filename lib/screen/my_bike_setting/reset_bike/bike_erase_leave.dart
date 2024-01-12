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
          _bikeProvider.currentUserModel!.uid, _bikeProvider.currentBikeModel!.deviceIMEI!).listen((uploadStatus) {

        if(uploadStatus == UploadFirestoreResult.success){

          _settingProvider.changeSheetElement(SheetList.leaveSuccessful);

          currentSubscription?.cancel();
        } else if(uploadStatus == UploadFirestoreResult.failed) {
          SmartDialog.dismiss();
          SmartDialog.show(
              widget: EvieSingleButtonDialogOld(
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
        bool shouldClose = true;
        await showDialog<void>(
            context: context,
            builder: (BuildContext context) =>
                EvieOneDialog(
                    title: "Stay with Us",
                    content1: "We're handling the progress for you. It won't take long. Please stay on this page until we're done. Your understanding is valued!",
                    middleContent: "Understood",
                    svgpicture: SvgPicture.asset("assets/images/stay.svg"),
                    onPressedMiddle: () {
                      shouldClose = false;
                      Navigator.of(context).pop();
                    })
        );
        return shouldClose;
      },
      child: Container(
        color: EvieColors.grayishWhite,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Lottie.asset('assets/animations/account-verify.json'),
            Lottie.asset('assets/animations/erase_bike.json',

              height: 236.46.h,
              width: 419.235.w,

            ),
          ],
        ),
      ),
    );

  }
}
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class BikeEraseUnlink extends StatefulWidget{
  const BikeEraseUnlink({Key?key}) : super(key:key);
  @override
  _BikeEraseUnlinkState createState() => _BikeEraseUnlinkState();
}

class _BikeEraseUnlinkState extends State<BikeEraseUnlink>{

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      ///Listen provider data in init state
      //_bikeProvider = Provider.of<BikeProvider>(context, listen: false);
      _bikeProvider = context.read<BikeProvider>();

      _bikeProvider.unlinkBikeNew().listen((event) {
        switch(event){
          case UploadFirestoreResult.uploading:
            // TODO: Handle this case.
            break;
          case UploadFirestoreResult.failed:
            showFailed();
            break;
          case UploadFirestoreResult.partiallySuccess:
            // TODO: Handle this case.
            break;
          case UploadFirestoreResult.success:
            _settingProvider.changeSheetElement(SheetList.forgetCompleted);
            break;
        }
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
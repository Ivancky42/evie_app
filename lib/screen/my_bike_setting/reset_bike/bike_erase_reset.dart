import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
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

class BikeEraseReset extends StatefulWidget{
  const BikeEraseReset({Key?key}) : super(key:key);
  @override
  _BikeEraseResetState createState() => _BikeEraseResetState();
}

class _BikeEraseResetState extends State<BikeEraseReset>{

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {


      _bluetoothProvider = context.read<BluetoothProvider>();
      _bluetoothProvider.factoryReset().listen((event) {
       if(event.result  == CommandResult.success){

         _bikeProvider = context.read<BikeProvider>();
         _bikeProvider.resetBikeNew().listen((event) {
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
               _settingProvider.changeSheetElement(SheetList.fullCompleted);
               break;
           }
         });

       }else if(event.result == CommandResult.failed){
         showFailed();
       }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//Code here
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
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
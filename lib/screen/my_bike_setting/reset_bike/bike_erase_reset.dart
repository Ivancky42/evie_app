import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_single_button_dialog.dart';

class BikeEraseReset extends StatefulWidget{
  const BikeEraseReset({super.key});
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
               _bluetoothProvider.disconnectDevice();
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

                height: 236.46.h,
                width: 419.235.w,

              ),
            ],
          ),
        ),
      ),
    );

  }
}
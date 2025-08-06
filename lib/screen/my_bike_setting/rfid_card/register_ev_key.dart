import 'dart:async';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_button.dart';


class RegisterEVKey extends StatefulWidget {
  const RegisterEVKey({super.key});

  @override
  _RegisterEVKeyState createState() => _RegisterEVKeyState();
}

class _RegisterEVKeyState extends State<RegisterEVKey> {

  late BluetoothProvider _bluetoothProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;
  late StreamSubscription addRFIDStream;
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startScanRFIDCard());
  }

  @override
  Widget build(BuildContext context) {
    _bluetoothProvider =  Provider.of<BluetoothProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // addRFIDStream.cancel();
        // if(_bikeProvider.rfidList.length >0){
        //   _settingProvider.changeSheetElement(SheetList.evKeyList);
        // }else{
        //   _settingProvider.changeSheetElement(SheetList.bikeSetting);
        // }

        return true;
      },
      child: Scaffold(
        // appBar: PageAppbar(
        //   title: 'Register EV-Key',
        //   onPressed: () {
        //     addRFIDStream.cancel();
        //     if(_bikeProvider.rfidList.length >0){
        //       _settingProvider.changeSheetElement(SheetList.evKeyList);
        //     }else{
        //       _settingProvider.changeSheetElement(SheetList.bikeSetting);
        //     }
        //   },
        // ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: EvieLength.target_reference_button_a),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: Container(
                              width: 25.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: EvieColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: Container(
                              width: 25.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: EvieColors.progressBarGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 32.5.h, 16.w,4.h),
                        child: Text(
                          "Flash your EV-Key at the lock",
                          style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 81.h),
                        child: Text(
                          "Hold and place your EV-Key near the bike's lock.",
                          style: EvieTextStyles.body18,
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          //color: Colors.red,
                          width: 330.w,
                          height: 330.w,
                          child: Lottie.asset('assets/animations/RFID-card-register-R2.json', repeat: false, animate: isAnimate),
                        )
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      onPressed: (){
                        addRFIDStream.cancel();
                        if(_bikeProvider.rfidList.isNotEmpty){
                          _settingProvider.changeSheetElement(SheetList.evKeyList);
                        }else{
                          _settingProvider.changeSheetElement(SheetList.bikeSetting);
                        }
                      },
                      child: Text("Exit EV-Key Registration", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  startScanRFIDCard(){
    showCustomLightLoading("Register EV-Key....");
    setState(() {
      isAnimate = true;
    });
    addRFIDStream = _bluetoothProvider.addRFID().listen((addRFIDStatus)  async {
      SmartDialog.dismiss(status: SmartStatus.loading);

      if (addRFIDStatus.addRFIDState == AddRFIDState.startReadCard) {
      }else if(addRFIDStatus.addRFIDState == AddRFIDState.addCardSuccess){
          addRFIDStream.cancel();
          SmartDialog.dismiss(status: SmartStatus.loading);

          final result = await _bikeProvider.uploadRFIDtoFireStore(addRFIDStatus.rfidNumber!, "EV-Key ${(_bikeProvider.rfidList.length + 1).toString()}");
          if (result == true) {

            _settingProvider.changeSheetElement(SheetList.nameEv, addRFIDStatus.rfidNumber!);

          } else {
            _settingProvider.changeSheetElement(SheetList.evAddFailed);
          }

      }else if(addRFIDStatus.addRFIDState == AddRFIDState.cardIsExist){
        ///Upload to firestore and change to name rfid page
        addRFIDStream.cancel();
        showEVKeyExistAndUploadToFirestore(context, addRFIDStatus.rfidNumber!);
        _settingProvider.changeSheetElement(SheetList.evKeyList, addRFIDStatus.rfidNumber!);
      }
    }, onError: (error) {
      addRFIDStream.cancel();
      SmartDialog.dismiss(status: SmartStatus.loading);
      //showAddEVKeyFailed(context);
      _settingProvider.changeSheetElement(SheetList.evAddFailed);
    });
  }

}

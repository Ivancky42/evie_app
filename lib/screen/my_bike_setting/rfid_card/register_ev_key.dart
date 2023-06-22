import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';


class RegisterEVKey extends StatefulWidget {
  const RegisterEVKey({Key? key}) : super(key: key);

  @override
  _RegisterEVKeyState createState() => _RegisterEVKeyState();
}

class _RegisterEVKeyState extends State<RegisterEVKey> {

  late BluetoothProvider _bluetoothProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;
  late StreamSubscription addRFIDStream;

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
        Navigator.of(context).pop();
        addRFIDStream.cancel();
        if(_bikeProvider.rfidList.length >0){
          _settingProvider.changeSheetElement(SheetList.evKeyList);
        }else{
          showBikeSettingSheet(context);
        }

        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Register EV-Key',
          onPressed: () {
            Navigator.of(context).pop();
            addRFIDStream.cancel();
            if(_bikeProvider.rfidList.length >0){
              _settingProvider.changeSheetElement(SheetList.evKeyList);
            }else{
              showBikeSettingSheet(context);
            }
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 32.5.h, 16.w,4.h),
                  child: Text(
                    "Flash your EV-Key at the lock",
                    style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
                  child: Text(
                    "Hold and place your EV-Key near the bike's lock.",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Center(
                      child: Container(
                        width: double.infinity,
                        height: 500.h,
                        child: Lottie.asset('assets/animations/RFIDCardRegister.json', width: 200.w, height: 228.84.h),
                      ),
                    ),

              ],
            ),
          ],
        ),),
    );
  }

  startScanRFIDCard(){
    SmartDialog.showLoading(msg: "register RFID....");
    addRFIDStream = _bluetoothProvider.addRFID().listen((addRFIDStatus)  async {
      SmartDialog.dismiss(status: SmartStatus.loading);

      if (addRFIDStatus.addRFIDState == AddRFIDState.startReadCard) {
      }else if(addRFIDStatus.addRFIDState == AddRFIDState.addCardSuccess){
          addRFIDStream.cancel();
          SmartDialog.dismiss(status: SmartStatus.loading);

          final result = await _bikeProvider.uploadRFIDtoFireStore(addRFIDStatus.rfidNumber!, "RFID Card");
          if (result == true) {

            showAddEVKeySuccess(context, addRFIDStatus.rfidNumber!);

          } else {
            showUploadEVKeyToFirestoreFailed(context);
          }

      }else if(addRFIDStatus.addRFIDState == AddRFIDState.cardIsExist){
        ///Upload to firestore and change to name rfid page
        addRFIDStream.cancel();
        final result = await _bikeProvider.uploadRFIDtoFireStore(addRFIDStatus.rfidNumber!, "RFID Card");
        if (result == true) {

          showEVKeyExistAndUploadToFirestore(context, addRFIDStatus.rfidNumber!);

        } else {
          _settingProvider.changeSheetElement(SheetList.evAddFailed);
        }
      }
    }, onError: (error) {
      addRFIDStream.cancel();
      SmartDialog.dismiss(status: SmartStatus.loading);
      //showAddEVKeyFailed(context);
      _settingProvider.changeSheetElement(SheetList.evAddFailed);
    });
  }

}

import 'dart:async';
import 'dart:io';
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
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
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

    return WillPopScope(
      onWillPop: () async {
        addRFIDStream.cancel();
        if(_bikeProvider.rfidList.length >0){
          changeToEVKeyList(context);
        }else{
          showBikeSettingSheet(context);
        }

        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Register your EV-Key',
          onPressed: () {
            addRFIDStream.cancel();
            if(_bikeProvider.rfidList.length >0){
              changeToEVKeyList(context);
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
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: Text(
                    "Flash your EV-Key at the lock",
                    style: EvieTextStyles.h2,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 155.h),
                  child: Text(
                    "Hold and place your EV-Key near the bike's lock.",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,221.h),
                    child: Center(
                      child:  Lottie.asset('assets/animations/RFIDCardRegister.json'),
                    ),
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
        ///Upload to firestore and change to name bike page
        addRFIDStream.cancel();
        final result = await _bikeProvider.uploadRFIDtoFireStore(addRFIDStatus.rfidNumber!, "RFID Card");
        if (result == true) {

          showEVKeyExistAndUploadToFirestore(context, addRFIDStatus.rfidNumber!);

        } else {
          showAddEVKeyFailed(context);
        }
      }
    }, onError: (error) {
      addRFIDStream.cancel();
      SmartDialog.dismiss(status: SmartStatus.loading);
      showAddEVKeyFailed(context);
    });
  }

}

import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_single_button_dialog.dart';


///User profile page with user account information

class AddNewRFID extends StatefulWidget {
  const AddNewRFID({Key? key}) : super(key: key);

  @override
  _AddNewRFIDState createState() => _AddNewRFIDState();
}

class _AddNewRFIDState extends State<AddNewRFID> {

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
          changeToRFIDListScreen(context);
        }else{
          changeToNavigatePlanScreen(context);
        }

        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'Add New RFID Card',
          onPressed: () {
            addRFIDStream.cancel();
            if(_bikeProvider.rfidList.length >0){
              changeToRFIDListScreen(context);
            }else{
              changeToNavigatePlanScreen(context);
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
                    "Add New RFID Card",
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 155.h),
                  child: Text(
                    "Scan your RFID card",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,221.h),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/mention_amigo.svg",
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
            SmartDialog.show(
                widget: EvieSingleButtonDialog(
                    title: "Success",
                    content: "Card added",
                    rightContent: "OK",
                    onPressedRight: () {
                      SmartDialog.dismiss();

                      changeToNameRFIDScreen(context, addRFIDStatus.rfidNumber!);
                    }));
          } else {
            SmartDialog.show(
                widget: EvieSingleButtonDialog(
                    title: "Error",
                    content: "Error upload rfid to firestore",
                    rightContent: "OK",
                    onPressedRight: () {
                      SmartDialog.dismiss();
                      changeToRFIDAddFailedScreen(context);
                    }));
          }

      }else if(addRFIDStatus.addRFIDState == AddRFIDState.cardIsExist){
        ///Upload to firestore and change to name bike page
        addRFIDStream.cancel();
        final result = await _bikeProvider.uploadRFIDtoFireStore(addRFIDStatus.rfidNumber!, "RFID Card");
        if (result == true) {
          SmartDialog.show(
              widget: EvieSingleButtonDialog(
                  title: "Success",
                  content: "Card already exists, data uploaded",
                  rightContent: "OK",
                  onPressedRight: () {
                    SmartDialog.dismiss();

                    changeToNameRFIDScreen(context, addRFIDStatus.rfidNumber!);
                  }));
        } else {
          SmartDialog.show(
              widget: EvieSingleButtonDialog(
                  title: "Error",
                  content: "Error upload rfid to firestore",
                  rightContent: "OK",
                  onPressedRight: () {
                    SmartDialog.dismiss();
                    changeToRFIDAddFailedScreen(context);
                  }));
        }
      }
    }, onError: (error) {
      addRFIDStream.cancel();
      SmartDialog.dismiss(status: SmartStatus.loading);
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialog(
          title: "Error",
          content: error.toString(),
          rightContent: "OK",
          onPressedRight: (){
            SmartDialog.dismiss();
            changeToRFIDAddFailedScreen(context);
          }));
    });
  }

}

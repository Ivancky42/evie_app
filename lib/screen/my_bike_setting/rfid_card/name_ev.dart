import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';



class NameEV extends StatefulWidget {
  //final String rfidNumber;

  const NameEV(
      //this.rfidNumber,
      {Key? key}) : super(key: key);

  @override
  _NameEVState createState() => _NameEVState();
}

class _NameEVState extends State<NameEV> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  final TextEditingController _rfidNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        SmartDialog.show(
            widget: EvieDoubleButtonDialog(
                title: "Are you sure you want to quit adding RFID?",
                childContent: const Text("?"),
                leftContent: "Cancel",
                rightContent: "Yes",
                onPressedLeft: () {
                  SmartDialog.dismiss();
                },
                onPressedRight: () async {
                  SmartDialog.dismiss();
                  await _bikeProvider.deleteRFIDFirestore(_settingProvider.stringPassing!);
                  _bluetoothProvider.deleteRFID(_settingProvider.stringPassing!);
                  _settingProvider.changeSheetElement(SheetList.bikeSetting);
                }));
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'New EV-Key',
          onPressed: () {
            SmartDialog.show(
                widget: EvieDoubleButtonDialog(
                    title: "Are you sure you want to quit adding RFID?",
                    childContent: const Text("?"),
                    leftContent: "Cancel",
                    rightContent: "Yes",
                    onPressedLeft: () {
                      SmartDialog.dismiss();
                    },
                    onPressedRight: () {
                      SmartDialog.dismiss();
                      _bikeProvider.deleteRFIDFirestore(_settingProvider.stringPassing!);
                      _bluetoothProvider.deleteRFID(_settingProvider.stringPassing!);
                      _settingProvider.changeSheetElement(SheetList.bikeSetting);
                    }));
          },
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 2.h),
                    child: Text(
                      "Label your EV-Key",
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 11.h),
                    child: Text(
                      "Label your EV-Key similar with the name you wrote on the Key so that you can differentiate them easily. ",
                      style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: EvieTextFormField(
                      controller: _rfidNameController,
                      obscureText: false,
                      // keyboardType: TextInputType.name,
                      hintText: "EV-Key Label",
                      labelText: "EV-Key 1",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter RFID Card name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16.w, 127.84.h, 16.w, EvieLength.buttonWord_ButtonBottom),
                child: SizedBox(
                  height: 48.h,
                  width: double.infinity,
                  child: EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {

                        ///For keyboard un focus
                        FocusManager.instance.primaryFocus?.unfocus();

                        addRFIDtoFireStore(_rfidNameController.text.trim());

                      }
                    },
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonbutton_buttonBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Can't think of any name now",
                      softWrap: false,
                      style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      _settingProvider.changeSheetElement(SheetList.evKeyList);
                      // if(_bikeProvider.rfidList.length >0){
                      //   _settingProvider.changeSheetElement(SheetList.evKeyList);
                      // }else{
                      //   showBikeSettingSheet(context);
                      // }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addRFIDtoFireStore(String rfidName) async {
    final result = await _bikeProvider.uploadRFIDtoFireStore(_settingProvider.stringPassing!, rfidName);
    if (result == true) {
      SmartDialog.show(
          widget: EvieSingleButtonDialog(
              title: "Success",
              content: "Card added",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();

                ///Change to rfid list
                _settingProvider.changeSheetElement(SheetList.evKeyList);
              }));
    } else {
      SmartDialog.show(
          widget: EvieSingleButtonDialog(
              title: "Error",
              content: "Error upload rfid to firestore",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();
                _settingProvider.changeSheetElement(SheetList.evAddFailed);
              }));
    }
  }
}

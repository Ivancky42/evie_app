import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';



class NameRFID extends StatefulWidget {
  final String rfidNumber;

  const NameRFID(this.rfidNumber, {Key? key}) : super(key: key);

  @override
  _NameRFIDState createState() => _NameRFIDState();
}

class _NameRFIDState extends State<NameRFID> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    final TextEditingController _rfidNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
                onPressedRight: () {
                  SmartDialog.dismiss();
                  _bikeProvider.deleteRFIDFirestore(widget.rfidNumber);
                  _bluetoothProvider.deleteRFID(widget.rfidNumber);
                  changeToNavigatePlanScreen(context);
                }));
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'New RFID Card',
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
                      _bikeProvider.deleteRFIDFirestore(widget.rfidNumber);
                      _bluetoothProvider.deleteRFID(widget.rfidNumber);
                      changeToNavigatePlanScreen(context);
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
                    padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 4.h),
                    child: Text(
                      "Give your RFID Card a name",
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
                    child: Text(
                      "some texts here",
                      style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: EvieTextFormField(
                      controller: _rfidNameController,
                      obscureText: false,
                      //     keyboardType: TextInputType.name,
                      hintText: "Name your RFID Card",
                      labelText: "Name your RFID Card",
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
                    16.w, 127.84.h, 16.w, EvieLength.button_Bottom),
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
                        addRFIDtoFireStore(_rfidNameController.text.trim());
                      }
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
    final result = await _bikeProvider.uploadRFIDtoFireStore(widget.rfidNumber, rfidName);
    if (result == true) {
      SmartDialog.show(
          widget: EvieSingleButtonDialog(
              title: "Success",
              content: "Card added",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();

                ///Change to rfid list
                changeToRFIDListScreen(context);
              }));
    } else {
      SmartDialog.show(
          widget: EvieSingleButtonDialog(
              title: "Error",
              content: "Error upload rfid to firestore",
              rightContent: "OK",
              onPressedRight: () {
                SmartDialog.dismiss();
                changeToRFIDCardScreen(context);
              }));
    }
  }
}

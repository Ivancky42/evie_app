import 'dart:io';
import 'package:evie_test/api/model/rfid_model.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/bluetooth_provider.dart';
import '../bluetooth/modelResult.dart';
import '../theme/ThemeChangeNotifier.dart';

///User profile page with user account information

class RFIDCardManage extends StatefulWidget {
  const RFIDCardManage({Key? key}) : super(key: key);

  @override
  _RFIDCardManageState createState() => _RFIDCardManageState();
}

class _RFIDCardManageState extends State<RFIDCardManage> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    changeToUserHomePageScreen(context);
                  }),
              const Text('RFID card'),
            ],
          ),
        ),
        body: Scaffold(
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                          const Text("RFID LIST"),
                          Text(
                              "Amount of rfid:  ${_bikeProvider.rfidList.length}"),
                          Container(
                            height: 500,
                              width:double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                                color: Color(0xffD7E9EF),
                              ),
                              child: Center(
                                child: ListView.separated(
                                  itemCount: _bikeProvider.rfidList.length,
                                  itemBuilder: (context, index) {
                                    String key = _bikeProvider.rfidList.keys
                                        .elementAt(index);
                                    return listItem(
                                        _bikeProvider.rfidList[key]);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider();
                                  },
                                ),
                              )),
                          FloatingActionButton.small(
                            heroTag: null,
                            child: const Icon(Icons.add),
                            onPressed: () {
                              SmartDialog.showLoading(msg: "Adding rfid....");
                              if (_bluetoothProvider.bleStatus ==
                                  BleStatus.ready) {
                                // _bluetoothProvider.addRFID([0x1A,0x2B,0x3C,0x4D]).listen(
                                //     (addResult) {
                                //   SmartDialog.dismiss(
                                //       status: SmartStatus.loading);
                                //   if (addResult.result ==
                                //       CommandResult.success) {
                                //
                                //     _bikeProvider.uploadRFIDtoFireStore([0x1A,0x2B,0x3C,0x4D]); //result
                                //
                                //     print("Success");
                                //
                                //     /// Successfully added
                                //   } else {
                                //     /// Failed to added
                                //   }
                                // }, onError: (error) {
                                //   SmartDialog.dismiss(
                                //       status: SmartStatus.loading);
                                //   print(error);
                                // });
                              } else {
                                showAlertDialog(context);
                              }
                            },
                          ),
                        ])))))));
  }

  Widget listItem(RFIDModel? rfidModel) {
    if (rfidModel != null) {
      return ListTile(
        leading: Text(rfidModel.rfidID!,style: TextStyle(fontSize: 10),),
        //   title: deviceName(discoveredDevice.name),
        //  subtitle: deviceSignal(discoveredDevice.rssi.toString()),
        trailing: FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.remove),
          onPressed: () {
            SmartDialog.showLoading(msg: "Remove rfid....");
            if (_bluetoothProvider.bleStatus == BleStatus.ready) {
              // _bluetoothProvider.deleteRFID([0x1A,0x2B,0x3C,0x4D]).listen((removeResult) {
              //   SmartDialog.dismiss(status: SmartStatus.loading);
              //   if (removeResult.result == CommandResult.success) {
              //     print("success delete");
              //     /// Successfully delete
              //   } else {
              //     /// Failed to delete
              //   }
              // }, onError: (error) {
              //   SmartDialog.dismiss(status: SmartStatus.loading);
              //   print(error);
              // });
            } else {
              showAlertDialog(context);
            }
          },
        ),
      );
    } else {
      return Container();
    }
  }
}

import 'dart:async';

import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/model/rfid_model.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/length.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar_badge.dart';
import '../../../widgets/evie_textform.dart';

class EVKeyList extends StatefulWidget {
  const EVKeyList({super.key});

  @override
  _EVKeyListState createState() => _EVKeyListState();
}

class _EVKeyListState extends State<EVKeyList> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  bool isManageList = false;
  DeviceConnectResult? deviceConnectResult;

  late StreamSubscription deleteRFIDStream;
  late Completer<String?> deleteAllEVKeyCompleter;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    final TextEditingController rfidNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (_bikeProvider.rfidList.isEmpty) {
      Future.delayed(Duration.zero).then((value) {
        _settingProvider.changeSheetElement(SheetList.evKey);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: PageAppbarWithoutBadge(
          title: 'EV-Key',
          withAction: _bikeProvider.isOwner! ? true : false,
          onPressedLeading: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
          onPressedAction: () {
            showActionListSheet(context, [ActionList.removeAllEVKeys],);
          },
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(0, 28.h, 0, EvieLength.target_reference_button_a),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) {
                            return Container();
                          },
                          itemCount: _bikeProvider.rfidList.length,
                          itemBuilder: (context, index) {
                            return Slidable(
                              key: UniqueKey(),
                              endActionPane:  _bikeProvider.isOwner == true ? ActionPane(
                                extentRatio: 0.18,
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    spacing:10,
                                    onPressed: (context) async{
                                      RFIDModel rfidModel = _bikeProvider.rfidList.values.elementAt(index);
                                      showRemoveEVKeyDialog(context, rfidModel, _bikeProvider, _bluetoothProvider);
                                    },
                                    backgroundColor: EvieColors.lightRed,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,

                                  ),
                                ],
                              ) : null,
                              child: Container(
                                //height: 64.h,
                                //color: Colors.yellow,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      //color: Colors.red,
                                      height: 64.h,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icons/key.svg",
                                                  height: 30.h,
                                                  width: 30.w,
                                                ),
                                                SizedBox(
                                                  width: 12.w,
                                                ),
                                                Text(
                                                  _bikeProvider.rfidList.values.elementAt(index).rfidName,
                                                  //"EV-Key 1",
                                                  style: EvieTextStyles.body18,
                                                ),

                                              ],
                                            ),
                                            isManageList ? SizedBox(
                                              width: 107.w,
                                              height: 43.h,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  ///Remove all rfid key
                                                  //deleteSingleFRFID(index);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(20.w)),
                                                  elevation: 0.0,
                                                  backgroundColor: EvieColors.primaryColor,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 14.h, vertical: 14.h),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/delete.svg",
                                                      height: 20.h,
                                                      width: 20.w,
                                                    ),
                                                    Text(
                                                      "Delete",
                                                      style: EvieTextStyles.body12.copyWith(color: EvieColors.grayishWhite),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ) :
                                            IconButton(
                                              onPressed: () {
                                                FocusNode nameFocusNode = FocusNode();
                                                nameFocusNode.requestFocus();

                                                bool isFirst = true;

                                                rfidNameController.text = _bikeProvider.rfidList.values.elementAt(index).rfidName ?? '';

                                                rfidNameController.addListener(() {
                                                  if (rfidNameController.selection.baseOffset != rfidNameController.selection.extentOffset) {
                                                    // Text is selected
                                                    //print('Text selected: ${_nameController.text.substring(_nameController.selection.baseOffset, _nameController.selection.extentOffset)}');
                                                  } else {
                                                    // Cursor is moved
                                                    if (isFirst) {
                                                      isFirst = false;
                                                      rfidNameController.selection = TextSelection(
                                                          baseOffset: 0, extentOffset: rfidNameController.text.length);
                                                    }
                                                  }
                                                });

                                                SmartDialog.show(
                                                    builder: (_) => Form(
                                                      key: formKey,
                                                      child: EvieDoubleButtonDialog(
                                                          title: "Name Your EV-Key",
                                                          childContent: Container(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "Personalize your EV-Key with a unique name that sets it apart from the rest.",
                                                                  style: EvieTextStyles.body16.copyWith(color:EvieColors.lightBlack),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      0.h, 12.h, 0.h, 8.h),
                                                                  child: EvieTextFormField(
                                                                    controller:
                                                                    rfidNameController,
                                                                    obscureText: false,
                                                                    keyboardType: TextInputType.name,
                                                                    focusNode: nameFocusNode,
                                                                    hintText: "EV-Key 1 (pre-select texts)",
                                                                    labelText: "EV-Key Label",
                                                                    validator: (value) {
                                                                      if (value == null || value.isEmpty) {
                                                                        return 'Please enter EV-Key name';
                                                                      }
                                                                      return null;
                                                                    },
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "100 Maximum Character",
                                                                  style: EvieTextStyles.body12.copyWith(color:EvieColors.lightBlack),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          leftContent: "Cancel",
                                                          rightContent: "Save",
                                                          onPressedLeft: () {
                                                            SmartDialog.dismiss();
                                                          },
                                                          onPressedRight: () async {
                                                            if (formKey.currentState!.validate()) {

                                                              ///For keyboard un focus
                                                              FocusManager.instance.primaryFocus?.unfocus();

                                                              SmartDialog.dismiss();
                                                              final result = await _bikeProvider.updateRFIDCardName(
                                                                  _bikeProvider.rfidList.keys.elementAt(index),
                                                                  rfidNameController.text.trim());

                                                              result == true ?
                                                              showSuccessUpdateEVKey(context)
                                                                  : showFailUpdateEVKey(context);
                                                            }
                                                          }),
                                                    ));
                                              },
                                              icon: SvgPicture.asset(
                                                "assets/buttons/pen_edit.svg",
                                                height: 31.h,
                                                width: 31.w,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 57.w),
                                          child: Divider(
                                            thickness: 0.2.h,
                                            color: EvieColors.darkWhite,
                                            height: 0,
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              )
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Add EV-Key",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      //changeToAddNewEVKey(context);
                      // _settingProvider.changeSheetElement(SheetList.evKey);
                      if (deviceConnectResult == null
                          || deviceConnectResult == DeviceConnectResult.disconnected
                          || deviceConnectResult == DeviceConnectResult.scanTimeout
                          || deviceConnectResult == DeviceConnectResult.connectError
                          || deviceConnectResult == DeviceConnectResult.scanError
                          || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                      ) {
                        _settingProvider.changeSheetElement(SheetList.registerEvKey);
                        showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                        //showConnectDialog(_bluetoothProvider, _bikeProvider);
                      }
                      else if (deviceConnectResult == DeviceConnectResult.connected) {
                        _settingProvider.changeSheetElement(SheetList.registerEvKey);
                      }
                    },
                  ),
                )
              ],
            )
        )
      ),
    );
  }
}

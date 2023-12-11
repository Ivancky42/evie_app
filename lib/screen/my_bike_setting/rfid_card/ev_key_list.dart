import 'dart:async';

import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/model/rfid_model.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

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
import '../../../api/navigator.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_appbar_badge.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';

class EVKeyList extends StatefulWidget {
  const EVKeyList({Key? key}) : super(key: key);

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

    final TextEditingController _rfidNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
            padding: EdgeInsets.fromLTRB(0, 28.h, 0, EvieLength.screen_bottom),
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
                                    backgroundColor: EvieColors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,

                                  ),
                                ],
                              ) : null,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Padding(
                                        padding: EdgeInsets.fromLTRB(0.w, 0.h, 6.w, 0.h),
                                        child: SvgPicture.asset(
                                          "assets/icons/key.svg",
                                          height: 30.h,
                                          width: 30.w,
                                        ),
                                      ),
                                      title: Text(
                                        _bikeProvider.rfidList.values.elementAt(index).rfidName,
                                        //"EV-Key 1",
                                        style: EvieTextStyles.body18,
                                      ),
                                      // subtitle: Text(
                                      //   _bikeProvider.rfidList.keys.elementAt(index),
                                      //   style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                      // ),
                                      trailing: isManageList ? Container(
                                        width: 107.w,
                                        height: 43.h,
                                        child: ElevatedButton(
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
                                        ),
                                      ) :
                                      IconButton(
                                        onPressed: () {
                                          SmartDialog.show(
                                              widget: Form(
                                                key: _formKey,
                                                child: EvieDoubleButtonDialog(
                                                    title: "Name Your EV-Key",
                                                    childContent: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Label your smart key similiar with the name you wrote on the key so that you can differentiate them easily.",
                                                            style: EvieTextStyles.body16.copyWith(color:EvieColors.lightBlack),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(
                                                                0.h, 12.h, 0.h, 8.h),
                                                            child: EvieTextFormField(
                                                              controller:
                                                              _rfidNameController,
                                                              obscureText: false,
                                                              keyboardType: TextInputType.name,
                                                              hintText:
                                                              "EV-Key 1 (pre-select texts)",
                                                              labelText: "EV-Key Label",
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return 'Please enter RFID name';
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
                                                      if (_formKey.currentState!.validate()) {

                                                        ///For keyboard un focus
                                                        FocusManager.instance.primaryFocus?.unfocus();

                                                        SmartDialog.dismiss();
                                                        final result = await _bikeProvider.updateRFIDCardName(
                                                            _bikeProvider.rfidList.keys.elementAt(index),
                                                            _rfidNameController.text.trim());

                                                        result == true ?
                                                        showAddEVKeyNameSuccess(context)
                                                            : SmartDialog.show(
                                                            widget: EvieSingleButtonDialogOld(
                                                                title: "Error",
                                                                content:
                                                                "Please try again",
                                                                rightContent:
                                                                "OK",
                                                                onPressedRight: () {
                                                                  SmartDialog.dismiss();
                                                                }));
                                                      }
                                                    }),
                                              ));
                                        },
                                        icon: SvgPicture.asset(
                                          "assets/buttons/pen_edit.svg",
                                          height: 24.h,
                                          width: 24.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 70.w),
                                        child: Divider(
                                          thickness: 0.2.h,
                                          color: EvieColors.darkWhite,
                                          height: 0,
                                        ),
                                      )
                                  ),
                                ],
                              ),
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

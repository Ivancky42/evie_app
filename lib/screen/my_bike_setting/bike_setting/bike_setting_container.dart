import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_model.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';

class BikeSettingContainer extends StatefulWidget {
  final BikeSettingModel bikeSettingModel;
  const BikeSettingContainer({Key? key, required this.bikeSettingModel}) : super(key: key);

  @override
  State<BikeSettingContainer> createState() => _BikeSettingContainerState();
}

class _BikeSettingContainerState extends State<BikeSettingContainer> {

  late BikeProvider _bikeProvider;
  late FirmwareProvider _firmwareProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  String? label;
  String? pageNavigate;

  final TextEditingController _bikeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    label = widget.bikeSettingModel.label;
    _bikeProvider = Provider.of<BikeProvider>(context);
    _firmwareProvider = Provider.of<FirmwareProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    if(deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice){
      Future.delayed(Duration.zero, () {
        if(pageNavigate != null){
          switch(pageNavigate){
            case "EV-Key":
              pageNavigate = null;
              if (_bikeProvider.rfidList.isNotEmpty) {
                changeToEVKeyList(context);
              }
              else {
                changeToEVKey(context);
              }
              break;
            case "Motion Sensitivity":
              pageNavigate = null;
              changeToMotionSensitivityScreen(context);
              break;
            case "Firmware Version":
              pageNavigate = null;
              changeToFirmwareInformation(context);
              break;
          }
        }
      });
    }

    switch(label) {
      case "Bike Name":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: Container(
                height: 62.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect_filled.svg",
                                height: 15.h,
                                width: 15.w,
                              ) : SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect.svg",
                                height: 15.h,
                                width: 15.w,
                              ),
                            ],
                          ),
                          Text(
                            _bikeProvider.currentBikeModel?.deviceName ?? "",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: (){
                          showEditBikeNameDialog(_formKey, _bikeNameController, _bikeProvider);
                        },
                        icon:   SvgPicture.asset(
                          "assets/buttons/pen_edit.svg",
                          height:20.h,
                          width:20.w,
                        ),),
                    ],
                  ),
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "EV-Key":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                if (deviceConnectResult == null
                    || deviceConnectResult == DeviceConnectResult.disconnected
                    || deviceConnectResult == DeviceConnectResult.scanTimeout
                    || deviceConnectResult == DeviceConnectResult.connectError
                    || deviceConnectResult == DeviceConnectResult.scanError
                    || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                ) {
                  setState(() {
                    pageNavigate = label;
                  });
                  showConnectDialog(_bluetoothProvider, _bikeProvider);
                }
                else if (deviceConnectResult == DeviceConnectResult.connected) {
                  if (_bikeProvider.rfidList.isNotEmpty) {
                    changeToEVKeyList(context);
                  }
                  else {
                    changeToEVKey(context);
                  }
                }
              },
              child: Container(
                height: 62.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect_filled.svg",
                                height: 15.h,
                                width: 15.w,
                              ) : SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect.svg",
                                height: 15.h,
                                width: 15.w,
                              ),
                            ],
                          ),
                          Text(
                            _bikeProvider.rfidList.length.toString() + " " + label!,
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                          )
                        ],
                      ),
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Motion Sensitivity":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (deviceConnectResult == null
                    || deviceConnectResult == DeviceConnectResult.disconnected
                    || deviceConnectResult == DeviceConnectResult.scanTimeout
                    || deviceConnectResult == DeviceConnectResult.connectError
                    || deviceConnectResult == DeviceConnectResult.scanError
                    || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                ) {
                  setState(() {
                    pageNavigate = label;
                  });
                  showConnectDialog(_bluetoothProvider, _bikeProvider);
                }
                else if (deviceConnectResult == DeviceConnectResult.connected) {
                  changeToMotionSensitivityScreen(context);
                }
              },
              child: Container(
                height: 62.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect_filled.svg",
                                height: 15.h,
                                width: 15.w,
                              ) : SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect.svg",
                                height: 15.h,
                                width: 15.w,
                              ),
                            ],
                          ),
                          Text(
                            _bikeProvider.currentBikeModel?.movementSetting?.sensitivity   ?? "None",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                          )
                        ],
                      ),
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Subscription":
        return Column(
          children: [
            Divider(
              thickness: 11.h,
              color: const Color(0xffF4F4F4),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToCurrentPlanScreen(context);
              },
              child: Container(
                height: 62.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect_filled.svg",
                                height: 15.h,
                                width: 15.w,
                              ) : SvgPicture.asset(
                                "assets/icons/bluetooth_disconnect.svg",
                                height: 15.h,
                                width: 15.w,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _bikeProvider.isPlanSubscript == false ? "Starter" : "Premium",
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                                height: 20.h,
                                width: 20.w,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Share Bike":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (getOpacityByRole() == 0.3) {
                  showUpgradePlanToast(context);
                }
                else {
                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(10.h);
                  }
                  else {
                    changeToShareBikeUserListScreen(context);
                    //showControlAdmissionToast(10.h);
                  }
                }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  height: 62.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  label!,
                                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                ),
                                deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                  "assets/icons/bluetooth_disconnect_filled.svg",
                                  height: 15.h,
                                  width: 15.w,
                                ) : SvgPicture.asset(
                                  "assets/icons/bluetooth_disconnect.svg",
                                  height: 15.h,
                                  width: 15.w,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${_bikeProvider.bikeUserList.length} Riders",
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                ),
                                SizedBox(width: 8.17.w,),
                                SvgPicture.asset(
                                  "assets/icons/batch_tick.svg",
                                  height: 20.h,
                                  width: 20.w,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                          height: 24.h,
                          width: 24.w,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ),
            const EvieDivider(),
          ],
        );
      case "Bike Status Alert":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (checkFunctionByRole()) {
                  changeToBikeStatusAlertScreen(context);
                }
                else {
                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(context);
                  }
                  else {
                    showControlAdmissionToast(context);
                  }
                }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  height: 44.h,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/buttons/next.svg",
                          ),
                        ],
                      )
                  ),
                ),
              )
            ),
            const EvieDivider(),
          ],
        );
      case "SOS Center":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (checkFunctionByRole()) {
                  changeToSOSCenterScreen(context);
                }
                else {
                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(context);
                  }
                  else {
                    showControlAdmissionToast(context);
                  }
                }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  height: 44.h,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/buttons/next.svg",
                          ),
                        ],
                      )
                  ),
                ),
              )
            ),
            const EvieDivider(),
          ],
        );
      case "View Data":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (checkFunctionByRole()) {

                }
                else {
                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(context);
                  }
                  else {
                    showControlAdmissionToast(context);
                  }
                }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  height: 44.h,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                label!,
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/buttons/next.svg",
                          ),
                        ],
                      )
                  ),
                ),
            ),
            ),
            const EvieDivider(),
          ],
        );
      case "About Bike":
        return Column(
          children: [
            Divider(
              thickness: 11.h,
              color: const Color(0xffF4F4F4),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                changeToAboutBike(context);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Firmware Version":
        return Column(
          children: [
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (deviceConnectResult == null
                      || deviceConnectResult == DeviceConnectResult.disconnected
                      || deviceConnectResult == DeviceConnectResult.scanTimeout
                      || deviceConnectResult == DeviceConnectResult.connectError
                      || deviceConnectResult == DeviceConnectResult.scanError
                      || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                  ) {
                    setState(() {
                      pageNavigate = label;
                    });
                    showConnectDialog(_bluetoothProvider, _bikeProvider);
                  }
                  else if (deviceConnectResult == DeviceConnectResult.connected) {
                    changeToFirmwareInformation(context);
                  }
                },
                child: Container(
                  height: 62.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  label!,
                                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                ),
                                deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                  "assets/icons/bluetooth_disconnect_filled.svg",
                                  height: 15.h,
                                  width: 15.w,
                                ) : SvgPicture.asset(
                                  "assets/icons/bluetooth_disconnect.svg",
                                  height: 15.h,
                                  width: 15.w,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _firmwareProvider.currentFirmVer ?? "Not available",
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                ),
                                SizedBox(width: 4.w,),
                                Visibility(
                                  visible: !_firmwareProvider.isLatestFirmVer,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: EvieColors.primaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(6.w,4.h,6.w,4.h),
                                        child: Text("Update Available",  style: EvieTextStyles.body12.copyWith(color: EvieColors.grayishWhite),),
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                          height: 24.h,
                          width: 24.w,
                        ),
                      ],
                    ),
                  ),
                ),
            ),
            const EvieDivider(),
          ],
        );
      case "User Manual":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Reset Bike":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToResetBike(context);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
            Divider(
              thickness: 11.h,
              color: const Color(0xffF4F4F4),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  double getOpacityByRole() {
    if (_bikeProvider.isOwner == true) {
      ///Premium owner
      if (_bikeProvider.isPlanSubscript == true) {
        return 1.0;
      }
      ///Starter owner
      else {
        return 0.3;
      }
    }
    else {
      ///Premium user
      if (_bikeProvider.isPlanSubscript == true) {
        return 1.0;
      }
      ///Starter user
      else {
        return 1.0;
      }
    }
  }

  bool checkFunctionByRole() {
    if (_bikeProvider.isOwner == true) {
      ///Premium owner
      if (_bikeProvider.isPlanSubscript == true) {
        return true;
      }
      ///Starter owner
      else {
        return false;
      }
    }
    else {
      ///Premium user
      if (_bikeProvider.isPlanSubscript == true) {
        return false;
      }
      ///Starter user
      else {
        return false;
      }
    }
  }
}

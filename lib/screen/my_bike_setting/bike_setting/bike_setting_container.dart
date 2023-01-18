import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_model.dart';
import 'package:evie_test/widgets/custom_divider.dart';
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

    if(deviceConnectResult == DeviceConnectResult.connected){
      Future.delayed(Duration.zero, () {
        if(pageNavigate != null){
          switch(pageNavigate){
            case "EV-Key":
              pageNavigate = null;
              if (_bikeProvider.rfidList.isNotEmpty) {
                changeToRFIDListScreen(context);
              }
              else {
                changeToRFIDCardScreen(context);
              }
              break;
            case "Motion Sensitivity":
              pageNavigate = null;
              changeToMotionSensitivityScreen(context);
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
              onTap: () async {
                if (deviceConnectResult == null
                    || deviceConnectResult == DeviceConnectResult.disconnected
                    || deviceConnectResult == DeviceConnectResult.scanTimeout
                    || deviceConnectResult == DeviceConnectResult.connectError
                    || deviceConnectResult == DeviceConnectResult.scanError) {
                  setState(() {
                    pageNavigate = label;
                  });
                  showConnectDialog(_bluetoothProvider);
                }
                else if (deviceConnectResult == DeviceConnectResult.connected) {
                  if (_bikeProvider.rfidList.isNotEmpty) {
                    changeToRFIDListScreen(context);
                  }
                  else {
                    changeToRFIDCardScreen(context);
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
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff5F6060)
                                ),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                            style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                    || deviceConnectResult == DeviceConnectResult.scanError) {
                  setState(() {
                    pageNavigate = label;
                  });
                  showConnectDialog(_bluetoothProvider);
                }
                else if (deviceConnectResult == DeviceConnectResult.connected) {
                  if (_bikeProvider.rfidList.isNotEmpty) {
                    changeToRFIDListScreen(context);
                  }
                  else {
                    changeToRFIDCardScreen(context);
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
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff5F6060)
                                ),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                            style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                    || deviceConnectResult == DeviceConnectResult.scanError) {
                  setState(() {
                    pageNavigate = label;
                  });
                  showConnectDialog(_bluetoothProvider);
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
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff5F6060)
                                ),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                            style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff5F6060)
                                ),
                              ),
                              deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                                "Pro Plan",
                                style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5F6060)
                                  ),
                                ),
                                deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                                  style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                                style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                                style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                                style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                              style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                      || deviceConnectResult == DeviceConnectResult.scanError) {
                    setState(() {
                      pageNavigate = label;
                    });
                    showConnectDialog(_bluetoothProvider);
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
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5F6060)
                                  ),
                                ),
                                deviceConnectResult == DeviceConnectResult.connected ? SvgPicture.asset(
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
                              _firmwareProvider.currentFirmVer ?? "Not available",
                              style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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
                              style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
          ],
        );
      case "Reset Bike":
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
                              style: TextStyle(fontSize: 16.sp),
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
            const CustomDivider(),
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

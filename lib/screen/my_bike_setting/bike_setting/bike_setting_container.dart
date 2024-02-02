import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_model.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/setting.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_single_button_dialog.dart';

class BikeSettingContainer extends StatefulWidget {
  final BikeSettingModel bikeSettingModel;
  const BikeSettingContainer({Key? key, required this.bikeSettingModel}) : super(key: key);

  @override
  State<BikeSettingContainer> createState() => _BikeSettingContainerState();
}

class _BikeSettingContainerState extends State<BikeSettingContainer> with WidgetsBindingObserver{

  late BikeProvider _bikeProvider;
  late FirmwareProvider _firmwareProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  late NotificationProvider _notificationProvider;

  DeviceConnectResult? deviceConnectResult;
  String? label;
  String? pageNavigate;
  bool hasPermission = false;

  final TextEditingController _bikeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _notificationProvider = context.read<NotificationProvider>();
    _notificationProvider.checkNotificationPermission();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationProvider.checkNotificationPermission();
      //print("App resumed");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    label = widget.bikeSettingModel.label;
    _bikeProvider = Provider.of<BikeProvider>(context);
    _firmwareProvider = Provider.of<FirmwareProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    switch(_notificationProvider.permissionStatus) {
      case PermissionStatus.denied:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.granted:
        if (!hasPermission) {
          setState(() {
            hasPermission = true;
          });
        }
        break;
      case PermissionStatus.restricted:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.limited:
        if (!hasPermission) {
          setState(() {
            hasPermission = true;
          });
        }
        break;
      case PermissionStatus.permanentlyDenied:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case PermissionStatus.provisional:
        if (hasPermission) {
          setState(() {
            hasPermission = false;
          });
        }
        break;
      case null:
      // TODO: Handle this case.
        break;
    }
    
    if(deviceConnectResult == DeviceConnectResult.connected &&
        _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice){
      Future.delayed(Duration.zero, () {
        if(pageNavigate != null){
          switch(pageNavigate){
            case "EV-Key":
              pageNavigate = null;
              if (_bikeProvider.rfidList.isNotEmpty) {
                _settingProvider.changeSheetElement(SheetList.evKeyList);
              }
              else {
                _settingProvider.changeSheetElement(SheetList.evKey);
              }
              break;
            case "Motion Sensitivity":
              pageNavigate = null;
              _settingProvider.changeSheetElement(SheetList.motionSensitivity);

              break;
            case "Firmware Version":
              pageNavigate = null;
              _settingProvider.changeSheetElement(SheetList.firmwareInformation);
              break;
          }
        }
      });
    }

    switch(label) {
      case "Bike Name":
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if(_bikeProvider.isOwner == true){

                }
                else{
                  showAccNoPermissionToast(context);
                }
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 10.h),
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
                              // deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                              //   "assets/icons/bluetooth_disconnect_filled.svg",
                              //   height: 15.h,
                              //   width: 15.w,
                              // ) : SvgPicture.asset(
                              //   "assets/icons/bluetooth_disconnect.svg",
                              //   height: 15.h,
                              //   width: 15.w,
                              // ),
                            ],
                          ),
                          Text(
                            _bikeProvider.currentBikeModel?.deviceName ?? "",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                          )
                        ],
                      ),
                      Visibility(
                        visible: _bikeProvider.isOwner == true,
                        child: IconButton(
                          onPressed: (){
                            showEditBikeNameDialog(_formKey, _bikeNameController, _bikeProvider);
                          },
                          icon:   SvgPicture.asset(
                            "assets/buttons/pen_edit.svg",
                            height: 31.h,
                            width: 31.w,
                          ),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
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
                  showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                  // showEvieActionableBarDialog(context, _bluetoothProvider, _bikeProvider);
                }
                else if (deviceConnectResult == DeviceConnectResult.connected) {
                  if (_bikeProvider.rfidList.isNotEmpty) {
                    _settingProvider.changeSheetElement(SheetList.evKeyList);
                  }
                  else {
                    _settingProvider.changeSheetElement(SheetList.evKey);
                  }
                }
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
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
                                "assets/icons/bluetooth.svg",
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Motion Sensitivity":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                if(_bikeProvider.isOwner == true){
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
                    showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                    //showConnectDialog(_bluetoothProvider, _bikeProvider);
                  }
                  else if (deviceConnectResult == DeviceConnectResult.connected) {
                    _settingProvider.changeSheetElement(SheetList.motionSensitivity);
                  }
                }
                else{
                  showAccNoPermissionToast(context);
                }

              },
              child: Container(
                //color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
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
                                "assets/icons/bluetooth.svg",
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
                            capitalizeFirstCharacter(_bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None"),
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                          )
                        ],
                      ),
                      _bikeProvider.isOwner == true ?
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ) : Container(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      // case "Recovery Mode":
      //   return Column(
      //     children: [
      //       GestureDetector(
      //         behavior: HitTestBehavior.translucent,
      //         onTap: () async {
      //
      //           if(_bikeProvider.isOwner == true){
      //             if (deviceConnectResult == null
      //                 || deviceConnectResult == DeviceConnectResult.disconnected
      //                 || deviceConnectResult == DeviceConnectResult.scanTimeout
      //                 || deviceConnectResult == DeviceConnectResult.connectError
      //                 || deviceConnectResult == DeviceConnectResult.scanError
      //                 || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
      //             ) {
      //               showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
      //             }
      //             else if (deviceConnectResult == DeviceConnectResult.connected) {
      //               //SmartDialog.showLoading(msg: 'Entering Recovery Mode....');
      //               showCustomLightLoading('Entering Recovery Mode....');
      //               _bluetoothProvider.cableUnlock();
      //               await Future.delayed(Duration(seconds: 2));
      //               showRecoveringModeToast(context);
      //               SmartDialog.dismiss();
      //             }
      //           }
      //           else{
      //             showAccNoPermissionToast(context);
      //           }
      //
      //         },
      //         child: Container(
      //           child: Padding(
      //               padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Text(
      //                         label!,
      //                         style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
      //                       ),
      //                       SizedBox(width: 8.17.w,),
      //                       deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
      //                         "assets/icons/bluetooth.svg",
      //                         height: 15.h,
      //                         width: 15.w,
      //                       ) : SvgPicture.asset(
      //                         "assets/icons/bluetooth_disconnect.svg",
      //                         height: 15.h,
      //                         width: 15.w,
      //                       ),
      //                     ],
      //                   ),
      //                   SvgPicture.asset(
      //                     "assets/buttons/next.svg",
      //                   ),
      //                 ],
      //               )
      //           ),
      //         ),
      //       ),
      //       Container(
      //           child: Padding(
      //             padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
      //             child: Divider(
      //               thickness: 0.2.h,
      //               color: EvieColors.darkWhite,
      //               height: 0,
      //             ),
      //           )
      //       ),
      //     ],
      //   );
      case "EV+":
        return Column(
          children: [
            Container(
              color: const Color(0xffF4F4F4),
              padding: EdgeInsets.zero,
              height: 12.h,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _settingProvider.changeSheetElement(SheetList.currentPlan);
                //_settingProvider.changeSheetElement(SheetList.proPlan);
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
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
                              // deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                              //   "assets/icons/bluetooth_disconnect_filled.svg",
                              //   height: 15.h,
                              //   width: 15.w,
                              // ) : SvgPicture.asset(
                              //   "assets/icons/bluetooth_disconnect.svg",
                              //   height: 15.h,
                              //   width: 15.w,
                              // ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _bikeProvider.isPlanSubscript == false ? "No Subscription" : "EV-Secure",
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                                width: 24.w,
                                height: 24.w,
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "PedalPals":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                if (getOpacityByRole() == 0.3) {
                  showUpgradePlanToast(context, _settingProvider);
                }
                else {
                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(10.h, _settingProvider);
                    showUpgradePlanToast(10.h, _settingProvider);
                  }
                  else {
                    if(_bikeProvider.currentBikeModel?.pedalPalsModel == null || _bikeProvider.currentBikeModel?.pedalPalsModel?.name == ""){
                      _settingProvider.changeSheetElement(SheetList.pedalPals);
                    }else{
                      _settingProvider.changeSheetElement(SheetList.pedalPalsList, _bikeProvider.currentBikeModel?.deviceIMEI);
                    }

                    // Navigator.of(context).pop();
                    // showShareBikeUserListSheet(context);

                    //await _bikeProvider.createTeam("Team Sherryen");
                    //showControlAdmissionToast(10.h);
                  }
                }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
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
                                // deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                //   "assets/icons/bluetooth_disconnect_filled.svg",
                                //   height: 15.h,
                                //   width: 15.w,
                                // ) : SvgPicture.asset(
                                //   "assets/icons/bluetooth_disconnect.svg",
                                //   height: 15.h,
                                //   width: 15.w,
                                // ),

                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _bikeProvider.bikeUserList.length == 1 ? "None Shared" :
                                  "Shared with ${_bikeProvider.bikeUserList.length - 1} ",
                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                                ),
                                SizedBox(width: 8.17.w,),
                                SvgPicture.asset(
                                  "assets/icons/batch_tick.svg",
                                  width: 24.w,
                                  height: 24.w,
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "EV-Secure Alerts":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                  if (getOpacityByRole() == 0.3) {
                    showUpgradePlanToast(context, _settingProvider);
                  }else{
                    _settingProvider.changeSheetElement(SheetList.orbitalAntiThefts);
                  }

                // if (checkFunctionByRole()) {
                //   _settingProvider.changeSheetElement(SheetList.orbitalAntiThefts);
                // }
                // else {
                //   if (getOpacityByRole() == 0.3) {
                //     showUpgradePlanToast(context, _settingProvider);
                //   }
                //   // else {
                //   //   showControlAdmissionToast(context);
                //   // }
                // }
              },
              child: Opacity(
                opacity: getOpacityByRole(),
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'EV-Secure Alerts',
                                style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                                width: 24.w,
                                height: 24.w,
                              ),
                              SizedBox(width: 4.w,),
                              hasPermission ?
                              Container() :
                              SvgPicture.asset(
                                "assets/icons/notification_alert.svg",
                                width: 24.w,
                                height: 24.w,
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );

      //case "SOS Center", "View Data"
      // case "SOS Center":
      //   return Column(
      //     children: [
      //       GestureDetector(
      //         behavior: HitTestBehavior.translucent,
      //         onTap: () {
      //           if (checkFunctionByRole()) {
      //             changeToSOSCenterScreen(context);
      //           }
      //           else {
      //             if (getOpacityByRole() == 0.3) {
      //               showUpgradePlanToast(context);
      //             }
      //             else {
      //               showControlAdmissionToast(context);
      //             }
      //           }
      //         },
      //         child: Opacity(
      //           opacity: getOpacityByRole(),
      //           child: Container(
      //             height: 44.h,
      //             child: Padding(
      //                 padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Row(
      //                       children: [
      //                         Text(
      //                           label!,
      //                           style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
      //                         ),
      //                         SizedBox(width: 8.17.w,),
      //                         SvgPicture.asset(
      //                           "assets/icons/batch_tick.svg",
      //                         ),
      //                       ],
      //                     ),
      //                     SvgPicture.asset(
      //                       "assets/buttons/next.svg",
      //                     ),
      //                   ],
      //                 )
      //             ),
      //           ),
      //         )
      //       ),
      //       const EvieDivider(),
      //     ],
      //   );


      // case "View Data":
      //   return Column(
      //     children: [
      //       GestureDetector(
      //         behavior: HitTestBehavior.translucent,
      //         onTap: () {
      //           if (checkFunctionByRole()) {
      //
      //           }
      //           else {
      //             if (getOpacityByRole() == 0.3) {
      //               showUpgradePlanToast(context);
      //             }
      //             else {
      //               showControlAdmissionToast(context);
      //             }
      //           }
      //         },
      //         child: Opacity(
      //           opacity: getOpacityByRole(),
      //           child: Container(
      //             height: 44.h,
      //             child: Padding(
      //                 padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Row(
      //                       children: [
      //                         Text(
      //                           label!,
      //                           style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
      //                         ),
      //                         SizedBox(width: 8.17.w,),
      //                         SvgPicture.asset(
      //                           "assets/icons/batch_tick.svg",
      //                         ),
      //                       ],
      //                     ),
      //                     SvgPicture.asset(
      //                       "assets/buttons/next.svg",
      //                     ),
      //                   ],
      //                 )
      //             ),
      //           ),
      //       ),
      //       ),
      //       const EvieDivider(),
      //     ],
      //   );
      case "About Bike":
        return Column(
          children: [
            Container(
              color: const Color(0xffF4F4F4),
              padding: EdgeInsets.zero,
              height: 12.h,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _settingProvider.changeSheetElement(SheetList.aboutBike);
              },
              child: Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Bike Software":
        return Column(
          children: [
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if(_bikeProvider.isOwner == true){
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
                      showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                      //showConnectDialog(_bluetoothProvider, _bikeProvider);
                    }
                    else if (deviceConnectResult == DeviceConnectResult.connected) {
                      _settingProvider.changeSheetElement(SheetList.firmwareInformation);
                    }
                  }else{
                    showAccNoPermissionToast(context);
                  }
                  //_settingProvider.changeSheetElement(SheetList.firmwareInformation);
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
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
                                  "Bike Software",
                                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                ),
                                deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice ? SvgPicture.asset(
                                  "assets/icons/bluetooth.svg",
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
                        _bikeProvider.isOwner == true ?
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                          height: 24.h,
                          width: 24.w,
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
            ),
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "User Manual":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                //_settingProvider.changeSheetElement(SheetList.userManual);
                const url = 'https://eviebikes.com/pages/downloads';
                final Uri _url = Uri.parse(url);
                launch(_url);
              },
              child: Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
                          "assets/buttons/external_link.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Troubleshoot" :
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _settingProvider.changeSheetElement(SheetList.troubleshoot);
              },
              child: Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Troubleshoot",
                              style: EvieTextStyles.body18.copyWith(
                                  color: EvieColors.lightBlack),
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Reset Bike":
        if (_bikeProvider.isOwner == true) {
          return Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_bikeProvider.isOwner == true) {
                    _settingProvider.changeSheetElement(SheetList.resetBike2);
                  } else {
                    _settingProvider.changeSheetElement(SheetList.leaveTeam);
                    //_settingProvider.changeSheetElement(SheetList.resetBike2);
                  }
                },
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [

                              if (_bikeProvider.isOwner == true)...{
                                Text(
                                  "Reset",
                                  style: EvieTextStyles.body18.copyWith(
                                      color: EvieColors.lightBlack),
                                ),
                              } else
                                ...{
                                  Text(
                                    "Leave Team",
                                    style: EvieTextStyles.body18.copyWith(
                                        color: EvieColors.lightBlack),
                                  ),
                                }
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
              Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                    child: Divider(
                      thickness: 0.2.h,
                      color: EvieColors.darkWhite,
                      height: 0,
                    ),
                  )
              ),
              // Divider(
              //   thickness: 11.h,
              //   color: const Color(0xffF4F4F4),
              // ),
            ],
          );
        }
        else {
          return Container();
        }

      case "Leave Team":
        if (_bikeProvider.isOwner == true) {
          return Container();
        }
        else {
          return Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _settingProvider.changeSheetElement(SheetList.leaveTeam);
                },
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Leave Team",
                                style: EvieTextStyles.body18.copyWith(
                                    color: EvieColors.lightBlack),
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
              Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                    child: Divider(
                      thickness: 0.2.h,
                      color: EvieColors.darkWhite,
                      height: 0,
                    ),
                  )
              ),
            ],
          );
        }
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

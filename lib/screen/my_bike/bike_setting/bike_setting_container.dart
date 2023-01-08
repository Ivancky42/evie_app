import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike/bike_setting/bike_setting_model.dart';
import 'package:evie_test/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../bluetooth/modelResult.dart';

class BikeSettingContainer extends StatefulWidget {
  final BikeSettingModel bikeSettingModel;
  const BikeSettingContainer({Key? key, required this.bikeSettingModel}) : super(key: key);

  @override
  State<BikeSettingContainer> createState() => _BikeSettingContainerState();
}

class _BikeSettingContainerState extends State<BikeSettingContainer> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  DeviceConnectResult? deviceConnectResult;
  String? label;
  String? pageNavigate;

  @override
  Widget build(BuildContext context) {
    label = widget.bikeSettingModel.label;
    _bikeProvider = Provider.of<BikeProvider>(context);
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
          }
        }
      });
    }

    switch(label) {
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
                  String? pageNavigate = await showConnectDialog(_bluetoothProvider, label);
                  setState(() {
                    this.pageNavigate = pageNavigate;
                  });
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
                            _bikeProvider.currentBikeModel?.movementSetting?.sensitivity ?? "None",
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
                changeToShareBikeUserListScreen(context);
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
                changeToBikeStatusAlertScreen(context);
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
            const CustomDivider(),
          ],
        );
      case "SOS Center":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToSOSCenterScreen(context);
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
            const CustomDivider(),
          ],
        );
      default:
        return Container(
          child: Center(
            child: Text("APA LU MAU"),
          ),
        );
    }
  }
}

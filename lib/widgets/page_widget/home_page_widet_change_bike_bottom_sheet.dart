import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../bluetooth/modelResult.dart';
import '../evie_switch.dart';

///Pass is connected
///Pass current bike model
///Different switch value

class ChangeBikeBottomSheet extends StatefulWidget {
  const ChangeBikeBottomSheet({Key? key}) : super(key: key);

  @override
  _ChangeBikeBottomSheetState createState() => _ChangeBikeBottomSheetState();
}

class _ChangeBikeBottomSheetState extends State<ChangeBikeBottomSheet> {
  List<bool> boolList = [false, false, false, false, false];

  static const Color _thumbColor = EvieColors.ThumbColorTrue;

  DeviceConnectionState? connectionState;
  CableLockResult? cableLockState;

  bool? isDeviceConnected;

  @override
  Widget build(BuildContext context) {
    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    /// get bluetooth connection state and lock unlock to detect isConnected
    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    cableLockState = _bluetoothProvider.cableLockState;

    ///Handle all data if bool isDeviceConnected is true
    if (connectionState == DeviceConnectionState.connected &&
            cableLockState?.lockState == LockState.lock ||
        cableLockState?.lockState == LockState.unlock) {
      setState(() {
        isDeviceConnected = true;
      });
    } else {
      setState(() {
        isDeviceConnected = false;
      });
    }

    if (isDeviceConnected == true) {
      for (int index = 0; index < _bikeProvider.userBikeList.length; index++) {
        if (_bikeProvider.userBikeList.keys.elementAt(index) ==
            _bikeProvider.currentBikeModel?.deviceIMEI) {
          boolList[index] = true;
        }
      }
    } else if (isDeviceConnected == false) {
      for (int index = 0; index < _bikeProvider.userBikeList.length; index++) {
        if (_bikeProvider.userBikeList.keys.elementAt(index) ==
            _bikeProvider.currentBikeModel?.deviceIMEI) {
          boolList[index] = false;
        }
      }
    }

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECEDEB),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          width: double.infinity,
          height: (81 + ((_bikeProvider.userBikeList.length + 1) * 59)).h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 11.h),
                child: Image.asset(
                  "assets/buttons/home_indicator.png",
                  width: 40.w,
                  height: 4.h,
                ),
              ),
              Container(
                height: ((1 + _bikeProvider.userBikeList.length) * 59).h,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _bikeProvider.userBikeList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 59.h,
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0.h, 6.w, 17.h),
                          child: Image(
                            image: AssetImage(getCurrentBikeStatusImage(
                                _bikeProvider.userBikeDetails.values
                                    .elementAt(index)
                                    .location
                                    .status)),
                            height: 25.h,
                            width: 39.59.w,
                          ),
                        ),
                        title: Text(
                          _bikeProvider.userBikeDetails.values
                              .elementAt(index)
                              .deviceName,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Row(
                          children: [
                            SvgPicture.asset(
                              getCurrentBikeStatusIcon(_bikeProvider
                                  .userBikeDetails.values
                                  .elementAt(index)
                                  .location
                                  .status),
                              height: 20.h,
                              width: 20.w,
                            ),
                            Text(getCurrentBikeStatusString(
                                isDeviceConnected!,
                                _bikeProvider.userBikeDetails.values
                                    .elementAt(index)
                                    .location
                                    .status)),
                          ],
                        ),
                        trailing: CupertinoSwitch(
                          value: boolList[index],
                          activeColor: const Color(0xff6A51CA),
                          thumbColor: _thumbColor,
                          trackColor: const Color(0xff6A51CA).withOpacity(0.5),
                          onChanged: (value) async {
                            boolList[index] = value!;

                            if (value == true) {
                              await _bikeProvider.changeBikeUsingIMEI(
                                  _bikeProvider.userBikeList.values
                                      .elementAt(index)
                                      .deviceIMEI);
                              //           _bluetoothProvider.startScanAndConnect();

                              Navigator.pop(context);
                            } else if (value == false) {
                              boolList[index] = false;
                              _bluetoothProvider.disconnectDevice();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 59.h,
                child: GestureDetector(
                  onTap: () {
                    changeToTurnOnQRScannerScreen(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 6.w, 17.h),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        "assets/buttons/add_new_bike.svg",
                      ),
                      title: Text(
                        "Add New Bike",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  getCurrentBikeStatusImage(String dangerStatus) {
    switch (dangerStatus) {
      case 'safe':
        {
          if (cableLockState?.lockState == LockState.unlock) {
            return "assets/images/bike_HPStatus/bike_safe.png";
          } else {
            return "assets/images/bike_HPStatus/bike_safe.png";
          }
        }
      case 'warning':
        {
          return "assets/images/bike_HPStatus/bike_warning.png";
        }

      case 'danger':
        {
          return "assets/images/bike_HPStatus/bike_danger.png";
        }

      default:
        {
          return "assets/images/bike_HPStatus/bike_safe.png";
        }
    }
  }

  getCurrentBikeStatusIcon(String dangerStatus) {
    switch (dangerStatus) {
      case 'safe':
        {
          if (cableLockState?.lockState == LockState.unlock) {
            return "assets/buttons/bike_security_unlock.svg";
          } else {
            return "assets/buttons/bike_security_lock_and_secure.svg";
          }
        }
      case 'warning':
        {
          return "assets/buttons/bike_security_warning.svg";
        }
      case 'danger':
        {
          return "assets/buttons/bike_security_danger.svg";
        }
      default:
        {
          return "assets/buttons/bike_security_lock_and_secure.svg";
        }
    }
  }

  getCurrentBikeStatusString(bool isLocked, String status) {
    switch (isLocked) {
      case true:
        if (status == "safe") {
          return "Locked & Secure";
        } else if (status == "warning") {
          return "Movement Detected";
        } else if (status == "danger") {
          return "Under Threat";
        }
        break;
      case false:
        if (status == "safe") {
          return "Unlocked";
        } else if (status == "warning") {
          return "Movement Detected";
        } else if (status == "danger") {
          return "Under Threat";
        }
        break;
    }
    return "Locked & Secure";
  }
}

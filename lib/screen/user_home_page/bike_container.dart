import 'dart:async';

import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/model/user_bike_model.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/function.dart';
import '../../api/model/bike_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../bluetooth/modelResult.dart';

class BikeContainer extends StatefulWidget {
  final BikeModel bikeModel;
  const BikeContainer({Key? key, required this.bikeModel}) : super(key: key);

  @override
  State<BikeContainer> createState() => _BikeContainerState();
}

class _BikeContainerState extends State<BikeContainer> {

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  bool isSpecificDeviceConnected = false;

  @override
  Widget build(BuildContext context) {

    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    NotificationProvider _notificationProvider = Provider.of<NotificationProvider>(context);

    /// get bluetooth connection state and lock unlock to detect isConnected
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    ///Handle all data if bool isDeviceConnected is true
    if (deviceConnectResult == DeviceConnectResult.connected) {
      if (_bluetoothProvider.currentBikeModel?.deviceIMEI == widget.bikeModel.deviceIMEI) {
        setState(() {
          isSpecificDeviceConnected = true;
        });
      }
      else {
        setState(() {
          isSpecificDeviceConnected = false;
        });
      }
    } else {
      setState(() {
        isSpecificDeviceConnected = false;
      });
    }

    ///List tile
    return Padding(
      padding: EdgeInsets.only(left:16.w, right: 16.w, bottom: 10.h, top: 6.h),
      child: Container(
        height: 88.h,
        decoration:  BoxDecoration(
          color:EvieColors.dividerWhite,
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 8.0.w,
              blurRadius: 8.0.w,
            ),
          ],
              border: widget.bikeModel.deviceIMEI == _bikeProvider.currentBikeModel!.deviceIMEI ? Border.all(
                color: EvieColors.primaryColor,
                width: 2,
              ) : null,
        ),
        child: ListTile(

          leading:
          //padding: EdgeInsets.fromLTRB(16.w, 17.h, 0.w, 0.h),
          Image.asset('assets/images/bike_round.png', ),
          title: Padding(
            padding: EdgeInsets.only(top:10.h),
            child: Row(
              children: [
                Text(
                    widget.bikeModel.deviceName!,
                    style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
                ),

              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    getCurrentBikeStatusIcon(widget.bikeModel, _bikeProvider, _bluetoothProvider),
                    height: 20.h,
                    width: 20.w,
                  ),
                  Text(getCurrentBikeStatusString(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, _bikeProvider,_bluetoothProvider), style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan)),
                ],
              ),


              Container(
                // height: 33.h,
                // width: 125.w,
                // child: ElevatedButton(
                //   child: Text(
                //     "Bike Setting",
                //     style: EvieTextStyles.body14.copyWith(color: EvieColors.primaryColor,fontWeight: FontWeight.w900),),
                //   onPressed: () async {
                //     ///Switch bike animation
                //     await _bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
                //     changeToBikeSetting(context, 'SwitchBike');
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20.0),
                //         side:  BorderSide(color: EvieColors.primaryColor, width: 1.0.w)),
                //     elevation: 0.0,
                //     backgroundColor: Colors.transparent,
                //
                //   ),
                // ),
              ),
            ],
          ),

          trailing: IconButton(
              onPressed: () async {
                if(!isSpecificDeviceConnected){
                  await _bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
                  StreamSubscription? subscription;
                  subscription = _bikeProvider.switchBike().listen((result) {
                    if(result == SwitchBikeResult.success){
                      ///set auto connect flag on bluetooth provider,
                      ///once bluetooth provider received new current bike model,
                      ///it will connect follow by the flag.
                      _bluetoothProvider.setAutoConnect();
                      subscription?.cancel();
                      _notificationProvider.compareActionableBarTime();
                      Navigator.pop(context);
                    }
                    else if(result == SwitchBikeResult.failure){
                      subscription?.cancel();
                      SmartDialog.show(
                          widget: EvieSingleButtonDialog(
                              title: "Error",
                              content: "Cannot change bike, please try again.",
                              rightContent: "OK",
                              onPressedRight: () {
                                SmartDialog.dismiss();
                              }));
                    }else{}
                  });

                }else{
                  await _bluetoothProvider.disconnectDevice();
                }
              },
              icon: isSpecificDeviceConnected ?
              SvgPicture.asset(
                "assets/buttons/ble_button_connect.svg",
                height: 50.h,
                width: 50.w,
              ) :
              SvgPicture.asset(
                "assets/buttons/ble_button_disconnect.svg",
                height: 50.h,
                width: 50.w,
              )
          ),
        ),
      ),
    );
  }

}

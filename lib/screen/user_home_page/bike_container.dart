import 'dart:async';
import 'dart:collection';

import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/function.dart';
import '../../api/model/bike_model.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../bluetooth/modelResult.dart';

class BikeContainer extends StatefulWidget {
  final BikeModel bikeModel;
  final LinkedHashMap bikesPlan;
  const BikeContainer({super.key, required this.bikeModel, required this.bikesPlan});

  @override
  State<BikeContainer> createState() => _BikeContainerState();
}

class _BikeContainerState extends State<BikeContainer> {

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  bool isSpecificDeviceConnected = false;

  @override
  Widget build(BuildContext context) {

    BikeProvider bikeProvider = Provider.of<BikeProvider>(context);
    BluetoothProvider bluetoothProvider = Provider.of<BluetoothProvider>(context);
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context);

    /// get bluetooth connection state and lock unlock to detect isConnected
    deviceConnectResult = bluetoothProvider.deviceConnectResult;

    ///Handle all data if bool isDeviceConnected is true
    if (deviceConnectResult == DeviceConnectResult.connected) {
      if (bluetoothProvider.currentBikeModel?.deviceIMEI == widget.bikeModel.deviceIMEI) {
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
      child: GestureDetector(
        onTap: () async {

          /// if target pressed device imei != current device imei
          if(widget.bikeModel.deviceIMEI != bikeProvider.currentBikeModel!.deviceIMEI){
            if( deviceConnectResult == DeviceConnectResult.connecting ||
                deviceConnectResult == DeviceConnectResult.scanning ||
                deviceConnectResult == DeviceConnectResult.connected ||
                deviceConnectResult == DeviceConnectResult.partialConnected||
                deviceConnectResult == DeviceConnectResult.disconnecting){
              await bluetoothProvider.stopScan();
              //await _bluetoothProvider.connectSubscription?.cancel();
              await bluetoothProvider.disconnectDevice();
              bluetoothProvider.switchBikeDetected();
              bluetoothProvider.startScanTimer?.cancel();
              await bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
              Navigator.pop(context);
            }else{
               await bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
               Navigator.pop(context);
            }
          }

        },
        child: Container(
          height: 96.h,
          width: double.infinity,
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
            border: bikeProvider.currentBikeModel != null ?
                widget.bikeModel.deviceIMEI == bikeProvider.currentBikeModel!.deviceIMEI ?
                Border.all(
                  color: EvieColors.primaryColor,
                  width: 2,
                ) : null : null,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 8.w, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.h,
                      height: 64.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: getCurrentBikeStatusColour(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, bikeProvider,bluetoothProvider),
                          width: 2.5.w,
                        ),
                      ),
                      child: widget.bikeModel.model == 'S1' ?
                      Image(
                        image: const AssetImage("assets/buttons/bike_default_S1.png"),
                        width: 56.h,
                        height: 56.h,
                      ) :
                      widget.bikeModel.model == 'T1' ?
                      Image(
                        image: const AssetImage("assets/buttons/bike_default_T1.png"),
                        width: 56.h,
                        height: 56.h,
                      ) :
                      Image(
                        image: const AssetImage("assets/buttons/bike_default_L1.png"),
                        width: 56.h,
                        height: 56.h,
                      )
                    ),
                    SizedBox(width: 16.w,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 180.w,
                              child: Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 150.w, // Set the maximum width here
                                    ),
                                    child: Text(
                                      widget.bikeModel.deviceName!,
                                      style: EvieTextStyles.target_reference_h3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  getCurrentBikeStatusTag(widget.bikeModel, bikeProvider, bluetoothProvider)
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              child:  Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        color: Colors.transparent,
                                        child: SvgPicture.asset(
                                          getCurrentBikeStatusIcon(widget.bikeModel, widget.bikesPlan, bluetoothProvider),
                                          height: 24.h,
                                          width: 24.w,
                                        ),
                                      ),
                                      SizedBox(width: 4.w,),
                                      Container(
                                        width: 150.w,
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 0),
                                          child: Text(getCurrentBikeStatusString(widget.bikeModel, bikeProvider,bluetoothProvider),
                                            style: EvieTextStyles.body18.copyWith(color: getCurrentBikeStatusColourText(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, bikeProvider,bluetoothProvider),
                                            ),
                                            softWrap: true,
                                            overflow:  TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                      iconSize: 45.w,
                      onPressed: () async {
                        if(!isSpecificDeviceConnected){
                          if(widget.bikeModel.deviceIMEI == bikeProvider.currentBikeModel!.deviceIMEI){
                            checkBleStatusAndConnectDevice(bluetoothProvider, bikeProvider);
                            notificationProvider.compareActionableBarTime();
                            Navigator.pop(context);

                          }
                          else{
                            await bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
                            StreamSubscription? subscription;
                            subscription = bikeProvider.switchBike().listen((result) {
                              if(result == SwitchBikeResult.success){
                                ///set auto connect flag on bluetooth provider,
                                ///once bluetooth provider received new current bike model,
                                ///it will connect follow by the flag.
                                bluetoothProvider.setAutoConnect();
                                subscription?.cancel();
                                notificationProvider.compareActionableBarTime();
                                Navigator.pop(context);
                              }
                              else if(result == SwitchBikeResult.failure){
                                subscription?.cancel();
                                SmartDialog.show(
                                    builder: (_) => EvieSingleButtonDialog(
                                        title: "Error",
                                        content: "Unable to switch bike, Please try again.",
                                        rightContent: "Retry",
                                        onPressedRight: () {
                                          SmartDialog.dismiss();
                                        }));
                              }else{}
                            });
                          }
                        }
                        else{
                          await bluetoothProvider.disconnectDevice();
                        }
                      },
                      icon: isSpecificDeviceConnected ?
                      SvgPicture.asset(
                        "assets/buttons/ble_button_connect.svg",
                        height: 45.w,
                        width: 45.w,
                      ) :
                      SvgPicture.asset(
                        "assets/buttons/ble_button_disconnect.svg",
                        height: 45.w,
                        width: 45.w,
                      )
                  ),
                )
              ],
            ),
          )
            // ListTile(
            //   contentPadding: EdgeInsets.only(left: 18.w, right: 8.w),
            //   leading: Container(
            //     width: 56.h,
            //     height: 56.h,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       border: Border.all(
            //         color: getCurrentBikeStatusColour(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, _bikeProvider,_bluetoothProvider),
            //         width: 2.5.w,
            //       ),
            //     ),
            //     child: widget.bikeModel.bikeIMG == ''
            //         ? Image(
            //       image: const AssetImage("assets/buttons/bike_left_pic.png"),
            //       width: 56.h,
            //       height: 56.h,
            //     )
            //         : ClipOval(
            //       child: CachedNetworkImage(
            //         imageUrl: widget.bikeModel.bikeIMG!,
            //         placeholder: (context, url) => const CircularProgressIndicator(color: EvieColors.primaryColor,),
            //         errorWidget: (context, url, error) => Icon(Icons.error),
            //         width: 56.h,
            //         height: 56.h,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            //
            //   title: Padding(
            //     padding: EdgeInsets.only(top:10.h),
            //     child: Row(
            //       children: [
            //         Text(
            //           widget.bikeModel.deviceName!,
            //           style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
            //         ),
            //         getCurrentBikeStatusTag(widget.bikeModel, _bikeProvider, _bluetoothProvider)
            //       ],
            //     ),
            //   ),
            //   subtitle: Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Row(
            //         children: [
            //           SvgPicture.asset(
            //             getCurrentBikeStatusIcon(widget.bikeModel, _bikeProvider, _bluetoothProvider),
            //             height: 20.h,
            //             width: 20.w,
            //           ),
            //           Text(getCurrentBikeStatusString(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, _bikeProvider,_bluetoothProvider),
            //             style: EvieTextStyles.body18.copyWith(color:
            //             getCurrentBikeStatusColourText(deviceConnectResult == DeviceConnectResult.connected, widget.bikeModel, _bikeProvider,_bluetoothProvider),
            //             ),
            //             softWrap: true,
            //             overflow:  TextOverflow.visible,
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            //   trailing: IconButton(
            //       onPressed: () async {
            //         if(!isSpecificDeviceConnected){
            //           if(widget.bikeModel.deviceIMEI == _bikeProvider.currentBikeModel!.deviceIMEI){
            //             checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
            //             _notificationProvider.compareActionableBarTime();
            //             Navigator.pop(context);
            //
            //           }else{
            //             await _bikeProvider.changeBikeUsingIMEI(widget.bikeModel.deviceIMEI!);
            //             StreamSubscription? subscription;
            //             subscription = _bikeProvider.switchBike().listen((result) {
            //               if(result == SwitchBikeResult.success){
            //                 ///set auto connect flag on bluetooth provider,
            //                 ///once bluetooth provider received new current bike model,
            //                 ///it will connect follow by the flag.
            //                 _bluetoothProvider.setAutoConnect();
            //                 subscription?.cancel();
            //                 _notificationProvider.compareActionableBarTime();
            //                 Navigator.pop(context);
            //               }
            //               else if(result == SwitchBikeResult.failure){
            //                 subscription?.cancel();
            //                 SmartDialog.show(
            //                     widget: EvieSingleButtonDialog(
            //                         title: "Error",
            //                         content: "Cannot change bike, please try again.",
            //                         rightContent: "OK",
            //                         onPressedRight: () {
            //                           SmartDialog.dismiss();
            //                         }));
            //               }else{}
            //             });
            //           }
            //         }else{
            //           await _bluetoothProvider.disconnectDevice();
            //         }
            //       },
            //       icon: isSpecificDeviceConnected ?
            //       SvgPicture.asset(
            //         "assets/buttons/ble_button_connect.svg",
            //         height: 50.h,
            //         width: 50.w,
            //       ) :
            //       SvgPicture.asset(
            //         "assets/buttons/ble_button_disconnect.svg",
            //         height: 50.h,
            //         width: 50.w,
            //       )
            //   ),
            // ),
        ),
      ),
    );
  }

}

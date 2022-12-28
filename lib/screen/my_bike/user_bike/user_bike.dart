import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';
import '../my_bike_function.dart';
import '../my_bike_widget.dart';



///User profile page with user account information

class UserBike extends StatefulWidget {
  const UserBike({Key? key}) : super(key: key);

  @override
  _UserBikeState createState() => _UserBikeState();
}

class _UserBikeState extends State<UserBike> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  final TextEditingController _bikeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  DeviceConnectionState? connectionState;
  CableLockResult? cableLockState;
  bool isDeviceConnected = false;


  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

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

    Future.delayed(Duration.zero, () {
      if (_bluetoothProvider.connectionStateUpdate?.failure != null) {
        _bluetoothProvider.disconnectDevice();
        SmartDialog.show(
            keepSingle: true,
            widget: EvieSingleButtonDialogCupertino(
                title: "Cannot connect bike",
                content: "Move your device near the bike and try again",
                rightContent: "OK",
                onPressedRight: () {
                  SmartDialog.dismiss();
                }));
      }
    });

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
                child: Container(
                  child: Text(
                    "My EVIE Bike",
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                height: 96.h,
                child: Row(
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(27.7.w, 14.67.h, 18.67.w, 14.67.h),
                      child: Image(
                        ///Change based on status
                        image: AssetImage(returnBikeStatusImage(_bikeProvider.currentBikeModel?.location?.isConnected ?? true, _bikeProvider.currentBikeModel?.location?.status ?? "")),
                        width: 86.86.h,
                        height: 54.85.h,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _bikeProvider.currentBikeModel?.deviceName ?? "",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              onPressed: (){
                                SmartDialog.show(
                                    widget: Form(
                                      key: _formKey,
                                      child: EvieDoubleButtonDialog(
                                          title: "Name Your Bike",
                                          childContent: Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:  EdgeInsets.fromLTRB(0.h, 12.h, 0.h, 8.h),
                                                  child: EvieTextFormField(
                                                    controller: _bikeNameController,
                                                    obscureText: false,
                                                    keyboardType: TextInputType.name,
                                                    hintText: "give your bike a unique name",
                                                    labelText: "Bike Name",
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Please enter bike name';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 25.h),
                                                  child: Text("100 Maximum Character", style: TextStyle(fontSize: 12.sp, color: Color(0xff252526)),),
                                                ),
                                              ],
                                            ),
                                          ),
                                          leftContent: "Cancel",
                                          rightContent: "Save",
                                          onPressedLeft: (){SmartDialog.dismiss();},
                                          onPressedRight: (){
                                            if (_formKey.currentState!.validate()) {
                                              _bikeProvider.updateBikeName(_bikeNameController.text.trim()).then((result){
                                                SmartDialog.dismiss();
                                                if(result == true){
                                                  SmartDialog.show(
                                                      keepSingle: true,
                                                      widget: EvieSingleButtonDialogCupertino
                                                        (title: "Success",
                                                          content: "Update successful",
                                                          rightContent: "Ok",
                                                          onPressedRight: (){
                                                            SmartDialog.dismiss();
                                                          } ));
                                                } else{
                                                  SmartDialog.show(
                                                      keepSingle: true,
                                                      widget: EvieSingleButtonDialogCupertino
                                                        (title: "Not Success",
                                                          content: "An error occur, try again",
                                                          rightContent: "Ok",
                                                          onPressedRight: (){SmartDialog.dismiss();} ));
                                                }
                                              });
                                            }

                                          }),
                                    ));
                              },
                              icon:   SvgPicture.asset(
                                "assets/buttons/pen_edit.svg",
                                height:20.h,
                                width: 20.w,
                              ),),
                          ],
                        ),
                        Container(
                          width: 143.w,
                          height: 40.h,
                          child: ElevatedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/bluetooth_small_white.svg",
                                  height:16.h,
                                  width: 16.w,
                                ),
                                Text(_bluetoothProvider.connectionStateUpdate?.connectionState.name == "connecting" ? "Connecting" :_bluetoothProvider.connectionStateUpdate?.connectionState.name == "connected" ?  "Connected" : "Connect Bike", style: TextStyle(fontSize: 12.sp, color: Color(0xffECEDEB)),), ],
                            ),
                            onPressed: (){
                              _bluetoothProvider.startScanAndConnect();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w)),
                              elevation: 0.0,
                              backgroundColor: EvieColors.PrimaryColor,
                              //padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.h),

                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Divider(
                        thickness: 0.5.h,
                        color: const Color(0xff8E8E8E),
                        height: 0,
                      ),
                      BikePageContainer (
                          subtitle: "RFID Car/Flash Key/E-key/Smart Key",
                          content: _bikeProvider.rfidList.length.toString(),
                          onPress: () {
                            if(isDeviceConnected){
                              if(_bikeProvider.rfidList.isNotEmpty){
                                changeToRFIDListScreen(context);
                              }else{
                                changeToRFIDCardScreen(context);
                              }

                            }else{
                              SmartDialog.show(widget: EvieDoubleButtonDialog(
                                  title: "Please Connect Your Bike",
                                  childContent: Text("Please connect your bike to access the function...?",style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w400),),
                                  leftContent: "Cancel",
                                  rightContent: "Connect Bike",
                                  onPressedLeft: (){SmartDialog.dismiss();},
                                  onPressedRight: (){
                                    SmartDialog.dismiss();
                                    _bluetoothProvider.startScanAndConnect();
                                  }));
                            }
                          },
                          trailingImage: "assets/buttons/next.svg"),
                      BikePageDivider(),
                      Opacity(
                        opacity: 0.3,
                        child: BikePageContainer (
                            subtitle: "Motion Sensitivity",
                            content: "Medium",
                            onPress: () {},
                            trailingImage: "assets/buttons/next.svg"),
                      ),
                      Divider(
                        thickness: 11.h,
                        color: const Color(0xffF4F4F4),
                      ),
                      Opacity(
                        opacity: 0.3,
                        child: BikePageContainer (
                            subtitle: "Subscription",
                            contents: Row(
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
                            onPress: () {},
                            trailingImage: "assets/buttons/next.svg"),
                      ),
                      BikePageDivider(),
                      Opacity(
                        opacity: 0.3,
                        child: BikePageContainer (
                            subtitle: "Share Bike",
                            contents: Row(
                              children: [
                                Text(
                                  "2 Riders",
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
                            onPress: () {},
                            trailingImage: "assets/buttons/next.svg"),
                      ),
                      BikePageDivider(),
                      BikePageContainer (
                          contents: Row(
                            children: [
                              Text(
                                "Bike Notification",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          onPress: () {},
                          trailingImage: "assets/buttons/next.svg"),
                      BikePageDivider(),
                      BikePageContainer (
                          contents: Row(
                            children: [
                              Text(
                                "Crash Alert",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 8.17.w,),
                              SvgPicture.asset(
                                "assets/icons/batch_tick.svg",
                              ),
                            ],
                          ),
                          onPress: () {},
                          trailingImage: "assets/buttons/next.svg"),
                      BikePageDivider(),
                      Opacity(
                        opacity: 0.3,
                        child: BikePageContainer (
                            contents: Row(
                              children: [
                                Text(
                                  "Manage Data",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 8.17.w,),
                                SvgPicture.asset(
                                  "assets/icons/batch_tick.svg",
                                ),
                              ],
                            ),
                            onPress: () {},
                            trailingImage: "assets/buttons/external_link.svg"),
                      ),
                      Divider(
                        thickness: 11.h,
                        color: const Color(0xffF4F4F4),
                      ),
                      BikePageContainer (
                          content: "About Bike",
                          onPress: () {},
                          trailingImage: "assets/buttons/next.svg"),
                      BikePageDivider(),
                      BikePageContainer (
                          subtitle: "Firmware Version",
                          content: "0.3.3",
                          onPress: () {},
                          trailingImage: "assets/buttons/next.svg"),
                      BikePageDivider(),
                      BikePageContainer (
                          content: "User Manual",
                          onPress: () {},
                          trailingImage: "assets/buttons/external_link.svg"),
                      Opacity(
                        opacity: 0.3,
                        child: BikePageContainer (
                            content: "Reset Bike",
                            onPress: () {},
                            trailingImage:"assets/buttons/next.svg"),
                      ),
                      BikePageDivider(),
                      BikePageContainer (
                          content: "Delete Bike",
                          onPress: () {},
                          trailingImage:"assets/buttons/next.svg"),
                      BikePageDivider(),
                    ],
                  ),
                ),
              ),


            ],
          )),
    );
  }
}

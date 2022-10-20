import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/animation/ripple_pulse_animation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';

import '../api/provider/bike_provider.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';

class UserHomeBluetooth extends StatefulWidget{
  const UserHomeBluetooth({ Key? key }) : super(key: key);
  @override
  _UserHomeBluetoothState createState() => _UserHomeBluetoothState();
}

class _UserHomeBluetoothState extends State<UserHomeBluetooth> {

  late BluetoothProvider bluetoothProvider = context.watch<BluetoothProvider>();
  late BikeProvider bikeProvider = context.watch<BikeProvider>();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    bluetoothProvider.stopScan();
    super.dispose();
  }

  Widget deviceSignal(String rssi) {
    return Text("rssi : " + rssi);
  }


  Widget deviceMacAddress(String deviceId) {
    return Text(deviceId);
  }

  Widget deviceName(String deviceName) {
    String name = '';

    if (deviceName.isNotEmpty) {
      name = deviceName;
    } else {
      name = 'N/A';
    }

    return Text(name);
  }

  Widget leading() {
    return const CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }


  Widget listItem(DiscoveredDevice? discoveredDevice) {
    if (discoveredDevice != null) {
      return ListTile(
        leading: leading(),
        title: deviceName(discoveredDevice.name),
        subtitle: deviceSignal(discoveredDevice.rssi.toString()),
        trailing: IconButton(
          iconSize: 25,
          icon: const Image(
            image: AssetImage("assets/buttons/arrow_right.png"),
            height: 20.0,
          ),
          tooltip: 'Connect',
          onPressed: () {

            SmartDialog.show(
              tag: "ConnectBike",
                widget: EvieDoubleButtonDialog(
                  //buttonNumber: "2",
                    title: "Connect Bike",
                    content:
                    "Connect to this bike?",
                    leftContent: "Cancel",
                    rightContent: "Connect",
                    image: Image.asset(
                      "assets/evieBike.png",
                      width: 36,
                      height: 36,
                    ),
                    onPressedLeft: () {
                      SmartDialog.dismiss(tag: "ConnectBike");
                    },
                    onPressedRight: () {
                      SmartDialog.dismiss(tag: "ConnectBike");
                      bluetoothProvider.stopScan();
                      Navigator.pop(context);
                      SmartDialog.showLoading(backDismiss: false);
                      try {
                        bluetoothProvider.connectDevice(discoveredDevice.id);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }));
          },
        ),
      );
    }
    else {
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, ()  {
    if (bluetoothProvider.bleStatus == BleStatus.ready) {
      SmartDialog.dismiss(
    //      tag: "bluetoothOff"
      );
      if (bluetoothProvider.scanSubscription == null) {
        bluetoothProvider.startScan();
      }
    }
    else if(bluetoothProvider.bleStatus == BleStatus.poweredOff){
      SmartDialog.show(
        keepSingle: true,
        //  tag: "bluetoothOff",
          widget: EvieDoubleButtonDialog(
              title: "Bluetooth Required",
              content: "Please turn on your bluetooth in phone setting",
              leftContent: "Cancel",
              rightContent: "Setting",
              image: Image.asset(
                "assets/icons/bluetooth_logo.png",
                width: 36,
                height: 36,
              ),
              onPressedLeft: () {
                SmartDialog.dismiss();
              },
              onPressedRight: () {
                OpenSettings.openBluetoothSetting();
              })
      );
    }
    });


    if(bluetoothProvider.isPaired == true){
      bluetoothProvider.setIsPairedResult(false);
      if(bluetoothProvider.deviceID != null) {
        bikeProvider.uploadToFireStore(
            bluetoothProvider.deviceID)
            .then((result) {
          if (result == true) {
            SmartDialog.dismiss(status: SmartStatus.loading);
            SmartDialog.show(
                tag: "ConnectSuccess",
                widget:EvieSingleButtonDialog(
                    title: "Success",
                    content: "Connected",
                    rightContent: "OK",
                    onPressedRight: () {
                      SmartDialog.dismiss(tag:"ConnectSuccess");




                      changeToTestBLEScreen(context);
                      //changeToUserHomePageScreen(context);




                    }));

          } else {
            SmartDialog.show(
                widget:EvieSingleButtonDialog(
                    title: "Error",
                    content: "Error connect bike, try again",
                    rightContent: "OK",
                    onPressedRight: () {SmartDialog.dismiss();}
                )
            );
          }
        }
        );
      }
    }


    return Scaffold(
      appBar: AppBar(title: const Text("Connect Your Bike",
        style: TextStyle(fontSize: 24.0),
      ),
        centerTitle: true,
        bottom: PreferredSize(
          child: Text("Tap bluetooth icon to search \nBluetooth Status : " + bluetoothProvider.bleStatus.toString(),
          style:const TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),),
          preferredSize: Size.fromHeight(0),
        ),),
      body: Container(
        child:Stack(
          alignment: Alignment.center,
          children: <Widget>[
            RipplePulseAnimation(),
            IconButton(
              iconSize: 55,
              icon: Image.asset("assets/icons/bluetooth_logo.png"),
              tooltip: 'Bluetooth',
              onPressed: () {

               showDeviceList();

              },
            ),
          ],
        ),
      ),
    );
  }

  showDeviceList() {
    showModalBottomSheet(

        context: context,
  ///      backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          ///Delete list item where the name is NA
          //scanResultList.removeWhere((item) => item.device.name.isEmpty);
          bluetoothProvider = context.watch<BluetoothProvider>();

          return
            Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
               color: Color(0xffD7E9EF),
                ),
                child: Center(
                  child: ListView.separated(

                    itemCount: bluetoothProvider.discoverDeviceList.length,
                    itemBuilder: (context, index) {
                      String key = bluetoothProvider.discoverDeviceList.keys.elementAt(index);
                      return listItem(bluetoothProvider.discoverDeviceList[key]);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
                )
            );
        });
  }
}

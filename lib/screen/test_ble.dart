import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';


import '../api/backend/stripe_api_caller.dart';
import '../api/model/plan_model.dart';
import '../api/navigator.dart';
import '../api/provider/auth_provider.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/plan_provider.dart';
import '../api/provider/setting_provider.dart';
import '../test/test qr scanner.dart';
import '../widgets/evie_button.dart';
import '../widgets/evie_double_button_dialog.dart';
import '../widgets/evie_single_button_dialog.dart';
import '../widgets/evie_textform.dart';

class TestBle extends StatefulWidget {
  const TestBle({Key? key}) : super(key: key);

  @override
  _TestBleState createState() => _TestBleState();
}

class _TestBleState extends State<TestBle> {
  late BluetoothProvider bluetoothProvider;
  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;
  late PlanProvider _planProvider;
  late SettingProvider _settingProvider;
  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
  StreamSubscription? connectSubscription;
  String connectionStatus = "";
  final TextEditingController _qrCodeController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _qrCodeController.text = "QRCODE:";
    _ipAddressController.text = "IP:";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    connectSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    bluetoothProvider = context.watch<BluetoothProvider>();
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    connectionStateUpdate = bluetoothProvider.connectionStateUpdate;
    connectionState = bluetoothProvider.connectionStateUpdate?.connectionState;

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                  ),
                  onPressed: () {

                    changeToTripHistory(context);
                  }
              ),

              const Text('Test BLE'),

            ],
          ),
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bluetooth Status : " + bluetoothProvider.bleStatus.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "MAC Address : " + (connectionStateUpdate?.deviceId ?? "No Device"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "DEVICE IMEI : " + (bluetoothProvider.iotInfoModel?.deviceIMEI ?? "No Device IMEI"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "QR Code : " + (bluetoothProvider.iotInfoModel?.qrCode ?? "No QR Code"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "IP Address : " + (bluetoothProvider.iotInfoModel?.ipAddress ?? "No IP Address"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                Text(
                  "Firmware Version : " + (bluetoothProvider.iotInfoModel?.firmwareVer ?? ""),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Com Key Value : " + (bluetoothProvider.requestComKeyResult != null ? bluetoothProvider.requestComKeyResult!.communicationKey.toString() : "No Communication Key"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Battery Level : " + (bluetoothProvider.bikeInfoResult != null ? bluetoothProvider.bikeInfoResult!.batteryLevel! + "%" : "Not detected"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Current Speed : " + (bluetoothProvider.bikeInfoResult != null ? bluetoothProvider.bikeInfoResult!.speed! + " km/h" : "Not detected"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Single Riding Mileage : " + (bluetoothProvider.bikeInfoResult != null ? bluetoothProvider.bikeInfoResult!.singleRidingMileage! + " m" : "Not detected"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Estimate Remaining Mileage : " + (bluetoothProvider.bikeInfoResult != null ? bluetoothProvider.bikeInfoResult!.remainingMileage! + " m" : "Not detected"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Lock Status : " + (bluetoothProvider.cableLockState?.lockState != null ? bluetoothProvider.cableLockState!.lockState == LockState.lock ? "LOCK" : bluetoothProvider.cableLockState!.lockState == LockState.unlock ? "UNLOCK" : "UNKNOWN": "UNKNOWN"),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Connection status : " + connectionStatus,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Failed status : " + (bluetoothProvider.errorPromptResult?.errorMessage.name ?? ""),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Query RFID : " + (bluetoothProvider.queryRFIDCardResult?.rfidNumber ?? ""),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                  child: EvieButton(
                    onPressed: () async {
                      if (bluetoothProvider.deviceConnectResult == DeviceConnectResult.partialConnected || bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected) {
                        await bluetoothProvider.disconnectDevice();
                        await bluetoothProvider.stopScan();
                        await connectSubscription?.cancel();
                      }
                      else {
                        await bluetoothProvider.disconnectDevice();
                        await bluetoothProvider.stopScan();
                        await connectSubscription?.cancel();
                        connectSubscription = bluetoothProvider.startScanAndConnect().listen((deviceConnectStatus) {
                          print(deviceConnectStatus.name);
                          switch (deviceConnectStatus) {
                            case DeviceConnectResult.scanning:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.scanTimeout:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.scanError:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.connecting:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.partialConnected:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.connected:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              connectSubscription?.cancel();
                              break;
                            case DeviceConnectResult.disconnecting:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.disconnected:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                            case DeviceConnectResult.connectError:
                            // TODO: Handle this case.
                              setState(() {
                                connectionStatus = deviceConnectStatus.name.toString();
                              });
                              break;
                          }
                        });
                      }
                    },
                    width: double.infinity,
                    child: Text(
                      connectionState?.name == "connected" ? "Disconnect Device"
                          : connectionState?.name == "connecting" ? "Connecting Device"
                          : "Connect Device",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: EvieButton(
                    onPressed: () async {
                      SmartDialog.showLoading(msg: "Unlocking cable lock....");
                      if (bluetoothProvider.bleStatus == BleStatus.ready) {
                        StreamSubscription? subscription;
                        subscription = bluetoothProvider.cableUnlock().listen((cableLockResult) {
                          if (bluetoothProvider.cableLockState?.lockState == LockState.unlock) {
                            SmartDialog.dismiss(status: SmartStatus.loading);
                            subscription?.cancel();
                          }
                        }, onError: (error) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          print(error);
                          subscription?.cancel();
                        });
                      }
                      else {
                        showAlertDialog(context);
                      }
                    },
                    width: double.infinity,
                    child: const Text(
                      "Unlock Cable Lock",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Get cable lock status...");
                      if (bluetoothProvider.bleStatus == BleStatus.ready) {
                        bluetoothProvider.getCableLockStatus().listen((cableLockResult) {
                          if (cableLockResult.lockState == LockState.lock) {

                          }
                          else {

                          }
                          SmartDialog.dismiss(status: SmartStatus.loading);
                        }, onError: (error) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          print(error);
                        });
                      }
                      else {
                        showAlertDialog(context);
                      }
                    },

                    width: double.infinity,
                    child: const Text(
                      "Get Cable Lock Status",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: EvieButton(
                    onPressed: () async {
                      ///Send command to get total packet of IOT information
                      bluetoothProvider.requestTotalPacketOfIotInfo();
                    },

                    width: double.infinity,
                    child: const Text(
                      "Get IOT Info",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.show(
                          widget: Form(
                            key: _formKey,
                            child: EvieDoubleButtonDialog(
                                title: "Update",
                                childContent: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:  EdgeInsets.fromLTRB(0.h, 2.h, 0.h, 2.h),
                                        child: EvieTextFormField(
                                          controller: _qrCodeController,
                                          obscureText: false,
                                          keyboardType: TextInputType.name,
                                          hintText: "QRCODE:XXXXX",
                                          labelText: "Update QR Code",
                                        ),
                                      ),
                                      Padding(
                                        padding:  EdgeInsets.fromLTRB(0.h, 2.h, 0.h, 2.h),
                                        child: EvieTextFormField(
                                          controller: _ipAddressController,
                                          obscureText: false,
                                          keyboardType: TextInputType.name,
                                          hintText: "IP Address:XXX.XXX.XXX.XXX",
                                          labelText: "Update IP Address",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                leftContent: "Cancel",
                                rightContent: "Save",
                                onPressedLeft: (){
                                  SmartDialog.dismiss();
                                  _qrCodeController.text = "QRCODE:";
                                  _ipAddressController.text = "IP:";
                                },
                                onPressedRight: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (bluetoothProvider.bleStatus == BleStatus.ready) {
                                      if (bluetoothProvider.connectionStateUpdate?.connectionState == DeviceConnectionState.connected) {
                                        if (_qrCodeController.text != "QRCODE:" && _ipAddressController.text != "IP:") {
                                          bluetoothProvider.updateIotData(_qrCodeController.text.trim() + "," + _ipAddressController.text.trim() + ",");
                                        }
                                        else if (_ipAddressController.text != "IP:") {
                                          bluetoothProvider.updateIotData(_ipAddressController.text.trim() + ",");
                                        }
                                        else if (_qrCodeController.text != "QRCODE:") {
                                          bluetoothProvider.updateIotData(_qrCodeController.text.trim() + ",");
                                        }

                                        SmartDialog.dismiss();
                                        _qrCodeController.text = "QRCODE:";
                                        _ipAddressController.text = "IP:";
                                      }
                                    }
                                  }
                                }),
                          )
                      );
                    },

                    width: double.infinity,
                    child: const Text(
                      "Update IOT Data",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: EvieButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        bluetoothProvider.firmwareUpgradeListener.stream.listen((firmwareUpgradeResult) {
                          if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.startUpgrade) {
                            print("Start Upgrade Firmware");
                          }
                          else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgrading) {
                            print("Upgrading firmware: " +
                                (firmwareUpgradeResult.progress * 100)
                                    .toString() + "%");
                          }
                          else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeSuccessfully) {
                            ///go to success page
                            print("OTA State: " + firmwareUpgradeResult.firmwareUpgradeState.toString());
                          }
                          else if (firmwareUpgradeResult.firmwareUpgradeState == FirmwareUpgradeState.upgradeFailed) {
                            print("OTA State: " + firmwareUpgradeResult.firmwareUpgradeState.toString());
                          }
                        });

                        bluetoothProvider.startUpgradeFirmware(file);

                      } else {
                        // User canceled the picker
                      }
                    },
                       width: double.infinity,
                    child: const Text(
                      "Upgrade Firmware",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Text(
                          bluetoothProvider.firmwareUpgradeState.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        LinearPercentIndicator(
                          width: 350,
                          animation: false,
                          lineHeight: 20.0,
                          animationDuration: 0,
                          percent: bluetoothProvider.fwUpgradeProgress,
                          center: Text(
                            (bluetoothProvider.fwUpgradeProgress * 100).toStringAsFixed(0) + "%",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: EvieColors.primaryColor,
                          backgroundColor: EvieColors.greyFill,
                        ),
                      ],
                    )
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "register RFID....");
                      bluetoothProvider.addRFID().listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        if (addRFIDStatus.addRFIDState == AddRFIDState.startReadCard) {
                          /// Successfully Changed BLE Key
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Register RFID",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Delete RFID....");
                      if (bluetoothProvider.queryRFIDCardResult != null) {
                        bluetoothProvider.deleteRFID(bluetoothProvider
                            .queryRFIDCardResult!.rfidNumber!).listen((
                            deleteRFIDStatus) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          if (deleteRFIDStatus.result ==
                              CommandResult.success) {}
                          else {}
                        }, onError: (error) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          print(error);
                        });
                      }
                      else {
                        SmartDialog.show(widget: Text("No Query RFID available", style: TextStyle(color: Colors.black),));
                      }
                    },

                    width: double.infinity,
                    child: const Text(
                      "Delete RFID",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "query RFID index 0....");
                      bluetoothProvider.queryRFID(0).listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },
                             width: double.infinity,
                    child: const Text(
                      "Query RFID 0",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "query RFID index 1....");
                      bluetoothProvider.queryRFID(1).listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Query RFID 1",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "query RFID index 2....");
                      bluetoothProvider.queryRFID(2).listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Query RFID 2",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "query RFID index 3....");
                      bluetoothProvider.queryRFID(3).listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Query RFID 3",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "query RFID index 4....");
                      bluetoothProvider.queryRFID(4).listen((addRFIDStatus) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Query RFID 4",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Changing BLE Key to yOTmK50z....");
                      StreamSubscription? subscription;
                      subscription = bluetoothProvider.changeBleKey().listen((changeBleKeyResult) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        subscription?.cancel();
                        if (changeBleKeyResult.result == CommandResult.success) {
                          /// Successfully Changed BLE Key
                          /// Remember update this BLE KEY to firestore ### very important.
                          changeBleKeyResult.bleKey;
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        subscription?.cancel();
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Change BLE Key",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Changing BLE Name....");
                      bluetoothProvider.changeBleName().listen((changeBleNameResult) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        if (changeBleNameResult.result == CommandResult.success) {
                          /// Successfully Changed BLE Key
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Change BLE Name",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Changing Movement Setting....");
                      bluetoothProvider.changeMovementSetting(true, MovementSensitivity.low).listen((changeBleNameResult) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        if (changeBleNameResult.result == CommandResult.success) {
                          /// Successfully Changed BLE Key
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Enable Movement Setting with low mode",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Changing Movement Setting....");
                      bluetoothProvider.changeMovementSetting(false, MovementSensitivity.low).listen((changeBleNameResult) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        if (changeBleNameResult.result == CommandResult.success) {
                          /// Successfully Changed BLE Key
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },

                    width: double.infinity,
                    child: const Text(
                      "Disable Movement Setting with low mode",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () {
                      SmartDialog.showLoading(msg: "Factory Reset....");
                      bluetoothProvider.factoryReset().listen((changeBleNameResult) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        if (changeBleNameResult.result == CommandResult.success) {
                          /// Successfully Changed BLE Key
                        }
                        else {
                          /// Failed to change BLE key
                        }
                      }, onError: (error) {
                        SmartDialog.dismiss(status: SmartStatus.loading);
                        print(error);
                      });
                    },
                    width: double.infinity,
                    child: const Text(
                      "Factory Reset",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "System Theme Mode",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    _settingProvider.enableSystemTheme();
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Light Theme Mode",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    _settingProvider.enableLightTheme();
                  },
                ),

                EvieButton(
                  width: double.infinity,
                  child: const Text(
                    "Dark Theme Mode",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    _settingProvider.enableDarkTheme();
                  },
                ),


                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Get token",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SimApiCaller.getAccessToken();
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Activate Sim",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SimApiCaller.activateSim("64e85bf1b5bb40c773b159dfda5ba98e7eec2f154ff78c3029a5b21596d4e961", "8944502701221855684").then((value) {
                      print(value);
                    });
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Deactivate Sim",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SimApiCaller.deactivateSim("64e85bf1b5bb40c773b159dfda5ba98e7eec2f154ff78c3029a5b21596d4e961", "8944502701221855684").then((value) {
                      print(value);
                    });
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Get Sim Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SimApiCaller.getSimStatus("64e85bf1b5bb40c773b159dfda5ba98e7eec2f154ff78c3029a5b21596d4e961", "8944502701221855684").then((value) {
                      print(value);
                    });
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Qr code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => TestQRScan()));
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Onboarding",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    changeToStayCloseToBike(context);
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Unlock bike",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.showLoading(msg: "Unlocking");
                    StreamSubscription? subscription;
                    subscription = bluetoothProvider.cableUnlock().listen((unlockResult) {
                      SmartDialog.dismiss(status: SmartStatus.loading);
                      subscription?.cancel();
                      if (unlockResult.result == CommandResult.success) {
                        print("unlock success");
                      }
                      else {
                        print("unlock not success");
                      }
                    }, onError: (error) {
                      SmartDialog.dismiss(status: SmartStatus.loading);
                      subscription?.cancel();
                      print(error);
                    });
                  },
                ),

                ///Delete bike for development purpose
                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Delete Bike",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialogCupertino(
                          //buttonNumber: "2",
                            title: "Delete bike",
                            content:
                            "Are you sure you want to delete this bike?",
                            leftContent: "Cancel",
                            rightContent: "Delete",

                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              try {
                                SmartDialog.dismiss();
                                bool result = _bikeProvider.deleteBike(
                                    _bikeProvider
                                        .currentBikeModel!.deviceIMEI!
                                        .trim());
                                if (result == true) {
                                  SmartDialog.show(
                                      widget:
                                      EvieSingleButtonDialogCupertino(
                                          title: "Success",
                                          content:
                                          "Successfully delete bike",
                                          rightContent: "OK",
                                          onPressedRight: () {
                                            SmartDialog.dismiss();
                                          }));
                                } else {
                                  SmartDialog.show(
                                      widget:
                                      EvieSingleButtonDialogCupertino(
                                          title: "Error",
                                          content:
                                          "Error delete bike, try again",
                                          rightContent: "OK",
                                          onPressedRight: () {
                                            SmartDialog.dismiss();
                                          }));
                                }
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                            }));
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Share Bike",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    changeToSharesBikeScreen(context);
                  },
                ),

                Text("Available Plans", style: TextStyle(
                  fontSize: 16, color: Colors.black,
                ),),

                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _planProvider.availablePlanList.length,
                  itemBuilder: (context, index) {
                    String key = _planProvider.availablePlanList.keys.elementAt(index);
                    PlanModel planModel = _planProvider.availablePlanList[key];
                    return EvieButton(

                      width: double.infinity,
                      child: Text(
                        "Checkout plan : " + planModel.name.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        _planProvider.getPrice(planModel).then((priceModel) {
                          _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
                            changeToStripeCheckoutScreen(context, value, _bikeProvider.currentBikeModel!, planModel, priceModel);
                          });
                        });
                      },
                    );
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Change Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    //StripeApiCaller.changeSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l", "price_1Lp11KBjvoM881zM7rIdanjj", "si_MY7fGJWs01DGF5");
                  },
                ),

                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Cancel Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    //StripeApiCaller.cancelSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l");
                  },
                ),
                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "RFID card",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {

                  },
                ),
                EvieButton(

                  width: double.infinity,
                  child: const Text(
                    "Sign out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () async {
                    SmartDialog.showLoading();
                    try {
                      await _bikeProvider.clear();
                      await _authProvider.signOut(context).then((result) {
                        if (result == true) {
                          SmartDialog.dismiss();
                          // _authProvider.clear();

                          changeToWelcomeScreen(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed out'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          SmartDialog.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error, Try Again'),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      });
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

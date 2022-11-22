import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../api/navigator.dart';
import '../widgets/evie_button.dart';

class TestBle extends StatefulWidget {
  const TestBle({Key? key}) : super(key: key);

  @override
  _TestBleState createState() => _TestBleState();
}

class _TestBleState extends State<TestBle> {
  late BluetoothProvider bluetoothProvider;
  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;

  @override
  Widget build(BuildContext context) {

    bluetoothProvider = context.watch<BluetoothProvider>();
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
                    changeToUserBluetoothScreen(context);
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
                  "Connection status : " + (connectionState?.name ?? ""),
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
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () {
                      if (connectionState!.name == "connected") {
                        bluetoothProvider.disconnectDevice(connectionStateUpdate!.deviceId);
                      }
                      else if (connectionState!.name == "connecting") {

                      }
                      else {
                        bluetoothProvider.connectDevice(connectionStateUpdate!.deviceId, "RIiOU5wK");
                      }
                    },
                    height: 12.2,
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
                  padding: EdgeInsets.all(20),
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
                    height: 12.2,
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
                  padding: EdgeInsets.all(20),
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                    height: 12.2,
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
                      bluetoothProvider.changeMovementSetting().listen((changeBleNameResult) {
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
                    height: 12.2,
                    width: double.infinity,
                    child: const Text(
                      "Change Movement Setting",
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
                    height: 12.2,
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

                Padding(
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        bluetoothProvider.startUpgradeFirmware(file);
                      } else {
                        // User canceled the picker
                      }
                    },
                    height: 12.2,
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
                        progressColor: EvieColors.PrimaryColor,
                        backgroundColor: EvieColors.greyFill,
                      ),
                    ],
                  )
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: EvieButton(
                    onPressed: () async {
                      StreamSubscription? subscription;
                      try {
                        subscription = bluetoothProvider.iotInfoModelStream.listen((iotInfoModel) {
                          print(iotInfoModel.deviceIMEI.toString());
                          subscription?.cancel();
                          ///After get IOT Info Model, add bike information to firestore.
                          /// Then change ble key and update blekey to firestore.
                        });
                      } catch (e, s) {
                        print(s);
                      }
                    },
                    height: 12.2,
                    width: double.infinity,
                    child: const Text(
                      "Listen IoT info",
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
                    onPressed: () async {
                      StreamSubscription? subscription;
                      try {
                        subscription = bluetoothProvider.pairDevice("8C:59:DC:FA:44:8A").listen((pairDeviceResult) {
                          print(pairDeviceResult.pairingState.toString());
                          switch (pairDeviceResult.pairingState) {
                            case PairingState.unknown:
                              // TODO: Handle this case.
                              break;
                            case PairingState.startPairing:
                              // TODO: Handle this case.
                              break;
                            case PairingState.pairing:
                              // TODO: Handle this case.
                              break;
                            case PairingState.gettingIotInfo:
                              // TODO: Handle this case.
                              break;
                            case PairingState.errorPrompt:
                              // TODO: Handle this case.
                              subscription?.cancel();
                              break;
                            case PairingState.pairDeviceSuccess:
                              // TODO: Handle this case.
                              subscription?.cancel();
                              break;
                            case PairingState.pairDeviceFailed:
                              // TODO: Handle this case.
                              subscription?.cancel();
                              break;
                          }
                        });
                      } catch (e, s) {
                        print(s);
                        subscription?.cancel();
                      }
                    },
                    height: 12.2,
                    width: double.infinity,
                    child: const Text(
                      "Pair Device",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

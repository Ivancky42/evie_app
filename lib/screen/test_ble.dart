import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

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
      body: Center(
        child: Column(
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
              "Failed status : " + (connectionStateUpdate?.failure?.code.name ?? ""),
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
              child: EvieButton_LightBlue(
                onPressed: () {
                  if (connectionState!.name == "connected") {
                    bluetoothProvider.disconnectDevice(connectionStateUpdate!.deviceId);
                  }
                  else if (connectionState!.name == "connecting") {

                  }
                  else {
                    bluetoothProvider.connectDevice(connectionStateUpdate!.deviceId);
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

          ],
        ),
      )
    );
  }
}

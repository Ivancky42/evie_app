import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/animation/ripple_pulse_animation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';


///Cannot use when user bluetooth is off, should check user bluetooth
///then request turn on bluetooth


class UserHomeBluetooth extends StatefulWidget{
  const UserHomeBluetooth({ Key? key }) : super(key: key);
  @override
  _UserHomeBluetoothState createState() => _UserHomeBluetoothState();
}

class _UserHomeBluetoothState extends State<UserHomeBluetooth> {

  final bool _isScanning = false;
  late BluetoothProvider bluetoothProvider;

  @override
  initState() {
    super.initState();
    bluetoothProvider = context.read<BluetoothProvider>();
    bluetoothProvider.startScan();
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
        title: deviceName(discoveredDevice!.name),
        subtitle: deviceSignal(discoveredDevice.rssi.toString()),
        trailing: IconButton(
          iconSize: 25,
          icon: const Image(
            image: AssetImage("assets/buttons/arrow_right.png"),
            height: 20.0,
          ),
          tooltip: 'Connect',
          onPressed: () {
            bluetoothProvider.connectDevice(discoveredDevice.id);
            Navigator.of(context).pushNamed('/testBle');
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

    return Scaffold(
      appBar: AppBar(title: const Text("Connect Your Bike",
        style: TextStyle(fontSize: 24.0),
      ),
        centerTitle: true,
        bottom: const PreferredSize(
          child: Text("Tap bluetooth icon to search",
          style:TextStyle(
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
                //Navigator.pushReplacementNamed(context, '/connectBTDevice');
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



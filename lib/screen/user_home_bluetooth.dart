import 'package:flutter/material.dart';
import 'package:evie_test/animation/ripple_pulse_animation.dart';
import 'package:flutter_blue/flutter_blue.dart';


///Cannot use when user bluetooth is off, should check user bluetooth
///then request turn on bluetooth


class UserHomeBluetooth extends StatefulWidget{
  const UserHomeBluetooth({ Key? key }) : super(key: key);
  @override
  _UserHomeBluetoothState createState() => _UserHomeBluetoothState();
}

class _UserHomeBluetoothState extends State<UserHomeBluetooth> {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResultList = [];
  final bool _isScanning = false;

  @override
  initState() {
    super.initState();
    init();
  }

  void init() {
    scan();
  }


  scan() async {
    if (!_isScanning) {
      scanResultList.clear();
      flutterBlue.startScan(timeout: Duration(seconds: 5));
      flutterBlue.scanResults.listen((results) {

        scanResultList = results;
        setState(() {});
      });
    } else {
      flutterBlue.stopScan();
    }
  }

  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }


  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }


  Widget deviceName(ScanResult r) {
    String name = '';

    if (r.device.name.isNotEmpty) {
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      name = r.advertisementData.localName;
    } else {
      name = 'N/A';
    }

    return Text(name);
  }

  Widget leading(ScanResult r) {
    return const CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }


  Widget listItem(ScanResult r) {

    return ListTile(
      leading: leading(r),
      title: deviceName(r),
      //subtitle: deviceMacAddress(r),
      //trailing: deviceSignal(r),
      trailing: IconButton(
        iconSize: 25,
        icon: const Image(
          image: AssetImage("assets/buttons/arrow_right.png"),
          height: 20.0,
        ),
        tooltip: 'Connect',
        onPressed: () {
          //
        },
      ),
    );
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
          scanResultList.removeWhere((item) => item.device.name.isEmpty);

          return
            Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
   ///               color: Color(0xffD7E9EF),
                ),
                child: Center(
                  child: ListView.separated(

                    itemCount: scanResultList.length,
                    itemBuilder: (context, index) {

                      return listItem(scanResultList[index]);
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



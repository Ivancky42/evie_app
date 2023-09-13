// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
//
// ///Currently not in use
//
//
// class ConnectBluetoothDevice extends StatefulWidget{
//   const ConnectBluetoothDevice({ Key? key }) : super(key: key);
//   @override
//   _ConnectBluetoothDeviceState createState() => _ConnectBluetoothDeviceState();
// }
//
// class _ConnectBluetoothDeviceState extends State<ConnectBluetoothDevice> {
//
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   List<ScanResult> scanResultList = [];
//   final bool _isScanning = false;
//
//   @override
//   initState() {
//     super.initState();
//     init();
//   }
//
//   void init() {
//     scan();
//   }
//
//
//   scan() async {
//     if (!_isScanning) {
//       scanResultList.clear();
//       flutterBlue.startScan(timeout: Duration(seconds: 5));
//       flutterBlue.scanResults.listen((results) {
//
//         scanResultList = results;
//         setState(() {});
//       });
//     } else {
//       flutterBlue.stopScan();
//     }
//   }
//
//   Widget deviceSignal(ScanResult r) {
//     return Text(r.rssi.toString());
//   }
//
//
//   Widget deviceMacAddress(ScanResult r) {
//     return Text(r.device.id.id);
//   }
//
//
//   Widget deviceName(ScanResult r) {
//     String name = '';
//
//     if (r.device.name.isNotEmpty) {
//       name = r.device.name;
//     } else if (r.advertisementData.localName.isNotEmpty) {
//       name = r.advertisementData.localName;
//     } else {
//       name = 'N/A';
//     }
//
//     return Text(name);
//   }
//
//   Widget leading(ScanResult r) {
//     return const CircleAvatar(
//       child: Icon(
//         Icons.bluetooth,
//         color: Colors.white,
//       ),
//       backgroundColor: Colors.cyan,
//     );
//   }
//
//
//   Widget listItem(ScanResult r) {
//
//     return ListTile(
//       leading: leading(r),
//       title: deviceName(r),
//       //subtitle: deviceMacAddress(r),
//       //trailing: deviceSignal(r),
//       trailing: IconButton(
//         iconSize: 25,
//         icon: const Image(
//           image: AssetImage("assets/buttons/arrow_right.png"),
//           height: 20.0,
//         ),
//         tooltip: 'Connect',
//         onPressed: () {
//           //
//         },
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     showDeviceList();
//     throw UnimplementedError();
//   }
//
//
//
//   showDeviceList() {
//     showModalBottomSheet(
//         context: context,
//         backgroundColor: EvieColors.transparent,
//         builder: (BuildContext context) {
//
//           ///Delete list item where the name is NA
//           scanResultList.removeWhere((item) => item.device.name.isEmpty);
//
//           return
//             Container(
//                 decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16.0),
//                     topRight: Radius.circular(16.0),
//                   ),
//                   color: Color(0xffD7E9EF),
//                 ),
//                 child: Center(
//                   child: ListView.separated(
//
//                     itemCount: scanResultList.length,
//                     itemBuilder: (context, index) {
//
//                       return listItem(scanResultList[index]);
//                     },
//                     separatorBuilder: (BuildContext context, int index) {
//                       return Divider();
//                     },
//                   ),
//                 )
//             );
//         });
//   }
// }
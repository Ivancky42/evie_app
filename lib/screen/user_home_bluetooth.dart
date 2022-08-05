import 'package:flutter/material.dart';
import 'package:evie_test/animation/ripple_pulse_animation.dart';

class UserHomeBluetooth extends StatefulWidget{
  const UserHomeBluetooth({ Key? key }) : super(key: key);
  @override
  _UserHomeBluetoothState createState() => _UserHomeBluetoothState();
}

class _UserHomeBluetoothState extends State<UserHomeBluetooth> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect To Bluetooth"), centerTitle: true,),
      body: Container(
            child:Stack(
            alignment: Alignment.center,
            children: const <Widget>[
              RipplePulseAnimation(),
              Icon(
                Icons.bluetooth,
                color: Colors.black54,
                size: 30.0,
              ),
            ],
          ),
        ),
    );
  }
}
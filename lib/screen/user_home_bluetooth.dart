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
      body:
      InkWell(
          child:Container(
            child:Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RipplePulseAnimation(),
              IconButton(
                iconSize: 35,
                icon: Icon(Icons.bluetooth),
                color: Colors.black54,
                tooltip: 'Connect your bike',
                onPressed: () {
                },
              ),
            ],
          ),
        ),

        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hello'),
              actions:[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },

      )
    );
  }

}
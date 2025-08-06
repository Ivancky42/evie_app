
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';



class ThemeChangeOnPress extends StatefulWidget {
  const ThemeChangeOnPress({super.key});

  @override
  _ThemeChangeOnPressState createState() => _ThemeChangeOnPressState();
}

class _ThemeChangeOnPressState extends State<ThemeChangeOnPress> {

  late CurrentUserProvider _currentUserProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child:  Scaffold(
          body: Stack(
              children:const [





              ]
          )
      ),
    );
  }
}

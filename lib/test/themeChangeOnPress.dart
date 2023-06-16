import 'dart:async';

import 'package:evie_bike/api/provider/auth_provider.dart';
import 'package:evie_bike/api/provider/bluetooth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_bike/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';


import 'package:evie_bike/widgets/evie_button.dart';

class ThemeChangeOnPress extends StatefulWidget {
  const ThemeChangeOnPress({Key? key}) : super(key: key);

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

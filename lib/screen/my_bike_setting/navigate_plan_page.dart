
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../api/navigator.dart';

class NavigatePlanPage extends StatefulWidget {
  const NavigatePlanPage({Key? key}) : super(key: key);

  @override
  _NavigatePlanPageState createState() => _NavigatePlanPageState();
}

class _NavigatePlanPageState extends State<NavigatePlanPage> {

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
        child: Scaffold(body: _buildChild()));
  }
  Widget _buildChild() {
    return const BikeSetting();
  }
}

import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike/admin_free_plan/admin_free_plan.dart';
import 'package:evie_test/screen/my_bike/admin_paid_plan/admin_paid_plan.dart';
import 'package:evie_test/screen/my_bike/user_bike/user_bike.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import '../../../api/colours.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../widgets/evie_single_button_dialog.dart';


class NavigatePlanPage extends StatefulWidget {
  const NavigatePlanPage({Key? key}) : super(key: key);

  @override
  _NavigatePlanPageState createState() => _NavigatePlanPageState();
}

class _NavigatePlanPageState extends State<NavigatePlanPage> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
        child: Scaffold(body: _buildChild()));

  }
  Widget _buildChild() {
    if (_bikeProvider.isPlanSubscript == true) {

      var result = _bikeProvider.checkIsOwner();

      if(result == true){
        ///bikeUser - role is owner ?
        return const AdminPaidPlan();
      }else{
        return const UserBike();
      }
    } else {
      return const AdminFreePlan();
    }
  }
}

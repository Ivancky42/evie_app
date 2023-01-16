
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../api/provider/bike_provider.dart';



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
    return BikeSetting();
    // if (_bikeProvider.isPlanSubscript == true) {
    //   if(_bikeProvider.isOwner == true){
    //     return const AdminPaidPlan();
    //   }else{
    //     return const UserBike();
    //   }
    // } else {
    //   return const AdminFreePlan();
    // }
  }
}

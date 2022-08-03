import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:evie_test/screen/user_home_setting.dart';


class UserHomePage extends StatefulWidget{
  const UserHomePage({ Key? key }) : super(key: key);
  @override
  _UserHomePageState createState() => _UserHomePageState();

}

class _UserHomePageState extends State<UserHomePage>{

  int currentIndex = 0;

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    UserHomeBluetooth(),
    UserHomeSetting(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          actions: <Widget>[
            IconButton(
              iconSize: 25,
              icon: const Icon(Icons.person),
              tooltip: 'User Profile',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/userProfile');

            //    ScaffoldMessenger.of(context).showSnackBar(
            //        const SnackBar(content: Text('User Profile')));

              },
            ),
            IconButton(
              iconSize: 25,
              icon: const Icon(Icons.notifications),
              tooltip: 'Notification',
              onPressed: () {

              },
            ),
          ],


        ),

      //Body should change when bottom navigation bar state change
      body: screen[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        //For disable animation
        //type: BottomNavigationBarType.fixed,
        iconSize: 25,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            tooltip: 'User Profile',
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            tooltip: 'Bluetooth Pairing',
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            label: '',
          ),
        ],

      ),
    );
  }


}
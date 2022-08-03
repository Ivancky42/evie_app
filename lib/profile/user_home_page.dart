import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evie_test/widgets/widgets.dart';

class UserHomePage extends StatefulWidget{
  const UserHomePage({ Key? key }) : super(key: key);
  @override
  _UserHomePageState createState() => _UserHomePageState();

}

class _UserHomePageState extends State<UserHomePage>{

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: const Text(
            "Home",
            style: TextStyle(
              //fontSize: 24.0,
            ),
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[


              Image.asset('assets/evieBike.png'),
              const Text(
                'EVIE PRO - Modal A',
                style: TextStyle(fontSize: 20.0),
              ),

              const SizedBox(
                height: 100.0,
              ),

              EvieButton_LightBlue(
                width: double.infinity,
                child: const Text("Connect To Bike",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hello'),
                      content: const Text('No finish yet'),
                      actions:[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 44.0,
              ),

            ]
        ),
      ),

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
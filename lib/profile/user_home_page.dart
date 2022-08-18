import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:evie_test/screen/user_home_setting.dart';
import 'package:evie_test/screen/user_home_history.dart';

///User default home page when login condition is true

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  //Current index is 0, init state body[screen] is user home page general screen
  int currentIndex = 0;

  ///Appbar title
  String _title = 'Home';

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    UserHomeBluetooth(),
    UserHomeHistory(),
    UserHomeSetting(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Text(
            _title,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: <Widget>[
        Align(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(10),
              )),
              child: IconButton(
                iconSize: 25,
                icon: const Icon(Icons.person),
                tooltip: 'User Profile',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/userProfile');

                  //    ScaffoldMessenger.of(context).showSnackBar(
                  //        const SnackBar(content: Text('User Profile')));
                },
              ),
            ),
        ),

            const SizedBox(
              width: 20, //<-- SEE HERE
            ),

            Align(
            child:Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10),
                  )),
              child: IconButton(
                iconSize: 25,
                icon: const Icon(Icons.notifications),
                tooltip: 'Notification',
                onPressed: () {},
              ),
            ),
           ),

            const SizedBox(
              width: 10, //<-- SEE HERE
            ),

          ],
        ),

        //Body should change when bottom navigation bar state change
        body: screen[currentIndex],
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: const Color(0xff00B6F1),
          onPressed: () {
            Icon(Icons.lock);
            //code to execute on button press
          },
          child: Icon(Icons.lock_open), //icon inside button
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10.0,
          child: BottomNavigationBar(
            //For disable animation
            //type: BottomNavigationBarType.fixed,
            iconSize: 23,
            selectedItemColor: Color(0xff00B6F1),
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;

                ///Change title according pages index
                switch (index) {
                  case 0:
                    {
                      _title = 'Home';
                    }
                    break;
                  case 1:
                    {
                      _title = '';
                    }
                    break;
                  case 2:
                    {
                      _title = 'History';
                    }
                    break;
                  case 3:
                    {
                      _title = 'Setting';
                    }
                    break;
                }
              });
            },

            items: [
              BottomNavigationBarItem(
                icon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/home.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 23,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/home_selected.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 23,
                ),
                tooltip: 'User Profile',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.bluetooth),
                  padding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                ),
                tooltip: 'Bluetooth Pairing',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.history),
                  padding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                ),
                tooltip: 'Settings',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/setting.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 23,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/setting_selected.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 23,
                ),
                tooltip: 'Settings',
                label: '',
              ),
            ],
          ),
        ));
  }
}

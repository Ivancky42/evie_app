import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:evie_test/screen/user_home_setting.dart';
import 'package:evie_test/screen/user_home_history.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../api/navigator.dart';
import '../api/provider/notification_provider.dart';
import '../screen/onboarding/bike_scanning.dart';
import '../screen/onboarding/lets_go.dart';
import '../screen/verify_email.dart';
import '../theme/ThemeChangeNotifier.dart';

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
  String _title = '';

  late NotificationProvider _notificationProvider;
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    UserHomeBluetooth(),
    UserHomeHistory(),
    UserProfile(),
    TestBle(),
  ];


  @override
  Widget build(BuildContext context) {
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);


    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 5.5.h,
          title: Text(
            _title,
            style: TextStyle(fontSize: 21.sp),
          ),
          centerTitle: false,
          actions: <Widget>[
            if (currentIndex == 0) ... [

            Align(
            child:Container(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(10),
                  )),
              child: IconButton(
                iconSize: 25,
                icon: ThemeChangeNotifier().isDarkMode(context) == true ?
                    _notificationProvider.isReadAll == true?
                const Image(
                  image: AssetImage(
                      "assets/buttons/notification_white.png"),
                  height: 19.99,
                  width: 17.98,
                ) :  const Icon(Icons.notifications_active_outlined
                    )
                        :
                    _notificationProvider.isReadAll == true?
                const Image(
                  image: AssetImage(
                      "assets/buttons/notification.png"),
                  height: 17.98,
                  width: 17.98,
                ):  const Icon(Icons.notifications_active_outlined
                    ),
                tooltip: 'Notification',
                onPressed: () {
                  changeToNotificationScreen(context);
                },
              ),
            ),
           ),
            const SizedBox(
              width: 20,
            ),
          ],
          ],
        ),

        //Body should change when bottom navigation bar state change
        body: screen[currentIndex],

        /*
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: lockColour,
          onPressed: () {
            setState(() {
              _unlock = !_unlock;
            });
          },

          //icon inside button
          child: lockImage,

        ),

         */
     //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
       //   shape: CircularNotchedRectangle(),
       //   notchMargin: 10.0,
          child: BottomNavigationBar(
            //For disable animation
            //type: BottomNavigationBarType.fixed,
            iconSize: 23,
            selectedItemColor: Color(0xff69489D),
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;

                ///Change title according pages index
                switch (index) {
                  case 0:
                    {
                      _title = '';
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
                  case 4:
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
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/home_selected.png"),
                  ),
        //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                tooltip: 'User Profile',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.bluetooth),
         //         padding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                ),
                tooltip: 'Bluetooth Pairing',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.history),
          //        padding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                ),
                tooltip: 'Settings',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/user.png"),
                  ),
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/user_selected.png"),
                  ),
           //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                tooltip: 'User',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/user.png"),
                  ),
                  //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/user_selected.png"),
                  ),
                  //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                tooltip: 'User',
                label: '',
              ),
            ],
          ),
        ));
  }
}

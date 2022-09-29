import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:evie_test/screen/user_home_setting.dart';
import 'package:evie_test/screen/user_home_history.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../api/navigator.dart';
import '../api/provider/notification_provider.dart';
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
  String _title = 'Home';

  bool _unlock = false;

  late NotificationProvider _notificationProvider;

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    UserHomeBluetooth(),
    UserHomeHistory(),
    UserHomeSetting(),
  ];

  @override
  Widget build(BuildContext context) {
    _notificationProvider = Provider.of<NotificationProvider>(context);

    Color lockColour = const Color(0xff00B6F1);
    Image lockImage = Image(
      image: const AssetImage("assets/buttons/lock_unlock.png"),
      height: 3.h,
      fit: BoxFit.fitWidth,
    );

    if(_unlock == false){
      lockImage = Image(
        image: const AssetImage("assets/buttons/lock_lock.png"),
        height: 3.h,
        fit: BoxFit.fitWidth,
      );
      lockColour = const Color(0xff00B6F1);
    }else if(_unlock == true){

      lockImage = Image(
        image: AssetImage("assets/buttons/lock_unlock.png"),
        height: 8.h,
        fit: BoxFit.fitWidth,
      );
      lockColour = const Color(0xff404E53);
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Text(
            _title,
            style: TextStyle(
                fontFamily:'Raleway-Bold',fontSize: 21.sp),
          ),
          centerTitle: false,
          actions: <Widget>[
            if (currentIndex == 0) ... [
            Align(
            child: Container(
              height: 6.8.h,
              width: 6.8.h,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(10),
              )),
              child: IconButton(
                iconSize: 25,

                icon: ThemeChangeNotifier().isDarkMode(context) == true ?
                const Image(
                  image: AssetImage(
                      "assets/buttons/user_white.png"),
                  height: 17.0,
                ) :
                const Image(
                  image: AssetImage(
                      "assets/buttons/user.png"),
                  height: 17.0,
                ),

                tooltip: 'User Profile',
                onPressed: () {
                  changeToUserProfileScreen(context);

                  //    ScaffoldMessenger.of(context).showSnackBar(
                  //        const SnackBar(content: Text('User Profile')));
                },
              ),
            ),
        ),

            const SizedBox(
              width: 20,
            ),

            Align(
            child:Container(
              height: 6.8.h,
              width: 6.8.h,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white.withOpacity(0.3),
                  borderRadius: const BorderRadius.all(Radius.circular(10),
                  )),
              child: IconButton(
                iconSize: 25,
                icon: ThemeChangeNotifier().isDarkMode(context) == true ?
                    _notificationProvider.isReadAll == true?
                const Image(
                  image: AssetImage(
                      "assets/buttons/notification_white.png"),
                  height: 17.0,
                ) :  const Icon(Icons.notifications_active_outlined
                    )
                        :
                    _notificationProvider.isReadAll == true?
                const Image(
                  image: AssetImage(
                      "assets/buttons/notification.png"),
                  height: 17.0,
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
                  height: 6.3.h,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/home_selected.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
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
                  height: 6.3.h,
                ),
                activeIcon: Container(
                  child: const Image(
                    image: AssetImage("assets/buttons/setting_selected.png"),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: 6.3.h,
                ),
                tooltip: 'Settings',
                label: '',
              ),
            ],
          ),
        ));
  }
}

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/profile/user_profile.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/user_home_page/free_plan/free_plan.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:evie_test/screen/user_home_bluetooth.dart';
import 'package:evie_test/screen/user_home_setting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../my_account/my_account.dart';

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


  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    FreePlan(),
    UserHomeBluetooth(),
    TestBle(),
    MyAccount(),
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(

        //Body should change when bottom navigation bar state change
        body: screen[currentIndex],

        bottomNavigationBar: BottomAppBar(

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
                      _title = '';
                    }
                    break;
                  case 3:
                    {
                      _title = '';
                    }
                    break;
                  case 4:
                    {
                      _title = '';
                    }
                    break;
                }
              });
            },

            items: [
              BottomNavigationBarItem(
                icon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/home.svg",
                  ),
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                activeIcon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/home_selected.svg",
                  ),
        //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                tooltip: 'User Profile',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/statistic.svg",
                  ),
                  //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                activeIcon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/statistic_selected.svg",
                  ),
                  //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                tooltip: 'User Profile',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/bike.svg",
                  ),
                  //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                activeIcon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/bike_selected.svg",
                  ),
                  //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                tooltip: 'User Profile',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/notification.svg",
                  ),
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                activeIcon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/notification.svg",
                  ),
           //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                tooltip: 'User',
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/user.svg",
                  ),
                  //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                activeIcon: Container(
                  child: SvgPicture.asset(
                    "assets/buttons/user_selected.svg",
                  ),
                  //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  height: EvieLength.bottom_bar_icon_height,
                ),
                tooltip: 'User',
                label: '',
              ),
            ],
          ),
        ));
  }
}

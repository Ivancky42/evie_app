import 'package:evie_test/api/length.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/user_home_page/free_plan/free_plan.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../my_account/my_account.dart';
import '../my_bike/admin_free_plan/admin_free_plan.dart';
import '../my_bike/admin_paid_plan/admin_paid_plan.dart';
import '../my_bike/navigate_plan_page.dart';
import '../my_bike/user_bike/user_bike.dart';

///User default home page when login condition is true

class UserHomePage extends StatefulWidget {
  final int? currentIndex;
  const UserHomePage(this.currentIndex, {Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  //Current index is 0, init state body[screen] is user home page general screen
  late int currentIndex;

  ///Appbar title
  String _title = '';

  @override
  void initState() {
    currentIndex = widget.currentIndex ?? 0;
  }

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    UserHomeGeneral(),
    TestBle(),
    NavigatePlanPage(),
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

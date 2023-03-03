import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/test_ble.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/free_plan/free_plan.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../feeds/feeds.dart';
import '../my_account/account/my_account.dart';
import '../../abandon/user_notification.dart';

///User default home page when login condition is true

class UserHomePage extends StatefulWidget {
  final int? currentIndex;
  const UserHomePage(this.currentIndex, {Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  ///Current index is 0, init state body[screen] is user home page general screen
  late int currentIndex;

  ///Appbar title
  String _title = '';

  @override
  void initState() {
    currentIndex = widget.currentIndex ?? 0;
  }

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    const UserHomeGeneral(),
    const TripHistory(),
    const Feeds(),
    const MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        //Body should change when bottom navigation bar state change
        body: screen[currentIndex],

        bottomNavigationBar: BottomAppBar(
         // height: 80.h,
          child: BottomNavigationBar(
            //For disable animation
            //type: BottomNavigationBarType.fixed,
         //   iconSize: 15,
            //selectedItemColor: Color(0xff69489D),
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/home.svg",
                    ),
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),

                activeIcon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/home_selected.svg",
                    ),
        //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),
                tooltip: 'User Profile',
                label: '',
              ),


              BottomNavigationBarItem(
                icon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
       //          alignment: Alignment(0,-1.0),
                    child: SvgPicture.asset(
                      "assets/buttons/statistic.svg",
                    ),
                    //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),

                activeIcon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
      //            alignment: Alignment(0,-1.0),
                    child: SvgPicture.asset(
                      "assets/buttons/statistic_selected.svg",
                    ),
                    //          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),
                tooltip: 'User Profile',
                label: '',
              ),


              BottomNavigationBarItem(
                icon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/notification.svg",
                    ),
          //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),

                activeIcon:Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/notification_selected.svg",
                    ),
           //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),
                tooltip: 'User',
                label: '',
              ),


              BottomNavigationBarItem(
                icon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/user.svg",
                    ),
                    //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),

                activeIcon: Transform.translate(
                  offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                  child: Container(
                    child: SvgPicture.asset(
                      "assets/buttons/user_selected.svg",
                    ),
                    //       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                    height: EvieLength.bottom_bar_icon_height,
                  ),
                ),
                tooltip: 'User',
                label: '',
              ),


            ],
          ),
        ));
  }
}

// class CustomBottomNavigationBarItem extends BottomNavigationBarItem {
//   CustomBottomNavigationBarItem({required Widget icon, required Widget title})
//       : super(
//     icon: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [icon],
//     ),
//   );
// }
//
// CustomBottomNavigationBarItem(
// icon: Icon(Icons.home),
// title: Text('Home'),
// ),
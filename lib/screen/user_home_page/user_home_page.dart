import 'dart:io';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../test/test.dart';
import '../feeds/feeds.dart';
import '../feeds/feeds2.dart';
import '../my_account/account/my_account.dart';
import '../../abandon/user_notification.dart';


class UserHomePage extends StatefulWidget {
  final int? currentIndex;
  const UserHomePage(this.currentIndex, {Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  ///Current index is 0, init state body[screen] is user home page general screen
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.currentIndex ?? 0;
  }

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    const UserHomeGeneral(),
    const Feeds2(),
    //Test(),
    const MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: EvieColors.transparent,
      body: Builder(
        builder: (context) =>
            CupertinoPageScaffold(
              //backgroundColor: Colors.red,
              child: Scaffold(
                body: screen[currentIndex],
                bottomNavigationBar: BottomAppBar(
                  color: EvieColors.dividerWhite,
                  height:  Platform.isIOS ? 50.h : 60.h,
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
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
                          backgroundColor: EvieColors.dividerWhite,
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
                          tooltip: 'Home',
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
                          tooltip: 'Feeds',
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
                  ),
                ) ,
              ),
            ),
      ),
    );
  }
}

// class CustomBottomNavigationBarItem extends BottomNavigationBarItem {
//   CustomBottomNavigationBarItem({required Widget icon, required Widget title}) : super(
//     icon: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [icon],
//     ),
//   );
// }
import 'dart:io';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/screen/user_home_general.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../../test/test.dart';
import '../feeds/feeds.dart';
import '../my_account/account/my_account.dart';


class UserHomePage extends StatefulWidget {
  final int? currentIndex;
  const UserHomePage(this.currentIndex, {Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  ///Current index is 0, init state body[screen] is user home page general screen
  late int currentIndex;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    currentIndex = widget.currentIndex ?? 0;
    _notificationProvider = context.read<NotificationProvider>();
  }

  ///Body Screen navigation by bottom navigation bar
  final screen = [
    const UserHomeGeneral(),
    const Feeds(),
    const MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    _notificationProvider = context.watch<NotificationProvider>();
    return Scaffold(
      body: screen[currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: EvieColors.dividerWhite,
        height:  Platform.isIOS ? 50.h : 60.h,
        child: Container(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: BottomNavigationBar(
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
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.67.h),
                      child: Container(
                        child: SvgPicture.asset(
                          "assets/buttons/home.svg",
                        ),
                        //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        height: EvieLength.bottom_bar_icon_height,
                      ),
                    )
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
                  tooltip: 'My Bike',
                  label: 'My Bike',
                ),


                BottomNavigationBarItem(
                  icon: _notificationProvider.isReadAll ?
                  Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.67.h),
                      child: Container(
                        child: SvgPicture.asset(
                          "assets/buttons/notification.svg",
                        ),
                        height: EvieLength.bottom_bar_icon_height,
                      ),
                    )
                  ) : Transform.translate(
                      offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.67.h),
                        child: Container(
                          child: SvgPicture.asset(
                            "assets/buttons/notification_with_dot.svg",
                          ),
                          height: EvieLength.bottom_bar_icon_height,
                        ),
                      )
                  ),

                  activeIcon: _notificationProvider.isReadAll ?
                  Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Stack(
                      children: [
                        Container(
                          child: SvgPicture.asset(
                            "assets/buttons/notification_selected.svg",
                          ),
                          height: EvieLength.bottom_bar_icon_height,
                        ),
                      ],
                    )
                  ) :
                  Transform.translate(
                      offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                      child: Stack(
                        children: [
                          Container(
                            child: SvgPicture.asset(
                              "assets/buttons/notification_selected_with_dot.svg",
                            ),
                            height: EvieLength.bottom_bar_icon_height,
                          ),
                        ],
                      )
                  ),
                  tooltip: 'Feeds',
                  label: 'Feeds',
                ),


                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.67.h),
                      child: Container(
                        child: SvgPicture.asset(
                          "assets/buttons/user.svg",
                        ),
                        //        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        height: EvieLength.bottom_bar_icon_height,
                      ),
                    )
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
                  tooltip: 'My Account',
                  label: 'My Account',
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFFC4C4C4), // Set your desired border color
                width: 0.5, // Set the border width
              ),
            ),
          ),
        )
      ) ,
    );
  }
}
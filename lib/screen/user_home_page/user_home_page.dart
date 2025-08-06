
import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../api/colours.dart';
import '../feeds/feeds.dart';
import '../my_account/account/my_account.dart';
import '../user_home_general_v2.dart';


class UserHomePage extends StatefulWidget {
  final int? currentIndex;
  const UserHomePage(this.currentIndex, {super.key});

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
    //const UserHomeGeneral(),
    const UserHomeGeneralV2(),
    const Feeds(),
    const MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    _notificationProvider = context.watch<NotificationProvider>();
    return Scaffold(
      body: screen[currentIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          //height: Platform.isIOS ? 98.h : 60.h,
          child: BottomNavigationBar(
            elevation: 100.0,
            backgroundColor:EvieColors.dividerWhite,
            selectedFontSize: 12.0,
            currentIndex: currentIndex,
            selectedItemColor: EvieColors.primaryColor,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                backgroundColor: EvieColors.dividerWhite,
                icon:Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/home.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ),
                activeIcon: Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.w,
                              //color: Colors.red,
                              child: SvgPicture.asset(
                                "assets/buttons/on_selected.svg",
                                //width: 10.w,
                                height: 2.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/home_selected.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ),
                tooltip: 'My Bike',
                label: 'My Bike',
              ),


              BottomNavigationBarItem(
                icon: _notificationProvider.isReadAll ?
                Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/notification.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ) : Transform.translate(
                    offset: Offset(0, -3),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/buttons/notification_with_dot.svg",
                              height: 24.h,
                            ),
                          ],
                        )
                    )
                ),

                activeIcon: _notificationProvider.isReadAll ?
                Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.w,
                              //color: Colors.red,
                              child: SvgPicture.asset(
                                "assets/buttons/on_selected.svg",
                                //width: 10.w,
                                height: 2.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/notification_selected.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ) :
                Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.w,
                              //color: Colors.red,
                              child: SvgPicture.asset(
                                "assets/buttons/on_selected.svg",
                                //width: 10.w,
                                height: 2.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/notification_selected_with_dot.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ),
                tooltip: 'Feeds',
                label: 'Feeds',
              ),


              BottomNavigationBarItem(
                backgroundColor: EvieColors.dividerWhite,
                icon:Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/user.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ),
                activeIcon: Transform.translate(
                    offset: Offset(0, EvieLength.bottom_bar_icon_offset),
                    child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.w,
                              //color: Colors.red,
                              child: SvgPicture.asset(
                                "assets/buttons/on_selected.svg",
                                //width: 10.w,
                                height: 2.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SvgPicture.asset(
                              "assets/buttons/user_selected.svg",
                              height: 22.h,
                            ),
                          ],
                        )
                    )
                ),
                tooltip: 'My Account',
                label: 'My Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
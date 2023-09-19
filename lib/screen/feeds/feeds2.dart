import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/enumerate.dart';
import '../../api/filter.dart';
import '../../api/fonts.dart';
import '../../api/sheet.dart';
import 'feeds_container.dart';

///User profile page with user account information

class Feeds2 extends StatefulWidget {
  const Feeds2({Key? key}) : super(key: key);

  @override
  _Feeds2State createState() => _Feeds2State();
}

class _Feeds2State extends State<Feeds2> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  @override
  void dispose() {

    ///Change isRead status to true by exit this page
    for (var element in _notificationProvider.notificationList.values) {
      if(element.isRead == false){
        _notificationProvider.updateIsReadStatus(element.notificationId);
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showQuitApp() as bool?;
        return exitApp ?? false;
      },
      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Feeds",
                        style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                      ),
                      IconButton(
                          onPressed: (){
                            showActionListSheet(context, [ActionList.clearFeed],);
                          },
                          icon:  SvgPicture.asset(
                            "assets/buttons/more.svg",
                          ))
                    ],
                  ),
                ),
              ),


              Expanded(
                child: Container(
                  child: _notificationProvider.notificationList.isNotEmpty ?
                  ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _notificationProvider.notificationList.length,
                    itemBuilder: (context, index) {

                      return FeedsContainer(index: index);

                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(height: 1.5.h,);
                    },
                  ) : Padding(
                    padding:  EdgeInsets.only(top:180.h ),
                    child: Center(
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/images/bike_email.svg",
                          ),
                          SizedBox(
                            height: 60.h,
                          ),
                          Text(
                            "You're all caught up!",
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

}

import 'dart:collection';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';


class ShareBike extends StatefulWidget{
  const ShareBike({ Key? key }) : super(key: key);
  @override
  _ShareBikeState createState() => _ShareBikeState();
}

class _ShareBikeState extends State<ShareBike> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);


     return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Share Bike',
          onPressed: () {
            changeToNavigatePlanScreen(context);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: Text(
                    "Bike Sharing with your love one",
                    style: EvieTextStyles.h2,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                  child: Text(
                  "Sharing is caring, and now you can share your bike with the ones you love! "
                      "Bike sharing is a great way to bond together. Get started now and make memories that will last a lifetime!",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,22.h),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/share_bike.svg",
                      height: 287.89.h,
                      width: 262.07.w,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,0.h),
                    child: Text(
                  "You don't have share bike with any rider yet.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Share Bike",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {
                    changeToShareBikeInvitationScreen(context);
                  },
                ),
              ),
            ),

          ],
        ),),
    );
  }

}
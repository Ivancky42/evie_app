import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/length.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../my_account/my_account_widget.dart';



///User profile page with user account information

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
        appBar: AccountPageAppbar(
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
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 106.h),
                  child: Text(
                    "You are able to share your EVIE bike with your love one by sending them email invitation... copy need to change.. sending email = ask to register EVIE, "
                        "but won't auto add bike, need to resend invitation.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,22.h),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/mention_amigo.svg",
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,0.h),
                    child: Text(
                  "You don't have any other user sharing this bike together yet.",
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    changeToShareBikeInvitationScreen(context);
                  },
                ),
              ),
            ),

            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
            //     child: SizedBox(
            //       width: double.infinity,
            //       child: TextButton(
            //         child: Text(
            //           "Forgot Password",
            //           softWrap: false,
            //           style: TextStyle(fontSize: 12.sp,color: EvieColors.PrimaryColor,decoration: TextDecoration.underline,),
            //         ),
            //         onPressed: () {
            //
            //         },
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),),
    );
  }

}
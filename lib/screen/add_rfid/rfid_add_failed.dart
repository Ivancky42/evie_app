import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_textform.dart';
import '../user_home_page/user_home_page.dart';

///User profile page with user account information

class RFIDAddFailed extends StatefulWidget {
  const RFIDAddFailed({Key? key}) : super(key: key);

  @override
  _RFIDAddFailedState createState() => _RFIDAddFailedState();
}

class _RFIDAddFailedState extends State<RFIDAddFailed> {

  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(

        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 76.h, 16.w,4.h),
                  child: Text(
                    "Oops! Something went wrong",
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 106.h),
                  child: Text(
                    "Some description",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,221.h),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/mention_amigo.svg",

                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                  onPressed: () {
      changeToAddNewRFIDScreen(context);
                  },
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(150.w,25.h,150.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Cancel add new RFID Card",style: TextStyle(fontSize: 12.sp,color: EvieColors.PrimaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                 changeToNavigatePlanScreen(context);
                    },
                  ),
                ),
              ),
            ),

          ],
        ),),
    );
  }
}

import 'dart:io';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';


import '../../api/colours.dart';
import '../../api/navigator.dart';

///User profile page with user account information

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
            child: Container(
              child: Text(
                "My Account",
                style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
              ),
            ),
          ),
          Container(
            height: 96.h,
            child: Row(
              children: [
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(27.7.w, 14.67.h, 18.67.w, 14.67.h),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      //imageUrl: document['profileIMG'],
                      imageUrl: _currentUserProvider.currentUserModel != null ? _currentUserProvider.currentUserModel!.profileIMG : "",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 66.67.h,
                      height: 66.67.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUserProvider.currentUserModel?.name ?? "",
                      style:EvieTextStyles.headline.copyWith(color:EvieColors.lightBlack),
                    ),
                    Text(
                      _currentUserProvider.currentUserModel?.email ?? "",
                      style:EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                    ),

                  ],
                )
              ],
            ),
          ),
          Divider(
            thickness: 0.5.h,
            color: EvieColors.darkWhite,
            height: 0,
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AccountPageContainer(
                      content: "Edit Personal Info",
                      onPress: () {changeToEditProfile(context);},
                      trailingImage: "assets/buttons/next.svg"),
                  const AccountPageDivider(),
                  AccountPageContainer(
                      content: "My Garage",
                      onPress: () {
                        changeToMyGarageScreen(context);
                        /// my garage, bike setting  = navigate plan
                      //  changeToNavigatePlanScreen(context);
                      },
                      trailingImage: "assets/buttons/next.svg"),
                  Divider(
                    thickness: 11.h,
                    color: EvieColors.dividerWhite,
                  ),
                  AccountPageContainer(
                      content: "Push Notification",
                      onPress: () {
                        changeToPushNotification(context);
                      },
                      trailingImage: "assets/buttons/next.svg"),
                  const AccountPageDivider(),
                  AccountPageContainer(
                      content: "Email Notification",
                      onPress: () {},
                      trailingImage: "assets/buttons/next.svg"),
                  const AccountPageDivider(),
                  AccountPageContainer(
                      content: "Display Setting",
                      onPress: () {},
                      trailingImage: "assets/buttons/next.svg"),
                  Divider(
                    thickness: 11.h,
                    color: EvieColors.dividerWhite,
                  ),
                  AccountPageContainer(
                      content: "Help Center",
                      onPress: () {},
                      trailingImage: "assets/buttons/external_link.svg"),
                  const AccountPageDivider(),
                  AccountPageContainer(
                      content: "Privacy Policy",
                      onPress: () {},
                      trailingImage: "assets/buttons/external_link.svg"),
                 const AccountPageDivider(),
                  AccountPageContainer(
                      content: "Terms & Conditions",
                      onPress: () {},
                      trailingImage: "assets/buttons/external_link.svg"),
                  const AccountPageDivider(),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 24.h, bottom: 10.h),
                    child: Container(
                      height: 45.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(
                          "Logout",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                        ),
                        onPressed: () async {
                          SmartDialog.showLoading();
                          try {
                            await _bikeProvider.clear();
                            await _authProvider.signOut(context).then((result) {
                              if (result == true) {
                                SmartDialog.dismiss();
                                // _authProvider.clear();
                                changeToWelcomeScreen(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Signed out'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                SmartDialog.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error, Try Again'),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            });
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                          elevation: 0.0,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
                    child: Container(
                      height: 45.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(
                          "Revoke Account",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                        ),
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                          elevation: 0.0,
                          backgroundColor: Colors.transparent,

                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Evie v0.0.1",
                            style: EvieTextStyles.body12.copyWith(color:EvieColors.darkWhite),
                          ),
                          Text(
                            "Copyright 2022 by Beno Inc",
                            style: EvieTextStyles.body12.copyWith(color:EvieColors.darkWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(
          //       left: 16.w, right: 16.w, top: 24.h, bottom: 10.h),
          //   child: Container(
          //     height: 45.h,
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       child: Text(
          //         "Logout",
          //         style: TextStyle(
          //           fontSize: 17.sp,
          //           color: Color(0xff7A7A79), fontWeight: FontWeight.w700
          //         ),
          //       ),
          //       onPressed: () async {
          //         SmartDialog.showLoading();
          //         try {
          //           await _bikeProvider.clear();
          //           await _authProvider.signOut(context).then((result) {
          //             if (result == true) {
          //               SmartDialog.dismiss();
          //               // _authProvider.clear();
          //
          //               changeToWelcomeScreen(context);
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                   content: Text('Signed out'),
          //                   duration: Duration(seconds: 2),
          //                 ),
          //               );
          //             } else {
          //               SmartDialog.dismiss();
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                   content: Text('Error, Try Again'),
          //                   duration: Duration(seconds: 4),
          //                 ),
          //               );
          //             }
          //           });
          //         } catch (e) {
          //           debugPrint(e.toString());
          //         }
          //       },
          //       style: ElevatedButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10.0),
          //             side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
          //         elevation: 0.0,
          //         backgroundColor: Colors.transparent,
          //
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(
          //       left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
          //   child: Container(
          //     height: 45.h,
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       child: Text(
          //         "Revoke Account",
          //         style: TextStyle(
          //             fontSize: 17.sp,
          //             color: Color(0xff7A7A79),
          //             fontWeight: FontWeight.w700),
          //       ),
          //       onPressed: () {
          //       },
          //       style: ElevatedButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10.0),
          //             side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
          //         elevation: 0.0,
          //         backgroundColor: Colors.transparent,
          //
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 14.h),
          //   child: Center(
          //     child: Column(
          //       children: [
          //         Text(
          //           "Evie v0.0.1",
          //           style: TextStyle(
          //               fontSize: 12.sp,
          //             color: Color(0xff8E8E8E),
          //           ),
          //         ),
          //         Text(
          //           "Copyright 2022 by Beno Inc",
          //           style: TextStyle(
          //             fontSize: 12.sp,
          //             color: Color(0xff8E8E8E),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      )),
    );
  }
}

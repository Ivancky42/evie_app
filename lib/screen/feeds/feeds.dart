import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/widgets/feeds_list_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/filter.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/model/bike_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/setting_provider.dart';
import '../../api/snackbar.dart';
import '../../widgets/evie_single_button_dialog.dart';

///User profile page with user account information

class Feeds extends StatefulWidget {
  const Feeds({Key? key}) : super(key: key);

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  late CurrentUserProvider _currentUserProvider;
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  LinkedHashMap selectedBikeList = LinkedHashMap<String, BikeModel>();

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
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
                  child: Text(
                    "Feeds",
                    style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                    child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _bikeProvider.userBikeList.length,
                    itemBuilder: (context, index) {

                      if(_bikeProvider.userBikePlans.isNotEmpty) {
                        if (_bikeProvider.userBikePlans.values.elementAt(index)?.periodEnd.toDate() != null) {
                          if (calculateDateDifferenceFromNow(
                              _bikeProvider.userBikePlans.values.elementAt(index).periodEnd.toDate()) >= 0) {
                            ///if connection lost
                            if (_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].location.isConnected == false) {
                              return FeedsListTile(
                                  image: "assets/buttons/bike_security_warning.svg",
                                  title: "Connection Lost",
                                  subtitle: "${_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].deviceName} has lost connection. Last update was time. "
                                      "${_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].deviceName} will be back online after...",
                                  isDanger: false,
                                  date: _bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].lastUpdated.toDate(),
                                  onPressRight: () async {
                                    await _bikeProvider.changeBikeUsingIMEI(
                                        _bikeProvider.userBikePlans.keys.elementAt(index));
                                    changeToUserHomePageScreen(context);
                                  });
                            } else {
                              ///if condition == danger or warning
                              if (_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].location.status == "danger") {
                                return FeedsListTile(
                                    image: "assets/buttons/bike_security_danger.svg",
                                    title: "Theft Attempt Alert",
                                    subtitle: "${_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].deviceName}, Your bike is under threat! Someone is trying to steal your bike!",
                                    isDanger: true,
                                    date: _bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].lastUpdated.toDate(),
                                    onPressRight: () async {
                                      await _bikeProvider.changeBikeUsingIMEI(
                                          _bikeProvider.userBikePlans.keys.elementAt(index));
                                      changeToUserHomePageScreen(context);
                                    });
                              } else if (_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].location.status == "warning") {
                                return FeedsListTile(
                                    image: "assets/buttons/bike_security_warning.svg",
                                    title: "Movement Detected",
                                    subtitle: "${_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].deviceName}, Movement were detected at Malaysia",
                                    isDanger: false,
                                    date: _bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].lastUpdated.toDate(),
                                    onPressRight: () async {
                                      await _bikeProvider.changeBikeUsingIMEI(
                                          _bikeProvider.userBikePlans.keys.elementAt(index));
                                      changeToUserHomePageScreen(context);
                                    });
                              } else if (_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].location.status == "fall") {
                                return FeedsListTile(
                                    image: "assets/buttons/bike_security_warning.svg",
                                    title: "Fall Detected",
                                    subtitle: "${_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].deviceName}, Fall detect detected when detection detecting detect",
                                    isDanger: false,
                                    date: _bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].lastUpdated.toDate(),
                                    onPressRight: () async {
                                      await _bikeProvider.changeBikeUsingIMEI(
                                          _bikeProvider.userBikePlans.keys.elementAt(index));
                                      changeToUserHomePageScreen(context);
                                    });
                              } else if (_bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].location.status == "crash") {
                                return FeedsListTile(
                                    image: "assets/buttons/bike_security_danger.svg",
                                    title: "Crash Alert",
                                    subtitle: "EVIE detected that ${_currentUserProvider.currentUserModel!.name} has fallen from bike... "
                                        "To checkout where is ${_currentUserProvider.currentUserModel!.name}, click on \"Track My Bike\"",
                                    isDanger: true,
                                    date: _bikeProvider.userBikeDetails[_bikeProvider.userBikePlans.keys.elementAt(index)].lastUpdated.toDate(),
                                    onPressRight: () async {
                                      await _bikeProvider.changeBikeUsingIMEI (
                                          _bikeProvider.userBikePlans.keys.elementAt(index));
                                      changeToUserHomePageScreen(context);
                                    });
                              } else {
                                return Container();
                              }
                            }
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      }
                    }, separatorBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                      //    Divider(height: 1.5.h,),
                        ],
                      );
                    },
                    ),
                  ),

                    SizedBox(
                      height: 10.h,
                    ),

                    Divider(height: 1.5.h,),

                    Container(
                      child: _notificationProvider.notificationList.isNotEmpty || EvieFilter.isAllBikeSafe(_bikeProvider.userBikeDetails) != true ?
                      ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _notificationProvider.notificationList.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: UniqueKey(),
                            endActionPane:  ActionPane(
                              extentRatio: 0.3,
                              motion: const StretchMotion(),
                              // dismissible: DismissiblePane(
                              //
                              //   ///Confirm dismiss only when decline
                              //   // confirmDismiss: () async {
                              //   //   return await showDialog(
                              //   //     context: context,
                              //   //     builder: (BuildContext context) {
                              //   //           return EvieDoubleButtonDialog(
                              //   //               title: "Are you sure",
                              //   //               childContent: const Text("sure ma"),
                              //   //               leftContent: "Cancel",
                              //   //               rightContent: "ok",
                              //   //               onPressedLeft: (){Navigator.of(context).pop(false);},
                              //   //               onPressedRight: (){Navigator.of(context).pop(true);});
                              //   //     },
                              //   //   );
                              //   // },
                              //
                              //   onDismissed: () async {
                              //     if(_notificationProvider.notificationList.values.elementAt(index).status == "pending"){
                              //       decline(index);
                              //     }else{
                              //       var result = await _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                              //       if(!result){
                              //         showDeleteNotificationFailed();
                              //       }
                              //     }
                              //   },
                              // ),
                              children: [
                                SlidableAction(
                                  spacing:10,
                                  onPressed: (context) async{
                                    if(_notificationProvider.notificationList.values.elementAt(index).status == "userPending"){
                                      decline(index);
                                    }else {
                                      var result = await _notificationProvider.deleteNotification(
                                          _notificationProvider.notificationList.keys.elementAt(index));
                                      if (result) {
                                        //showDeleteNotificationSuccess();
                                      } else {
                                        showDeleteNotificationFailed();
                                      }
                                    }
                                  },
                                  backgroundColor: EvieColors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),

                            child: GestureDetector(
                                onTap: () async {
                                  _notificationProvider.updateIsReadStatus(_notificationProvider
                                      .notificationList.keys
                                      .elementAt(index));
                                },

                                child: Container(
                                  color: _notificationProvider
                                      .notificationList.values
                                      .elementAt(index)
                                      .isRead! == false ? Color(0xffE6E2F6) : Colors.transparent,
                                  child: Padding(
                                    padding:  EdgeInsets.only(top: 14.h, bottom: 14.h),
                                    child: ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width:260.w,
                                              child: Text(_notificationProvider
                                                  .notificationList.values
                                                  .elementAt(index)
                                                  .title!, style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),),
                                            ),

                                            Text(calculateTimeAgo(_notificationProvider.notificationList.values.elementAt(index).created!.toDate()),
                                              style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),),
                                          ],
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional.centerStart,
                                              child: Text(
                                                "${_notificationProvider.notificationList.values.elementAt(index).body!}",
                                                //                  "\n\n${_notificationProvider.notificationList.values.elementAt(index).created!.toDate()}",
                                                style: TextStyle(
                                                  color: SettingProvider()
                                                      .isDarkMode(context) ==
                                                      true
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),


                                              ),
                                            ),

                                            Visibility(
                                              ///type == shareBike, status == pending
                                              visible: _notificationProvider.notificationList.values.elementAt(index).status == "userPending",
                                              child: Row(
                                                children: [
                                                  Align(
                                                      alignment: AlignmentDirectional.bottomStart,
                                                      child: EvieButton_ReversedColor(
                                                          onPressed: (){

                                                            decline(index);

                                                          },
                                                          child: Text(
                                                            "Decline",
                                                            style: TextStyle(fontSize: 17.sp,
                                                                color: EvieColors.primaryColor),
                                                          ),
                                                          height: 36.h,
                                                          width: 169.w)
                                                  ),

                                                  Align(
                                                      alignment: AlignmentDirectional.bottomEnd,
                                                      child: EvieButton(
                                                          onPressed: () async {
                                                            SmartDialog.show(
                                                                backDismiss: false,
                                                                widget: Container(
                                                                    color: EvieColors.grayishWhite,
                                                                    width: double.infinity,
                                                                    height: double.infinity,
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                        height: 157.h,
                                                                        width: 279.h,
                                                                          child: Lottie.asset(
                                                                              'assets/animations/add-bike.json',
                                                                          repeat: true,
                                                                            height: 157.h,
                                                                            width: 279.h,
                                                                              fit: BoxFit.cover
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 60.h,),
                                                                        Text("Accepting invitation and adding bike...", style:EvieTextStyles.body16.copyWith(color: EvieColors.darkGray),)
                                                                      ],
                                                                    )
                                                                ));

                                                            StreamSubscription? currentSubscription;
                                                            currentSubscription = _bikeProvider.acceptSharedBike(
                                                                _notificationProvider.notificationList.values.elementAt(index).deviceIMEI!,
                                                                _currentUserProvider.currentUserModel!.uid)
                                                                .listen((uploadStatus) async {
                                                              if(uploadStatus == UploadFirestoreResult.success){
                                                                SmartDialog.dismiss();
                                                                _notificationProvider.updateUserNotificationSharedBikeStatus(
                                                                    _notificationProvider.notificationList.keys.elementAt(index));

                                                                showBikeAddSuccessfulToast(context);

                                                                changeToUserHomePageScreen(context);
                                                                for (var element in _bikeProvider.userBikeNotificationList) {
                                                                  await _notificationProvider.subscribeToTopic(
                                                                      "${_bikeProvider.currentBikeModel!.deviceIMEI}$element");
                                                                }

                                                                currentSubscription?.cancel();
                                                              } else if(uploadStatus == UploadFirestoreResult.failed) {
                                                                SmartDialog.dismiss();
                                                                SmartDialog.show(
                                                                    backDismiss: false,
                                                                    widget: EvieSingleButtonDialog(
                                                                        title: "Error",
                                                                        content: "Try again",
                                                                        rightContent: "OK",
                                                                        onPressedRight: () async {
                                                                          SmartDialog.dismiss();
                                                                        }));
                                                              }else{};
                                                            },
                                                            );


                                                            // _bikeProvider
                                                            //     .acceptSharedBikeStatus(
                                                            //     notificationModel.deviceIMEI!, _currentUserProvider.currentUserModel!.uid)
                                                            //     .then((result) {
                                                            //   if (result == true) {
                                                            //     SmartDialog.dismiss();
                                                            //     _notificationProvider
                                                            //         .updateUserNotificationSharedBikeStatus(key);
                                                            //     SmartDialog.show(
                                                            //         widget: EvieSingleButtonDialogCupertino(
                                                            //             title: "Success",
                                                            //             content: "Bike added",
                                                            //             rightContent: "OK",
                                                            //             onPressedRight: () {
                                                            //               SmartDialog.dismiss();
                                                            //             }));
                                                            //   } else {
                                                            //     SmartDialog.dismiss();
                                                            //     SmartDialog.show(
                                                            //         widget: EvieSingleButtonDialogCupertino(
                                                            //             title: "Error",
                                                            //             content: "Bike not added, try again",
                                                            //             rightContent: "OK",
                                                            //             onPressedRight: () {
                                                            //               SmartDialog.dismiss();
                                                            //             }));
                                                            //   }
                                                            // });

                                                          },
                                                          child: Text(
                                                            "OK",
                                                            style: TextStyle(fontSize: 17.sp,
                                                              color: EvieColors.grayishWhite,),
                                                          ),
                                                          height: 36.h,
                                                          width: 169.w)
                                                  ),

                                                ],
                                              ),
                                            ),

                                          ],
                                        )),
                                  ),
                                )),
                          );
                        },
                        separatorBuilder:
                            (BuildContext context, int index) {
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
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

  decline(int index){
    SmartDialog.show(
        widget: EvieDoubleButtonDialog(
          title: "Are you sure you want to decline?",
          childContent: Text('Are you sure you want to decline?'),
          leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
          rightContent: "Yes",
          onPressedRight: () async {
            SmartDialog.dismiss();
            SmartDialog.showLoading();
            StreamSubscription? currentSubscription;

            currentSubscription = _bikeProvider.declineSharedBike(
                _notificationProvider.notificationList.values.elementAt(index).deviceIMEI!,
                _notificationProvider.notificationList.values.elementAt(index).notificationId).listen((cancelStatus) {
              if(cancelStatus == UploadFirestoreResult.success){

                SmartDialog.dismiss(status: SmartStatus.loading);
                SmartDialog.show(
                    keepSingle: true,
                    widget: EvieSingleButtonDialog(
                        title: "Success",
                        content: "You declined the invitation",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(cancelStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialog(
                        title: "Not success",
                        content: "Try again",
                        rightContent: "Close",
                        onPressedRight: ()=>SmartDialog.dismiss()
                    ));
              }else{}

            },
            );

          },
        ));
  }
}

import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/enumerate.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/model/bike_model.dart';
import '../../api/model/notification_model.dart';
import '../../api/navigator.dart';
import '../../api/provider/setting_provider.dart';
import '../../api/provider/shared_pref_provider.dart';
import '../../api/sheet.dart';
import '../../api/snackbar.dart';
import '../../bluetooth/modelResult.dart';
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
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  late SharedPreferenceProvider _sharedPreferenceProvider;
  String? isFirstFeedRequest;

  LinkedHashMap selectedBikeList = LinkedHashMap<String, BikeModel>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //requestNotificationPermission();
    _sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    isFirstFeedRequest = _sharedPreferenceProvider.feed;

    if (isFirstFeedRequest == 'null') {
      _sharedPreferenceProvider.setIsFirstFeedRequest('done');
      Future.delayed(Duration.zero).then((value) {
        SmartDialog.show(
          widget: FeedFirstDialog(),
        );
      });
    }
  }

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

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      // Notification permission is granted
      //print('Notification permission is granted');
    } else {
      Future.delayed(Duration.zero).then((value) {
        SmartDialog.show(
          keepSingle: true,
          widget: FeedFirstDialog(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    requestNotificationPermission();

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
                padding: EdgeInsets.fromLTRB(16.w, 51.h, 16.w, 0.h),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Feeds",
                        style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                      ),
                      _notificationProvider.notificationList.isNotEmpty ?
                      GestureDetector(
                          onTap: (){
                            showActionListSheet(context, [ActionList.clearFeed],);
                          },
                          child: Container(
                            child:  SvgPicture.asset(
                              "assets/buttons/more.svg", width: 36.w, height: 36.w,
                            ),
                          )
                      )
                      : Container(),
                    ],
                  ),
                ),
              ),

              _notificationProvider.notificationList.isEmpty ?
              Padding(
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
              ) :
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _notificationProvider.notificationList.length,
                      itemBuilder: (context, index) {
                        NotificationModel notificationModel = _notificationProvider.notificationList.values.elementAt(index);
                        switch (notificationModel.status) {
                          case 'userPending':
                            return Slidable(
                              key: UniqueKey(),
                              endActionPane: ActionPane(
                                extentRatio: 0.3,
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    spacing: 10,
                                    onPressed: (context) async {
                                      decline(index);
                                    },
                                    backgroundColor: EvieColors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  _notificationProvider.updateIsReadStatus(
                                      _notificationProvider.notificationList.keys.elementAt(index));
                                },
                                child: Container(
                                  color: notificationModel.isRead == false ? EvieColors.lightWhite : EvieColors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                              child: Container(
                                                //color: Colors.red,
                                                child: Text(
                                                  notificationModel.title!,
                                                  style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),
                                                ),
                                              )
                                          ),
                                          Container(
                                            //color: Colors.green,
                                            child: Text(
                                              calculateTimeAgo(notificationModel.created!.toDate()),
                                              style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),
                                            ),
                                          )
                                        ],
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional.centerStart,
                                            child: Text(
                                                "${notificationModel.body!}",
                                                style: EvieTextStyles.body16.copyWith(fontWeight: FontWeight.w500, color: EvieColors.darkGrayishCyan)
                                            ),
                                          ),
                                          SizedBox(height: 6.h,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              EvieButton_ReversedColor(
                                                onPressed: () {
                                                  decline(index);
                                                },
                                                child: Text(
                                                  "Decline",
                                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.primaryColor, fontWeight: FontWeight.w800),
                                                ),
                                                height: 40.h,
                                                width: 180.w,
                                              ),
                                              EvieButton(
                                                onPressed: () async {
                                                  await _bikeProvider.acceptInvitation(notificationModel.deviceIMEI!, _currentUserProvider.currentUserModel!.uid);

                                                  FirebaseFirestore.instance
                                                      .collection('bikes')
                                                      .doc(notificationModel.deviceIMEI!)
                                                      .get().then((doc) {
                                                        Map<String, dynamic>? obj = doc.data();
                                                        BikeModel bikeModel = BikeModel.fromJson(obj!);
                                                        changeToAcceptingInvitationScreen(context, notificationModel.deviceIMEI!, _currentUserProvider.currentUserModel!.uid, _notificationProvider.notificationList.keys.elementAt(index), _currentUserProvider.currentUserModel?.name, bikeModel.pedalPalsModel?.name);
                                                  });
                                                },
                                                child: Text(
                                                  "Accept",
                                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                                                ),
                                                height: 40.h,
                                                width: 180.w,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          case 'userShared':
                            return Slidable(
                              key: UniqueKey(),
                              endActionPane: ActionPane(
                                extentRatio: 0.3,
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    spacing: 10,
                                    onPressed: (context) async {
                                      _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                                    },
                                    backgroundColor: EvieColors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  _notificationProvider.updateIsReadStatus(
                                      _notificationProvider.notificationList.keys.elementAt(index));
                                },
                                child: Container(
                                  color: notificationModel.isRead == false ? EvieColors.lightWhite : EvieColors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                              child: Container(
                                                //color: Colors.red,
                                                child: Text(
                                                  notificationModel.title!,
                                                  style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),
                                                ),
                                              )
                                          ),
                                          Container(
                                            //color: Colors.green,
                                            child: Text(
                                              calculateTimeAgo(notificationModel.created!.toDate()),
                                              style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),
                                            ),
                                          )
                                        ],
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional.centerStart,
                                            child: Text(
                                              "${notificationModel.body!}",
                                              style: EvieTextStyles.body16.copyWith(fontWeight: FontWeight.w500, color: EvieColors.darkGrayishCyan),
                                            ),
                                          ),
                                          SizedBox(height: 6.h,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              EvieButton(
                                                onPressed: () async {
                                                  if (_bikeProvider.userBikeList.containsKey(notificationModel.deviceIMEI)) {
                                                    _settingProvider.changeSheetElement(SheetList.pedalPalsList);
                                                    showSheetNavigate(context);
                                                  }
                                                  else {
                                                    showTeamNotAvailableDialog(context);
                                                  }

                                                },
                                                child: Text(
                                                  "See My Team",
                                                  style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                                                ),
                                                height: 40.h,
                                                width: 170.w,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          default:
                            if (notificationModel.action == 'update-now') {
                              return Slidable(
                                key: UniqueKey(),
                                endActionPane: ActionPane(
                                  extentRatio: 0.3,
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      spacing: 10,
                                      onPressed: (context) async {
                                        _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                                      },
                                      backgroundColor: EvieColors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    _notificationProvider.updateIsReadStatus(_notificationProvider.notificationList.keys.elementAt(index));
                                  },
                                  child: Container(
                                    color: notificationModel.isRead == false ? EvieColors.lightWhite : EvieColors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Container(
                                                  //color: Colors.red,
                                                  child: Text(
                                                    notificationModel.title!,
                                                    style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),
                                                  ),
                                                )
                                            ),
                                            Container(
                                              //color: Colors.green,
                                              child: Text(
                                                calculateTimeAgo(notificationModel.created!.toDate()),
                                                style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),
                                              ),
                                            )
                                          ],
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional.centerStart,
                                              child: Text(
                                                  "${notificationModel.body!}",
                                                  style: EvieTextStyles.body16.copyWith(fontWeight: FontWeight.w500, color: EvieColors.darkGrayishCyan)
                                              ),
                                            ),
                                            SizedBox(height: 6.h,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                EvieButton(
                                                    onPressed: () async {
                                                      if (_bluetoothProvider.deviceConnectResult == null
                                                          || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.disconnected
                                                          || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanTimeout
                                                          || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connectError
                                                          || _bluetoothProvider.deviceConnectResult == DeviceConnectResult.scanError
                                                          || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                                                      ) {
                                                        // setState(() {
                                                        //   pageNavigate = 'registerEVKey';
                                                        // });
                                                        showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                                                        // showEvieActionableBarDialog(context, _bluetoothProvider, _bikeProvider);
                                                      }
                                                      else if (_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected) {
                                                        _settingProvider.changeSheetElement(SheetList.firmwareInformation);
                                                        showSheetNavigate(context);
                                                      }
                                                    },
                                                    child: Text(
                                                      "Update Now",
                                                      style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                                                    ),
                                                    height: 40.h,
                                                    width: 159.w
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (notificationModel.action == 'find-out-more') {
                              return Slidable(
                                key: UniqueKey(),
                                endActionPane: ActionPane(
                                  extentRatio: 0.3,
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      spacing: 10,
                                      onPressed: (context) async {
                                        _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                                      },
                                      backgroundColor: EvieColors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    _notificationProvider.updateIsReadStatus(_notificationProvider.notificationList.keys.elementAt(index));
                                  },
                                  child: Container(
                                    color: notificationModel.isRead == false ? EvieColors.lightWhite : EvieColors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Container(
                                                  //color: Colors.red,
                                                  child: Text(
                                                    notificationModel.title!,
                                                    style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),
                                                  ),
                                                )
                                            ),
                                            Container(
                                              //color: Colors.green,
                                              child: Text(
                                                calculateTimeAgo(notificationModel.created!.toDate()),
                                                style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),
                                              ),
                                            )
                                          ],
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional.centerStart,
                                              child: Text(
                                                "${notificationModel.body!}",
                                                style: EvieTextStyles.body16.copyWith(fontWeight: FontWeight.w500, color: EvieColors.darkGrayishCyan),
                                              ),
                                            ),
                                            SizedBox(height: 6.h,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                EvieButton(
                                                    onPressed: () async {
                                                      ///Need http:// or https
                                                      final Uri url = Uri.parse('http://${notificationModel.url}');

                                                      /// await launchUrl(url,mode: LaunchMode.externalApplication)  for open at external browser
                                                      if (await launchUrl(url)) {}else{
                                                        throw Exception('Could not launch $url');
                                                      }
                                                    },
                                                    child: Text(
                                                      "Find Out More",
                                                      style: EvieTextStyles.body18.copyWith(color: EvieColors.grayishWhite, fontWeight: FontWeight.w800),
                                                    ),
                                                    height: 40.h,
                                                    width: 159.w),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            else {
                              return Slidable(
                                key: UniqueKey(),
                                endActionPane: ActionPane(
                                  extentRatio: 0.3,
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      spacing: 10,
                                      onPressed: (context) async {
                                        _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(index));
                                      },
                                      backgroundColor: EvieColors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    _notificationProvider.updateIsReadStatus(_notificationProvider.notificationList.keys.elementAt(index));
                                  },
                                  child: Container(
                                    color: notificationModel.isRead == false ? EvieColors.lightWhite : EvieColors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Container(
                                                  //color: Colors.red,
                                                  child: Text(
                                                    notificationModel.title!,
                                                    style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),
                                                  ),
                                                )
                                            ),
                                            Container(
                                              //color: Colors.green,
                                              child: Text(
                                                calculateTimeAgo(notificationModel.created!.toDate()),
                                                style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),
                                              ),
                                            )
                                          ],
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional.centerStart,
                                              child: Text(
                                                  "${notificationModel.body!}",
                                                  style: EvieTextStyles.body16.copyWith(fontWeight: FontWeight.w500, color: EvieColors.darkGrayishCyan)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: Colors.transparent,
                            child: Divider(
                              thickness: 0.2.h,
                              color: EvieColors.darkWhite,
                              height: 0,
                            ),
                        );
                      },
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
            showCustomLightLoading();
            StreamSubscription? currentSubscription;
            currentSubscription = _bikeProvider.declineSharedBike(
                _notificationProvider.notificationList.values.elementAt(index).deviceIMEI!,
                _notificationProvider.notificationList.values.elementAt(index).notificationId).listen((cancelStatus) {
              if(cancelStatus == UploadFirestoreResult.success){

                SmartDialog.dismiss(status: SmartStatus.loading);
                SmartDialog.show(
                    keepSingle: true,
                    widget: EvieSingleButtonDialogOld(
                        title: "Success",
                        content: "You declined the invitation",
                        rightContent: "Close",
                        onPressedRight: () => SmartDialog.dismiss()
                    ));
                currentSubscription?.cancel();
              } else if(cancelStatus == UploadFirestoreResult.failed) {
                SmartDialog.dismiss();
                SmartDialog.show(
                    widget: EvieSingleButtonDialogOld(
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

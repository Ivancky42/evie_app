import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/feeds/feeds_visible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';

import 'package:evie_test/widgets/evie_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/model/notification_model.dart';
import '../../api/navigator.dart';
import '../../api/snackbar.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_single_button_dialog.dart';

class FeedsContainer extends StatefulWidget {

  LinkedHashMap<String, NotificationModel> notificationList = LinkedHashMap<String, NotificationModel>();
  int index;

  FeedsContainer({Key? key,
    //required this.notificationList,
    required this.index,
  }) : super(key: key);

  @override
  _FeedsContainerState createState() => _FeedsContainerState();
}

class _FeedsContainerState extends State<FeedsContainer> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    return Slidable(
      key: UniqueKey(),
      endActionPane:  ActionPane(
        extentRatio: 0.3,
        motion: const StretchMotion(),

        ///Dismissible
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
              if(_notificationProvider.notificationList.values.elementAt(widget.index).status == "userPending"){
                decline(widget.index, _bikeProvider, _notificationProvider );
              }else {
                var result = await _notificationProvider.deleteNotification(
                    _notificationProvider.notificationList.keys.elementAt(widget.index));
                if (result) {
                  //showDeleteNotificationSuccess();
                } else {
                  showDeleteNotificationFailed();
                }
              }
            },
            backgroundColor: EvieColors.red,
            foregroundColor: EvieColors.white,
            icon: Icons.delete,
          ),
        ],
      ),

      child: GestureDetector(
          onTap: () async {
            // _notificationProvider.updateIsReadStatus(_notificationProvider
            //     .notificationList.keys
            //     .elementAt(widget.index));
          },

          child: Container(
            color: _notificationProvider.notificationList.values.elementAt(widget.index).isRead! == false ? EvieColors.lightWhite : EvieColors.transparent,
            child: Padding(
              padding:  EdgeInsets.only(top: 14.h, bottom: 14.h),
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // width:260.w,
                        child: Text(_notificationProvider
                            .notificationList.values
                            .elementAt(widget.index)
                            .title!, style: EvieTextStyles.headlineB.copyWith(color: EvieColors.mediumLightBlack),),
                      ),

                      Text(calculateTimeAgo(_notificationProvider.notificationList.values.elementAt(widget.index).created!.toDate()),
                        style: EvieTextStyles.body12.copyWith(color: EvieColors.darkGrayishCyan),),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          "${_notificationProvider.notificationList.values.elementAt(widget.index).body!}",
                          // "\n\n${_notificationProvider.notificationList.values.elementAt(widget.index).created!.toDate()}",
                          style:  EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan),
                        ),
                      ),

                      ///Button visible based on different condition
                      FeedsVisible(index: widget.index),

                    ],
                  )),
            ),
          )),
    );
  }
}


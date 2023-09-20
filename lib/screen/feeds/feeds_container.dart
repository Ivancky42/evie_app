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
        children: [
          SlidableAction(
            spacing:10,
            onPressed: (context) async{
              if(_notificationProvider.notificationList.values.elementAt(widget.index).status == "userPending"){
                decline(widget.index, _bikeProvider, _notificationProvider );
              }
              else {
                var result = await _notificationProvider.deleteNotification(_notificationProvider.notificationList.keys.elementAt(widget.index));
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
          onTap: () async {},
          child: Container(
            color: _notificationProvider.notificationList.values.elementAt(widget.index).isRead! == false ? EvieColors.lightWhite : EvieColors.transparent,
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                          _notificationProvider.notificationList.values.elementAt(widget.index).body!,
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


import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/navigator.dart';
import '../../api/snackbar.dart';

class AcceptingInvitation extends StatefulWidget {
  final String deviceIMEI;
  final String currentUid;
  final String notificationId;
  const AcceptingInvitation({Key? key, required this.deviceIMEI, required this.currentUid, required this.notificationId}) : super(key: key);

  @override
  State<AcceptingInvitation> createState() => _AcceptingInvitationState();
}

class _AcceptingInvitationState extends State<AcceptingInvitation> {
  late BikeProvider _bikeProvider;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
    _notificationProvider = context.read<NotificationProvider>();
    fetchData(_bikeProvider, _notificationProvider);
  }

  Future<void> fetchData(_bikeProvider, _notificationProvider) async {
    final result = await _bikeProvider.listenAcceptInvitation(widget.deviceIMEI, widget.currentUid);
    if (result == 'Success') {
      _bikeProvider.changeBikeUsingIMEI(widget.deviceIMEI!);
      _notificationProvider.updateUserNotificationSharedBikeStatus(widget.notificationId);
      for (var element in _bikeProvider.userBikeNotificationList) {
        await _notificationProvider.subscribeToTopic("${widget.deviceIMEI!}$element");
      }
      showBikeAddSuccessfulToast(context);
      changeToUserHomePageScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 60.h,),
            Text(
              "Accepting invitation and adding bike...",
              style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGray),
            )
          ],
        ),
      ),
    );
  }
}

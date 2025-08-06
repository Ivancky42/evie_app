
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../api/provider/notification_provider.dart';

class ClearFeed extends StatefulWidget {
  const ClearFeed({
    super.key,

  });

  @override
  State<ClearFeed> createState() => _ClearFeedState();
}

class _ClearFeedState extends State<ClearFeed> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late NotificationProvider _notificationProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _notificationProvider = Provider.of<NotificationProvider>(context);

    return Padding(
      padding:
      EdgeInsets.only(left: 0.w, top: 0.h, bottom: 0.h, right: 0.w),
      child: GestureDetector(
          onTap: () async {
            Navigator.pop(context);
            showClearFeed(_notificationProvider);
          },
          child: Container(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 8.w, right: 8.w),
              leading: Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                ),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/delete_black.svg",
                    ),
                  ),
                ),
              ),
              title:Text(
                "Clear Feed",
                style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
              ),
              subtitle: Wrap(
                  children: [
                    Text(
                      "Delete all your notifications.",
                      style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.bold, color: EvieColors.darkGrayishCyan),
                    ),
                  ]
              ),
            ),
          )
      ),
    );
  }
}

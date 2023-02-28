import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/text_column.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';

class AboutBike extends StatefulWidget {
  const AboutBike({Key? key}) : super(key: key);

  @override
  _AboutBikeState createState() => _AboutBikeState();
}

class _AboutBikeState extends State<AboutBike> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late FirmwareProvider _firmwareProvider;

  int totalSeconds = 105;

  StreamSubscription? stream;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _firmwareProvider = Provider.of<FirmwareProvider>(context);

    return WillPopScope(
      onWillPop: () async {

          changeToNavigatePlanScreen(context);

        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'About Bike',
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
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Model Name",
                      body: "EVIE S series"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Model Number",
                      body: "Model Number"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Serial Number",
                      body: "1234567890"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Bluetooth Number",
                      body: "1234567890"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Bluetooth Mac Address",
                      body: "1234567890"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "IMEI",
                      body: _bikeProvider.currentBikeModel?.deviceIMEI ?? ""),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Total Mileage",
                      body: "0 km"),
                ),
                const AccountPageDivider(),
              ],
            ),
          ],
        ),
      ),
    );
  }

}




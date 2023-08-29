import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
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

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/provider/trip_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';

class UserManual extends StatefulWidget {
  const UserManual({Key? key}) : super(key: key);

  @override
  _UserManualState createState() => _UserManualState();
}

class _UserManualState extends State<UserManual> {

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  int totalSeconds = 105;

  StreamSubscription? stream;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {

        //_settingProvider.changeSheetElement(SheetList.bikeSetting);

        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'User Manual',
          onPressed: () {

            _settingProvider.changeSheetElement(SheetList.bikeSetting);

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
                      title: "Serial Number",
                      body: _bikeProvider.currentBikeModel?.serialNumber ?? "-"),
                ),
                const AccountPageDivider(),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Bluetooth Name",
                      body: _bikeProvider.currentBikeModel?.bleName ?? "-"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Bluetooth Mac Address",
                      body: _bikeProvider.currentBikeModel?.macAddr ?? "-"),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "IMEI",
                      body: _bikeProvider.currentBikeModel?.deviceIMEI ?? ""),
                ),
                const AccountPageDivider(),
                // Padding(
                //   padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                //   child:TextColumn(
                //     title: "Total Mileage",
                //     body: _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
                //     "${(_tripProvider.currentTripHistoryLists.values.fold<double>(0, (prev, element) => prev + element.distance!.toDouble())/1000).toStringAsFixed(2)} km":
                //     "${_settingProvider.convertMeterToMilesInString(_tripProvider.currentTripHistoryLists.values.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()))} miles",
                //   ),
                // ),
                const AccountPageDivider(),
              ],
            ),
          ],
        ),
      ),
    );
  }

}




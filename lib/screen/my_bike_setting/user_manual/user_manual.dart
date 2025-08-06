import 'dart:async';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/widgets/text_column.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/enumerate.dart';
import '../../../widgets/evie_appbar.dart';

class UserManual extends StatefulWidget {
  const UserManual({super.key});

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




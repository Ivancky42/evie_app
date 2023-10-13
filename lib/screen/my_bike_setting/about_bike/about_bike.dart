import 'dart:async';
import 'dart:io';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
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
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/firmware_provider.dart';
import '../../../api/provider/trip_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';

class AboutBike extends StatefulWidget {
  const AboutBike({Key? key}) : super(key: key);

  @override
  _AboutBikeState createState() => _AboutBikeState();
}

class _AboutBikeState extends State<AboutBike> {

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
          title: 'About Bike',
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
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,4.h),
                  child:TextColumn(
                      title: "Total Distance",

                    ///Use bikeModel mileage
                    ///If it is (10) means 1km , (20) means 2km, 2 means 0.2km. and miles
                      body: _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
                      "${(_bikeProvider.currentBikeModel?.mileage ?? 0)} km":
                      "${_settingProvider.convertKiloMeterToMilesInString(_bikeProvider.currentBikeModel?.mileage != null ? _bikeProvider.currentBikeModel?.mileage!.toDouble() : 0)} miles",
                ),
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




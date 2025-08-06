import 'dart:async';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/widgets/text_column.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/evie_appbar.dart';

class AboutBike extends StatefulWidget {
  const AboutBike({super.key});

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
                  padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                        title: "Model Name",
                        body: 'EVIE ${_bikeProvider.currentBikeModel!.model!}'),
                  ),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                        title: "Serial Number",
                        body: _bikeProvider.currentBikeModel?.serialNumber ?? "-"),
                  ),
                ),
                const AccountPageDivider(),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                        title: "Bluetooth Name",
                        body: _bikeProvider.currentBikeModel?.bleName ?? "-"),
                  ),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                        title: "Bluetooth Mac Address",
                        body: _bikeProvider.currentBikeModel?.macAddr ?? "-"),
                  ),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                        title: "Device IMEI",
                        body: _bikeProvider.currentBikeModel?.deviceIMEI ?? ""),
                  ),
                ),
                const AccountPageDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: TextColumn(
                      title: "Total Mileage",

                      ///Use bikeModel mileage
                      ///If it is (10) means 1km , (20) means 2km, 2 means 0.2km. and miles
                      body: _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
                      "${(_bikeProvider.currentBikeModel?.mileage ?? 0)} km":
                      "${_settingProvider.convertKiloMeterToMilesInString(_bikeProvider.currentBikeModel?.mileage != null ? _bikeProvider.currentBikeModel?.mileage!.toDouble() : 0)} miles",
                    ),
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




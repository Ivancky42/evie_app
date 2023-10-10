import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_oval.dart';
import '../../home_page_widget.dart';


class Location extends StatefulWidget {
  Location({
    Key? key
  }) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;

  GeoPoint? selectedGeopoint;
  bool isLocation = true;
  String locationName = "Loading";

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _settingProvider = Provider.of<SettingProvider>(context, listen: false);
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return EvieCard(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              child: EvieOvalGrayLocation(
                buttonText: isLocation ? 'Location' : 'Distance',
                onPressed: () {
                  setState(() {
                    isLocation = !isLocation;
                  });
                },
              ),
              padding: EdgeInsets.only(top: 16.h),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLocation ?
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 11.h),
                    child: Container(
                      child: SvgPicture.asset("assets/icons/location_pin_point.svg",
                        height: 36.h, width:  36.w,),
                    )
                ) :
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 11.h),
                    child: Container(
                      child: SvgPicture.asset("assets/icons/distance.svg",
                        height: 36.h, width:  36.w,),
                    )
                ),
                isLocation ?
                Selector<LocationProvider, String?>(
                  selector: (context, locationProvider) => _locationProvider.currentPlaceMarkString,
                  builder: (context, currentPlaceMarkString, child) {
                    return Text(
                      currentPlaceMarkString ?? 'Loading',
                      style: EvieTextStyles.headlineB.copyWith( color: EvieColors.mediumLightBlack, height:1.2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    );
                  },
                ) :
                Row(
                  children: [
                    Text(
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.imperialSystem ?
                      _settingProvider.convertKiloMeterToMilesInString(_locationProvider.calculateDistance())  : (_locationProvider.calculateDistance().toStringAsFixed(2)),
                      style: EvieTextStyles.headlineB.copyWith( color: EvieColors.mediumLightBlack, height:1.2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      _settingProvider.currentMeasurementSetting == MeasurementSetting.imperialSystem ?
                      ' mi away' : ' km away',
                      style: EvieTextStyles.body14,
                      maxLines: 2,
                    ),
                  ],
                ),
                Text(calculateTimeAgo(_locationProvider.locationModel!.updated!.toDate()),
                    style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack, fontWeight: FontWeight.w400)),
                SizedBox(height: 16.h,),
              ],
            )
          ],
        ),
      )

    );
  }
}



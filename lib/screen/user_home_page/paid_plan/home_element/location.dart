import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_oval.dart';


class Location extends StatefulWidget {
  const Location({
    super.key
  });

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
  }

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void _showActionSheet(BuildContext context, List<AvailableMap> availableMaps) {
    final action = CupertinoActionSheet(
      title: Column(
        children: [
          Text(
            "Selection",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 3.h,),
          Text(
            "Navigation to my bike location with",
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
      actions: <Widget>[
        SizedBox(
          height: availableMaps.length * 72.h,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      if (selectedGeopoint != null) {
                        MapLauncher.showDirections(
                          mapType: availableMaps[index].mapType,
                          destination: Coords(
                            selectedGeopoint!.latitude,
                            selectedGeopoint!.longitude,
                          ),
                        );
                      } else {
                        MapLauncher.showDirections(
                          mapType: availableMaps[index].mapType,
                          destination: Coords(
                            _bikeProvider.currentBikeModel!.location!.geopoint!.latitude,
                            _bikeProvider.currentBikeModel!.location!.geopoint!.longitude,
                          ),
                        );
                      }
                    },
                    child: Container(
                      child: Text(
                        availableMaps[index].mapName,
                        style: TextStyle(fontSize: 20.sp, color: EvieColors.blue, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Divider(), // Add a divider between items
                ],
              );
            },
            itemCount: availableMaps.length,
          ),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: EvieColors.blue),),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    showCupertinoModalPopup(
        context: context, builder: (context) => action);
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;

    return GestureDetector(
      onTap: () async {
        List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
        _showActionSheet(context, availableMaps);
      },
      child: EvieCard3(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: EvieOvalGrayLocation(
                    buttonText: isLocation ? 'Location' : 'Distance',
                    onPressed: () {
                      setState(() {
                        isLocation = !isLocation;
                      });
                    },
                  ),
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

      ),
    );
  }
}



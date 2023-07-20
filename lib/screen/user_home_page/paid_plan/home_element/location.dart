import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../api/sheet_2.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
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

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return EvieCard(
      color: EvieColors.lightGrayishCyan,
      decoration: BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: [
          BoxShadow(
            color: EvieColors.grayishWhite, // Hex color with opacity
            offset: Offset(0, 8), // X and Y offset
            blurRadius: 16, // Blur radius
            spreadRadius: 0, // Spread radius
          ),
        ],
      ),
      onPress: (){

      },

      title: "Location",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset("assets/icons/location_pin_point.svg",
              height: 36.h, width:  36.w,),
            Text(getCurrentBikeStatusString(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected, _bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
              style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray),
            ),
            Text(calculateTimeAgo(_locationProvider.locationModel!.updated!.toDate()),
                style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack, fontWeight: FontWeight.w400)),
            SizedBox(height: 16.h,),
          ],
        ),
      ),

    );
  }
}



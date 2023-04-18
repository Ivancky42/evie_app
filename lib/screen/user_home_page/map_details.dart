
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
///import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../widgets/evie_radio_button.dart';
import '../../../widgets/evie_switch.dart';

class MapDetails extends StatefulWidget {


  MapDetails({
    Key? key,

  }) : super(key: key);

  @override
  State<MapDetails> createState() => _MapDetailsState();
}

class _MapDetailsState extends State<MapDetails> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Padding(
          //   padding:  EdgeInsets.only(top: 13.h),
          //   child: SvgPicture.asset(
          //     "assets/buttons/down.svg",
          //   ),
          // ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                EdgeInsets.only(left: 17.w, top: 10.h, bottom: 11.h),
                child: Text(
                  "Map",
                  style: EvieTextStyles.h1,
                ),
              ),

            ],
          ),
          const Divider(
            thickness: 2,
          ),
        //
        // MapWidget(
        //     resourceOptions: ResourceOptions(
        //         accessToken: _locationProvider.defPublicAccessToken
        //     ),
        //   styleUri: "https://api.mapbox.com/styles/v1/helloevie/claug0xq5002w15mk96ksixpz/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGVsbG9ldmllIiwiYSI6ImNsN3pvMm9oZTBsM3ozcG4zd2NmenVlZWQifQ.Y1R7b5ban6IwnLODyrf9Zw",
        //     cameraOptions: CameraOptions(
        //       zoom: 16,
        //     )
        // ),


        ],
      ),
      height: 750.h,
    );
  }
}


import 'dart:typed_data';

import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

  MapboxMap? mapboxMap;

  OnMapScrollListener? onMapScrollListener;

  ///F I D
  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///When location change marker change
    mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
      final ByteData bytes = await rootBundle.load(loadMarkerImageString(_locationProvider.locationModel?.status ?? ""));
      final Uint8List list = bytes.buffer.asUint8List();
      var options = <PointAnnotationOptions>[];
      for (var i = 0; i < 1; i++) {
        options.add( PointAnnotationOptions(
          geometry: Point(coordinates:  Position(
              _locationProvider.locationModel?.geopoint.longitude ?? 0,
              _locationProvider.locationModel?.geopoint.latitude ?? 0
          )).toJson(), image: list,
          iconSize: 1.5.h,
        ));
      }
      pointAnnotationManager.createMulti(options);
    });
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);


    ///When location change marker change
    mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
      final ByteData bytes = await rootBundle.load(loadMarkerImageString(_locationProvider.locationModel?.status ?? ""));
      final Uint8List list = bytes.buffer.asUint8List();
      var options = <PointAnnotationOptions>[];
      for (var i = 0; i < 1; i++) {
        options.add( PointAnnotationOptions(
          geometry: Point(coordinates:  Position(
              _locationProvider.locationModel?.geopoint.longitude ?? 0,
              _locationProvider.locationModel?.geopoint.latitude ?? 0
          )).toJson(), image: list,
          iconSize: 1.5.h,
        ));
      }
      pointAnnotationManager.createMulti(options);
    });

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

        Container(
          height: 600.h,
          child: MapWidget(
            onScrollListener: onMapScrollListener,
              key: const ValueKey("mapWidget"),
              resourceOptions: ResourceOptions(
                  accessToken: _locationProvider.defPublicAccessToken
              ),
            onMapCreated: _onMapCreated,
            styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(
                  _locationProvider.locationModel?.geopoint.longitude ?? 0,
                  _locationProvider.locationModel?.geopoint.latitude ?? 0
              )).toJson(),
                zoom: 16,
          ),
            gestureRecognizers: [Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())].toSet(),
        ),
        ),
        ],
      ),
      height: 750.h,
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:image/image.dart' as IMG;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import 'package:latlong2/latlong.dart';

import 'home_element/battery.dart';
import 'home_element/status.dart';


class ThreatMap extends StatefulWidget {

  const ThreatMap({Key? key,}) : super(key: key);

  @override
  State<ThreatMap> createState() => _ThreatMapState();
}

class _ThreatMapState extends State<ThreatMap> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

  int? snapshotLength;

  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  bool isFirstLoadUserLocation = true;
  bool isFirstLoadMarker = true;
  bool isMapListShowing = false;

  StreamSubscription? userLocationSubscription;
  Position userPosition = Position(0, 0);

  var options = <PointAnnotationOptions>[];
  var currentAnnotationId;

  List<map_launcher.AvailableMap>? availableMaps;
  GeoPoint? selectedGeopoint;

  var currentClickedAnnotation;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    _locationProvider.setDefaultSelectedGeopoint();
    initLocationService();
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    userLocationSubscription?.cancel();
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    loadMarker();
  }

  _onMapLoaded(MapLoadedEventData onMapLoaded) async {
  }

  void initLocationService() async {
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

          Container(
            color: EvieColors.lightBlack,
            child: Padding(
              padding: EdgeInsets.only(left: 17.w, top: 45.h, bottom: 11.h, right:17.w),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  GestureDetector(
                      onTap: (){
                        showExitOrbitalAntiTheft(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/close.svg",
                      )),
                  Text(
                    "Orbital Anti-theft",
                    style: EvieTextStyles.h2.copyWith(color: EvieColors.grayishWhite),
                  ),

                  GestureDetector(
                      onTap: (){
                        changeToThreatTimeLine(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/list.svg",
                      )),
                ],
              ),
            ),
          ),

          Expanded(
                child: Stack(
                  children: [
                    MapWidget(
                      onScrollListener: onMapScrollListener,
                      key: const ValueKey("mapWidget"),
                      resourceOptions: ResourceOptions(
                          accessToken: _locationProvider.defPublicAccessToken),
                      onMapCreated: _onMapCreated,
                      onMapLoadedListener: _onMapLoaded,
                      styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                      cameraOptions: CameraOptions(
                        center: Point(
                            coordinates: Position(
                                _locationProvider.locationModel?.geopoint.longitude ?? 0,
                                _locationProvider.locationModel?.geopoint.latitude ?? 0))
                            .toJson(),
                        zoom: 16,
                      ),
                      gestureRecognizers: [
                        Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())
                      ].toSet(),
                    ),

                    Padding(
                      padding:  EdgeInsets.only(bottom:280.h),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () async {
                            List<map_launcher.AvailableMap> availableMaps =
                            await map_launcher.MapLauncher.installedMaps;
                            if (isMapListShowing) {
                              setState(() {
                                this.availableMaps = null;
                                isMapListShowing = false;
                              });
                            } else {
                              setState(() {
                                this.availableMaps = availableMaps;
                                isMapListShowing = true;
                              });
                            }
                          },
                          child: Container(
                              height: 50.h,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    availableMaps != null
                                        ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            if(selectedGeopoint != null){
                                              map_launcher.MapLauncher.showDirections(
                                                  mapType: availableMaps![index].mapType,
                                                  destination: map_launcher.Coords(
                                                      selectedGeopoint!.latitude,
                                                      selectedGeopoint!.longitude));
                                            }else{
                                              map_launcher.MapLauncher.showDirections(
                                                  mapType: availableMaps![index].mapType,
                                                  destination: map_launcher.Coords(
                                                      _bikeProvider.currentBikeModel!.location!.geopoint.latitude,
                                                      _bikeProvider.currentBikeModel!.location!.geopoint.longitude));
                                            }

                                          },
                                          child: SvgPicture.asset(
                                            availableMaps![index].icon,
                                            width: 36.w,
                                            height: 36.h,
                                          ),
                                        );
                                      },
                                      itemCount: availableMaps?.length,
                                    )
                                        : SizedBox(),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.h),
                                      child: SvgPicture.asset(
                                        "assets/buttons/direction.svg",
                                        width: 50.w,
                                        height: 50.h,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),

                    Padding(
                      padding:  EdgeInsets.only(bottom:230.h),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () async {
                            pointBounce2(mapboxMap, _locationProvider, userPosition);
                          },
                          child: Container(
                              height: 50.h,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8.h),
                                  child: SvgPicture.asset(
                                    "assets/buttons/location.svg",
                                    width: 50.w,
                                    height: 50.h,
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),

                    Padding(
                      padding:  EdgeInsets.only(bottom:0.h),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(16, 2, 6, 8),
                                  child: Status(),
                                ),
                              ),
                            ),

                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(6, 2, 16, 8),
                                  child: UnlockingSystem(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
             ),
          ),
       ]
      ),
      height: 750.h,
    );
  }

  void locationListener() {

    print("location did change");

    //getDistanceBetween();
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    animateBounce(mapboxMap, _locationProvider.locationModel?.geopoint.longitude ?? 0, _locationProvider.locationModel?.geopoint.latitude ?? 0);
    loadMarker();
  }

  loadMarker() async {
    ///Marker
    options.clear();

    if(currentAnnotationId != null){
      ///Check if have this id
      await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationId);
    }

    await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {

      ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
      currentAnnotationId = pointAnnotationManager;

      // for (int i = 1; i <= 7; i++) {}
      final ByteData bytes1 = await rootBundle.load("assets/icons/danger_pin/danger_pin_1.png");
      final ByteData bytes2 = await rootBundle.load("assets/icons/danger_pin/danger_pin_2.png");
      final ByteData bytes3 = await rootBundle.load("assets/icons/danger_pin/danger_pin_3.png");
      final ByteData bytes4 = await rootBundle.load("assets/icons/danger_pin/danger_pin_4.png");
      final ByteData bytes5 = await rootBundle.load("assets/icons/danger_pin/danger_pin_5.png");
      final ByteData bytes6 = await rootBundle.load("assets/icons/danger_pin/danger_pin_6.png");
      final ByteData bytes7 = await rootBundle.load("assets/icons/danger_pin/danger_pin_7.png");

      final Uint8List pin1 = bytes1.buffer.asUint8List();
      final Uint8List pin2 = bytes2.buffer.asUint8List();
      final Uint8List pin3 = bytes3.buffer.asUint8List();
      final Uint8List pin4 = bytes4.buffer.asUint8List();
      final Uint8List pin5 = bytes5.buffer.asUint8List();
      final Uint8List pin6 = bytes6.buffer.asUint8List();
      final Uint8List pin7 = bytes7.buffer.asUint8List();

      List<Uint8List> pins = [
        pin1, pin2, pin3, pin4, pin5, pin6, pin7,
      ];

      ///load a few more marker
      //for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
      ///Only load 7 latest of threatRouteList value to display marker
      for (int i = 0; i < 7; i++) {

        // GeoPoint routeGeopoint = _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint;

          options.add(
            PointAnnotationOptions(
              geometry: Point(
                  coordinates: Position(
                    _bikeProvider.threatRoutesLists.values
                        .elementAt(i)
                        .geopoint
                        .longitude ?? 0,
                    _bikeProvider.threatRoutesLists.values
                        .elementAt(i)
                        .geopoint
                        .latitude ?? 0,
                  )).toJson(),
              image: pins[i],
              iconSize: 2.h,
              // textField: "Text",
              // textOffset: [0.0, 3],
              // textColor: Colors.black.value,
            ),);

        pointAnnotationManager.setIconAllowOverlap(false);
        pointAnnotationManager.createMulti(options);

        OnPointAnnotationClickListener listener = MyPointAnnotationClickListener(_locationProvider);
        pointAnnotationManager.addOnPointAnnotationClickListener(listener);
      }
    });

    ///User location
    final ByteData bytes = await rootBundle.load("assets/icons/user_location_icon.png");
    final Uint8List list = bytes.buffer.asUint8List();

    IMG.Image? img = IMG.decodeImage(list);
    IMG.Image resized = IMG.copyResize(img!, width: 50.w.toInt(), height:70.h.toInt());
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

    mapboxMap?.location.updateSettings(
        LocationComponentSettings(
            enabled: true,
            // pulsingEnabled: true,
            // puckBearingEnabled: true,
            locationPuck: LocationPuck(
                locationPuck2D: LocationPuck2D(
                  topImage: resizedImg,
                  bearingImage: resizedImg,
                  shadowImage: resizedImg,
                  //scaleExpression: "50",
                ))));

    Layer? layer;

    if (Platform.isAndroid) {
      layer = await mapboxMap?.style.getLayer("mapbox-location-indicator-layer");
    } else {
      layer = await mapboxMap?.style.getLayer("puck");
    }

    var location = (layer as LocationIndicatorLayer).location;
    userPosition = Position(location![1]!, location[0]!);

  }

  // loadMarker() async {
  //   ///Marker
  //   options.clear();
  //
  //   if(currentAnnotationId != null){
  //     ///Check if have this id
  //     await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationId);
  //   }
  //
  //   await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
  //
  //     ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
  //     currentAnnotationId = pointAnnotationManager;
  //
  //       final ByteData bytes = await rootBundle.load("assets/icons/marker_danger.png");
  //       final Uint8List list = bytes.buffer.asUint8List();
  //
  //     final ByteData bytes2 = await rootBundle.load("assets/icons/marker_danger_deactivate.png");
  //     final Uint8List list2 = bytes2.buffer.asUint8List();
  //
  //
  //     if (_locationProvider.selectedAnnotationGeopoint == _locationProvider.locationModel?.geopoint) {
  //       ///First marker
  //       options.add(
  //         PointAnnotationOptions(
  //           geometry: Point(
  //               coordinates: Position(
  //                 _locationProvider.locationModel?.geopoint.longitude ?? 0,
  //                 _locationProvider.locationModel?.geopoint.latitude ?? 0,
  //               )).toJson(),
  //           image: list,
  //           iconSize: 1.4.h,
  //         ),
  //       );
  //     }
  //     else {
  //       options.add(
  //         PointAnnotationOptions(
  //           geometry: Point(
  //               coordinates: Position(
  //                 _locationProvider.locationModel?.geopoint.longitude ?? 0,
  //                 _locationProvider.locationModel?.geopoint.latitude ?? 0,
  //               )).toJson(),
  //           image: list2,
  //           iconSize: 2.0.h,
  //         ),);
  //     }
  //
  //       ///load a few more marker
  //       for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
  //         GeoPoint routeGeopoint = _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint;
  //
  //         if (_locationProvider.selectedAnnotationGeopoint == routeGeopoint) {
  //           options.add(
  //             PointAnnotationOptions(
  //               geometry: Point(
  //                   coordinates: Position(
  //                     _bikeProvider.threatRoutesLists.values
  //                         .elementAt(i)
  //                         .geopoint
  //                         .longitude ?? 0,
  //                     _bikeProvider.threatRoutesLists.values
  //                         .elementAt(i)
  //                         .geopoint
  //                         .latitude ?? 0,
  //                   )).toJson(),
  //               image: list,
  //               iconSize: 1.4.h,
  //             ),
  //           );
  //         }
  //         else {
  //           options.add(
  //             PointAnnotationOptions(
  //               geometry: Point(
  //                   coordinates: Position(
  //                     _bikeProvider.threatRoutesLists.values
  //                         .elementAt(i)
  //                         .geopoint
  //                         .longitude ?? 0,
  //                     _bikeProvider.threatRoutesLists.values
  //                         .elementAt(i)
  //                         .geopoint
  //                         .latitude ?? 0,
  //                   )).toJson(),
  //               image: list2,
  //               iconSize: 2.0.h,
  //               // textField: "Text",
  //               // textOffset: [0.0, 3],
  //               // textColor: Colors.black.value,
  //             ),);
  //         }
  //
  //          pointAnnotationManager.setIconAllowOverlap(false);
  //          pointAnnotationManager.createMulti(options);
  //
  //         OnPointAnnotationClickListener listener = MyPointAnnotationClickListener(_locationProvider);
  //         pointAnnotationManager.addOnPointAnnotationClickListener(listener);
  //       }
  //
  //
  //   });
  //
  //   ///User location
  //   final ByteData bytes = await rootBundle.load("assets/icons/user_location_icon.png");
  //   final Uint8List list = bytes.buffer.asUint8List();
  //
  //   IMG.Image? img = IMG.decodeImage(list);
  //   IMG.Image resized = IMG.copyResize(img!, width: 50.w.toInt(), height:70.h.toInt());
  //   Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
  //
  //   mapboxMap?.location.updateSettings(
  //       LocationComponentSettings(
  //           enabled: true,
  //           // pulsingEnabled: true,
  //           // puckBearingEnabled: true,
  //           locationPuck: LocationPuck(
  //               locationPuck2D: LocationPuck2D(
  //                 topImage: resizedImg,
  //                 bearingImage: resizedImg,
  //                 shadowImage: resizedImg,
  //                 //scaleExpression: "50",
  //               ))));
  //
  //   Layer? layer;
  //
  //   if (Platform.isAndroid) {
  //     layer = await mapboxMap?.style.getLayer("mapbox-location-indicator-layer");
  //   } else {
  //     layer = await mapboxMap?.style.getLayer("puck");
  //   }
  //
  //   var location = (layer as LocationIndicatorLayer).location;
  //     userPosition = Position(location![1]!, location[0]!);
  //
  // }
}

class MyPointAnnotationClickListener extends OnPointAnnotationClickListener {
  PointAnnotation? currentClickedAnnotation;

  late LocationProvider _locationProvider;

  MyPointAnnotationClickListener(LocationProvider locationProvider) {
    _locationProvider = locationProvider;
  }

  @override
   onPointAnnotationClick(PointAnnotation annotation) {
    print('Point annotation clicked: ${annotation.id}');
    print('Point Geometry: ' + annotation.geometry!['coordinates'].toString());
    currentClickedAnnotation = annotation;
    _locationProvider.setSelectedAnnotation(currentClickedAnnotation!);
  }
}

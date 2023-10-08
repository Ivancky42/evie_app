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
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:image/image.dart' as IMG;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../../api/colours.dart';
import '../../../../api/function.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import 'package:latlong2/latlong.dart';

import '../home_element/battery.dart';
import '../home_element/location.dart';
import '../home_element/status.dart';
import '../home_element/threat_unlocking_system.dart';


class ThreatMap extends StatefulWidget {
  final bool? triggerConnect;
  const ThreatMap(this.triggerConnect, {Key? key}) : super(key: key);

  @override
  State<ThreatMap> createState() => _ThreatMapState();
}

class _ThreatMapState extends State<ThreatMap> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  bool isFirstLoadUserLocation = true;
  bool isFirstLoadMarker = true;
  bool isMapListShowing = false;
  bool alreadyTriggerConnect = false;

  int? snapshotLength;

  StreamSubscription? userLocationSubscription;
  Position userPosition = Position(0, 0);

  PointAnnotationManager? currentAnnotationManager;
  List<PointAnnotation>? pointAnnotation;
  List<map_launcher.AvailableMap>? availableMaps;

  GeoPoint? selectedGeopoint;

  var options = <PointAnnotationOptions>[];
  var currentClickedAnnotation;
  Timer? timer;


  @override
  void initState() {
    super.initState();
    _bluetoothProvider = context.read<BluetoothProvider>();
    Future.delayed(Duration.zero).then((value) {
      _locationProvider = Provider.of<LocationProvider>(context, listen: false);
      _locationProvider.addListener(locationListener);
      _locationProvider.setDefaultSelectedGeopoint();
      initLocationService();

      if (widget.triggerConnect != null) {
        if (widget.triggerConnect!) {
          if (_bluetoothProvider.bleStatus == BleStatus.ready) {
            Future.delayed(Duration(seconds: 1)).then((value) {
              _bluetoothProvider.startScanRSSI();
              showThreatDialog(context);
            });
          }
          else if (_bluetoothProvider.bleStatus == BleStatus.poweredOff || _bluetoothProvider.bleStatus == BleStatus.unauthorized) {
            showBluetoothNotTurnOn();
          }
        }
      }
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _locationProvider.removeListener(locationListener);
    userLocationSubscription?.cancel();
    options.clear();
    timer?.cancel();

    // if(currentAnnotationManager != null){
    //   await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationManager as BaseAnnotationManager);
    // currentAnnotationManager = null;
    // }


  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    loadMarker();

    ///User location
    final ByteData bytes = await rootBundle.load("assets/icons/security/user_location_icon.png");
    final Uint8List list = bytes.buffer.asUint8List();

    final ByteData bytes2 = await rootBundle.load("assets/icons/security/top_location.png");
    final Uint8List list2 = bytes2.buffer.asUint8List();

    final ByteData bytes3 = await rootBundle.load("assets/icons/security/shadow.png");
    final Uint8List list3 = bytes3.buffer.asUint8List();

    IMG.Image? img = IMG.decodeImage(list);
    IMG.Image resized = IMG.copyResize(img!, width: 20.w.toInt(), height:20.w.toInt());
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

    await mapboxMap.location.updateSettings(
        LocationComponentSettings(
          pulsingColor: 6967754,
          enabled: true,
          pulsingEnabled: true,
          puckBearingEnabled: true,
          //accuracyRingColor: 6967754,
          //accuracyRingBorderColor: 6967754,
          puckBearingSource: PuckBearingSource.HEADING,
          // locationPuck: LocationPuck(
          //     locationPuck2D: LocationPuck2D(
          //       topImage: list2,
          //       bearingImage: list,
          //       //shadowImage: list3,
          //     )
          // )
        ));

    // timer = Timer.periodic(const Duration(seconds: 1),
    //         (Timer t) => updateUserPositionAndBearing());
  }

  _onMapLoaded(MapLoadedEventData onMapLoaded) async {
    ///On map create function
  }
  void initLocationService() async {
    ///Any location service
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

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
                        showEvieExitOrbitalDialog(context);
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
                        changeToThreatTimeLine(context, PageTransitionType.fade);
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
                      resourceOptions: ResourceOptions(accessToken: _locationProvider.defPublicAccessToken),
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
                                    availableMaps != null ? ListView.builder(
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
                            //pointBounce2(mapboxMap, _locationProvider, userPosition);
                            mapboxMap?.flyTo(
                                CameraOptions(
                                    center: Point(
                                        coordinates: Position(userPosition.lng, userPosition.lat)).toJson(),
                                    zoom: 16
                                  ),
                                MapAnimationOptions(duration: 2000, startDelay: 0));
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
                                  child: Location(),
                                ),
                              ),
                            ),

                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(6, 2, 16, 8),
                                  child: ThreatUnlockingSystem(page: 'map'),
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
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    loadMarker();
  }

  loadMarker() async {
    List<Uint8List> pins = [];

    ///Clear Marker
    options.clear();


    ///Check if have this manager
    // if(currentAnnotationManager != null){
    //   await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationManager as BaseAnnotationManager);
    //   currentAnnotationManager = null;
    // }

    await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
      ///Using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen

      ///Create new annotation manager
      currentAnnotationManager = pointAnnotationManager;

      ///Load and add 7 image
      for (int i = 1; i <= 7; i++) {
        var bytes = await rootBundle.load("assets/icons/danger_pin/danger_pin_${i.toString()}.png");
        pins.add(bytes.buffer.asUint8List());
      }

      if(pointAnnotation != null){
        pointAnnotation?.forEach((element) {currentAnnotationManager?.delete(element);});
        pointAnnotation?.clear();
      }

      ///threatRoutesLists.length is always 7 or less
      for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {

        // GeoPoint routeGeopoint = _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint;
        // createOneAnnotation(
        //     pins[i],
        //     _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.longitude ?? 0,
        //     _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.latitude ?? 0);
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
              iconSize: i == 0 ? 35.mp : 2,
            ),);

        currentAnnotationManager?.setIconAllowOverlap(false);
        currentAnnotationManager?.createMulti(options);
        OnPointAnnotationClickListener listener = MyPointAnnotationClickListener(_locationProvider);
        pointAnnotationManager.addOnPointAnnotationClickListener(listener);
      }
    });
  }

  Future<void> updateUserPositionAndBearing() async {
    Layer? layer;
    if (Platform.isAndroid) {
      layer =
      await mapboxMap?.style.getLayer("mapbox-location-indicator-layer");
    } else {
      layer = await mapboxMap?.style.getLayer("puck");
    }

    var location = (layer as LocationIndicatorLayer)?.location;
    userPosition = Position(location![1]!, location[0]!);
  }

  void createOneAnnotation(Uint8List list, latitude, longitude) {
    currentAnnotationManager?.create(
        PointAnnotationOptions(
        geometry: Point(
            coordinates: Position(
              latitude, longitude,
            )).toJson(),
        iconSize: Platform.isIOS ? 2.5.h : 3.0.h, image: list))
        .then((value) {pointAnnotation?.add(value);});
  }
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

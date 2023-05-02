import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:evie_test/screen/user_home_page/paid_plan/home_element/battery.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/rides.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as IMG;
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:latlong2/latlong.dart';

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

  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  int? snapshotLength;

  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  bool isFirstLoadUserLocation = true;
  bool isFirstLoadMarker = true;
  var options = <PointAnnotationOptions>[];

  StreamSubscription? userLocationSubscription;
  LocationData? userLocation;

  final Location _locationService = Location();

  Position _position = Position(0, 0);

  var currentAnnotationId;
  List<map_launcher.AvailableMap>? availableMaps;
  bool isMapListShowing = false;
  GeoPoint? selectedGeopoint;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);

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


    // ///User location icon and
    // final ByteData bytes = await rootBundle.load("assets/icons/user_location_icon.png");
    // final Uint8List list = bytes.buffer.asUint8List();
    //
    //   mapboxMap?.location.updateSettings(
    //       LocationComponentSettings(
    //           layerBelow: "iconsLayer",
    //           enabled: true,
    //           pulsingEnabled: true,
    //           puckBearingEnabled: true,
    //           locationPuck: LocationPuck(
    //               locationPuck2D: LocationPuck2D(
    //                 topImage: list,
    //                 bearingImage: list,
    //                 shadowImage: list,
    //                 //scaleExpression: "50",
    //               )
    //           )));

  }

  void initLocationService() async {
    // ///For user live location
    // await _locationService.changeSettings(interval: 5000, distanceFilter: 1);
    //
    // ///For user live location
    // userLocationSubscription = _locationService.onLocationChanged.listen((LocationData result) async {
    //   if (mounted) {
    //     setState(() {
    //       userLocation = result;
    //
    //       if(userLocation != null && _locationProvider.locationModel?.status != null) {
    //
    //         if(isFirstLoadUserLocation == true){
    //           Future.delayed(const Duration(milliseconds: 50), () {
    //             animateBounce();
    //           });
    //           isFirstLoadUserLocation = false;
    //         }
    //
    //         ///User location update will bounce every once, causing almost infinity bounce if open comment
    //         //       animateBounce();
    //
    //       }
    //     });
    //   }
    // });
    //
    // if(userLocation != null && _locationProvider.locationModel?.status != null){
    //   locationListener();
    // }
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    // timer = Timer.periodic(const Duration(seconds: 1),
    //         (Timer t) => updateUserPositionAndBearing());

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Padding(
              //   padding:  EdgeInsets.only(top: 13.h),
              //   child: SvgPicture.asset(
              //     "assets/buttons/down.svg",
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 17.w, top: 10.h, bottom: 11.h),
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
                    padding:  EdgeInsets.only(bottom:250.h),
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
                  padding:  EdgeInsets.only(bottom:200.h),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () async {

                        pointBounce();
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
                                child: Battery(),
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
            ],
          ),

        ],
      ),
      height: 750.h,
    );
  }

  void locationListener() {
    //setButtonImage();
    //getDistanceBetween();
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    animateBounce();
    // loadImage(currentDangerStatus);
  }


  loadMarker() async {
    ///Marker
    options.clear();

    if(currentAnnotationId != null){
      mapboxMap?.annotations.removeAnnotationManager(currentAnnotationId);
    }

    mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {

      ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
        currentAnnotationId = pointAnnotationManager;

      ///Add danger threat
      if (_locationProvider.locationModel!.isConnected == true && _bikeProvider.currentBikeModel?.location?.status == "danger") {

        final ByteData bytes = await rootBundle.load("assets/icons/marker_danger.png");
        final Uint8List list = bytes.buffer.asUint8List();

        ///load a few more marker
        for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
          options.add(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
              _bikeProvider.threatRoutesLists.values
                      .elementAt(i)
                      .geopoint
                      .longitude ??
                  0,
              _bikeProvider.threatRoutesLists.values
                      .elementAt(i)
                      .geopoint
                      .latitude ??
                  0,
            )).toJson(),
            image: list,
            iconSize: 1.5.h,
          ));

          pointAnnotationManager.setIconAllowOverlap(false);
          pointAnnotationManager.createMulti(options);
        }
      } else {
        final ByteData bytes = await rootBundle.load(loadMarkerImageString(_locationProvider.locationModel?.status ?? "safe"));
        final Uint8List list = bytes.buffer.asUint8List();

        options.add(PointAnnotationOptions(
          geometry: Point(
                  coordinates: Position(
                      _locationProvider.locationModel?.geopoint.longitude ?? 0,
                      _locationProvider.locationModel?.geopoint.latitude ?? 0))
              .toJson(),
          image: list,
          iconSize: 1.5.h,
        ));

        pointAnnotationManager.setIconAllowOverlap(false);
        pointAnnotationManager.createMulti(options);
      }
    });

    ///User location
    final ByteData bytes = await rootBundle.load("assets/icons/user_location_icon.png");
    final Uint8List list = bytes.buffer.asUint8List();

    IMG.Image? img = IMG.decodeImage(list);
    IMG.Image resized = IMG.copyResize(img!, width: 40.w.toInt(), height: 60.h.toInt());
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
      layer =
      await mapboxMap?.style.getLayer("mapbox-location-indicator-layer");
    } else {
      layer = await mapboxMap?.style.getLayer("puck");
    }

    var location = (layer as LocationIndicatorLayer)?.location;
    setState(() {
      _position = Position(location![1]!, location[0]!);
    });
  }

  animateBounce() {
    mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
                  coordinates: Position(
                      _locationProvider.locationModel?.geopoint.longitude ?? 0,
                      _locationProvider.locationModel?.geopoint.latitude ?? 0))
              .toJson(),
          zoom: 16,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0));

    loadMarker();
  }


  pointBounce() {

    final LatLng southwest = LatLng(
      min(_locationProvider.locationModel?.geopoint.latitude ?? 0, _position.lat.toDouble()),
      min(_locationProvider.locationModel?.geopoint.longitude ?? 0, _position.lng.toDouble()),
    );

    final LatLng northeast = LatLng(
      max(_locationProvider.locationModel?.geopoint.latitude ?? 0, _position.lat.toDouble()),
      max(_locationProvider.locationModel?.geopoint.longitude ?? 0, _position.lng.toDouble()),
    );
    LatLngBounds latLngBounds = LatLngBounds(southwest, northeast);

    mapboxMap?.flyTo(
        CameraOptions(
          padding: MbxEdgeInsets(top: 100.h, left: 170.w, bottom: 180.h, right: 170.w),
          center: latLngBounds.center.toJson(),
       //    zoom: _getZoomLevel(latLngBounds, 350.w ,750.h),

        ),
        MapAnimationOptions(duration: 2000, startDelay: 0),
    );

  }

  double _getZoomLevel(LatLngBounds bounds, width, height) {
    const double GLOBE_WIDTH = 256;
    int zoomLevel = 0;
    double lngDiff = (bounds.northEast!.longitude - bounds.southWest!.longitude).abs();
    double latDiff = (bounds.northEast!.latitude - bounds.southWest!.latitude).abs();
    double pixelRatio = width / GLOBE_WIDTH;
    double combinedDiff = (lngDiff + latDiff) / 2;
    while (combinedDiff / pixelRatio > height) {
      combinedDiff /= 2;
      zoomLevel++;
    }
    return zoomLevel.toDouble();
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          color: Colors.transparent,
          child: Container(
            child: Transform.rotate(
              //   angle: (direction * (math.pi / 180) * -1),
              angle: (direction * (math.pi / 180) * 1),
              child: Image.asset('assets/icons/user_location_icon.png'),
            ),
          ),
        );
      },
    );
  }
}

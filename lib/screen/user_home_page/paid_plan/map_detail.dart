import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:evie_test/widgets/evie-unlocking-button.dart';
import 'package:evie_test/widgets/evie_card.dart';
import 'package:image/image.dart' as IMG;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../../../api/colours.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../api/dialog.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../bluetooth/modelResult.dart';
import 'home_element/location.dart';
import 'home_element/status.dart';

class MyPointAnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print('Point annotation clicked: ${annotation.id}');
  }
}

class MapDetails extends StatefulWidget {
  MapDetails({Key? key}) : super(key: key);

  @override
  State<MapDetails> createState() => _MapDetailsState();
}

class _MapDetailsState extends State<MapDetails> with WidgetsBindingObserver{
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;
  Timer? timer;

  int? snapshotLength;

  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  bool isFirstLoadUserLocation = true;
  bool isFirstLoadMarker = true;
  bool isMapListShowing = false;

  StreamSubscription? userLocationSubscription;
  Position userPosition = Position(0, 0);

  var options = <PointAnnotationOptions>[];
  var currentAnnotationIdList = [];

  List<map_launcher.AvailableMap>? availableMaps;
  GeoPoint? selectedGeopoint;
  bool? isConnected;
  String? locationStatus;
  bool? isLocked;

  final tooltipController = JustTheController();
  final _controller = SuperTooltipController();

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
    Future.delayed(const Duration(seconds: 1), () {
      _controller.showTooltip();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //_locationProvider.checkLocationPermissionStatus();
    }
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    userLocationSubscription?.cancel();
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
            //pulsingEnabled: true,
            //puckBearingEnabled: true,
            //accuracyRingColor: 6967754,
            //accuracyRingBorderColor: 6967754,
            puckBearingSource: PuckBearingSource.HEADING,
            locationPuck: LocationPuck(
                locationPuck2D: LocationPuck2D(
                  topImage: list2,
                  bearingImage: list,
                  //shadowImage: list3,
                )
            )
        ));
    await Future.delayed(Duration(seconds: 1));
    await updateUserPositionAndBearing(true);

    timer = Timer.periodic(const Duration(seconds: 2),
            (Timer t) => updateUserPositionAndBearing(false));
  }

  _onMapLoaded(MapLoadedEventData onMapLoaded) async {}

  _onStyleLoaded(StyleLoadedEventData onStyleLoaded) async {}

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 17.w, top: 0.h, bottom: 6.h),
                    child: Text(
                      "Orbital Anti-Theft",
                      style: EvieTextStyles.h1,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: IconButton(
                      onPressed: () {
                        _settingProvider.changeSheetElement(SheetList.threatHistory);
                      },
                      icon: SvgPicture.asset(
                        "assets/buttons/list_purple.svg",
                        width: 36.w,
                        height: 36.w,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: EvieColors.darkWhite,
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
                      onStyleLoadedListener: _onStyleLoaded,
                      styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                      cameraOptions: CameraOptions(
                        center: Point(
                            coordinates: Position(
                                _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                                _locationProvider.locationModel?.geopoint!.latitude ?? 0))
                            .toJson(),
                        zoom: 16,
                      ),
                      gestureRecognizers: [
                        Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())
                      ].toSet(),
                    ),

                    _locationProvider.hasLocationPermission == true ?
                    Padding(
                      padding:  EdgeInsets.only(bottom:240.h),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () async {
                            pointBounce3(mapboxMap, _locationProvider, userPosition);
                          },
                          child: Container(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                    padding: EdgeInsets.only(right: 8.h),
                                    child: Container(
                                      //color: Colors.red,
                                      width: 64.w,
                                      height: 64.w,
                                      child: SvgPicture.asset(
                                        "assets/buttons/location.svg",
                                      ),
                                    )
                                ),
                              ))
                        ),
                      ),
                    ) :
                    Padding(
                      padding: EdgeInsets.only(bottom: 260.h),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            showEvieAllowOrbitalDialog(_locationProvider);
                          },
                          child: SuperTooltip(
                            onShow: () async {
                              await Future.delayed(Duration(seconds: 3));
                              _controller.hideTooltip();
                            },
                            backgroundColor: Colors.black,
                            showBarrier: false,
                            controller: _controller,
                            popupDirection: TooltipDirection.up,
                            hasShadow: false,
                            content: Padding(
                              padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                              child: Text(
                                "See your location",
                                softWrap: true,
                                style: EvieTextStyles.body14.copyWith(color: Colors.white),
                              ),
                            ),
                            child: GestureDetector(
                              child: Container(
                                //color: Colors.red,
                                padding: EdgeInsets.only(top: 20.h),
                                width: 70.w,
                                height: 70.w,
                                child: SvgPicture.asset(
                                  "assets/buttons/location_unavailable.svg",
                                ),
                              ),
                              onTap: () {
                                showEvieAllowOrbitalDialog(_locationProvider);
                              },
                            )
                          ),
                        )
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(bottom:23.h),
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
                                  child: EvieCard(
                                    child: UnlockingButton(),
                                  )
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
    if (selectedGeopoint != _locationProvider.locationModel?.geopoint) {
      selectedGeopoint = _locationProvider.locationModel?.geopoint;
      pointBounce3(mapboxMap, _locationProvider, userPosition);
      loadMarker();
    }

    if (isConnected != _locationProvider.locationModel?.isConnected || locationStatus != _locationProvider.locationModel?.status) {
      selectedGeopoint = _locationProvider.locationModel?.geopoint;
      locationStatus = _locationProvider.locationModel?.status;
      isConnected = _locationProvider.locationModel?.isConnected;
      pointBounce3(mapboxMap, _locationProvider, userPosition);
      loadMarker();
    }

    if (isLocked != _bikeProvider.currentBikeModel?.isLocked) {
      isLocked = _bikeProvider.currentBikeModel?.isLocked;
      pointBounce3(mapboxMap, _locationProvider, userPosition);
      loadMarker();
    }
  }

  loadMarker() async {

    ///Marker
    options.clear();
    if(currentAnnotationIdList.isNotEmpty){
      ///Check if have this id
      currentAnnotationIdList.forEach((element) async {
        await mapboxMap?.annotations.removeAnnotationManager(element);
      });
    }


    await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {

      ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
      currentAnnotationIdList.add(pointAnnotationManager);

      if(_locationProvider.locationModel!.isConnected == false){
        final ByteData bytes = await rootBundle.load("assets/icons/security/offline_4x.png");
        final Uint8List list = bytes.buffer.asUint8List();

        options.add(PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(
                  _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                  _locationProvider.locationModel?.geopoint!.latitude ?? 0))
              .toJson(),
          image: list,
          iconSize: Platform.isAndroid ? 38.mp : 16.mp,
        ));

        ///Add danger threat
      }else if (_locationProvider.locationModel!.isConnected == true && _bikeProvider.currentBikeModel?.location?.status == "danger") {

        // final ByteData bytes = await rootBundle.load("assets/icons/security/danger_4x.png");
        // final Uint8List list = bytes.buffer.asUint8List();
        //
        // ///load a few more marker
        // for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
        //   options.add(PointAnnotationOptions(
        //     geometry: Point(
        //         coordinates: Position(
        //           _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.longitude ?? 0,
        //           _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.latitude ?? 0,
        //         )).toJson(),
        //     image: list,
        //     iconSize: 35.mp,
        //   ));
        // }
        Navigator.pop(context);
      } else {
        final ByteData bytes = await rootBundle.load(loadMarkerImageString(_locationProvider.locationModel?.status ?? "safe", _bikeProvider.currentBikeModel?.isLocked ?? false));
        final Uint8List list = bytes.buffer.asUint8List();
        options.add(PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(
                  _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                  _locationProvider.locationModel?.geopoint!.latitude ?? 0))
              .toJson(),
          image: list,
          //iconImage: "assets/icons/security/safe_lock_3x.png",
          iconSize: Platform.isAndroid ? 38.mp : 16.mp,
        ));
      }
      pointAnnotationManager.setIconAllowOverlap(false);
      pointAnnotationManager.createMulti(options);
      pointAnnotationManager.addOnPointAnnotationClickListener(MyPointAnnotationClickListener());
    });
  }

  Future<void> updateUserPositionAndBearing(bool isFirstTime) async {
    Layer? layer;
    if (Platform.isAndroid) {
      layer =
      await mapboxMap?.style.getLayer("mapbox-location-indicator-layer");
    } else {
      layer = await mapboxMap?.style.getLayer("puck");
    }

    var location = (layer as LocationIndicatorLayer)?.location;
    userPosition = Position(location![1]!, location[0]!);
    num? latitude = userPosition[1];
    num? longitude = userPosition[0];
    _locationProvider.setUserPosition(GeoPoint(latitude!.toDouble(), longitude!.toDouble()));

    if (isFirstTime) {
      pointBounce3(mapboxMap, _locationProvider, userPosition);
    }
  }
}

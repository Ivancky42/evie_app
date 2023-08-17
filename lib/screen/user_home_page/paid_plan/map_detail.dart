import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/battery.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/rides.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/setting.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/unlocking_system.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as IMG;
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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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

class _MapDetailsState extends State<MapDetails> {
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

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.addListener(locationListener);
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    userLocationSubscription?.cancel();
    timer?.cancel();
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    loadMarker();

    ///User location
    final ByteData bytes = await rootBundle.load("assets/icons/user_location_icon.png");
    final Uint8List list = bytes.buffer.asUint8List();

    IMG.Image? img = IMG.decodeImage(list);
    IMG.Image resized = IMG.copyResize(img!, width: 50.w.toInt(), height:70.h.toInt());
    Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));

    await mapboxMap.location.updateSettings(
        LocationComponentSettings(
            enabled: true,
            pulsingEnabled: true,
            puckBearingEnabled: true,
            locationPuck: LocationPuck(
                locationPuck2D: LocationPuck2D(
                  topImage: resizedImg,
                  bearingImage: resizedImg,
                  shadowImage: resizedImg,
                  //scaleExpression: "50",
                ))
        ));

    timer = Timer.periodic(const Duration(seconds: 1),
            (Timer t) => updateUserPositionAndBearing());
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
                    padding: EdgeInsets.only(left: 17.w, top: 0.h, bottom: 0.h),
                    child: Text(
                      "Orbital Anti-Theft 2",
                      style: EvieTextStyles.h1,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only( top: 12.h,),
                    child: IconButton(
                      onPressed: () {
                        _settingProvider.changeSheetElement(SheetList.threatHistory);
                      },
                      icon: SvgPicture.asset(
                        "assets/buttons/list_purple.svg",

                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 0.5,
                color: EvieColors.darkWhite,
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
                      padding:  EdgeInsets.only(bottom:270.h),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () async {
                            _locationProvider.hasLocationPermission == true ?
                            pointBounce2(mapboxMap, _locationProvider, userPosition) :
                            {
                              if (await Permission.location.request().isGranted && await Permission.locationWhenInUse.request().isGranted) {
                                _locationProvider.checkLocationPermissionStatus()
                              }else if(await Permission.location.isPermanentlyDenied || await Permission.location.isDenied){
                                showLocationServiceDisable()
                              }
                            };
                          },
                          child: Container(
                              height: 50.h,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8.h),
                                  child: SvgPicture.asset(
                                    _locationProvider.hasLocationPermission == true ? "assets/buttons/location.svg" : "assets/buttons/location_unavailable.svg",
                                    width: 50.w,
                                    height: 50.h,
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),

                    Padding(
                      padding:  EdgeInsets.only(bottom:220.h),
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
                                  child: UnlockingSystem(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                        padding: EdgeInsets.only(left:16.w, right: 16.w),
                        child: Container(
                          width: double.infinity,
                          height: 36.h,
                          child: Padding(
                            padding: EdgeInsets.only(left:8.w, right: 8.w),
                            child: Row(
                              children: [
                                ///Get icon by status
                                SvgPicture.asset(
                                  getCurrentBikeStatusIconSimple(_bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
                                ),

                                SizedBox(width: 5.w),

                                ///Get text by status
                                Text(getCurrentBikeStatusString(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected, _bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
                                  style: EvieTextStyles.body16.copyWith(color: EvieColors.grayishWhite),),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(

                            ///Get colour by status
                            color: _bikeProvider.currentBikeModel!.location!.isConnected == false ||
                                _bikeProvider.currentBikeModel!.location!.status == "warning" ||
                                _bikeProvider.currentBikeModel!.location!.status == "fall" ?
                            EvieColors.orange : EvieColors.darkWhite,

                            borderRadius: BorderRadius.circular(10.w),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(122, 122, 121, 0.15),
                                offset: Offset(0, 3),
                                blurRadius: 12.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                        )
                    )

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
    animateBounce(mapboxMap, _locationProvider.locationModel?.geopoint.longitude ?? 0, _locationProvider.locationModel?.geopoint.latitude ?? 0);
    loadMarker();
    // loadImage(currentDangerStatus);
    //pointBounce(mapboxMap, _locationProvider, userPosition);
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
        final ByteData bytes = await rootBundle.load("assets/icons/marker_warning.png");
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

        ///Add danger threat
      }else if (_locationProvider.locationModel!.isConnected == true && _bikeProvider.currentBikeModel?.location?.status == "danger") {

        final ByteData bytes = await rootBundle.load("assets/icons/marker_danger.png");
        final Uint8List list = bytes.buffer.asUint8List();

        ///load a few more marker
        for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
          options.add(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
                  _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.longitude ?? 0,
                  _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint.latitude ?? 0,
                )).toJson(),
            image: list,
            iconSize: 1.5.h,
          ));
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
      }
      pointAnnotationManager.setIconAllowOverlap(false);
      pointAnnotationManager.createMulti(options);
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
}

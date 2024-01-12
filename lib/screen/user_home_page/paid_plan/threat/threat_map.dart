import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/shared_pref_provider.dart';
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
import 'package:open_settings/open_settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:timelines/timelines.dart';

import '../../../../api/colours.dart';
import '../../../../api/function.dart';
import '../../../../api/model/threat_routes_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import 'package:latlong2/latlong.dart';

import '../home_element/battery.dart';
import '../home_element/location.dart';
import '../home_element/threat_unlocking_system.dart';


class ThreatMap extends StatefulWidget {
  final bool? triggerConnect;
  const ThreatMap(this.triggerConnect, {Key? key}) : super(key: key);

  @override
  State<ThreatMap> createState() => _ThreatMapState();
}

class _ThreatMapState extends State<ThreatMap> with WidgetsBindingObserver{

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SharedPreferenceProvider _sharedPreferenceProvider;

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

  final double _initFabHeight = 300;
  double _fabHeight = 0;
  double _panelHeightOpen = 244.h;
  double _panelHeightClosed = 95.h;
  late final ScrollController scrollController;
  late final PanelController panelController;

  LinkedHashMap currentThreatRoutesLists = LinkedHashMap<String, ThreatRoutesModel>();

  bool isShowGPSLost = false;


  @override
  void initState() {
    scrollController = ScrollController();
    panelController = PanelController();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bluetoothProvider = context.read<BluetoothProvider>();
    _bikeProvider = context.read<BikeProvider>();
    _sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    _fabHeight = _initFabHeight;
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

    ///Unsub here
    String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
    _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~theft-attempt", false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
      _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~theft-attempt", false);
      _locationProvider.checkLocationPermissionStatus();
    }
    else if (state == AppLifecycleState.inactive) {
      String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
      _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~theft-attempt", true);
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
    _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~theft-attempt", true);
    _locationProvider.removeListener(locationListener);
    userLocationSubscription?.cancel();
    options.clear();
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    loadMarker2();

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
          puckBearingSource: PuckBearingSource.COURSE,
          locationPuck: LocationPuck(
              locationPuck2D: LocationPuck2D(
                topImage: list2,
                bearingImage: list,
                //shadowImage: list3,
              )
          )
        ));

    await Future.delayed(const Duration(seconds: 1));
    await updateUserPositionAndBearing(true);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    timer = Timer.periodic(const Duration(seconds: 1),
            (Timer t) async => await updateUserPositionAndBearing(false));

  }

  _onMapLoaded(MapLoadedEventData onMapLoaded) async {
    ///On map create function
  }
  void initLocationService() async {
    ///Any location service
  }


  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .30;
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
            height: Platform.isIOS ? 120.h : 90.h,
            color: EvieColors.lightBlack,
            child: Padding(
              padding: EdgeInsets.only(left: 17.w, top: Platform.isIOS ? 50.h : 30.h, bottom: 0, right:10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: (){
                        showEvieExitOrbitalDialog(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/close.svg",
                      )),
                  Text(
                    "EV-Secure",
                    style: EvieTextStyles.h2.copyWith(color: EvieColors.grayishWhite),
                   ),

                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      changeToThreatTimeLine(context, PageTransitionType.fade);
                    },
                    icon: SvgPicture.asset(
                      "assets/buttons/list.svg",
                      width: 36.w,
                      height: 36.w,
                    ),
                  ),
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

                    SlidingUpPanel(
                      defaultPanelState: PanelState.OPEN,
                      panelSnapping: false,
                      snapPoint: .9,
                      disableDraggableOnScrolling: false,
                      color: EvieColors.grayishWhite2,
                      header: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ForceDraggableWidget(
                              child: Container(
                                width: 100,
                                height: 40,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 12.0,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: 40.w,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                              color: EvieColors.lightGrayishCyan,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12.0))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      maxHeight: _panelHeightOpen,
                      minHeight: _panelHeightClosed,
                      parallaxEnabled: true,
                      parallaxOffset: .5,
                      body: Container(),
                      controller: panelController,
                      scrollController: scrollController,
                      panelBuilder: () => Padding(
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
                                    child: ThreatUnlockingSystem(page: 'map'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0)),
                      onPanelSlide: (double pos) => setState(() {
                        _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                            120;
                      }),
                    ),

                    Positioned(
                      right: 15.w,
                      top: 67.h,
                      child: GestureDetector(
                        onTap: () async {
                          showWhatToDoDialog(context);
                        },
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          child: SvgPicture.asset(
                            "assets/buttons/info-black.svg",
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 10.w,
                      bottom: _fabHeight - 20.h,
                      child: GestureDetector(
                        onTap: () async {
                          if (_locationProvider.hasLocationPermission) {
                            pointBounce3(mapboxMap, _locationProvider, userPosition);
                          }
                          else {
                            if (await Permission.location.request().isGranted && await Permission.locationWhenInUse.request().isGranted) {

                            }
                            else if(await Permission.location.isPermanentlyDenied || await Permission.location.isDenied){
                              if (Platform.isIOS) {
                                OpenSettings.openLocationSourceSetting();
                              }
                            }
                            _locationProvider.checkLocationPermissionStatus();
                          }
                        },
                        child: Container(
                            width: 64.w,
                            height: 64.w,
                            child: SvgPicture.asset(
                              _locationProvider.hasLocationPermission == true ? "assets/buttons/location.svg" : "assets/buttons/location_unavailable.svg",
                            ),
                        ),
                      ),
                    ),

                    isShowGPSLost ?
                    Positioned(
                      top: 20.h,
                      left: 20.w,
                      child: GestureDetector(
                        onTap: () {
                          showGPSNotFound();
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/notification_alert.svg",
                                ),
                                SizedBox(width: 10.w,),
                                Text(
                                  'Lost GPS location.',
                                  style: EvieTextStyles.body14,
                                )
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: EvieColors.thumbColorTrue,
                            borderRadius: BorderRadius.circular(10.w),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
                                offset: Offset(0, 8), // X and Y offset
                                blurRadius: 16, // Blur radius
                                spreadRadius: 0, // Spread radius
                              ),
                            ],
                          ),
                        ),
                      )
                    ) : Container(),
                  ],
             ),
          ),
       ]
      ),
      height: 750.h,
    );
  }

  void locationListener() {
    if (selectedGeopoint != _locationProvider.locationModel?.geopoint) {
      selectedGeopoint = _locationProvider.locationModel?.geopoint;
      pointBounce3(mapboxMap, _locationProvider, userPosition);
      loadMarker2();
    }
    else if (_bikeProvider.isUpdateThreat) {
      Future.delayed(Duration.zero).then((value) {
        _bikeProvider.setIsUpdateThreat();
      });
      pointBounce3(mapboxMap, _locationProvider, userPosition);
      loadMarker2();
    }
  }

  loadMarker2() async {
    List<Uint8List> pins = [];

    ///Clear Marker
    options.clear();

    ///Check if have this manager
    if(currentAnnotationManager != null){
      await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationManager as BaseAnnotationManager);
      currentAnnotationManager = null;
    }

    ThreatRoutesModel threatRoutesModel = _bikeProvider.threatRoutesLists.values.elementAt(0);
    if (threatRoutesModel.geopoint?.latitude == 0 && threatRoutesModel.geopoint?.longitude == 0) {
      setState(() {
        isShowGPSLost = true;
      });
    }
    else {
      setState(() {
        isShowGPSLost = false;
      });
    }

    await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
      ///Using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen

      ///Create new annotation manager
      currentAnnotationManager = pointAnnotationManager;
      if(pointAnnotation != null){
        pointAnnotation?.forEach((element) {currentAnnotationManager?.delete(element);});
        pointAnnotation?.clear();
      }

      final ByteData bytes = await rootBundle.load("assets/icons/security/danger_4x.png");
      final Uint8List dangerMain = bytes.buffer.asUint8List();

      options.add(PointAnnotationOptions(
        geometry: Point(
            coordinates: Position(
                _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                _locationProvider.locationModel?.geopoint!.latitude ?? 0))
            .toJson(),
        image: dangerMain,
        iconSize: Platform.isAndroid ? 38.mp : 16.mp,
      ));

      ///Load and add 7 image
      for (int i = 1; i <= 7; i++) {
        if (i != 1) {
          final ByteData bytes = await rootBundle.load(
              "assets/icons/danger_pin/danger_pin_${i.toString()}.png");
          final Uint8List list = bytes.buffer.asUint8List();
          pins.add(list);
        }
      }

      ///threatRoutesLists.length is always 7 or less
      for (int i = 0; i < _bikeProvider.threatRoutesLists.length; i++) {
        if (i != 0) {
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
              image: pins[i - 1],
              iconSize: Platform.isAndroid ? 0.8 : 0.4,
            ),);

          currentAnnotationManager?.setIconAllowOverlap(false);
          currentAnnotationManager?.createMulti(options);
        }
      }

      if (_bikeProvider.threatRoutesLists.length == 1) {
        currentAnnotationManager?.setIconAllowOverlap(false);
        currentAnnotationManager?.createMulti(options);
      }

      currentAnnotationManager?.addOnPointAnnotationClickListener(MyPointAnnotationClickListener(_locationProvider));
    });
  }

  void createOneAnnotation(Uint8List list, latitude, longitude) {
    currentAnnotationManager?.create(
        PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
                  latitude, longitude,
                )).toJson(),
            iconSize: Platform.isIOS ? 0.5 : 0.5, image: list))
        .then((value) {pointAnnotation?.add(value);});
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

class MyPointAnnotationClickListener extends OnPointAnnotationClickListener {
  PointAnnotation? currentClickedAnnotation;

  late LocationProvider _locationProvider;

  MyPointAnnotationClickListener(LocationProvider locationProvider) {
    _locationProvider = locationProvider;
  }

  @override
   onPointAnnotationClick(PointAnnotation annotation) {
    //print('Point annotation clicked: ${annotation.id}');
    //print('Point Geometry: ' + annotation.geometry!['coordinates'].toString());
    currentClickedAnnotation = annotation;
    _locationProvider.setSelectedAnnotation(currentClickedAnnotation!);
  }
}

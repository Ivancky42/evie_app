import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/orbital_list_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/model/event_model.dart';
import '../../../../api/model/location_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/current_user_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_card_2.dart';

class OrbitalAntiTheft extends StatefulWidget  {
  OrbitalAntiTheft({
    Key? key
  }) : super(key: key);

  @override
  State<OrbitalAntiTheft> createState() => _OrbitalAntiTheftState();
}

class _OrbitalAntiTheftState extends State<OrbitalAntiTheft> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;

  GeoPoint? selectedGeopoint;
  String? locationStatus;
  bool? isConnected;
  bool? isLocked;
  DeviceConnectResult? deviceConnectResult;

  var options = <PointAnnotationOptions>[];
  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  var currentAnnotationIdList = [];
  var markers = <Marker>[];
  int _currentIndex = 0;
  List<PointAnnotation>? pointAnnotation;


  @override
  void initState() {
    super.initState();
    // _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((value) {
      _locationProvider = Provider.of<LocationProvider>(context, listen: false);
      _locationProvider.setDefaultSelectedGeopoint();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationProvider.checkLocationPermissionStatus();
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
   this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    mapCreatedAnimateBounce();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    locationListener();

    List<Widget> _widgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FutureBuilder(
                future: getLocationModel(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
                      child: Center(
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              height: 300.h,
                              width: 170.w,
                              child: Transform.translate(
                                offset: Offset(0, -75.h),
                                child: Stack(
                                  children: [
                                    MapWidget(
                                      onTapListener: (hello) {
                                        if(_currentIndex == 0){
                                          _locationProvider.locations();
                                          if(_locationProvider.locationModel?.isConnected == false){
                                            _settingProvider.changeSheetElement(SheetList.mapDetails);
                                            showSheetNavigate(context);
                                          }else if(_bikeProvider.currentBikeModel?.location?.status == "danger") {
                                            // _settingProvider.changeSheetElement(SheetList.mapDetails);
                                            // showSheetNavigate(context);
                                            changeToThreatMap(context, false);
                                          }else{
                                            _settingProvider.changeSheetElement(SheetList.mapDetails);
                                            showSheetNavigate(context);
                                          }
                                        }else{
                                          if(_locationProvider.locationModel?.isConnected == false){
                                            _locationProvider.locations();
                                            _settingProvider.changeSheetElement(SheetList.threatHistory);
                                            showSheetNavigate(context);
                                          }else if(_bikeProvider.currentBikeModel?.location?.status == "danger"){
                                            _locationProvider.locations();
                                            changeToThreatTimeLine(context);
                                          }else {
                                            _settingProvider.changeSheetElement(SheetList.threatHistory);
                                            showSheetNavigate(context);
                                          }
                                        }
                                      },
                                      onScrollListener: onMapScrollListener,
                                      key: const ValueKey("mapWidget"),
                                      resourceOptions: ResourceOptions(
                                          accessToken: _locationProvider.defPublicAccessToken),
                                      onMapCreated: _onMapCreated,
                                      styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                                      cameraOptions: CameraOptions(
                                        center: Point(
                                            coordinates: Position(
                                                _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                                                _locationProvider.locationModel?.geopoint!.latitude ?? 0))
                                            .toJson(),
                                        zoom: 12,
                                      ),
                                    ),

                                    _locationProvider.hasLocationPermission ? SizedBox.shrink() : Positioned(
                                      bottom: 70.h,
                                      right: 10.w,
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        //onTap camera pic
                                        child: GestureDetector(
                                          onTap: () async {
                                            showEvieAllowOrbitalDialog(_locationProvider);
                                          },
                                          child: SvgPicture.asset(
                                            "assets/buttons/location_unavailable.svg",
                                            width: 36.w,
                                            height: 36.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: material.CircularProgressIndicator(color: EvieColors.primaryColor,),
                    );
                  }
                }),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 0, left:16.w, right:16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SvgPicture.asset(getCurrentBikeStatusIcon(_bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),),
                    _bikeProvider.currentBikeModel?.location?.status == 'safe' && _bikeProvider.currentBikeModel?.location?.isConnected == true ?
                    _bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?
                    Selector<BluetoothProvider, LockState?>(
                      selector: (context, bluetoothProvider) => bluetoothProvider.cableLockState?.lockState,
                      builder: (context, lockState, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(getCurrentBikeStatusIcon2(lockState)),
                            Text(
                              getCurrentBikeStatusString4(lockState),
                              style: EvieTextStyles.headlineB.copyWith(
                                color: EvieColors.darkGray,
                                height: 1.22,
                              ),
                            ),
                          ],
                        );
                      },
                    ) :
                    Consumer2<BikeProvider, BluetoothProvider>(
                      builder: (context, bikeProvider, bluetoothProvider, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(getCurrentBikeStatusIcon(bikeProvider.currentBikeModel!, bikeProvider, bluetoothProvider),),
                            Text(getCurrentBikeStatusString3(
                                bikeProvider, bluetoothProvider),
                              style: EvieTextStyles.headlineB.copyWith(
                                  color: EvieColors.darkGray, height: 1.22),),
                          ],
                        );
                      },
                    ) :
                    Consumer2<BikeProvider, BluetoothProvider>(
                    builder: (context, bikeProvider, bluetoothProvider, child) {
                      // return Text(getCurrentBikeStatusString2(bikeProvider, bluetoothProvider),
                      //   style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray, height: 1.22),);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bikeProvider.currentBikeModel != null ?
                          SvgPicture.asset(getCurrentBikeStatusIcon(bikeProvider.currentBikeModel, bikeProvider, bluetoothProvider),) : Container(),
                          Text(getCurrentBikeStatusString3(
                              bikeProvider, bluetoothProvider),
                            style: EvieTextStyles.headlineB.copyWith(
                                color: EvieColors.darkGray, height: 1.22),),
                        ],
                      );
                    },
                  ),

                  Selector<LocationProvider, String?>(
                    selector: (context, locationProvider) => _locationProvider.currentPlaceMarkString,
                    builder: (context, currentPlaceMarkString, child) {
                      return Container(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          currentPlaceMarkString ?? 'Loading',
                          style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumLightBlack, height: 1.2),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      );
                    },
                  ),
                  ///Bike provider lastUpdated minus current timestamp
                 Container(
                   padding: EdgeInsets.only(top: 4.h),
                   child: Text(calculateTimeAgo(_locationProvider.locationModel!.updated!.toDate()),
                            style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack)),
                 ),
                ],
              ),
            ),
          ),
        ],
      ),
      PaginateFirestore(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 16.w),
        itemsPerPage: 3,
        isLive: false,
        bottomLoader: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 24),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: EvieColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshots, index) {
          // Check if there is data at the given index
          if (index < documentSnapshots.length) {
            DocumentSnapshot snapshot = documentSnapshots[index];
            Map<String, dynamic>? obj = snapshot.data() as Map<String, dynamic>?;
            if (obj != null) {
              EventModel eventModel = EventModel.fromJson(snapshot.id, obj);
              if (eventModel.type != 'lost') {
                return OrbitalListContainer(eventModel: eventModel);
              }
              else {
                return Container();
              }
            }
          }

          // Return a placeholder or an empty widget if there's no data to display
          return Container();
        },
        query: FirebaseFirestore.instance.collection("bikes")
            .doc(_bikeProvider.currentBikeModel?.deviceIMEI)
            .collection("events")
            .orderBy("created", descending: true),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        border: returnBorderColour(_locationProvider),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
            offset: Offset(0, 8), // X and Y offset
            blurRadius: 16, // Blur radius
            spreadRadius: 0, // Spread radius
          ),
        ],
      ),
      child: Stack(
        children: [
          EvieCard2(
            onPress: (){
              ///Location
              if(_currentIndex == 0){
                _locationProvider.locations();
                if(_locationProvider.locationModel?.isConnected == false){
                  _settingProvider.changeSheetElement(SheetList.mapDetails);
                    showSheetNavigate(context);
                }else if(_bikeProvider.currentBikeModel?.location?.status == "danger") {
                  // _settingProvider.changeSheetElement(SheetList.mapDetails);
                  // showSheetNavigate(context);
                  changeToThreatMap(context, false);
                }else{
                  _settingProvider.changeSheetElement(SheetList.mapDetails);
                  showSheetNavigate(context);
                }
              }else{
                if(_locationProvider.locationModel?.isConnected == false){
                  _locationProvider.locations();
                  _settingProvider.changeSheetElement(SheetList.threatHistory);
                  showSheetNavigate(context);
                }else if(_bikeProvider.currentBikeModel?.location?.status == "danger"){
                  _locationProvider.locations();
                  changeToThreatTimeLine(context);
                }else {
                  _settingProvider.changeSheetElement(SheetList.threatHistory);
                  showSheetNavigate(context);
                }
              }
            },
            child: Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: CarouselSlider(
                          items: _widgets,
                          options: CarouselOptions(
                            padEnds: false,
                            height: double.infinity,
                            autoPlay: false,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            aspectRatio: 16/9,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            viewportFraction: 1.0,
                          ),
                        ),
                      ),


                      Padding(
                        padding: EdgeInsets.only(bottom: 9.h, right:25.w, top: 6.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _widgets.map((item) {
                            int index = _widgets.indexOf(item);
                            bool isCurrentIndex = _currentIndex == index;
                            //  double horizontalMargin = index == 0 ? 0.0 : 6.0;
                            double horizontalMargin = index == 0 ? 6.0 : 0.0;

                            return Container(
                              width: 6.w,
                              height: 6.h,
                              margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: horizontalMargin),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrentIndex ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          _bikeProvider.currentBikeModel?.location?.status == "danger" ?
          GestureDetector(
            onTap: (){
              showActionListSheet(context, [ActionList.deactivateTheftAlert]);
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                color: Colors.transparent,
                width: 100.w,
                height: 70.h,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: IconButton(
                        iconSize: 42.w,
                        icon: SvgPicture.asset(
                          "assets/buttons/dot.svg",
                        ),
                        onPressed: () {
                          showActionListSheet(context, [ActionList.deactivateTheftAlert]);
                        },
                      )
                  ),
                )
              ),
            ),
          ) : Container(),
        ],
      )
    );
  }

  Future<LocationModel?> getLocationModel() async {
    return _locationProvider.locationModel;
  }

  void locationListener() {
    if (isConnected != _locationProvider.locationModel?.isConnected || locationStatus != _locationProvider.locationModel?.status) {
      selectedGeopoint = _locationProvider.locationModel?.geopoint;
      locationStatus = _locationProvider.locationModel?.status;
      isConnected = _locationProvider.locationModel?.isConnected;
      mapCreatedAnimateBounce();
    }
    else {
      if (selectedGeopoint != _locationProvider.locationModel?.geopoint) {
        selectedGeopoint = _locationProvider.locationModel?.geopoint;
        locationStatus = _locationProvider.locationModel?.status;
        isConnected = _locationProvider.locationModel?.isConnected;
        mapCreatedAnimateBounce();
      }
    }
    if (isLocked != _bikeProvider.currentBikeModel?.isLocked) {
      isLocked = _bikeProvider.currentBikeModel?.isLocked;
      mapCreatedAnimateBounce();
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

      ///Add disconnected threat
      if(_locationProvider.locationModel!.isConnected == false){
        final ByteData bytes = await rootBundle.load("assets/icons/security/offline_4x.png");
        final Uint8List list = bytes.buffer.asUint8List();

        options.add(
            PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(
                        _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                        _locationProvider.locationModel?.geopoint!.latitude ?? 0
                    )).toJson(),
                iconSize: Platform.isAndroid ? 34.mp : 14.mp,
                image: list)
            );

        ///Add danger threat
      }
      else if (_locationProvider.locationModel!.isConnected == true && _bikeProvider.currentBikeModel?.location?.status == "danger") {

        final ByteData bytes = await rootBundle.load("assets/icons/security/danger_4x.png");
        final Uint8List list = bytes.buffer.asUint8List();

        options.add(
            PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(
                        _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                        _locationProvider.locationModel?.geopoint!.latitude ?? 0
                    )).toJson(),
                //iconSize: 170.w * 0.003,
                iconSize: Platform.isAndroid ? 34.mp : 14.mp,
                image: list));

      }
      else {
        final ByteData bytes = await rootBundle.load(loadMarkerImageString(_locationProvider.locationModel?.status ?? "safe", _bikeProvider.currentBikeModel?.isLocked ?? false));
        final Uint8List list = bytes.buffer.asUint8List();

        options.add(
            PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(
                        _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                        _locationProvider.locationModel?.geopoint!.latitude ?? 0
                    )).toJson(),
                iconSize: Platform.isAndroid ? 34.mp : 14.mp,
                image: list)
        );
      }

      pointAnnotationManager.setIconAllowOverlap(false);
      pointAnnotationManager.createMulti(options);

    });
  }


  void mapCreatedAnimateBounce() {
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    if (mapboxMap != null) {
      animateBounce();
    }
  }


  void animateBounce() {
    loadMarker();
    mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
              coordinates: Position(
                  _locationProvider.locationModel?.geopoint!.longitude ?? 0,
                  _locationProvider.locationModel?.geopoint!.latitude ?? 0))
              .toJson(),
          zoom: 12,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0));
  }

}



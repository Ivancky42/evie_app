import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/model/location_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/current_user_provider.dart';
import '../../../../api/provider/notification_provider.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../add_new_bike/mapbox_widget.dart';
import 'package:latlong2/latlong.dart';

import '../../home_page_widget.dart';

class OrbitalAntiTheft2 extends StatefulWidget {


  OrbitalAntiTheft2({
    Key? key
  }) : super(key: key);

  @override
  State<OrbitalAntiTheft2> createState() => _OrbitalAntiTheft2State();
}

class _OrbitalAntiTheft2State extends State<OrbitalAntiTheft2> with SingleTickerProviderStateMixin {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late CurrentUserProvider _currentUserProvider;

  GeoPoint? selectedGeopoint;
  DeviceConnectResult? deviceConnectResult;

  var options = <PointAnnotationOptions>[];
  MapboxMap? mapboxMap;
  OnMapScrollListener? onMapScrollListener;

  var currentAnnotationId;
  var markers = <Marker>[];

  late AnimationController _animationController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    _locationProvider.addListener(locationListener);
  }

  @override
  void dispose() {
    _locationProvider.removeListener(locationListener);
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) async {
   this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

   loadMarker();
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    List<Widget> _widgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FutureBuilder(
                future: getLocationModel(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 220.h,
                                  child: MapWidget(
                                    onScrollListener: onMapScrollListener,
                                    key: const ValueKey("mapWidget"),
                                    resourceOptions: ResourceOptions(
                                        accessToken: _locationProvider.defPublicAccessToken),
                                    onMapCreated: _onMapCreated,
                                    styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                                    cameraOptions: CameraOptions(
                                      center: Point(
                                          coordinates: Position(
                                              _locationProvider.locationModel?.geopoint.longitude ?? 0,
                                              _locationProvider.locationModel?.geopoint.latitude ?? 0))
                                          .toJson(),
                                      zoom: 12,
                                    ),
                                    // gestureRecognizers: [
                                    //   Factory<OneSequenceGestureRecognizer>(
                                    //           () => EagerGestureRecognizer())
                                    // ].toSet(),
                                  ),

                                  // child: Mapbox_Widget(
                                  //   isInteract: false,
                                  //   accessToken: _locationProvider.defPublicAccessToken,
                                  //   //onMapCreated: _onMapCreated,
                                  //   mapController: mapController,
                                  //   markers: markers,
                                  //   // onUserLocationUpdate: (userLocation) {
                                  //   //   if (this.userLocation != null) {
                                  //   //     this.userLocation = userLocation;
                                  //   //     getDistanceBetween();
                                  //   //   }
                                  //   //   else {
                                  //   //     this.userLocation = userLocation;
                                  //   //     getDistanceBetween();
                                  //   //     runSymbol();
                                  //   //   }
                                  //   // },
                                  //   latitude: _locationProvider.locationModel!.geopoint.latitude,
                                  //   longitude: _locationProvider.locationModel!.geopoint.longitude,
                                  //   zoom: 15,
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(getCurrentBikeStatusIcon(_bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),),
                  Text(getCurrentBikeStatusString(deviceConnectResult == DeviceConnectResult.connected, _bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
                    style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray),),

                  selectedGeopoint != null ? FutureBuilder<dynamic>(
                      future: _locationProvider.returnPlaceMarks(selectedGeopoint!.latitude, selectedGeopoint!.longitude),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data.name.toString(),
                            style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                          );
                        }else{
                          return Text(
                            "loading",
                            style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                          );
                        }
                      }
                  )
                      : Text(_locationProvider.currentPlaceMark?.name ?? "Not available",style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),),

                  ///Bike provider lastUpdated minus current timestamp
                  Text(calculateTimeAgo(_bikeProvider.currentBikeModel!.lastUpdated!.toDate()),
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack)),
                ],
              ),
            ),
          ),
        ],
      ),

      PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map?;
          if(_bikeProvider.threatFilterArray.contains(data!['type'])) {
            return Column(
              children: [
                ListTile(
                    leading: data == null ? const Text('Error')
                        : SvgPicture.asset(
                      getSecurityIconWidget(data['type']),
                      height: 36.h,
                      width: 36.w,
                    ),
                    title: data == null ? const Text('Error')
                        : data["address"] != null
                        ? Text(data["address"], style: EvieTextStyles.body18,)
                        : FutureBuilder<dynamic>(
                        future: _locationProvider.returnPlaceMarks(
                            data["geopoint"].latitude,
                            data["geopoint"].longitude),
                        builder: (context, snapshot) {

                          if (snapshot.hasData) {
                            _bikeProvider.uploadPlaceMarkAddressToFirestore(
                                _bikeProvider.currentBikeModel!.deviceIMEI!,
                                documentSnapshots[index].id, snapshot.data
                                .name.toString());
                            return Text(
                              snapshot.data.name.toString(),
                              style: EvieTextStyles.body18,
                            );
                          } else {
                            return const Text(
                              "loading",
                            );
                          }
                        }
                    ),
                    subtitle: data == null
                        ? const Text('Error in data')
                        : Text("${getSecurityTextWidget(
                        data["type"])} • ${calculateTimeAgoWithTime(
                        data["created"]!.toDate())}",
                      style: EvieTextStyles.body12,)

                ),
                const Divider(height: 1),
              ],
            );
          }else{
            return Container();
          }

        },
        query: FirebaseFirestore.instance.collection("bikes")
            .doc(_bikeProvider.currentBikeModel!.deviceIMEI!)
            .collection("events")
        //.where('type', whereIn: ['lock'])
        //.where('type', whereIn: _bikeProvider.threatFilterArray)
            .orderBy("created", descending: true),
        itemsPerPage: 3,
        isLive: false,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        // gradient: SweepGradient(
        //     startAngle: 0,
        //     colors: [Colors.white,EvieColors.lightRed,Colors.white,EvieColors.lightRed],
        //     transform: GradientRotation(_animationController.value*6)
        // )
      ),
      child: EvieCard(
        onPress: (){
          if(_currentIndex == 0){
            if(_locationProvider.locationModel?.isConnected == false){
              showMapDetailsSheet(context);
            }else if(_bikeProvider.currentBikeModel?.location?.status == "danger") {
            changeToThreatMap(context);
            }else{
              showMapDetailsSheet(context);
            }
          }else{
            if(_locationProvider.locationModel?.isConnected == false){
              showThreatHistorySheet(context);
            }else if(_bikeProvider.currentBikeModel?.location?.status == "danger"){
              changeToThreatTimeLine(context);
            }else {
              showThreatHistorySheet(context);
            }
          }
        },
        //height: 255.h,
        height: double.infinity,
        width: double.infinity,
        title: "Orbital Anti-theft",
        child: Expanded(
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  items: _widgets,
                  options: CarouselOptions(
                    padEnds: false,

                    height: double.infinity,
                    //height: 323.h,
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
                padding:  EdgeInsets.only(top: 9.h, bottom: 9.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _widgets.map((item) {
                    int index = _widgets.indexOf(item);
                    return Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LocationModel?> getLocationModel() async {
    return _locationProvider.locationModel;
  }

  loadMarker(){
    options.clear();

    if(currentAnnotationId != null){
      mapboxMap?.annotations.removeAnnotationManager(currentAnnotationId);
    }

    mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {

      ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
        currentAnnotationId = pointAnnotationManager;

        ///Add disconnected threat
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

        ///First marker
        options.add(
            PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(
                _locationProvider.locationModel?.geopoint.longitude ?? 0,
                _locationProvider.locationModel?.geopoint.latitude ?? 0,
              )).toJson(),
          image: list,
          iconSize: 1.5.h,
        )
        );

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

  void locationListener() {
    //setButtonImage();
    //getDistanceBetween();
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    animateBounce();
    // loadImage(currentDangerStatus);
  }


  void animateBounce() {
    mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
              coordinates: Position(
                  _locationProvider.locationModel?.geopoint.longitude ?? 0,
                  _locationProvider.locationModel?.geopoint.latitude ?? 0))
              .toJson(),
          zoom: 12,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0));
    loadMarker();
  }
}



import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/provider/bike_provider.dart';
import '../../api/dialog.dart';
import '../../api/enumerate.dart';
import '../../api/function.dart';
import '../../api/provider/ride_provider.dart';
import 'package:latlong2/latlong.dart';

import '../../widgets/evie_appbar.dart';


class RideDetail extends StatefulWidget{
  final String tripId;
  final TripHistoryModel currentTripHistoryList;
  const RideDetail(this.tripId, this.currentTripHistoryList, { super.key });
  @override
  _RideDetailState createState() => _RideDetailState();
}

class _RideDetailState extends State<RideDetail> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late SettingProvider _settingProvider;
  late BikeProvider _bikeProvider;
  late LocationProvider _locationProvider;
  late RideProvider _rideProvider;

  String? startAddress;
  String? endAddress;

  MapController? mapController;

  var markers = <Marker>[];

  var currentAnnotationId;
  var options = <PointAnnotationOptions>[];
  MapboxMap? mapboxMap;

  OnMapScrollListener? onMapScrollListener;

  bool isStartTripMissing = false;
  bool isEndTripMissing = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    if (widget.currentTripHistoryList.startTrip == null || widget.currentTripHistoryList.startTrip == const GeoPoint(0, 0)) {
      isStartTripMissing = true;
    }

    if (widget.currentTripHistoryList.endTrip == null || widget.currentTripHistoryList.endTrip == const GeoPoint(0, 0)) {
      isEndTripMissing = true;
    }
  }

  @override
  void dispose() {
    mapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _rideProvider = Provider.of<RideProvider>(context);

    if(startAddress == null || endAddress == null){
      if (!isStartTripMissing) {
        getAddress(widget.currentTripHistoryList.startTrip, widget.tripId, "startAddress");
      }

      if (!isEndTripMissing) {
        getAddress(widget.currentTripHistoryList.endTrip, widget.tripId, "endAddress");
      }
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },

      child: Scaffold(
        appBar: PageAppbar(
          title: 'Ride History',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //SizedBox(height: 8.5.h,),
                //Divider(thickness: 0.5, height: 5, color: EvieColors.darkWhite,),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,4.h),
                  child: Row(
                    children: [
                      Text(
                        calculateDateOnly(widget.currentTripHistoryList.startTime!.toDate(),widget.currentTripHistoryList.endTime!.toDate()),
                        style: EvieTextStyles.body18,
                      ),
                      Text(
                        calculateTimeOnly(widget.currentTripHistoryList.startTime!.toDate(),widget.currentTripHistoryList.endTime!.toDate()),
                        style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan, height: 1.6),
                      ),
                    ],
                  )
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Row(
                    children: [
                      Text(
                        thousandFormatting(widget.currentTripHistoryList.carbonPrint ?? 0),
                        style: EvieTextStyles.display,
                      ),
                      Text("  g",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan, height: 3)),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: Text(
                    "CO₂ Saved",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 11.h),
                  child: Container(
                    //color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Distance", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                              _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                              Row(
                                children: [
                                  Text((widget.currentTripHistoryList.distance!/1000).toStringAsFixed(2), style: EvieTextStyles.headlineB,),
                                  Text(" km", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                                ],
                              ) :
                              Row(
                                children: [
                                  Text(_settingProvider.convertMeterToMilesInString(widget.currentTripHistoryList.distance!.toDouble()), style: EvieTextStyles.headlineB,),
                                  Text(" miles", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                                ],
                              ),
                            ],
                          ),
                          //color: Colors.red,
                        ),


                        Container(
                          //color: Colors.yellow,
                          child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Avg. Speed", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),

                              _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
                              Row(
                                children: [
                                  Text((calculateAverageSpeed(widget.currentTripHistoryList.distance!.toDouble(),
                                      calculateTimeDifferentInHourMinutes(widget.currentTripHistoryList.endTime!.toDate(), widget.currentTripHistoryList.startTime!.toDate()))).toStringAsFixed(2),
                                    style: EvieTextStyles.headlineB,),
                                  Text(" km/h", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                                ],
                              ) :
                              Row(
                                children: [
                                  Text(((calculateAverageSpeed(widget.currentTripHistoryList.distance!.toDouble(),
                                      calculateTimeDifferentInHourMinutes(widget.currentTripHistoryList.endTime!.toDate(),widget.currentTripHistoryList.startTime!.toDate())))*0.621371).toStringAsFixed(2),
                                    style: EvieTextStyles.headlineB,),
                                  Text(" mp/h", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          //color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Duration", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                              Row(
                                children: [
                                  //Text(formatDuration(widget.currentTripHistoryList.startTime!.toDate(), widget.currentTripHistoryList.endTime!.toDate()), style: EvieTextStyles.headlineB,),

                                  returnTextStyle(widget.currentTripHistoryList.startTime!.toDate(),widget.currentTripHistoryList.endTime!.toDate()),

                                  // RichText(
                                  //   text: TextSpan(
                                  //     text: formatDuration(widget.currentTripHistoryList.startTime!.toDate(), widget.currentTripHistoryList.endTime!.toDate()).replaceAll('mins', "").replaceAll('h', "").replaceAll('m', ''),
                                  //     style: EvieTextStyles.headlineB,
                                  //     children: <TextSpan>[
                                  //       if (formatDuration(widget.currentTripHistoryList.startTime!.toDate(), widget.currentTripHistoryList.endTime!.toDate()).contains('mins'))
                                  //         TextSpan(
                                  //           text: 'mins',
                                  //           style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                                  //         ),
                                  //      if (formatDuration(widget.currentTripHistoryList.startTime!.toDate(), widget.currentTripHistoryList.endTime!.toDate()).contains('h'))
                                  //        TextSpan(
                                  //          text: 'm',
                                  //          style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                                  //        ),
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ),

                isStartTripMissing && isEndTripMissing ?
                Expanded(
                  child: Stack(
                    children: [
                      SvgPicture.asset('assets/images/dot-line.svg'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/bike_not_found.svg'),
                              Text(
                                'Location data not recorded.',
                                style: EvieTextStyles.body18,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showMissingGPSDataDialog(context);
                                },
                                child: Text(
                                  'Why did this happen?',
                                  style: EvieTextStyles.body14.copyWith(decoration: TextDecoration.underline,),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ) :
                Expanded(
                  child: Stack(
                    children: [
                      MapWidget(
                        onScrollListener: onMapScrollListener,
                        key: const ValueKey("mapWidget"),
                        resourceOptions: ResourceOptions(
                            accessToken: _locationProvider.defPublicAccessToken),
                        onMapCreated: _onMapCreated,
                        styleUri: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
                        cameraOptions: CameraOptions(
                          center: Point(
                              coordinates: Position(
                                widget.currentTripHistoryList.endTrip?.longitude ?? 0,
                                widget.currentTripHistoryList.endTrip?.latitude ?? 0,
                              ))
                              .toJson(),
                          zoom: 12,
                        ),
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer())
                        },
                      ),
                      isEndTripMissing || isStartTripMissing ?
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 0, 0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: EvieColors.thumbColorTrue,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
                                      offset: Offset(0, 8), // X and Y offset
                                      blurRadius: 16, // Blur radius
                                      spreadRadius: 0, // Spread radius
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset('assets/icons/notification_alert.svg'),
                                      SizedBox(width: 10.w,),
                                      Text(
                                        isEndTripMissing ? 'Ending position not recorded.' : 'Starting position not recorded.',
                                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      ) :
                      Container(),
                    ],
                  )
                ),
              ],
            ),
          ],
        ),),
    );
  }

  loadMarkerNew() async {
    options.clear();

    if(currentAnnotationId != null){
      await mapboxMap?.annotations.removeAnnotationManager(currentAnnotationId);
    }

    await mapboxMap?.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {

      ///using a "addOnPointAnnotationClickListener" to allow click on the symbols for a specific screen
      currentAnnotationId = pointAnnotationManager;

        final ByteData bytes = await rootBundle.load("assets/buttons/location_pin.png");
        final Uint8List list = bytes.buffer.asUint8List();

      final ByteData bytes2 = await rootBundle.load("assets/buttons/flag_point.png");
      final Uint8List list2 = bytes2.buffer.asUint8List();

      if (!isStartTripMissing) {
        options.add(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
                    widget.currentTripHistoryList.startTrip?.longitude ?? 0,
                    widget.currentTripHistoryList.startTrip?.latitude ?? 0))
                .toJson(),
            image: list,
            iconSize: Platform.isAndroid ? 38.0 : 16.0,
            textField: startAddress ?? "loading",
            textOffset: [0.0, 2.4],
            textColor: Colors.black.value,
            textSize: 14.sp
        ));
      }

      if (!isEndTripMissing) {
        options.add(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
                  widget.currentTripHistoryList.endTrip?.longitude ?? 0,
                  widget.currentTripHistoryList.endTrip?.latitude ?? 0,))
                .toJson(),
            image: list2,
            iconSize: Platform.isAndroid ? 38.0 : 16.0,
            textField: endAddress ?? "loading",
            textOffset: [0.0, 2],
            textColor: Colors.black.value,
            textSize: 14.sp
        ));
      }

      pointAnnotationManager.setIconAllowOverlap(false);
      pointAnnotationManager.createMulti(options);
    });

    if (isStartTripMissing || isEndTripMissing) {

    }
    else {
      Future.delayed(Duration(milliseconds: 500), () {
        animateBounce2();
      });
    }
  }


  getAddress(GeoPoint? trip, String tripId, String addressType) async {

    if(addressType == "startAddress"){
      if(widget.currentTripHistoryList.startAddress != null && widget.currentTripHistoryList.startAddress != ""){
        setState(() {
          startAddress = widget.currentTripHistoryList.startAddress;
        });
      }
      else{
        final snapshot = await _locationProvider.returnPlaceMarksString(trip!.latitude, trip.longitude);
        if(snapshot != null){
          _rideProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "startAddress",  snapshot.toString());
          setState(() {
            startAddress = snapshot.toString();
          });
          await loadMarkerNew();
        }
      }
    }
    else{
      if(widget.currentTripHistoryList.endAddress != null && widget.currentTripHistoryList.endAddress != ""){
        setState(() {
          endAddress = widget.currentTripHistoryList.endAddress;
        });

      }else{
        final snapshot = await _locationProvider.returnPlaceMarksString(trip!.latitude, trip.longitude);

        if(snapshot != null){
          _rideProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "endAddress",  snapshot.toString());
          setState(() {
            endAddress = snapshot.toString();
          });
          await loadMarkerNew();
        }
      }
    }


  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await this.mapboxMap?.compass.updateSettings(CompassSettings(enabled: false));
    await this.mapboxMap?.logo.updateSettings(LogoSettings(marginLeft: -200));
    await this.mapboxMap?.attribution.updateSettings(AttributionSettings(marginRight: -200));

    loadMarkerNew();
  }

  void animateBounce2() async {
    try {
      final LatLng southwest = LatLng(
        min(widget.currentTripHistoryList.startTrip?.latitude ?? 0,
          widget.currentTripHistoryList.endTrip?.latitude ?? 0,),
        min(widget.currentTripHistoryList.startTrip?.longitude ?? 0,
          widget.currentTripHistoryList.endTrip?.longitude ?? 0,),
      );

      final LatLng northeast = LatLng(
        max(widget.currentTripHistoryList.startTrip?.latitude ?? 0,
          widget.currentTripHistoryList.endTrip?.latitude ?? 0,),
        max(widget.currentTripHistoryList.startTrip?.longitude ?? 0,
          widget.currentTripHistoryList.endTrip?.longitude ?? 0,),
      );

      if (mapboxMap != null) {
        final CameraOptions cameraOpt = await mapboxMap!
            .cameraForCoordinateBounds(
          CoordinateBounds(
            northeast: Point(
              coordinates: Position(northeast.longitude, northeast.latitude),
            ).toJson(),
            southwest: Point(
                coordinates: Position(southwest.longitude, southwest.latitude)
            ).toJson(),
            infiniteBounds: true,
          ),
          MbxEdgeInsets(
            // use whatever padding you need
            left: 250.w,
            top: 200.h,
            bottom: 200.h,
            right: 250.w,
          ),
          null,
          null,
  
        );

        mapboxMap?.flyTo(
            cameraOpt, MapAnimationOptions(duration: 500, startDelay: 0));
      }
    } catch(error) {
      print(error);
    }
  }
}
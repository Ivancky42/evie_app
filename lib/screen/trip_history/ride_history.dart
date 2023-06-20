import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/trip_history_model.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/provider/trip_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_oval.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../api/function.dart';
import '../user_home_page/add_new_bike/mapbox_widget.dart';
import 'package:latlong2/latlong.dart';


class RideHistory extends StatefulWidget{
  final String tripId;
  final TripHistoryModel currentTripHistoryList;
  const RideHistory(this.tripId, this.currentTripHistoryList, { Key? key }) : super(key: key);
  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late SettingProvider _settingProvider;
  late BikeProvider _bikeProvider;
  late LocationProvider _locationProvider;
  late TripProvider _tripProvider;

  String? startAddress;
  String? endAddress;

  MapController? mapController;

  var markers = <Marker>[];

  var currentAnnotationId;
  var options = <PointAnnotationOptions>[];
  MapboxMap? mapboxMap;

  OnMapScrollListener? onMapScrollListener;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
    _tripProvider = Provider.of<TripProvider>(context);

    if(startAddress == null || endAddress == null){
      getAddress(widget.currentTripHistoryList.startTrip, widget.tripId, "startAddress");
      getAddress(widget.currentTripHistoryList.endTrip, widget.tripId, "endAddress");
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },

      child: Scaffold(
        // appBar: PageAppbar(
        //   title: 'Ride History',
        //   onPressed: () {
        //     changeToTripHistory(context);
        //   },
        // ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ride History",
                    style: EvieTextStyles.h1,
                     ),
                   ]
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,4.h),
                  child: Text(
                      calculateDateAgo(widget.currentTripHistoryList.startTime!.toDate(),widget.currentTripHistoryList.endTime!.toDate()),
                    style: EvieTextStyles.body18,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
                  child: Row(
                    children: [
                      Text(
                        thousandFormatting(widget.currentTripHistoryList.carbonPrint ?? 0),
                        style: EvieTextStyles.display,
                      ),
                      Text("  g",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan)),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                  child: Text(
                    "CO2 Saved",
                    style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 11.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Column(
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


                      Column(
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

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Battery Used", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
                          Row(
                            children: [
                              Text((widget.currentTripHistoryList.startBattery!.toInt() - widget.currentTripHistoryList.endBattery!.toInt()).toString(), style: EvieTextStyles.headlineB,),
                              Text(" %", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                Expanded(
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
                                widget.currentTripHistoryList.endTrip?.longitude ?? 0,
                                widget.currentTripHistoryList.endTrip?.latitude ?? 0,
                          ))
                          .toJson(),
                      zoom: 12,
                    ),
                    gestureRecognizers: [
                      Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer())
                    ].toSet(),
                  ),
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

        options.add(PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(
                  widget.currentTripHistoryList.startTrip?.longitude ?? 0,
                  widget.currentTripHistoryList.startTrip?.latitude ?? 0))
              .toJson(),
          image: list,
          iconSize: 2.h,
           textField: widget.currentTripHistoryList.startAddress ?? "loading",
           textOffset: [0.0, 2],
           textColor: Colors.black.value,
        ));

      options.add(PointAnnotationOptions(
        geometry: Point(
            coordinates: Position(
              widget.currentTripHistoryList.endTrip?.longitude ?? 0,
              widget.currentTripHistoryList.endTrip?.latitude ?? 0,))
            .toJson(),
        image: list2,
        iconSize:  2.h,
        textField: widget.currentTripHistoryList.endAddress ?? "loading",
        textOffset: [0.0, 2],
        textColor: Colors.black.value,
      ));

      pointAnnotationManager.setIconAllowOverlap(false);
      pointAnnotationManager.createMulti(options);
    });

    // Future.delayed(Duration(seconds: 1), () {
    //   animateBounceNew();
    // });

    Future.delayed(Duration(milliseconds: 500), () {
      animateBounce2();
    });

  }


  getAddress(GeoPoint? trip, String tripId, String addressType) async {

    if(addressType == "startAddress"){
      if(widget.currentTripHistoryList.startAddress != null && widget.currentTripHistoryList.startAddress != ""){
        setState(() {
          startAddress = widget.currentTripHistoryList.startAddress;
        });
      }else{
        final snapshot = await _locationProvider.returnPlaceMarks(trip!.latitude, trip!.longitude);

        if(snapshot != null){
          _tripProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "startAddress",  snapshot.name.toString());
          setState(() {
            startAddress = snapshot.name.toString();
          });
        }
      }
    }else{
      if(widget.currentTripHistoryList.endAddress != null && widget.currentTripHistoryList.endAddress != ""){
        setState(() {
          endAddress = widget.currentTripHistoryList.endAddress;
        });

      }else{
        final snapshot = await _locationProvider.returnPlaceMarks(trip!.latitude, trip!.longitude);

        if(snapshot != null){
          _tripProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "endAddress",  snapshot.name.toString());
          setState(() {
            endAddress = snapshot.name.toString();
          });
        }
      }
    }


  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    ///Disable scaleBar on top left corner
    await this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    loadMarkerNew();
  }



  void animateBounceNew() {
    final LatLng southwest = LatLng(
      min(widget.currentTripHistoryList.startTrip?.latitude ?? 0, widget.currentTripHistoryList.endTrip?.latitude ?? 0,),
      min(widget.currentTripHistoryList.startTrip?.longitude ?? 0, widget.currentTripHistoryList.endTrip?.longitude ?? 0,),
    );

    final LatLng northeast = LatLng(
      max(widget.currentTripHistoryList.startTrip?.latitude ?? 0,
        widget.currentTripHistoryList.endTrip?.latitude ?? 0,),
      max(widget.currentTripHistoryList.startTrip?.longitude ?? 0,
        widget.currentTripHistoryList.endTrip?.longitude ?? 0,),
    );
    LatLngBounds latLngBounds = LatLngBounds(southwest, northeast);

    mapboxMap?.flyTo(
      CameraOptions(
        padding: MbxEdgeInsets(
            top: 100.h, left: 170.w, bottom: 360.h, right: 170.w),
        center: latLngBounds.center.toJson(),
        //    zoom: _getZoomLevel(latLngBounds, 350.w ,750.h),

      ),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
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
            left: 200.w,
            top: 200.h,
            bottom: 200.h,
            right: 200.w,
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

///======================================== old flutter map with icon

// class RideHistory extends StatefulWidget{
//   final String tripId;
//   final TripHistoryModel currentTripHistoryList;
//   const RideHistory(this.tripId, this.currentTripHistoryList, { Key? key }) : super(key: key);
//   @override
//   _RideHistoryState createState() => _RideHistoryState();
// }
//
// class _RideHistoryState extends State<RideHistory> {
//
//
//   LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();
//
//   late SettingProvider _settingProvider;
//   late BikeProvider _bikeProvider;
//   late LocationProvider _locationProvider;
//   late TripProvider _tripProvider;
//
//   String? startAddress;
//   String? endAddress;
//
//   MapController? mapController;
//
//   var markers = <Marker>[];
//
//   @override
//   void initState() {
//     super.initState();
//     mapController = MapController();
//   }
//
//   @override
//   void dispose() {
//     mapController?.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _settingProvider = Provider.of<SettingProvider>(context);
//     _locationProvider = Provider.of<LocationProvider>(context);
//     _tripProvider = Provider.of<TripProvider>(context);
//
//
//     if(startAddress == null || endAddress == null){
//       getAddress(widget.currentTripHistoryList.startTrip, widget.tripId, "startAddress");
//       getAddress(widget.currentTripHistoryList.endTrip, widget.tripId, "endAddress");
//     }
//
//     loadMarker(widget.tripId, widget.currentTripHistoryList.startTrip, widget.currentTripHistoryList.endTrip, startAddress, endAddress);
//
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pop(context);
//         return false;
//       },
//
//       child: Scaffold(
//         // appBar: PageAppbar(
//         //   title: 'Ride History',
//         //   onPressed: () {
//         //     changeToTripHistory(context);
//         //   },
//         // ),
//         body: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 Padding(
//                   padding: EdgeInsets.only(left: 16.w, top: 16.h),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Ride History",
//                           style: EvieTextStyles.h1,
//                         ),
//                       ]
//                   ),
//                 ),
//
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,4.h),
//                   child: Text(
//                     calculateDateAgo(widget.currentTripHistoryList.startTime!.toDate(),widget.currentTripHistoryList.endTime!.toDate()),
//                     style: EvieTextStyles.body18,
//                   ),
//                 ),
//
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
//                   child: Row(
//                     children: [
//                       Text(
//                         "12345",
//                         style: EvieTextStyles.display,
//                       ),
//                       Text(" g",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayishCyan)),
//                     ],
//                   ),
//                 ),
//
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
//                   child: Text(
//                     "carbon footprint",
//                     style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 11.h),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Mileage", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
//
//                           _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
//                           Row(
//                             children: [
//                               Text((widget.currentTripHistoryList.distance!/1000).toStringAsFixed(2), style: EvieTextStyles.headlineB,),
//                               Text("km", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
//                             ],
//                           ) :
//                           Row(
//                             children: [
//                               Text(_settingProvider.convertMeterToMilesInString(widget.currentTripHistoryList.distance!.toDouble()), style: EvieTextStyles.headlineB,),
//                               Text("miles", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
//                             ],
//                           ),
//                         ],
//                       ),
//
//
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Avg. Speed", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
//
//                           _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem?
//                           Row(
//                             children: [
//                               Text((calculateAverageSpeed(widget.currentTripHistoryList.distance!.toDouble(),
//                                   calculateTimeDifferentInHour(widget.currentTripHistoryList.endTime!.toDate(),widget.currentTripHistoryList.startTime!.toDate()))).toStringAsFixed(2),
//                                 style: EvieTextStyles.headlineB,),
//                               Text("km/h", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
//                             ],
//                           ) :
//                           Row(
//                             children: [
//                               Text(((calculateAverageSpeed(widget.currentTripHistoryList.distance!.toDouble(),
//                                   calculateTimeDifferentInHour(widget.currentTripHistoryList.endTime!.toDate(),widget.currentTripHistoryList.startTime!.toDate())))*0.621371).toStringAsFixed(2),
//                                 style: EvieTextStyles.headlineB,),
//                               Text("mp/h", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
//                             ],
//                           ),
//                         ],
//                       ),
//
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Battery Used", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),),
//                           Row(
//                             children: [
//                               Text((widget.currentTripHistoryList.startBattery!.toInt() - widget.currentTripHistoryList.endBattery!.toInt()).toString(), style: EvieTextStyles.headlineB,),
//                               Text("%", style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//
//                 Expanded(
//
//                   child: Mapbox_Widget(
//                     accessToken:
//                     _locationProvider.defPublicAccessToken,
//                     //onMapCreated: _onMapCreated,
//
//                     mapController: mapController,
//                     markers: markers,
//                     // onUserLocationUpdate: (userLocation) {
//                     //   if (this.userLocation != null) {
//                     //     this.userLocation = userLocation;
//                     //     getDistanceBetween();
//                     //   }
//                     //   else {
//                     //     this.userLocation = userLocation;
//                     //     getDistanceBetween();
//                     //     runSymbol();
//                     //   }
//                     // },
//                     latitude: widget.currentTripHistoryList.endTrip?.latitude ?? 0,
//                     longitude: widget.currentTripHistoryList.endTrip?.longitude ?? 0,
//
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),),
//     );
//   }
//
//   // LatLng latLng
//   loadMarker(String tripId, GeoPoint? startTrip, GeoPoint? endTrip, String? startAddress, String? endAddress){
//     markers = [
//       ///Two fixed marker
//
//       Marker(
//         width: 700.w,
//         height: 100.h,
//         point: LatLng(startTrip?.latitude ?? 0, startTrip?.longitude ?? 0),
//         builder: (ctx) =>  Column(
//           children: [
//             SvgPicture.asset(
//               "assets/buttons/location_pin.svg",
//               height: 60.h,
//             ),
//
//             EvieOvalBlack(buttonText:startAddress ?? "loading"),
//           ],
//         ),
//       ),
//
//       Marker(
//         width: 700.w,
//         height: 100.h,
//         point: LatLng(endTrip?.latitude ?? 0, endTrip?.longitude ?? 0),
//         builder: (ctx) =>  Column(
//           children: [
//             SvgPicture.asset(
//               "assets/buttons/flag_point.svg",
//               height: 46.h,
//             ),
//
//             EvieOvalBlack(buttonText: endAddress ?? "loading"
//             ),
//
//           ],
//         ),
//       ),
//     ];
//
//     Future.delayed(Duration.zero, () {
//       animateBounce();
//     });
//   }
//
//
//   getAddress(GeoPoint? trip, String tripId, String addressType) async {
//
//     if(addressType == "startAddress"){
//       if(widget.currentTripHistoryList.startAddress != null && widget.currentTripHistoryList.startAddress != ""){
//         setState(() {
//           startAddress = widget.currentTripHistoryList.startAddress;
//         });
//       }else{
//         final snapshot = await _locationProvider.returnPlaceMarks(trip!.latitude, trip!.longitude);
//
//         if(snapshot != null){
//           _tripProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "startAddress",  snapshot.name.toString());
//           setState(() {
//             startAddress = snapshot.name.toString();
//           });
//         }
//       }
//     }else{
//       if(widget.currentTripHistoryList.endAddress != null && widget.currentTripHistoryList.endAddress != ""){
//         setState(() {
//           endAddress = widget.currentTripHistoryList.endAddress;
//         });
//
//       }else{
//         final snapshot = await _locationProvider.returnPlaceMarks(trip!.latitude, trip!.longitude);
//
//         if(snapshot != null){
//           _tripProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, tripId, "endAddress",  snapshot.name.toString());
//           setState(() {
//             endAddress = snapshot.name.toString();
//           });
//         }
//       }
//     }
//
//
//   }
//
//
//
//   void animateBounce() {
//
//     if (mapController != null) {
//
//       final LatLng southwest = LatLng(
//         min(widget.currentTripHistoryList.startTrip!.latitude,
//             widget.currentTripHistoryList.endTrip!.latitude),
//         min(widget.currentTripHistoryList.startTrip!.longitude,
//             widget.currentTripHistoryList.endTrip!.longitude),
//       );
//
//       final LatLng northeast = LatLng(
//         max(widget.currentTripHistoryList.startTrip!.latitude,
//             widget.currentTripHistoryList.endTrip!.latitude),
//         max(widget.currentTripHistoryList.startTrip!.longitude,
//             widget.currentTripHistoryList.endTrip!.longitude),
//       );
//
//       final latLngBounds = LatLngBounds(southwest, northeast);
//
//
//       mapController?.fitBounds(
//           latLngBounds,
//           options: FitBoundsOptions(
//             padding: EdgeInsets.fromLTRB(170.w, 100.h, 170.w, 360.h),
//           )
//       );
//
//     }
//   }
//
// }
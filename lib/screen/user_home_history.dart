import 'dart:collection';
import 'dart:typed_data';

import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/location_provider.dart';

class UserHomeHistory extends StatefulWidget {
  const UserHomeHistory({Key? key}) : super(key: key);

  @override
  _UserHomeHistoryState createState() => _UserHomeHistoryState();
}

class _UserHomeHistoryState extends State<UserHomeHistory> {
  late LocationProvider _locationProvider;
  late BikeProvider _bikeProvider;

  MapboxMapController? mapController;

  final Map<String, int> dangerStatus = {'safe': 1, 'warning': 2, 'danger': 3};
  String currentDangerStatus = 'safe';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //  mapController?.dispose();
    super.dispose();
  }

  Future<Uint8List> loadMarkerImage(String dangerStatus) async {
    switch (dangerStatus) {
      case 'safe':
        {
          var byteData = await rootBundle.load("assets/icons/marker_bike.png");
          return byteData.buffer.asUint8List();
        }
      case 'warning':
        {
          var byteData =
              await rootBundle.load("assets/icons/marker_warning.png");
          return byteData.buffer.asUint8List();
        }
      case 'danger':
        {
          var byteData =
              await rootBundle.load("assets/icons/marker_danger.png");
          return byteData.buffer.asUint8List();
        }
      default:
        {
          var byteData = await rootBundle.load("assets/icons/marker_bike.png");
          return byteData.buffer.asUint8List();
        }
    }
  }

  runSymbol() async {
    mapController?.clearSymbols();

    var markerImage = await loadMarkerImage(currentDangerStatus);
    mapController?.addImage('marker', markerImage);


    ///Change icon according to dangerous level
    await mapController?.addSymbol(
      SymbolOptions(
        //iconSize: 0.3,
        iconImage: "marker",
        geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
            _locationProvider.locationModel!.geopoint.longitude),
        // iconAnchor: "bottom",
      ),
    );

    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(_locationProvider.locationModel!.geopoint.latitude,
          _locationProvider.locationModel!.geopoint.longitude), zoom: 13),
    ));

    _locationProvider.getPlaceMarks(
        _locationProvider.locationModel!.geopoint.latitude,
        _locationProvider.locationModel!.geopoint.longitude);

    mapController?.onSymbolTapped.add((argument) {
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialog(
              title: "Bike Location",
              content:
                  "Latitude: ${_locationProvider.locationModel!.geopoint.latitude}\n"
                  "Longtitude: ${_locationProvider.locationModel!.geopoint.longitude}\n"
                  "Place: ${_locationProvider.currentPlaceMark?.name} "
                  "${_locationProvider.currentPlaceMark?.country}",
              rightContent: "Ok",
              onPressedRight: () {
                SmartDialog.dismiss();
              }));
    });

    /*
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        latLngBounds,
        left: 144,
        right: 144,
        top: 144,
        bottom: 144
    ));

     */
  }

  @override
  Widget build(BuildContext context) {
    _locationProvider = Provider.of<LocationProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    for (var element in dangerStatus.keys) {
      if (_bikeProvider.currentBikeModel!.location!.status == element) {
        currentDangerStatus = element;
      }
    }
    
    if (mapController != null) {
      runSymbol();
    }
    
    void _onMapCreated(MapboxMapController mapController) async {
      this.mapController = mapController;

      runSymbol();
      //mapController.updateSymbol(symbol, load);
    }

    /*
      mapController.addSymbol(
          SymbolOptions(
            iconImage: "assets/icons/marker_bike.png",
            geometry: LatLng(_bikeProvider.currentBikeModel!.location!.geopoint.latitude,
                _bikeProvider.currentBikeModel!.location!.geopoint.longitude),
            iconSize: 0.25,
          ));
       */

/*
    controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(_locationProvider.position!.latitude,  _locationProvider.position!.longitude),
        iconImage: "assets/icons/marker_bike.png",
      ),
    );
    */

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      //     child: Center(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${_locationProvider.locationModel!.status},\n"
                "long and lang: ${_locationProvider.locationModel!.geopoint.longitude},"
                "${_locationProvider.locationModel!.geopoint.latitude}\n\n"),

            FutureBuilder(
                future: getLocation(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: MapboxMap(
                        myLocationEnabled: true,
                        //   styleString: _locationProvider.mapBoxStyleToken,
                        trackCameraPosition: true,
                        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                        accessToken: _locationProvider.defPublicAccessToken,
                        compassEnabled: true,
                        // styleString: _locationProvider.mapBoxStyleToken,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target:
                          // LatLng(_locationProvider.position!.latitude,  _locationProvider.position!.longitude),
                          LatLng(_locationProvider.userPosition!.latitude,
                              _locationProvider.userPosition!.longitude),
                          zoom: 14,
                        ),
                      ),
                    );
                  }
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
            ),
            FloatingActionButton.small(
              child: const Icon(Icons.person),
              onPressed: () async {
                var position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);
                mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      position.latitude,
                      position.longitude,
                    ),
                    14,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      //        ),
    )
    );
  }

  Future<Position?> getLocation() async {
    return _locationProvider.userPosition;
  }

}

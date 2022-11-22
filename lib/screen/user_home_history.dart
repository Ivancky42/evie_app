import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/location_provider.dart';


///Temporary use for location and map service

class UserHomeHistory extends StatefulWidget {
  const UserHomeHistory({Key? key}) : super(key: key);

  @override
  _UserHomeHistoryState createState() => _UserHomeHistoryState();
}

class _UserHomeHistoryState extends State<UserHomeHistory> {

  final List<String> dangerStatus = ['safe', 'warning', 'danger'];
  String currentDangerStatus = 'safe';

  late LocationProvider _locationProvider;
  late BikeProvider _bikeProvider;
  late LatLngBounds latLngBounds;

  MapboxMapController? mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Load image according danger status
  Future<Uint8List> loadMarkerImage(String dangerStatus) async {
    switch (dangerStatus) {
      case 'safe':
        {
          var byteData = await rootBundle.load("assets/icons/marker_bike.png");
          return byteData.buffer.asUint8List();
        }
      case 'warning':
        {
          var byteData = await rootBundle.load("assets/icons/marker_warning.png");
          return byteData.buffer.asUint8List();
        }
      case 'danger':
        {
          var byteData = await rootBundle.load("assets/icons/marker_danger.png");
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
    if(mapController!.symbols.isNotEmpty){
      mapController?.clearSymbols();
    }

    var markerImage = await loadMarkerImage(currentDangerStatus);
    mapController?.addImage('marker', markerImage);

    ///Update symbol geometry and status instead of rebuild everytime
    //mapController?.updateSymbol(symbol, changes)

    addSymbol();

    final LatLng southwest = LatLng(
      min(_locationProvider.locationModel!.geopoint.latitude, _locationProvider.userPosition!.latitude),
      min(_locationProvider.locationModel!.geopoint.longitude, _locationProvider.userPosition!.longitude),
    );

    final LatLng northeast = LatLng(
      max(_locationProvider.locationModel!.geopoint.latitude, _locationProvider.userPosition!.latitude),
      max(_locationProvider.locationModel!.geopoint.longitude, _locationProvider.userPosition!.longitude),
    );

    latLngBounds = LatLngBounds(southwest: southwest, northeast: northeast);

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        latLngBounds,
        left: 80,
        right: 80,
        top: 80,
        bottom: 80,
    ));
    getPlace();
  }

  ///Change icon according to dangerous level
  void addSymbol() async{
    mapController?.addSymbol(
      SymbolOptions(
        iconImage: 'marker',
        geometry: LatLng(_locationProvider.locationModel!.geopoint.latitude,
            _locationProvider.locationModel!.geopoint.longitude),
      ),
    );
  }

  void getPlace(){
    _locationProvider.getPlaceMarks(
        _locationProvider.locationModel!.geopoint.latitude,
        _locationProvider.locationModel!.geopoint.longitude
    );

    mapController?.onSymbolTapped.add((argument) {
      SmartDialog.showAttach(
        keepSingle: true,
        alignmentTemp: Alignment.center,
        targetContext: context,
        widget: Container(
            width: 200,
            height: 50,
            color: Colors.white,
          child: Text("Bike Location:\n "
              "${_locationProvider.currentPlaceMark?.name} "
              "${_locationProvider.currentPlaceMark?.country}"),
        ),
      );
    });
  }

  void _onMapCreated(MapboxMapController mapController) async {
    setState(() {
      this.mapController = mapController;
    });
  }

  @override
  Widget build(BuildContext context) {
    _locationProvider = Provider.of<LocationProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);



    for (var element in dangerStatus) {
      if (_bikeProvider.currentBikeModel!.location!.status == element) {
        currentDangerStatus = element;
      }
    }
    
    if (mapController != null) {
      runSymbol();
    }

    return WillPopScope(
      onWillPop: () async {
        changeToUserHomePageScreen(context);
        return true;
      },

      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        //     child: Center(
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: ${_locationProvider.locationModel!.status} \n"),

              FutureBuilder(
                  future: getLocation(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      return SizedBox(
                        width: double.infinity,
                        height: 30.h,
                        child: MapboxMap(
                          myLocationEnabled: true,
                          //   styleString: _locationProvider.mapBoxStyleToken,
                          trackCameraPosition: true,
                          myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                          accessToken: _locationProvider.defPublicAccessToken,
                          compassEnabled: true,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                        target:
                        LatLng(_locationProvider.locationModel!.geopoint.latitude,
                            _locationProvider.locationModel!.geopoint.longitude),
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
      ),
    );
  }

  Future<Position?> getLocation() async {
    return _locationProvider.userPosition;
  }

}



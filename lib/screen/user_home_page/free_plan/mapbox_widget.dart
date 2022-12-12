import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Mapbox_Widget extends StatefulWidget {
  String accessToken;
  // Function(MapboxMapController)? onMapCreated;
  //VoidCallback onStyleLoadedCallback;
  //Function(UserLocation)? onUserLocationUpdate;
  double latitude;
  double longitude;
  MapController? mapController;
  List<Marker> markers;

  Mapbox_Widget({
    Key? key,
    required this.accessToken,
    // required this.onMapCreated,
    //required this.onStyleLoadedCallback,
    //  required this.onUserLocationUpdate,
    required this.latitude,
    required this.longitude,
    this.mapController,
    required this.markers,

  }) : super(key: key);

  @override
  _Mapbox_WidgetState createState() => _Mapbox_WidgetState();
}

class _Mapbox_WidgetState extends State<Mapbox_Widget> {


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        onMapCreated: (MapController mapController){

        },
        zoom: 16,
        center: LatLng(
            widget.latitude,
            widget.longitude),
      ),

      layers: [
        TileLayerOptions(
          urlTemplate:
          "https://api.mapbox.com/styles/v1/helloevie/claug0xq5002w15mk96ksixpz/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGVsbG9ldmllIiwiYSI6ImNsN3pvMm9oZTBsM3ozcG4zd2NmenVlZWQifQ.Y1R7b5ban6IwnLODyrf9Zw",
          additionalOptions: {
            'mapStyleId': "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
            'accessToken': widget.accessToken,
          },
        ),

        MarkerLayerOptions(
          markers: widget.markers,
        ),
      ],

    );

    //   MapboxMap(
    //   //useDelayedDisposal: true,
    //   myLocationEnabled: true,
    //   trackCameraPosition: true,
    //   myLocationTrackingMode:
    //   MyLocationTrackingMode.Tracking,
    //   myLocationRenderMode: MyLocationRenderMode.COMPASS,
    //   accessToken:widget.accessToken,
    //   compassEnabled: true,
    //   onMapCreated: widget.onMapCreated,
    //   styleString: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
    //   onStyleLoadedCallback: widget.onStyleLoadedCallback,
    //   onUserLocationUpdated: widget.onUserLocationUpdate,
    //   initialCameraPosition: CameraPosition(
    //     target: LatLng(
    //         widget.latitude,
    //         widget.longitude),
    //     zoom: 16,
    //   ),
    // );
  }
}


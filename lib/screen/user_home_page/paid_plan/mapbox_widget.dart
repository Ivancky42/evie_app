import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Mapbox_Widget extends StatefulWidget {
  String accessToken;
  Function(MapboxMapController)? onMapCreated;
  VoidCallback onStyleLoadedCallback;
  Function(UserLocation)? onUserLocationUpdate;
  double latitude;
  double longitude;

  Mapbox_Widget({
    Key? key,
    required this.accessToken,
    required this.onMapCreated,
    required this.onStyleLoadedCallback,
    required this.onUserLocationUpdate,
    required this. latitude,
    required this.longitude,

  }) : super(key: key);

  @override
  _Mapbox_WidgetState createState() => _Mapbox_WidgetState();
}

class _Mapbox_WidgetState extends State<Mapbox_Widget> {

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      useDelayedDisposal: true,
      myLocationEnabled: true,
      trackCameraPosition: true,
      myLocationTrackingMode:
      MyLocationTrackingMode.Tracking,
      myLocationRenderMode: MyLocationRenderMode.COMPASS,
      accessToken:widget.accessToken,
      compassEnabled: true,
      onMapCreated: widget.onMapCreated,
      styleString: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",
      onStyleLoadedCallback: widget.onStyleLoadedCallback,
      onUserLocationUpdated: widget.onUserLocationUpdate,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            widget.latitude,
            widget.longitude),
        zoom: 16,
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Mapbox_Widget extends StatelessWidget {

  String accessToken;
  Function(MapboxMapController)? onMapCreated;
  Function()? onStyleLoadedCallback;
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
  Widget build(BuildContext context) {
    return MapboxMap(
      //useHybridCompositionOverride: true,
      //    useDelayedDisposal: true,
      myLocationEnabled: true,
      trackCameraPosition: true,
      myLocationTrackingMode:
      MyLocationTrackingMode.Tracking,
      myLocationRenderMode: MyLocationRenderMode.COMPASS,
      accessToken:accessToken,
      compassEnabled: true,
      onMapCreated: onMapCreated,
      styleString: "mapbox://styles/helloevie/claug0xq5002w15mk96ksixpz",

      onStyleLoadedCallback: onStyleLoadedCallback,
      onUserLocationUpdated: onUserLocationUpdate,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            latitude,
            longitude),
        zoom: 16,
      ),
    );
  }
}


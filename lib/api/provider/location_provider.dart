import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/location_model.dart';

class LocationProvider extends ChangeNotifier {
  ///Mapbox default public token was store in gradle.properties file //Android

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String defPublicAccessToken = dotenv.env['DEF_PUBLIC_TOKEN'] ??
      'DPT not found';
  String mapBoxStyleToken = dotenv.env['MAPBOX_STYLE_TOKEN'] ?? 'MST not found';

  LocationModel? locationModel;
  UserLocation? userPosition;
  Placemark? currentPlaceMark;

  Future<void> init(LocationModel? locationModel) async {
    checkLocationPermissionStatus();
    if (locationModel == null) {}
    else {
      this.locationModel = locationModel;

      LocationPermission permission;
      permission = await Geolocator.requestPermission();

      getPlaceMarks(locationModel.geopoint.latitude, locationModel.geopoint.longitude);
      //userPosition = updateUserPosition();

      notifyListeners();
    }
  }

  checkLocationPermissionStatus() async {
    var locationStatus = await Permission.location.status;
    debugPrint("Location Status ${locationStatus.toString()}");

    switch (locationStatus) {
      case PermissionStatus.granted:
        return PermissionStatus.granted;
      case PermissionStatus.denied:
        return PermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
      // Pass
        break;
      case PermissionStatus.limited:
      // Pass
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void handlePermission() async {
    var status = await Permission.location.request();
    if (status.isPermanentlyDenied) {
      return;
    }

    status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      return;
    }

    status = await Permission.locationAlways.request();
    if (status.isPermanentlyDenied) {
      return;
    }
  }

  getPlaceMarks(double latitude, double longitude) async {

    currentPlaceMark = null;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          latitude, longitude, localeIdentifier: "en");

      if (placeMarks.isNotEmpty) {
        for (var element in placeMarks) {
          currentPlaceMark = element;
        }
      } else {
        currentPlaceMark = null;
      }
    }catch(error){
      debugPrint(error.toString());
      currentPlaceMark = null;
    }
    notifyListeners();
  }

  updateUserPosition(UserLocation userLocation) async {
    userPosition = userLocation;
    //notifyListeners();

  }

}
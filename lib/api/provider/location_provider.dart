import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dialog.dart';
import '../model/location_model.dart';
import '../model/threat_routes_model.dart';

class LocationProvider extends ChangeNotifier {
  ///Mapbox default public token was store in gradle.properties file //Android

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String defPublicAccessToken = dotenv.env['DEF_PUBLIC_TOKEN'] ?? 'DPT not found';
  String mapBoxStyleToken = dotenv.env['MAPBOX_STYLE_TOKEN'] ?? 'MST not found';

  LinkedHashMap? threatRoutesLists = LinkedHashMap<String, ThreatRoutesModel>();
  LinkedHashMap? get getThreatRoutesLists => threatRoutesLists;

  LocationModel? locationModel;
  //UserLocation? userPosition;
  Placemark? currentPlaceMark;
  PointAnnotation? selectedPointAnnotation;
  GeoPoint? selectedAnnotationGeopoint;

  bool hasLocationPermission = false;

  StreamSubscription? locationPermissionStatus;

  LocationProvider() {
    checkLocationPermissionStatus();
  }

  Future<void> update(LocationModel? locationModel, threatRoutesLists) async {

    if (locationModel != null) {
      if (this.locationModel != locationModel) {
        this.locationModel = locationModel;
        getPlaceMarks(locationModel.geopoint.latitude, locationModel.geopoint.longitude);
      }
    }

    if(threatRoutesLists != null){
      this.threatRoutesLists = threatRoutesLists;
    }

    notifyListeners();

    // if (locationModel == null) {}
    // else {
    //   this.locationModel = locationModel;
    //
    //   LocationPermission permission;
    //   permission = await Geolocator.requestPermission();
    //
    //   getPlaceMarks(locationModel.geopoint.latitude, locationModel.geopoint.longitude);
    //   //userPosition = updateUserPosition();
    //
    //   notifyListeners();
    // }
  }

  checkLocationPermissionStatus() async {
    locationPermissionStatus?.cancel();
    locationPermissionStatus = Permission.location.status.asStream().listen((event) {

      switch (event) {
        case PermissionStatus.granted:
          hasLocationPermission = true;
          break;
        case PermissionStatus.denied:
          hasLocationPermission = false;
          break;
        case PermissionStatus.permanentlyDenied:
          hasLocationPermission = false;
          break;
        case PermissionStatus.restricted:
        // Pass
          break;
        case PermissionStatus.limited:
        // Pass
          break;
        default:
          break;
      }
    });

    notifyListeners();

    // debugPrint("Location Status ${locationStatus.toString()}");
    //
    // switch (locationStatus) {
    //   case PermissionStatus.granted:
    //     hasLocationPermission = true;
    //     return PermissionStatus.granted;
    //   case PermissionStatus.denied:
    //     hasLocationPermission = false;
    //     return PermissionStatus.denied;
    //   case PermissionStatus.permanentlyDenied:
    //     hasLocationPermission = false;
    //     return PermissionStatus.permanentlyDenied;
    //   case PermissionStatus.restricted:
    //   // Pass
    //     break;
    //   case PermissionStatus.limited:
    //   // Pass
    //     break;
    //   default:
    //     break;
    // }
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
          break; // Exit the loop once a address is found
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

  Future<Placemark?> returnPlaceMarks(double latitude, double longitude) async {
    Placemark? placeMark;
    Placemark? placeMarkRenamed;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          latitude, longitude, localeIdentifier: "en");
      if (placeMarks.isNotEmpty) {
        //placeMark = placeMarks[0];
        for (var element in placeMarks) {
          placeMark = element;
          break; // Exit the loop once a address is found
        }
      } else {
        placeMark = null;
      }
    }catch(error){
      debugPrint(error.toString());
      placeMark = null;
    }

    placeMarkRenamed = Placemark(
      name : placeMark?.name?.replaceAll("NO HOUSE NUMBER, ", ""),
    );


    return placeMarkRenamed;
  }

  void setDefaultSelectedGeopoint() {
    selectedAnnotationGeopoint = locationModel?.geopoint;
    notifyListeners();
  }

  void setSelectedAnnotation(PointAnnotation pointAnnotation) {
    selectedPointAnnotation = pointAnnotation;
    print(pointAnnotation.geometry!['coordinates'].toString());

    Object? coordinatesList = pointAnnotation.geometry!['coordinates'];

    List<double> doublesList = (coordinatesList as List).map((coord) => coord as double).toList();
    double longitude = doublesList[0];
    double latitude = doublesList[1];
    selectedAnnotationGeopoint = GeoPoint(latitude, longitude);
    notifyListeners();
  }

  locations() async{
    if (await Permission.location.request().isGranted && await Permission.locationWhenInUse.request().isGranted) {
      checkLocationPermissionStatus();
    }else if(await Permission.location.isPermanentlyDenied || await Permission.location.isDenied){
      showLocationServiceDisable();
      //OpenSettings.openLocationSourceSetting();
    }
  }
  // updateUserPosition(UserLocation userLocation) async {
  //   userPosition = userLocation;
  //   //notifyListeners();
  //
  // }

}
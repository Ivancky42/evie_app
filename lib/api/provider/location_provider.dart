import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
  GeoPoint? userPosition;
  Placemark? currentPlaceMark;
  String? currentPlaceMarkString;
  PointAnnotation? selectedPointAnnotation;
  GeoPoint? selectedAnnotationGeopoint;
  GeoPoint? checkingGeopoint;
  String? checkPlaceMarkRenamed = "Loading";

  bool hasLocationPermission = false;

  StreamSubscription? locationPermissionStatus;

  LocationProvider() {
    checkLocationPermissionStatus();
  }

  Future<void> update(LocationModel? locationModel, threatRoutesLists) async {

    if (locationModel != null) {
      if (this.locationModel != locationModel) {
        if (this.locationModel?.geopoint != locationModel.geopoint) {
          getPlaceMarks(locationModel.geopoint.latitude,
              locationModel.geopoint.longitude);
        }
        this.locationModel = locationModel;
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

    Placemark? holder;
    currentPlaceMark = null;
    currentPlaceMarkString = null;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude, localeIdentifier: "en");

      if (placeMarks.isNotEmpty) {
        if (Platform.isAndroid) {
          //holder = placeMarks[3];

          holder = placeMarks[0];
          currentPlaceMark = Placemark(
            name : holder?.name?.replaceAll("NO HOUSE NUMBER, ", ""),
          );

          currentPlaceMarkString = (holder.name!.replaceAll("NO HOUSE NUMBER, ", "").toString() == "" ? holder.name.toString() : holder.name.toString() + ', ') + holder.thoroughfare.toString();
        }
        else {
          for (var element in placeMarks) {
            holder = element;
            break; // Exit the loop once a address is found
          }

          currentPlaceMark = Placemark(
            name : holder?.name?.replaceAll("NO HOUSE NUMBER, ", ""),
          );

          currentPlaceMarkString = holder?.name?.replaceAll("NO HOUSE NUMBER, ", "");
        }
      }
      else {
        currentPlaceMark = null;
        currentPlaceMarkString = null;
      }
    }catch(error){
      debugPrint(error.toString());
      currentPlaceMark = null;
      currentPlaceMarkString = null;
    }

    notifyListeners();
  }

  Future<Placemark?> returnPlaceMarks(double latitude, double longitude) async {
    Placemark? placeMark;
    Placemark? placeMarkRenamed;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude, localeIdentifier: "en");

      if (placeMarks.isNotEmpty) {
        if (Platform.isAndroid) {
          placeMark = placeMarks[0];

          placeMarkRenamed = Placemark(
            name : placeMark?.name?.replaceAll("NO HOUSE NUMBER, ", ""),
            thoroughfare: placeMark?.thoroughfare,
          );
        }
        else {
          for (var element in placeMarks) {
            placeMark = element;
            break; // Exit the loop once a address is found
          }

          placeMarkRenamed = Placemark(
            name : placeMark?.name?.replaceAll("NO HOUSE NUMBER, ", ""),
          );
        }
      }
      else {
        placeMarkRenamed = null;
      }
    }
    catch(error){
      debugPrint(error.toString());
      placeMark = null;
    }

    return placeMarkRenamed;
  }

  Future<String?> returnPlaceMarksString(double latitude, double longitude) async {
    Placemark? placeMark;
    String? placeMarkRenamed;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude, localeIdentifier: "en");

      if (placeMarks.isNotEmpty) {
        if (Platform.isAndroid) {
          placeMark = placeMarks[0];
          placeMarkRenamed = (placeMark.name!.replaceAll("NO HOUSE NUMBER, ", "").toString() == "" ? placeMark.name.toString() : placeMark.name.toString() + ', ') + placeMark.thoroughfare.toString();
        }
        else {
          for (var element in placeMarks) {
            placeMark = element;
            break; // Exit the loop once a address is found
          }

          placeMarkRenamed = placeMark?.name!.replaceAll("NO HOUSE NUMBER, ", "");
        }
      }
      else {
        placeMarkRenamed = null;
      }
    }
    catch(error){
      debugPrint(error.toString());
      placeMark = null;
    }

    return placeMarkRenamed;
  }

  Future<String?> returnPlaceMarksString2(GeoPoint selectedGeopoint) async {

    if (selectedGeopoint != checkingGeopoint) {
      checkingGeopoint = selectedGeopoint;
      Placemark? placeMark;
      String? placeMarkRenamed;
      try {
        List<Placemark> placeMarks = await placemarkFromCoordinates(
            checkingGeopoint!.latitude, checkingGeopoint!.longitude, localeIdentifier: "en");

        if (placeMarks.isNotEmpty) {
          if (Platform.isAndroid) {
            placeMark = placeMarks[0];
            placeMarkRenamed = (placeMark.name!
                .replaceAll("NO HOUSE NUMBER, ", "").toString() == ""
                ? placeMark.name.toString()
                : placeMark.name.toString() + ', ') +
                placeMark.thoroughfare.toString();
            checkPlaceMarkRenamed = placeMarkRenamed;
          }
          else {
            for (var element in placeMarks) {
              placeMark = element;
              break; // Exit the loop once a address is found
            }

            placeMarkRenamed =
                placeMark?.name!.replaceAll("NO HOUSE NUMBER, ", "");
            checkPlaceMarkRenamed = placeMarkRenamed;
          }
        }
        else {
          placeMarkRenamed = null;
        }

        notifyListeners();
      }
      catch (error) {
        debugPrint(error.toString());
        placeMark = null;
      }

      return placeMarkRenamed;
    }
    else {
      return checkPlaceMarkRenamed;
    }
  }

  void setUserPosition(GeoPoint userPosition) {
      this.userPosition = userPosition;
      notifyListeners();
  }

  // Calculate the distance between locationModel?.geopoint and userPosition
  double calculateDistance() {
    if (locationModel == null || userPosition == null) {
      // Handle null values, if necessary
      return 0;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      locationModel!.geopoint.latitude,
      locationModel!.geopoint.longitude,
      userPosition!.latitude,
      userPosition!.longitude,
    );

    // You now have the distance in meters. You can convert it to other units if needed.
    return distanceInMeters/1000;
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
    getPlaceMarks(latitude, longitude);
    notifyListeners();
  }

  locations() async{
    await checkLocationPermissionStatus();
    if (hasLocationPermission) {

    }
    else {
      showEvieAllowOrbitalDialog(this);
    }
  }

  clear() async {
    locationModel = null;
    threatRoutesLists?.clear();
    locationPermissionStatus?.cancel();
    notifyListeners();
  }

}
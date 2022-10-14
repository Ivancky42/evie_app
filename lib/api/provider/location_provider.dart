import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/utils.dart';
import 'package:geocoding/geocoding.dart';

import '../model/bike_model.dart';
import '../model/location_model.dart';

class LocationProvider extends ChangeNotifier {
  ///Mapbox default public token was store in gradle.properties file //Android

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String defPublicAccessToken = dotenv.env['DEF_PUBLIC_TOKEN'] ?? 'DB not found';
  String mapBoxStyleToken = dotenv.env['MAPBOX_STYLE_TOKEN'] ?? 'DB not found';

  LocationModel? locationModel;
  Position? userPosition;
  Placemark? currentPlaceMark;

  double dummyLat = 5.323792523984422;
  double dummyLong = 100.28216300994987;

  Geolocator geolocator = Geolocator();

  Future<void> init(LocationModel? locationModel) async {
    print(locationModel!.geopoint.latitude);
    if(locationModel == null){

    }
    else{
      this.locationModel = locationModel;
      ///Check location service availability, ask for permission if !


      ///Get bike already have location info in bike provider
      userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      //print(userPosition?.latitude);
      //print(userPosition?.longitude);

      //getBikeLocation("imei pass from main provider");

      notifyListeners();
    }
  }

  updateLocationStatus(){}

  getPlaceMarks(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    placemarks.forEach((element) {
      currentPlaceMark = element;
    });


  }

}

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  String status;
  GeoPoint geopoint;
  Timestamp? updated;

  LocationModel({
    required this.status,
    required this.geopoint,
    this.updated,
  });

  Map<String, dynamic> toJson() => {
    "status" : status,
    "geopoint" : geopoint,
    "updated": timestampToJson(updated)
  };

  factory LocationModel.fromJson(Map json) {
    return LocationModel(
      status: json['status']?? '',
      geopoint: fromJsonGeoPoint(json['geopoint'] as GeoPoint),
      updated: timestampFromJson(json['updated']),
    );
  }

  static GeoPoint fromJsonGeoPoint(GeoPoint geopoint) {
    return geopoint;
  }

  static GeoPoint toJsonGeoPoint(GeoPoint geopoint) {
    return geopoint;
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
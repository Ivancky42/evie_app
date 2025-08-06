
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  String? eventId;
  String? status;
  GeoPoint? geopoint;
  bool? isConnected;
  Timestamp? updated;

  LocationModel({
    this.eventId,
    this.status,
    this.geopoint,
    this.isConnected,
    this.updated,
  });

  Map<String, dynamic> toJson() => {
    "eventId" : eventId,
    "status" : status,
    "geopoint" : geopoint,
    "isConnected" : isConnected,
    "updated": timestampToJson(updated)
  };

  factory LocationModel.fromJson(Map json) {
    return LocationModel(
      eventId: json['eventId']?? '',
      status: json['status']?? '',
      isConnected: json['isConnected']?? true,
      geopoint: json['geopoint'] != null ? fromJsonGeoPoint(json['geopoint'] as GeoPoint) : null,
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
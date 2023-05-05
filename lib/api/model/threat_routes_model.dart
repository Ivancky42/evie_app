import 'package:cloud_firestore/cloud_firestore.dart';

class ThreatRoutesModel {
  GeoPoint? geopoint;
  Timestamp? created;
  String? address;

  ThreatRoutesModel({
    this.geopoint,
    this.created,
    this.address,
  });

  factory ThreatRoutesModel.fromJson(Map json) {
    return ThreatRoutesModel(
      geopoint: fromJsonGeoPoint(json['geopoint'] as GeoPoint) ?? const GeoPoint(0, 0),
      created: timestampFromJson(json['created']),
      address:  json['address'],
    );
  }

  static GeoPoint? fromJsonGeoPoint(GeoPoint? geopoint) {
    return geopoint;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}

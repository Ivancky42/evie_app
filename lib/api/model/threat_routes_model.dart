import 'package:cloud_firestore/cloud_firestore.dart';

class ThreatRoutesModel {
  GeoPoint? geopoint;
  Timestamp? created;

  ThreatRoutesModel({
    this.geopoint,
    this.created,
  });

  factory ThreatRoutesModel.fromJson(Map json) {
    return ThreatRoutesModel(
      geopoint: fromJsonGeoPoint(json['geopoint'] as GeoPoint),
      created: timestampFromJson(json['updated']),
    );
  }

  static GeoPoint? fromJsonGeoPoint(GeoPoint? geopoint) {
    return geopoint;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}

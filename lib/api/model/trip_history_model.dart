import 'package:cloud_firestore/cloud_firestore.dart';

class TripHistoryModel {
  ///m, meter
  int? carbonPrint;

  int? distance;

  int? startBattery;
  int? endBattery;

  GeoPoint? startTrip;
  GeoPoint? endTrip;

  Timestamp? startTime;
  Timestamp? endTime;

  String? startAddress;
  String? endAddress;

  TripHistoryModel({
    this.carbonPrint,

    this.distance,

    this.startBattery,
    this.endBattery,

    this.startTrip,
    this.endTrip,

    this.startTime,
    this.endTime,

    this.startAddress,
    this.endAddress,
  });

  factory TripHistoryModel.fromJson(Map json) {
    return TripHistoryModel(
      carbonPrint: json['carbonPrint'] ?? 0,
      
      distance: json['distance'] ?? 0,

      startBattery: json['startBattery'] ?? 0,
      endBattery: json['endBattery'] ?? 0,

      startTrip: fromJsonGeoPoint(json['startTrip'] as GeoPoint) ?? const GeoPoint(0, 0),
      endTrip: fromJsonGeoPoint(json['endTrip'] as GeoPoint) ?? const GeoPoint(0, 0),

      startTime: timestampFromJson(json['startTime']),
      endTime: timestampFromJson(json['endTime']),

      startAddress: json['startAddress'] ?? "",
      endAddress: json['endAddress'] ?? "",
    );
  }

  static GeoPoint? fromJsonGeoPoint(GeoPoint? geopoint) {
    return geopoint;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}

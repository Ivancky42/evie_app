import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String eventId;
  DateTime? created;
  GeoPoint geopoint;
  String type;
  String? address;

  EventModel({
    required this.eventId,
    required this.created,
    required this.geopoint,
    required this.type,
    this.address,
  });

  factory EventModel.fromJson(String eventId, Map json) {
    return EventModel(
      eventId: eventId,
      created: timestampFromJson(json['created']),
      geopoint: fromJsonGeoPoint(json['geopoint'] as GeoPoint),
      type: json['type']?? '',
      address: json['address'],
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

  static DateTime? timestampFromJson(Timestamp? timestamp) {
    return timestamp?.toDate(); // Convert the Firestore Timestamp to DateTime
  }
}
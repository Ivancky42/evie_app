import 'package:cloud_firestore/cloud_firestore.dart';

class RFIDModel {
  String? rfidID;
  Timestamp? created;

  RFIDModel({
    required this.rfidID,
    required this.created,
  });

  factory RFIDModel.fromJson(Map json, String rfidID) {
    return RFIDModel(
      rfidID:        rfidID,
      created:       timestampFromJson(json['created'] as Timestamp?),
    );
  }

  Map<String, dynamic> toJson() => {
    "created": timestampToJson(created),
  };

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



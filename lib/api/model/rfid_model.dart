import 'package:cloud_firestore/cloud_firestore.dart';

class RFIDModel {
  String? rfidID;
  String? rfidName;
  Timestamp? created;

  RFIDModel({
    required this.rfidID,
    this.rfidName,
    required this.created,
  });

  factory RFIDModel.fromJson(Map json) {
    return RFIDModel(
      rfidID:        json['rfidID']?? '',
      rfidName:      json['rfidName']?? '',
      created:       timestampFromJson(json['created'] as Timestamp?),
    );
  }

  // Map<String, dynamic> toJson() => {
  //   "created": timestampToJson(created),
  // };

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



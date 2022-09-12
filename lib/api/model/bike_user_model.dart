
import 'package:cloud_firestore/cloud_firestore.dart';

class BikeUserModel {
  String role;
  String uid;
  Timestamp? created;
  Timestamp? updated;

  BikeUserModel({
    required this.role,
    required this.uid,
    this.created,
  });

  Map<String, dynamic> toJson() => {
    "role" : role,
    "uid" : uid,
    "created": timestampToJson(created),
  };

  factory BikeUserModel.fromJson(Map json, imei) {
    return BikeUserModel(
      role: (json['role']?? '').toString(),
      uid: (json['uid']?? '').toString(),
      //  created: timestampFromJson(json['created']),
      //  updated: timestampFromJson(json['updated']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
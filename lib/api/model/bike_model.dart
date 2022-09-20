import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class BikeModel {
  String deviceType;
  String deviceIMEI;
  bool isLocked;
  String bikeName;
  Timestamp? created;
  Timestamp? updated;

  BikeModel({
    required this.deviceType,
    required this.deviceIMEI,
    required this.isLocked,
    required this.bikeName,
    this.created,
    this.updated,
  });

  Map<String, dynamic> toJson() => {
    "deviceType" : deviceType,
    "deviceIMEI" : deviceIMEI,
    "isLocked" : isLocked,
    "bikeName" : bikeName,
    "created": timestampToJson(created),
    "updated": timestampToJson(updated)
  };

  factory BikeModel.fromJson(Map json) {
    return BikeModel(
      deviceType: (json['deviceType']?? '').toString(),
      deviceIMEI: (json['deviceIMEI']?? '').toString(),
      bikeName: (json['bikeName']?? '').toString(),
      isLocked: json['isLocked']?? '',
      created: timestampFromJson(json['created']),
      updated: timestampFromJson(json['updated']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
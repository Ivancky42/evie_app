import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_model.dart';

class BikeModel {
  String deviceType;
  String deviceIMEI;
  bool isLocked;
  String bikeName;
  LocationModel? location;
  Timestamp? created;
  Timestamp? updated;

  BikeModel({
    required this.deviceType,
    required this.deviceIMEI,
    required this.isLocked,
    required this.bikeName,
    this.location,
    this.created,
    this.updated,
  });

  Map<String, dynamic> toJson() => {
    "deviceType" : deviceType,
    "deviceIMEI" : deviceIMEI,
    "isLocked" : isLocked,
    "bikeName" : bikeName,
    //"location" : location,
    "created": timestampToJson(created),
    "updated": timestampToJson(updated)
  };

  factory BikeModel.fromJson(Map json) {
    return BikeModel(
      deviceType: json['deviceType']?? '',
      deviceIMEI: json['deviceIMEI']?? '',
      bikeName:   json['bikeName']?? '',
      isLocked:   json['isLocked']?? false,
      location:   LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      created:    timestampFromJson(json['created']),
      updated:    timestampFromJson(json['updated']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
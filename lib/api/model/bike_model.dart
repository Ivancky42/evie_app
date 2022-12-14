import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_model.dart';

class BikeModel {

  int? batteryPercent;
  String? bleKey;
  Timestamp? created;
  String? deviceIMEI;
  String? deviceName;
  String? deviceType;
  int? errorCode;
  bool? isCharging;
  bool? isLocked;
  Timestamp? lastUpdated;
  LocationModel? location;
  String? macAddr;
  int? networkSignal;
  String? protVersion;
  Timestamp? registered;

  BikeModel({
    required this.batteryPercent,
    required this.bleKey,
    required this.created,
    required this.deviceIMEI,
    required this.deviceName,
    required this.deviceType,
    required this.errorCode,
    required this.isCharging,
    required this.isLocked,
    required this.lastUpdated,
    required this.location,
    required this.macAddr,
    required this.networkSignal,
    required this.protVersion,
    required this.registered,

  });

  Map<String, dynamic> toJson() => {
    "deviceType" : deviceType,
    "deviceIMEI" : deviceIMEI,
    "isLocked" : isLocked,
    //"location" : location,
    "created": timestampToJson(created),
  };

  factory BikeModel.fromJson(Map json) {
    return BikeModel(
      batteryPercent: json['batteryPercent']?? 0,
      bleKey: json['bleKey'] ?? null,
      created:    timestampFromJson(json['created']),
      deviceIMEI: json['deviceIMEI']?? '',
      deviceName: json['deviceName']?? '',
      deviceType: json['deviceType']?? '',
      errorCode: json['errorCode']?? 0,
      isCharging:   json['isCharging']?? false,
      isLocked:   json['isLocked']?? false,
      lastUpdated:    timestampFromJson(json['lastUpdated']),
      location:   LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      macAddr: json['macAddr']?? '',
      networkSignal: json['networkSignal']?? 0,
      protVersion: json['protVersion']?? '',
      registered:    timestampFromJson(json['registered']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
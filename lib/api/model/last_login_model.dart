import 'package:cloud_firestore/cloud_firestore.dart';

class LastLoginModel {
  String brand;
  String deviceId;
  String machine;
  String platform;
  String systemVer;
  String? country;
  Timestamp updated;

  LastLoginModel({
    required this.brand,
    required this.deviceId,
    required this.machine,
    required this.platform,
    required this.systemVer,
    this.country,
    required this.updated,
  });

  factory LastLoginModel.fromJson(Map json) {
    return LastLoginModel(
      brand:        json['brand']?? '',
      deviceId:     json['deviceId']?? '',
      machine:      json['machine']?? '',
      platform:     json['platform']?? '',
      systemVer:    json['systemVer']?? '',
      country:      json['country']?? '',
      updated:      timestampFromJson(json['updated'] as Timestamp),
    );
  }

  Map<String, dynamic> toJson() => {
    "brand" : brand,
    "deviceId": deviceId,
    "machine": machine,
    "platform": platform,
    "systemVer": systemVer,
    "updated": timestampToJson(updated)
  };

  static Timestamp timestampToJson(Timestamp timestamp) {
    return timestamp;
  }

  static Timestamp timestampFromJson(Timestamp timestamp) {
    return timestamp;
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';

class UserBikeModel {
  String deviceIMEI;
  String deviceType;
  Timestamp? created;
  Timestamp? updated;

  UserBikeModel({
    required this.deviceIMEI,
    required this.deviceType,
    this.created,
  });

  Map<String, dynamic> toJson() => {
    "deviceIMEI" : deviceIMEI,
    "deviceType" : deviceType,
    "created": timestampToJson(created),
  };

  factory UserBikeModel.fromJson(Map json) {
    return UserBikeModel(
      deviceType: (json['deviceType']?? '').toString(),
      deviceIMEI: (json['deviceIMEI']?? '').toString(),
      created: timestampFromJson(json['created']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
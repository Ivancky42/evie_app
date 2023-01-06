
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_setting_model.dart';

class UserBikeModel {
  String deviceIMEI;
  String deviceType;
  NotificationSettingModel? notificationSettings;
  Timestamp? created;
  Timestamp? updated;

  UserBikeModel({
    required this.deviceIMEI,
    required this.deviceType,
    this.notificationSettings,
    this.created,
  });


  factory UserBikeModel.fromJson(Map json) {
    return UserBikeModel(
      deviceType: json['deviceType']?? '',
      deviceIMEI: json['deviceIMEI']?? '',
      notificationSettings:  json['notificationSettings'] != null ? NotificationSettingModel.fromJson(json['notificationSettings'] as Map<String, dynamic>) : null,
      created:    timestampFromJson(json['created']),
    );
  }

  Map<String, dynamic> toJson() => {
    "deviceIMEI" : deviceIMEI,
    "deviceType" : deviceType,
    "created":     timestampToJson(created),
  };

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_setting_model.dart';

class UserModel {
  String uid;
  String email;
  String? name;
  String credentialProvider;
  String profileIMG;
  String? phoneNumber;
  Timestamp? created;
  Timestamp? updated;
  String? stripeId;
  String? stripeLink;
  NotificationSettingModel? notificationSettings;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    required this.credentialProvider,
    required this.profileIMG,
    this.phoneNumber,
    this.created,
    this.updated,
    this.stripeId,
    this.stripeLink,
    this.notificationSettings,
  });

  factory UserModel.fromJson(Map json) {
    return UserModel(
      uid:                json['uid']?? '',
      email:              json['email']?? '',
      name:               json['name']?? '',
      credentialProvider: json['credentialProvider']?? '',
      profileIMG:         json['profileIMG']?? '',
      phoneNumber:        json['phoneNumber']?? '',
      created:            timestampFromJson(json['created'] as Timestamp?),
      updated:            timestampFromJson(json['updated'] as Timestamp?),
      stripeId:           json['stripeId']?? '',
      stripeLink:         json['stripeLink']?? '',
      notificationSettings:  json['notificationSettings'] != null ? NotificationSettingModel.fromJson(json['notificationSettings'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "uid" : uid,
    "email": email,
    "name": name,
    "credentialProvider": credentialProvider,
    "profileIMG": profileIMG,
    "phoneNumber" : phoneNumber,
    "created": timestampToJson(created),
    "updated": timestampToJson(updated)
  };

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



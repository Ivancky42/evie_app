import 'package:cloud_firestore/cloud_firestore.dart';

import 'last_login_model.dart';
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
  LastLoginModel? lastLogin;
  bool isDeactivated;
  String? birthday;
  bool isBetaUser;

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
    this.lastLogin,
    this.birthday,
    required this.isDeactivated,
    required this.isBetaUser,
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
      lastLogin:  json['lastLogin'] != null ? LastLoginModel.fromJson(json['lastLogin'] as Map<String, dynamic>) : null,
      isDeactivated: json['isDeactivated'] ?? false,
        birthday: json['birthday'] ?? '',
      isBetaUser: json['isBetaUser']?? false,
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
    "updated": timestampToJson(updated),
    "isDeactivated": isDeactivated,
    "birthday": birthday,
  };

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



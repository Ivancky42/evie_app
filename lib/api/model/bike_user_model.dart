
import 'package:cloud_firestore/cloud_firestore.dart';

class BikeUserModel {
  String uid;
  String role;
  String? justInvited;
  String? status;
  String? notificationId;
  int? userId;
  Timestamp? created;

  BikeUserModel({
    required this.role,
    required this.uid,
    this.justInvited,
    this.status,
    this.notificationId,
    this.userId,
    this.created,
  });

  Map<String, dynamic> toJson() => {
    "uid" : uid,
    "role" : role,
    "userId" : userId,
    "created": timestampToJson(created),
  };

  factory BikeUserModel.fromJson(Map json) {
    return BikeUserModel(
      uid: json['uid']?? '',
      role: json['role']?? '',
      status: json['status']?? '',
      userId: json['userId'] ?? 10,
      notificationId: json['notificationId']?? '',
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
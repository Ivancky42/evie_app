import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String name;
  String credentialProvider;
  String profileIMG;
  String? phoneNumber;
  Timestamp? created;
  Timestamp? updated;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.credentialProvider,
    required this.profileIMG,
    this.phoneNumber,
    this.created,
    this.updated,
  });

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

  factory UserModel.fromJson(Map json) {
    return UserModel(
      uid: (json['uid']?? '').toString(),
      email: (json['email']?? '').toString(),
      name: (json['name']?? '').toString(),
      credentialProvider: (json['credentialProvider']?? '').toString(),
      profileIMG: (json['profileIMG']?? '').toString(),
      phoneNumber:(json['phoneNumber']?? '').toString(),
      created: timestampFromJson(json['created'] as Timestamp?),
      updated: timestampFromJson(json['updated'] as Timestamp?),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? body;
  String? deviceIMEI;
  String? status;
  String? title;
  String? type;
  bool? isRead;
  Timestamp? created;
  Timestamp? updated;


  NotificationModel({
    required this.body,
    required this.deviceIMEI,
    required this.status,
    required this.title,
    required this.type,
    required this.isRead,
    this.created,
    this.updated,
  });

  factory NotificationModel.fromJson(Map json) {
    return NotificationModel(
      body:        (json['body']?? ''      ).toString(),
      deviceIMEI:  (json['deviceIMEI']?? '').toString(),
      status:      (json['status']?? ''    ).toString(),
      title:       (json['title']?? ''     ).toString(),
      type:        (json['type']?? ''      ).toString(),
      isRead:      (json['isRead']?? ''    ),
      created:     timestampFromJson(json['created'] as Timestamp?),
      updated:     timestampFromJson(json['updated'] as Timestamp?),
    );
  }

  /*
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

   */

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}



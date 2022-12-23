import 'package:cloud_firestore/cloud_firestore.dart';

class SimSettingModel {
  String? iccid;
  Timestamp? created;
  Timestamp? updated;

  SimSettingModel({
    this.iccid,
    this.created,
    this.updated,
  });

  Map<String, dynamic> toJson() =>
      {
        "iccid": iccid,
        "created": timestampToJson(created),
        "updated": timestampToJson(updated)
      };

  factory SimSettingModel.fromJson(Map json) {
    return SimSettingModel(
      iccid: json['iccid'] ?? '',
      created: timestampFromJson(json['created']),
      updated: timestampFromJson(json['updated']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
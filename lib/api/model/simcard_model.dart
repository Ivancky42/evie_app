import 'package:cloud_firestore/cloud_firestore.dart';

class SimSettingModel {
  String? apn;
  String? iccid;
  Timestamp? created;
  Timestamp? updated;
  bool? isSimActivated;
  bool? isSimEventUpdated;

  SimSettingModel({
    this.iccid,
    this.created,
    this.updated,
    this.apn,
    this.isSimActivated,
    this.isSimEventUpdated,
  });

  Map<String, dynamic> toJson() => {
        "iccid": iccid,
        "apn": apn,
        "created": timestampToJson(created),
        "updated": timestampToJson(updated),
        "isSimActivated" : isSimActivated,
        "isSimEventUpdated": isSimEventUpdated,
  };

  factory SimSettingModel.fromJson(Map json) {
    return SimSettingModel(
      iccid: json['iccid'] ?? '',
      created: timestampFromJson(json['created']),
      updated: timestampFromJson(json['updated']),
        isSimEventUpdated: json['isSimEventUpdated'] ?? false,
        isSimActivated: json['isSimActivated'] ?? false,
      apn: json['apn'] ?? ""
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
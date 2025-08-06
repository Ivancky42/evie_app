import 'package:cloud_firestore/cloud_firestore.dart';


class FirmwareModel {
  String desc;
  String id;
  String title;
  String ver;
  String url;
  Timestamp? updated;
  String betaVer;
  String betaUrl;

  FirmwareModel({
    required this.desc,
    required this.id,
    required this.title,
    required this.ver,
    required this.url,
    required this.updated,
    required this.betaUrl,
    required this.betaVer,
  });

  factory FirmwareModel.fromJson(Map json) {
    return FirmwareModel(
      desc: json['desc']?? '',
      id: json['id']?? '',
      title: json['title']?? '',
      ver: json['ver']?? '',
      url: json['url']?? '',
      betaVer: json['betaVer']?? '',
      betaUrl: json['betaUrl']?? '',
      updated: timestampFromJson(json['updated']),
    );
  }

  Map<String, dynamic> toJson() => {

  };


  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
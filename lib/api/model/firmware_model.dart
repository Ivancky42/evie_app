import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/movement_setting_model.dart';
import 'package:evie_test/api/model/plan_model.dart';
import 'package:evie_test/api/model/simcard_model.dart';

import 'bike_plan_model.dart';
import 'location_model.dart';

class FirmwareModel {
  String desc;
  String id;
  String title;
  String ver;
  String url;

  FirmwareModel({
    required this.desc,
    required this.id,
    required this.title,
    required this.ver,
    required this.url,
  });

  factory FirmwareModel.fromJson(Map json) {
    return FirmwareModel(
      desc: json['desc']?? '',
      id: json['id']?? '',
      title: json['title']?? '',
      ver: json['ver']?? '',
      url: json['url']?? '',
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
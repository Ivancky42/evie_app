import 'package:cloud_firestore/cloud_firestore.dart';

class PedalPalsModel {

  String? id;
  String? name;
  Timestamp? created;
  Timestamp? updated;

  PedalPalsModel({
    required this.id,
    required this.name,
    required this.created,
    required this.updated,
  });

  factory PedalPalsModel.fromJson(Map json) {
    return PedalPalsModel(
      id:         json['id']?? '',
      name:       json['name']?? '',
      created:    timestampFromJson(json['created']),
      updated:    timestampFromJson(json['updated']),
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }

}
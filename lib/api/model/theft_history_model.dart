
import 'package:cloud_firestore/cloud_firestore.dart';

class ThreatHistoryModel {
  Timestamp? created;
  Timestamp? updated;

  ThreatHistoryModel({
    this.created,
    this.updated,
  });

  factory ThreatHistoryModel.fromJson(Map json) {
    return ThreatHistoryModel(
      created:       timestampFromJson(json['created'] as Timestamp),
      updated:       timestampFromJson(json['updated'] as Timestamp),
    );
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}





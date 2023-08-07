import 'package:cloud_firestore/cloud_firestore.dart';

class BatteryModel {
  int? percentage;
  Timestamp? lastUpdated;

  BatteryModel({
    this.percentage,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() =>
      {};

  factory BatteryModel.fromJson(Map json) {
    return BatteryModel(
      percentage: json['percentage'] ?? 0,
      lastUpdated: timestampFromJson(json['lastUpdated']),
    );
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class BatteryModel {
  int? percentage;
  Timestamp? lastUpdated;
  String? model;

  BatteryModel({
    this.percentage,
    this.lastUpdated,
    this.model,
  });

  Map<String, dynamic> toJson() =>
      {};

  factory BatteryModel.fromJson(Map json) {
    return BatteryModel(
      percentage: json['percentage'],
      model: json['model'],
      lastUpdated: timestampFromJson(json['lastUpdated']),
    );
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
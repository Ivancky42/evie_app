import 'package:cloud_firestore/cloud_firestore.dart';

class BikePlanModel {
  String? planId;
  String? name;
  String? product;
  Timestamp? periodStart;
  Timestamp? periodEnd;
  Timestamp? created;

  BikePlanModel({
    this.planId,
    this.name,
    this.product,
    this.periodStart,
    this.periodEnd,
    this.created,
  });

  Map<String, dynamic> toJson() =>
      {
      };

  factory BikePlanModel.fromJson(Map json) {
    return BikePlanModel(
      planId: json['eventId'] ?? '',
      name: json['name'] ?? '',
      product: json['product'] ?? '',
      periodStart: timestampFromJson(json['periodStart']),
      periodEnd: timestampFromJson(json['periodEnd']),
      created: timestampFromJson(json['created']),
    );
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
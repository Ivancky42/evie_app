import 'package:cloud_firestore/cloud_firestore.dart';

class BikePlanModel {
  String? planId;
  String? name;
  DocumentReference? product;
  Timestamp? startAt;
  Timestamp? expiredAt;
  Timestamp? created;

  BikePlanModel({
    this.planId,
    this.name,
    this.product,
    this.startAt,
    this.expiredAt,
    this.created,
  });

  Map<String, dynamic> toJson() =>
      {
      };

  factory BikePlanModel.fromJson(Map json) {
    return BikePlanModel(
      planId: json['eventId'] ?? '',
      name: json['name'] ?? '',
      product: json['product'] ?? null,
      startAt: timestampFromJson(json['startAt']) ?? Timestamp.fromDate(DateTime.now().subtract(Duration(days: 365))),
      expiredAt: timestampFromJson(json['expiredAt']) ??  Timestamp.fromDate(DateTime.now().subtract(Duration(days: 365))),
      created: timestampFromJson(json['created']),
    );
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }
}
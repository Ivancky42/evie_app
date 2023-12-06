
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  String? id;
  bool? active;
  String? description;
  List<dynamic>? images;
  String? name;
  String? role;
  String? taxCode;
  String? feature;

  PlanModel({
    this.id,
    required this.active,
    required this.description,
    required this.images,
    required this.name,
    required this.role,
    required this.taxCode,
    this.feature,
  });

  factory PlanModel.fromJson(Map json, String id) {
    return PlanModel(
        id: id,
        active: json['active'] ?? false,
        description: json['description'] ?? "",
        images: json['images'] ?? [],
        name: json['name'] ?? "",
        role: json['role'] ?? "",
        taxCode: json['tax_code'] ?? "",
        feature: json['stripe_metadata_feature'] ?? ""
    );
  }
}
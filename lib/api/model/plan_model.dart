
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  bool? active;
  String? description;
  List<dynamic>? images;
  String? name;
  String? role;
  String? taxCode;

  PlanModel({
    required this.active,
    required this.description,
    required this.images,
    required this.name,
    required this.role,
    required this.taxCode,
  });

  factory PlanModel.fromJson(Map json) {
    return PlanModel(
        active: json['active'] ?? false,
        description: json['description'] ?? "",
        images: json['images'] ?? [],
        name: json['name'] ?? "",
        role: json['role'] ?? "",
        taxCode: json['tax_code'] ?? ""
    );
  }
}
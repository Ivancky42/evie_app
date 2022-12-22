class PriceModel {
  String? id;
  bool? active;
  String? billingScheme;
  String? currency;
  String? description;
  String? type;
  String? unitAmount;

  PriceModel({
    this.id,
    required this.active,
    required this.billingScheme,
    required this.currency,
    required this.description,
    required this.type,
    required this.unitAmount,
  });

  factory PriceModel.fromJson(Map json, String id) {
    return PriceModel(
        id: id,
        active: json['active'] ?? false,
        billingScheme: json['billing_scheme'] ?? "",
        currency: json['currency'] ?? [],
        description: json['description'] ?? "",
        type: json['type'] ?? "",
        unitAmount: json['unit_amount'] ?? ""
    );
  }
}
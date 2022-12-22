class PriceModel {
  bool? active;
  String? billingScheme;
  String? currency;
  String? description;
  String? type;
  String? unitAmount;

  PriceModel({
    required this.active,
    required this.billingScheme,
    required this.currency,
    required this.description,
    required this.type,
    required this.unitAmount,
  });

  factory PriceModel.fromJson(Map json) {
    return PriceModel(
        active: json['active'] ?? false,
        billingScheme: json['billing_scheme'] ?? "",
        currency: json['currency'] ?? [],
        description: json['description'] ?? "",
        type: json['type'] ?? "",
        unitAmount: json['unit_amount'] ?? ""
    );
  }
}
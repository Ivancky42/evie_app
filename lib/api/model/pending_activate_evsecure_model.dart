
class PendingActivateEVSecure {
  String? orderId;
  bool? enabled;

  PendingActivateEVSecure({
    this.orderId,
    this.enabled,
  });

  Map<String, dynamic> toJson() => {
    "orderId" : orderId,
    "enabled" : enabled,
  };

  factory PendingActivateEVSecure.fromJson(Map json) {
    return PendingActivateEVSecure(
      orderId: json['orderId']?? '',
      enabled: json['enabled']?? false,
    );
  }
}
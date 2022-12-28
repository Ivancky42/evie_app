import 'dart:ffi';

class MovementSettingModel {
  bool? enabled;
  String? sensitivity;

  MovementSettingModel({
    this.enabled,
    this.sensitivity,
  });

  Map<String, dynamic> toJson() =>
      {
        "enabled": enabled,
        "sensitivity": sensitivity,
      };

  factory MovementSettingModel.fromJson(Map json) {
    return MovementSettingModel(
      enabled: json['enabled'] ?? false,
      sensitivity: json['sensitivity'] ?? '',
    );
  }
}
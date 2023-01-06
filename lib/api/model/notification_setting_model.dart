import 'dart:ffi';

class NotificationSettingModel {
  bool? connectionLost;
  bool? crash;
  bool? fallDetect;
  bool? lock;
  bool? lowBattery;
  bool? movementDetect;
  bool? planReminder;
  bool? theftAttempt;
  bool? firmwareUpdate;
  bool? general;

  NotificationSettingModel({
    this.connectionLost,
    this.crash,
    this.fallDetect,
    this.lock,
    this.lowBattery,
    this.movementDetect,
    this.planReminder,
    this.theftAttempt,
    this.firmwareUpdate,
    this.general,
  });

  factory NotificationSettingModel.fromJson(Map json) {
    return NotificationSettingModel(
      connectionLost: json['connectionLost'] ?? false,
      crash:          json['crash'] ?? false,
      fallDetect:     json['fallDetect'] ?? false,
      lock:           json['lock'] ?? false,
      lowBattery:     json['lowBattery'] ?? false,
      movementDetect: json['movementDetect'] ?? false,
      planReminder:   json['planReminder'] ?? false,
      theftAttempt:   json['theftAttempt'] ?? false,
      firmwareUpdate:   json['firmwareUpdate'] ?? false,
      general:   json['general'] ?? false,
    );
  }

  Map<String, dynamic> toJson() =>
      {

      };

}
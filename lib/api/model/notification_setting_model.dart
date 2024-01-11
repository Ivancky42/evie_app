import 'dart:ffi';

class NotificationSettingModel {
  bool? connectionLost;
  bool? crash;
  bool? fallDetect;
  bool? lock;
  bool? unlock;
  bool? lowBattery;
  bool? movementDetect;
  bool? planReminder;
  bool? theftAttempt;
  bool? firmwareUpdate;
  bool? general;
  bool? promo;
  bool? evKey;

  NotificationSettingModel({
    this.connectionLost,
    this.crash,
    this.fallDetect,
    this.lock,
    this.unlock,
    this.lowBattery,
    this.movementDetect,
    this.planReminder,
    this.theftAttempt,
    this.firmwareUpdate,
    this.general,
    this.promo,
    this.evKey,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettingModel &&
        connectionLost == other.connectionLost &&
        crash == other.crash &&
        fallDetect == other.fallDetect &&
        unlock == other.unlock &&
        lock == other.lock &&
        lowBattery == other.lowBattery &&
        movementDetect == other.movementDetect &&
        planReminder == other.planReminder &&
        theftAttempt == other.theftAttempt &&
        firmwareUpdate == other.firmwareUpdate &&
        general == other.general &&
        promo == other.promo &&
        evKey == other.evKey;
  }

  @override
  int get hashCode {
    return connectionLost.hashCode ^
    crash.hashCode ^
    fallDetect.hashCode ^
    lock.hashCode ^
    unlock.hashCode ^
    lowBattery.hashCode ^
    movementDetect.hashCode ^
    planReminder.hashCode ^
    theftAttempt.hashCode ^
    firmwareUpdate.hashCode ^
    general.hashCode ^
    promo.hashCode ^
    evKey.hashCode;
  }

  factory NotificationSettingModel.fromJson(Map json) {
    return NotificationSettingModel(
      connectionLost: json['connectionLost'] ?? false,
      crash:          json['crash'] ?? false,
      fallDetect:     json['fallDetect'] ?? false,
      unlock:         json['unlock'] ?? false,
      lock:           json['lock'] ?? false,
      lowBattery:     json['lowBattery'] ?? false,
      movementDetect: json['movementDetect'] ?? false,
      planReminder:   json['planReminder'] ?? false,
      theftAttempt:   json['theftAttempt'] ?? false,
      firmwareUpdate:   json['firmwareUpdate'] ?? false,
      general:   json['general'] ?? false,
      promo: json['promo'] ?? false,
      evKey: json['evKey'] ?? false,
    );
  }

  Map<String, dynamic> toJson() =>
      {

      };

}
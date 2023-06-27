import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/movement_setting_model.dart';
import 'package:evie_test/api/model/pedal_pals_model.dart';
import 'package:evie_test/api/model/plan_model.dart';
import 'package:evie_test/api/model/simcard_model.dart';
import 'package:evie_test/api/model/trip_history_model.dart';

import 'bike_plan_model.dart';
import 'location_model.dart';

// v comment: 3 attributes added
// String? bikeIMG
// this.bikeIMG
// bikeIMG: json['bikeIMG']??''

class BikeModel {

  int? batteryPercent;
  String? bleKey;
  String? bleName;
  Timestamp? created;
  String? deviceIMEI;
  String? deviceName;
  String? deviceType;
  int? errorCode;
  bool? isCharging;
  bool? isLocked;
  Timestamp? lastUpdated;
  LocationModel? location;
  TripHistoryModel? tripHistoryModel;
  PedalPalsModel? pedalPalsModel;
  MovementSettingModel? movementSetting;
  SimSettingModel? simSetting;
  BikePlanModel? bikePlanModel;
  PlanModel? planModel;
  String? macAddr;
  int? networkSignal;
  String? protVersion;
  String? firmVer;
  Timestamp? registered;
  String? ownerUid;
  String? ownerName;
  String? serialNumber;
  String? type;
  String? bikeIMG;

  BikeModel({
    required this.batteryPercent,
    required this.bleKey,
    required this.bleName,
    required this.created,
    required this.deviceIMEI,
    required this.deviceName,
    required this.deviceType,
    required this.errorCode,
    required this.isCharging,
    required this.isLocked,
    required this.lastUpdated,
    required this.location,
    this.tripHistoryModel,
    this.pedalPalsModel,
    this.movementSetting,
    this.bikePlanModel,
    this.simSetting,
    required this.macAddr,
    required this.networkSignal,
    required this.protVersion,
    this.firmVer,
    required this.registered,
    this.ownerUid,
    this.ownerName,
    this.serialNumber,
    this.type,
    this.bikeIMG,

  });

  Map<String, dynamic> toJson() => {
    "deviceType" : deviceType,
    "deviceIMEI" : deviceIMEI,
    "isLocked" : isLocked,
    //"location" : location,
    "created": timestampToJson(created),
  };

  factory BikeModel.fromJson(Map json) {
    return BikeModel(
      batteryPercent: json['batteryPercent']?? 0,
      bleKey: json['bleKey']?? null,
      bleName: json['bleName']?? '',
      created:    timestampFromJson(json['created']),
      deviceIMEI: json['deviceIMEI']?? '',
      deviceName: json['deviceName']?? '',
      deviceType: json['deviceType']?? '',
      errorCode: json['errorCode']?? 0,
      isCharging:   json['isCharging']?? false,
      isLocked:   json['isLocked']?? false,
      lastUpdated:    timestampFromJson(json['lastUpdated']),
      location:   LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      //tripHistoryModel:   TripHistoryModel.fromJson(json['tripHistory'] as Map<String, dynamic>),
      pedalPalsModel:  json['pedalPals'] != null ? PedalPalsModel.fromJson(json['pedalPals'] as Map<String, dynamic>) : null,
      movementSetting: json['movementSetting'] != null ? MovementSettingModel.fromJson(json['movementSetting'] as Map<String, dynamic>) : null,
      simSetting:   json['simSetting'] != null ? SimSettingModel.fromJson(json['simSetting'] as Map<String, dynamic>) : null,
      bikePlanModel:   json['plans'] != null ? BikePlanModel.fromJson(json['plans'] as Map<String, dynamic>) : null,
      macAddr: json['macAddr']?? '',
      networkSignal: json['networkSignal']?? 0,
      protVersion: json['protVersion']?? '',
      firmVer: json['firmVer']?? '',
      registered:    timestampFromJson(json['registered']),
      serialNumber: json['serialNumber']?? '',
      type: json['type']?? '',
      bikeIMG: json['bikeIMG']??'',
    );
  }

  Timestamp? timestampToJson(Timestamp? timestamp) {
    return timestamp;
  }

  static Timestamp? timestampFromJson(Timestamp? timestamp) {
    return timestamp;
  }

  setTripHistory(dynamic data){
    tripHistoryModel = data;
  }

}
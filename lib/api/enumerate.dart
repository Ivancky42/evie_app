enum SheetList{

  mapDetails,
  threatHistory,

  bikeSetting,

  evKey,
  registerEvKey,
  evAddFailed,

  evKeyList,
  nameEv,

  motionSensitivity,
  detectionSensitivity,

  currentPlan,
  managePlan,
  essentialPlan,
  proPlan,

  pedalPals,
  createTeam,
  shareBikeInvitation,
  invitationSent,
  userNotFound,
  pedalPalsList,

  orbitalAntiThefts,

  aboutBike,

  firmwareInformation,
  firmwareUpdateCompleted,
  firmwareUpdateFailed,

  userManual,

  resetBike,
  resetBike2,

  unlinkBike,
  bikeEraseUnlink,
  fullReset,
  bikeEraseReset,

  restoreCompleted,
  restoreIncomplete,

  forgetCompleted,
  forgetIncomplete,

  fullCompleted,
  fullIncomplete,

  leaveTeam,
  bikeEraseLeave,
  leaveSuccessful,
  leaveUnsuccessful,

  rideHistory,
  rideDetails,
  batteryDetails,
}

///List of Action
enum ActionList{
  deactivateTheftAlert,

}


enum BikeSettingList{
  bikeSetting,
  evKey,
  motionSensitivity,
  evPlusSubscription,
  pedalPals,
  pedalPalsList,
  orbitalAntiThefts,
  aboutBike,
  bikeSoftware,
  userManual,
  reset,
}

enum MeasurementSetting{
  ///meters
  metricSystem,

  ///miles
  imperialSystem,
}


enum ActionableBarItem{
  none,
  registerEVKey,
}

enum BikeStatus{
  unknown,
  safe,
  warning,
  connectionLost,
  danger
}

enum BLEScanResult{
  unknown,
  scanning,
  deviceFound,
  noDeviceFound,
  scanTimeout,
}
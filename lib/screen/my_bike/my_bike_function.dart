import 'package:flutter/material.dart';

returnBikeStatusImage(bool isConnected,String status) {
  if (isConnected == false) {
    return "assets/images/bike_HPStatus/bike_warning.png";
  } else {
    switch (status) {
      case "safe":
        return "assets/images/bike_HPStatus/bike_safe.png";
      case "warning":
      case "fall":
        return "assets/images/bike_HPStatus/bike_warning.png";
      case "danger":
      case "crash":
        return "assets/images/bike_HPStatus/bike_danger.png";
      default:
        return CircularProgressIndicator();
    }
  }
}


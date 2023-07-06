import 'dart:collection';

class EvieFilter {

  static isAllBikeSafe(LinkedHashMap userBikeDetails){
    bool isAllBikeSafe = true;

    for (var element in userBikeDetails.values) {
       if(element.location.isConnected == false ||
          element.location.status == "fall" ||
          element.location.status == "warning" ||
          element.location.status == "crash" ||
          element.location.status == "danger" ){
        isAllBikeSafe = false;
      }
    }
    return isAllBikeSafe;
  }

}
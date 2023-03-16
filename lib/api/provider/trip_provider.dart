import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../function.dart';
import '../model/trip_history_model.dart';
import 'bike_provider.dart';

enum TripFormat{
  day,
  week,
  month,
  year,
}


class TripProvider extends ChangeNotifier {

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String tripHistoryCollection = dotenv.env['DB_COLLECTION_TRIPHISTORY'] ?? 'DB not found';

  LinkedHashMap currentTripHistoryLists = LinkedHashMap<String, TripHistoryModel>();

  StreamSubscription? tripHistorySubscription;

  TripHistoryModel? currentTripHistoryModel;
  BikeModel? currentBikeModel;

  TripProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    getTripHistory();
  }

  Future<void> update(BikeModel? currentBikeModel) async {
    this.currentBikeModel = currentBikeModel;
    getTripHistory();
  }

  getTripHistory() async {
    tripHistorySubscription?.cancel();
    if(currentBikeModel != null){
      currentTripHistoryLists.clear();
      try{
        tripHistorySubscription = FirebaseFirestore.instance
            .collection(bikesCollection)
///            .doc(currentBikeModel!.deviceIMEI)
            .doc("862205055084620")
            .collection(tripHistoryCollection)
            .orderBy("startTime", descending: true)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            for (var docChange in snapshot.docChanges) {
              switch (docChange.type) {
                case DocumentChangeType.added:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  currentTripHistoryLists.putIfAbsent(docChange.doc.id, () => TripHistoryModel.fromJson(obj!));
                  notifyListeners();
                  break;
                case DocumentChangeType.removed:
                  currentTripHistoryLists.removeWhere((key, value) => key == docChange.doc.id);
                  notifyListeners();
                  break;
                case DocumentChangeType.modified:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  currentTripHistoryLists.update(docChange.doc.id, (value) => TripHistoryModel.fromJson(obj!));
                  notifyListeners();
                  break;
              }
            }
          }else{
            currentTripHistoryLists.clear();
          }
        });

      }catch (e) {
        debugPrint(e.toString());
        tripHistorySubscription?.cancel();
      }
    }
  }


   getYearStatusData(DateTime pickedData){

    List<double> returnData = [];
    double totalMileage = 0;
    double noOfRide = 0;

    /// Average Speed per Ride = Total Distance / Total Time per Ride
    /// Total Time = End Time - Start Time
    double totalTime = 0;
    double totalAverageSpeed = 0;

    ///Average Duration per Ride = Total Time per Ride / Number of Rides
    ///  (endTime-startTime) + (endTime-startTime) + (endTime-startTime)/ 3
    double totalDuration = 0;

    currentTripHistoryLists.forEach((key, value) {
      ///Filter date
      if(value.startTime.toDate().year == pickedData.year){

        noOfRide += 1;
        totalMileage += value.distance;
        totalTime += calculateTimeDifferentInHour(value.endTime!.toDate(), value.startTime!.toDate());
      }
    });

    totalAverageSpeed = calculateAverageSpeed(totalMileage, totalTime);
    totalDuration = (totalTime/noOfRide);

    returnData.add(totalMileage);
    returnData.add(noOfRide);
    returnData.add(totalAverageSpeed);
    returnData.add(totalDuration);

    return returnData;
  }

  Future uploadPlaceMarkAddressToFirestore(String deviceIMEI, String eventID, String targetAddress, String address) async {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .collection(tripHistoryCollection)
          .doc(eventID)
          .set({
        targetAddress: address,
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  clear(){
    tripHistorySubscription?.cancel();
    currentTripHistoryLists.clear();
  }
}

class ChartData {
  ChartData(this.x, this.y);

  dynamic x;
  dynamic y;
}

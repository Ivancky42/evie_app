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

enum DataType{
  mileage,
  noOfRide,
  carbonFootprint,
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
    if(currentBikeModel != null){
      currentTripHistoryLists.clear();
      try{
        tripHistorySubscription = FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(currentBikeModel!.deviceIMEI)
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

    // Average Speed per Ride = Total Distance / Total Time per Ride
    // Total Time = End Time - Start Time

 //   dynamic totalTime;
  //  double averageSpeed = 0;

    // Average Duration = Total Time / Number of Rides
    // Total Time = End Time - Start Time

 //   dynamic averageDuration;
    currentTripHistoryLists.forEach((key, value) {
      ///Filter date
      if(value.startTime.toDate().year == pickedData.year){

        noOfRide += 1;
        totalMileage += value.distance;

      //  totalTime += (value.endTime!.toDate().difference(value.startTime!.toDate())).inMinutes;


      }
    });

  //  averageSpeed = (totalMileage/totalTime);


    returnData.add(totalMileage);
    returnData.add(noOfRide);
    //returnData.add(averageSpeed);

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



  // getData(BikeProvider bikeProvider, TripProvider tripProvider, TripFormat tripFormat, DateTime pickedDate, chartData, currentTripHistoryListDay){
  //
  //   switch(tripFormat){
  //     case TripFormat.day:
  //       chartData.clear();
  //       currentTripHistoryListDay.clear();
  //
  //       tripProvider.currentTripHistoryLists.forEach((key, value) {
  //         ///Filter date
  //         if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
  //           chartData.add(ChartData(value.startTime.toDate(), value.distance.toDouble()));
  //           currentTripHistoryListDay.add(value);
  //         }
  //       });
  //       return;
  //     case TripFormat.week:
  //       chartData.clear();
  //       currentTripHistoryListDay.clear();
  //       // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)
  //       tripProvider.currentTripHistoryLists.forEach((key, value) {
  //         ///Filter date
  //         ///if pickeddate is before pickedData.add7days
  //         if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)))){
  //           chartData.add(ChartData(value.startTime.toDate().day, value.distance.toDouble()));
  //           currentTripHistoryListDay.add(value);
  //         }
  //         if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
  //           chartData.add(ChartData(value.startTime.toDate().day, value.distance.toDouble()));
  //           currentTripHistoryListDay.add(value);
  //         }
  //       });
  //       return;
  //     case TripFormat.month:
  //       chartData.clear();
  //       currentTripHistoryListDay.clear();
  //
  //       final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);
  //
  //       tripProvider.currentTripHistoryLists.forEach((key, value) {
  //         ///Filter date
  //         if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){
  //
  //           double totalDistance = 0;
  //
  //           for (int day = 1; day <= totalDaysInMonth; day++) {
  //             if(value.startTime.toDate().day == day){
  //               totalDistance += value.distance;
  //               chartData.add(ChartData(value.startTime.toDate().day, totalDistance));
  //             }
  //           }
  //           currentTripHistoryListDay.add(value);
  //         }
  //       });
  //
  //       return;
  //     case TripFormat.year:
  //       chartData.clear();
  //       currentTripHistoryListDay.clear();
  //
  //       tripProvider.currentTripHistoryLists.forEach((key, value) {
  //         ///Filter date
  //         if(value.startTime.toDate().year == pickedDate!.year){
  //
  //           double totalDistance = 0;
  //
  //           for (int month = 1; month <= 12; month++) {
  //             if(value.startTime.toDate().month == month){
  //               totalDistance += value.distance;
  //               chartData.add(ChartData(value.startTime.toDate().month, totalDistance));
  //             }
  //           }
  //           currentTripHistoryListDay.add(value);
  //         }
  //       });
  //       return;
  //   }
  // }


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

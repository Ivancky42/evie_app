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
  late List<TripHistoryModel> currentTripHistoryListDay = [];

  StreamSubscription? tripHistorySubscription;

  TripHistoryModel? currentTripHistoryModel;
  BikeModel? currentBikeModel;

  List<String> dataType = ["Mileage", "No of Ride", "Carbon Footprint"];
  late String currentData;

  late List<ChartData> chartData = [];
  
  TripProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    currentData = dataType.first;
    getTripHistory();
    notifyListeners();
  }

  Future<void> update(BikeModel? currentBikeModel) async {
    this.currentBikeModel = currentBikeModel;
    getTripHistory();
  }

  setCurrentData(data){
    currentData = data;
    notifyListeners();
  }

  getTripHistory() async {
    tripHistorySubscription?.cancel();
    if(currentBikeModel != null){
      currentTripHistoryLists.clear();
      try{
        tripHistorySubscription = FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(currentBikeModel!.deviceIMEI)
///            .doc("862205055084620")
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
        totalTime += calculateTimeDifferentInHourMinutes(value.endTime!.toDate(), value.startTime!.toDate());
      }
    });

    totalAverageSpeed = calculateAverageSpeed(totalMileage, totalTime);
    //totalDuration = (totalTime/noOfRide);

    ///Total duration per ride was change to total duration
    totalDuration = (totalTime);

    ///Carbon footprint per month = total carbon footprint / 12


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

  getData(BikeProvider bikeProvider, TripFormat format, DateTime pickedDate, bool isFirst){

    switch(format){
      case TripFormat.day:
        chartData.clear();
        currentTripHistoryListDay.clear();

        currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(calculateDateDifference(pickedDate!, value.startTime.toDate()) == 0){
            chartData.add(ChartData(value.startTime.toDate(), value.distance.toDouble()));
            currentTripHistoryListDay.add(value);
          }
        });
        return;
      case TripFormat.week:

        if (isFirst) {
          chartData.clear();
          currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for(int i = 0; i < 7; i ++){
            chartData.add((ChartData(pickedDate!.subtract(Duration(days: i)), 0)));
          }

          chartData = chartData.reversed.toList();

          currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 1))) && value.startTime.toDate().isAfter(pickedDate!.subtract(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
              newData.y = newData.y + value.distance.toDouble();
              currentTripHistoryListDay.add(value);
            }
          });
        }
        else {
          chartData.clear();
          currentTripHistoryListDay.clear();
          // value.startTime.toDate().isBefore(pickedDate!.add(Duration(days: 7)

          for (int i = 0; i < 7; i ++) {
            chartData.add((ChartData(pickedDate!.add(Duration(days: i)), 0)));
          }

          currentTripHistoryLists.forEach((key, value) {
            if(value.startTime.toDate().isAfter(pickedDate) && value.startTime.toDate().isBefore(pickedDate!.add(const Duration(days: 6)))){
              ChartData newData = chartData.firstWhere((data) =>
              data.x.day == value.startTime
                  .toDate()
                  .day);
              newData.y = newData.y + value.distance.toDouble();
              currentTripHistoryListDay.add(value);
            }
          });
        }

        return;
      case TripFormat.month:
        chartData.clear();
        currentTripHistoryListDay.clear();

        final totalDaysInMonth = daysInMonth(pickedDate!.year,  pickedDate!.month);

        for(int i = 1; i <= totalDaysInMonth; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, i), 0)));
        }
        currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().month == pickedDate!.month && value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.day == value.startTime.toDate().day);
            newData.y = newData.y + value.distance.toDouble();
            currentTripHistoryListDay.add(value);
          }
        });

        return;
      case TripFormat.year:
        chartData.clear();
        currentTripHistoryListDay.clear();

        for(int i = 1; i <= 12; i ++){
          chartData.add((ChartData(DateTime(pickedDate!.year, i, 1), 0)));
        }

        currentTripHistoryLists.forEach((key, value) {
          ///Filter date
          if(value.startTime.toDate().year == pickedDate!.year){

            ChartData newData = chartData.firstWhere((data) => data.x.month == value.startTime.toDate().month);
            newData.y = newData.y + value.distance.toDouble();
            currentTripHistoryListDay.add(value);
          }
        });
        return;
    }
  }

  isFilterData(List<TripHistoryModel> tripList, TripHistoryModel tripModel){
    return tripList.any((trip) =>
        trip.carbonPrint == tripModel.carbonPrint &&
        trip.distance == tripModel.distance &&
        trip.startBattery == tripModel.startBattery &&
        trip.endBattery == tripModel.endBattery &&
        trip.startTime == tripModel.startTime &&
        trip.endTime == tripModel.endTime &&
        trip.startTrip == tripModel.startTrip &&
        trip.endTrip == tripModel.endTrip);
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

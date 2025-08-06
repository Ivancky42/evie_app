import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../function.dart';
import '../model/trip_history_model.dart';

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

  List<String> dataType = ["Distance", "No of Ride", "Carbon Footprint"];
  late String currentData;

  late List<ChartData> chartData = [];

  int selectedIndex = -1;
  TripFormat tripFormat = TripFormat.day;
  
  TripProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    currentData = dataType.first;
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

  ///Get data once when load page into trip history data
  getTripHistory() async {
    //tripHistorySubscription?.cancel();
    if(currentBikeModel != null){
      currentTripHistoryLists.clear();
        await FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(currentBikeModel!.deviceIMEI)
///            .doc("862205055084620")
            .collection(tripHistoryCollection)
            .orderBy("startTime", descending: true)
            .get().then((value) {
              if(value.docs.isNotEmpty){
                for (var element in value.docs) {
                  Map<String, dynamic>? obj = element.data();
                  currentTripHistoryLists.putIfAbsent(element.id, () => TripHistoryModel.fromJson(obj));
                }
              }else{
                currentTripHistoryLists.clear();
              }
              notifyListeners();
           });
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

  changeSelectedIndex(dynamic index, TripFormat tripFormat){
    selectedIndex = index;
    this.tripFormat = tripFormat;

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

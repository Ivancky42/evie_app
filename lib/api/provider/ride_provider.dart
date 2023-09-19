import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../enumerate.dart';
import '../function.dart';
import '../model/trip_history_model.dart';

enum RideFormat{
  day,
  week,
  month,
  year,
}

enum RideDataType {
  mileage,
  noOfRide,
  carbonFootprint,
}


class RideProvider extends ChangeNotifier {

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String tripHistoryCollection = dotenv.env['DB_COLLECTION_TRIPHISTORY'] ?? 'DB not found';

  LinkedHashMap currentTripHistoryLists = LinkedHashMap<String, TripHistoryModel>();
  List<TripHistoryModel> dayRideHistoryList = [];
  List<TripHistoryModel> weekRideHistoryList = [];
  List<TripHistoryModel> monthRideHistoryList = [];
  List<TripHistoryModel> yearRideHistoryList = [];
  late List<TripHistoryModel> currentTripHistoryListDay = [];

  StreamSubscription? tripHistorySubscription;

  TripHistoryModel? currentTripHistoryModel;
  BikeModel? currentBikeModel;
  MeasurementSetting? measurementSetting;

  RideDataType rideDataType = RideDataType.mileage;

  /// * Homepage Ride Card (Week) *****
  RideDataType weekCardDateType = RideDataType.mileage;
  String? weekCardDataTypeString = 'Mileage';
  String? weekCardData;
  String? weekCardDataUnit;
  ///**********************************

  late String rideDataTypeString;
  late String rideDataString;
  late String rideDataDayString = "";
  late String rideDataWeekString = "";
  late String rideDataMonthString = "";
  late String rideDataYearString = "";
  late String rideDataUnit;

  late List<ChartData> chartData = [];
  late List<DayTimeChartData> dayTimeChartData = [];
  late List<ChartData> weekTimeChartData = [];
  late List<ChartData> monthTimeChartData = [];
  late List<ChartData> yearTimeChartData = [];

  int selectedIndex = -1;
  RideFormat rideFormat = RideFormat.day;

  RideProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    setRideData(RideDataType.mileage, RideFormat.day, DateTime.now());
  }

  Future<void> update(BikeModel? currentBikeModel, MeasurementSetting? measurementSetting) async {
    if (currentBikeModel != null && measurementSetting != null) {
      if (this.currentBikeModel != currentBikeModel || this.measurementSetting != measurementSetting) {
        this.currentBikeModel = currentBikeModel;
        this.measurementSetting = measurementSetting;
        await getTripHistory();
      }
    }
  }

  setRideData(RideDataType rideDataType, RideFormat rideFormat, DateTime pickedDate) {
    switch (rideFormat) {
      case RideFormat.day:
        setRideDataType(rideDataType, dayRideHistoryList, rideFormat);
        break;
      case RideFormat.week:
        setRideDataType(rideDataType, weekRideHistoryList, rideFormat);
        break;
      case RideFormat.month:
        setRideDataType(rideDataType, monthRideHistoryList, rideFormat);
        break;
      case RideFormat.year:
        setRideDataType(rideDataType, yearRideHistoryList, rideFormat);
        break;
      default:
        print('It\'s the weekend or an unknown day.');
    }
    getChartData(rideFormat, pickedDate);
    notifyListeners();
  }

  ///Get data once when load page into trip history data
  getTripHistory() async {
    tripHistorySubscription?.cancel();
    if(currentBikeModel != null){
      currentTripHistoryLists.clear();
      tripHistorySubscription = await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(tripHistoryCollection)
          .orderBy("startTime", descending: true)
          .snapshots()
          .listen((snapshot) async{

        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
            ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                if (obj != null) {
                  if (obj['endTime'] == null || obj['startTime'] == null) {

                  }
                  else {
                    currentTripHistoryLists.putIfAbsent(docChange.doc.id, () => TripHistoryModel.fromJson(obj!));
                    notifyListeners();
                  }
                }
                break;
              case DocumentChangeType.removed:
                currentTripHistoryLists.removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                if (obj != null) {
                  if (obj['endTime'] == null || obj['startTime'] == null) {

                  }
                  else {
                    currentTripHistoryLists.update(
                        docChange.doc.id, (value) =>
                        TripHistoryModel.fromJson(obj!));
                    notifyListeners();
                  }
                }
                break;
            }
          }
        }
        await getWeekRideHistory(DateTime.now());
        setWeekData(rideDataType);
      });
    }
  }


  /// *********************************
  /// *** Homepage Ride Card (Week) ***
  /// *********************************
  /// *********************************
  setWeekData(RideDataType rideDataType) {
    if (rideDataType == RideDataType.mileage) {
      weekCardDataTypeString = 'Mileage';
      if (measurementSetting == MeasurementSetting.metricSystem) {
        weekCardData = (weekRideHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        weekCardDataUnit = " km";
      }
      else {
        weekCardData = SettingProvider().convertMeterToMilesInString(weekRideHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        weekCardDataUnit = " miles";
      }
      weekCardDateType = rideDataType;
    }
    else if (rideDataType == RideDataType.noOfRide) {
      weekCardDataTypeString = 'No. of Rides';
      weekCardDateType = rideDataType;
      weekCardData = weekRideHistoryList.length.toStringAsFixed(0);
      weekCardDataUnit = " rides ";
    }
    else if (rideDataType == RideDataType.carbonFootprint) {
      weekCardDataTypeString = 'CO2 Saved';
      weekCardDateType = rideDataType;
      weekCardData = thousandFormatting((weekRideHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      weekCardDataUnit = " g";
    }
    notifyListeners();
  }



  /// *********************************
  /// *** Ride Data (Ride History)  ***
  /// *********************************
  /// *********************************
  getDayRideHistory(DateTime selectedDate) async {
    dayRideHistoryList.clear();

    // Filtering trip history for the selected day
    currentTripHistoryLists.forEach((key, trip) {
      if (trip is TripHistoryModel) {
        if (trip.startTime != null) {
          // Convert Timestamp to DateTime for comparison
          DateTime tripStartTime = trip.startTime!.toDate();

          if (_isSameDay(tripStartTime, selectedDate)) {
            // Add this trip to the filtered list
            dayRideHistoryList.add(trip);
          }
        }
      }
    });

    dayRideHistoryList.sort((a, b) => b.startTime!.toDate().compareTo(a.startTime!.toDate()));

    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  getWeekRideHistory(DateTime pickedDate) async {
    weekRideHistoryList.clear();
    // Calculate the start of the current week (Monday)
    DateTime startOfWeek = pickedDate.subtract(Duration(days: pickedDate.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    //print('Start of Week : ' + startOfWeek.toString());

    // Calculate the end of the desired week (Sunday)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
    //print('End of Week : ' + endOfWeek.toString());

    // Filtering trip history within the desired week
    currentTripHistoryLists.forEach((key, trip) {
      if (trip is TripHistoryModel) {
        if (trip.startTime != null) {
          // Convert Timestamp to DateTime for comparison
          DateTime tripStartTime = trip.startTime!.toDate();

          if (tripStartTime.isAfter(startOfWeek) && tripStartTime.isBefore(endOfWeek)) {
            // Add this trip to the filtered list
            weekRideHistoryList.add(trip);
          }
        }
      }
    });

    for (var trip in weekRideHistoryList) {
      //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
    }

    weekRideHistoryList.sort((a, b) => b.startTime!.toDate().compareTo(a.startTime!.toDate()));

    notifyListeners();
  }

  getMonthRideHistory(DateTime selectedMonth) async {
    monthRideHistoryList.clear();

    // Filtering trip history for the selected month
    currentTripHistoryLists.forEach((key, trip) {
      if (trip is TripHistoryModel) {
        if (trip.startTime != null) {
          // Convert Timestamp to DateTime for comparison
          DateTime tripStartTime = trip.startTime!.toDate();

          if (tripStartTime.year == selectedMonth.year && tripStartTime.month == selectedMonth.month) {
            // Add this trip to the filtered list
            monthRideHistoryList.add(trip);
          }
        }
      }
    });

    for (var trip in monthRideHistoryList) {
      //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
    }

    monthRideHistoryList.sort((a, b) => b.startTime!.toDate().compareTo(a.startTime!.toDate()));

    notifyListeners();
  }

  getYearRideHistory(int selectedYear) async {
    yearRideHistoryList.clear();

    // Filtering trip history for the selected year
    currentTripHistoryLists.forEach((key, trip) {
      if (trip is TripHistoryModel) {
        if (trip.startTime != null) {
          // Convert Timestamp to DateTime for comparison
          DateTime tripStartTime = trip.startTime!.toDate();

          if (tripStartTime.year == selectedYear) {
            // Add this trip to the filtered list
            yearRideHistoryList.add(trip);
          }
        }
      }
    });

    for (var trip in yearRideHistoryList) {
      //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
    }

    notifyListeners();
  }

  setRideDataType(RideDataType rideDataType, List<TripHistoryModel> tripHistoryList, RideFormat rideFormat,) {
    if (rideDataType == RideDataType.mileage) {
      rideDataTypeString = 'Mileage';
      if (measurementSetting == MeasurementSetting.metricSystem) {
        if (rideFormat == RideFormat.day) {
          rideDataDayString = (tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        }
        else if (rideFormat == RideFormat.week) {
          rideDataWeekString = (tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        }
        else if (rideFormat == RideFormat.month) {
          rideDataMonthString = (tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        }
        else if (rideFormat == RideFormat.year) {
          rideDataYearString = (tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        }
        rideDataUnit = " km";
      }
      else {
        if (rideFormat == RideFormat.day) {
          rideDataDayString = SettingProvider().convertMeterToMilesInString(tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        }
        else if (rideFormat == RideFormat.week) {
          rideDataWeekString = SettingProvider().convertMeterToMilesInString(tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        }
        else if (rideFormat == RideFormat.month) {
          rideDataMonthString = SettingProvider().convertMeterToMilesInString(tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        }
        else if (rideFormat == RideFormat.year) {
          rideDataYearString = SettingProvider().convertMeterToMilesInString(tripHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        }
        rideDataUnit = " miles";
      }
      this.rideDataType = rideDataType;
    }
    else if (rideDataType == RideDataType.noOfRide) {
      rideDataTypeString = 'No. of Rides';
      this.rideDataType = rideDataType;
      if (rideFormat == RideFormat.day) {
        rideDataDayString = tripHistoryList.length.toStringAsFixed(0);
      }
      else if (rideFormat == RideFormat.week) {
        rideDataWeekString = tripHistoryList.length.toStringAsFixed(0);
      }
      else if (rideFormat == RideFormat.month) {
        rideDataMonthString = tripHistoryList.length.toStringAsFixed(0);
      }
      else if (rideFormat == RideFormat.year) {
        rideDataYearString = tripHistoryList.length.toStringAsFixed(0);
      }
      rideDataUnit = " rides ";
    }
    else if (rideDataType == RideDataType.carbonFootprint) {
      rideDataTypeString = 'CO2 Saved';
      this.rideDataType = rideDataType;
      if (rideFormat == RideFormat.day) {
        rideDataDayString = thousandFormatting((tripHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      }
      else if (rideFormat == RideFormat.week) {
        rideDataWeekString = thousandFormatting((tripHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      }
      else if (rideFormat == RideFormat.month) {
        rideDataMonthString = thousandFormatting((tripHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      }
      else if (rideFormat == RideFormat.year) {
        rideDataYearString = thousandFormatting((tripHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      }
      rideDataUnit = " g";
    }
    notifyListeners();
  }

  setWeekRideDataType(RideDataType rideDataType) {
    if (rideDataType == RideDataType.mileage) {
      rideDataTypeString = 'Mileage';
      if (measurementSetting == MeasurementSetting.metricSystem) {
        rideDataString = (weekRideHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()) / 1000).toStringAsFixed(2);
        rideDataUnit = " km";
      }
      else {
        rideDataString = SettingProvider().convertMeterToMilesInString(weekRideHistoryList.fold<double>(0, (prev, element) => prev + element.distance!.toDouble()));
        rideDataUnit = " miles";
      }
      this.rideDataType = rideDataType;
    }
    else if (rideDataType == RideDataType.noOfRide) {
      rideDataTypeString = 'No. of Rides';
      this.rideDataType = rideDataType;
      rideDataString = weekRideHistoryList.length.toStringAsFixed(0);
      rideDataUnit = " rides ";
    }
    else if (rideDataType == RideDataType.carbonFootprint) {
      rideDataTypeString = 'CO2 Saved';
      this.rideDataType = rideDataType;
      rideDataString = thousandFormatting((weekRideHistoryList.fold<int>(0, (prev, element) => prev + element.carbonPrint!)));
      rideDataUnit = " g";
    }
  }

  /// *********************************
  /// *** Chart Data (Ride History) ***
  /// *********************************
  /// *********************************
  getChartData(RideFormat rideFormat, DateTime pickedDate) async {
    switch(rideFormat){
      case RideFormat.day:
        dayTimeChartData.clear();
        dayRideHistoryList.clear();
        await getDayRideHistory(pickedDate);

        for(int i = 0; i <= 23; i ++) {
          dayTimeChartData.add((DayTimeChartData(DateTime(
              pickedDate.year, pickedDate.month, pickedDate.day, i, 00), 0)));
        }
        notifyListeners();
        for (var trip in dayRideHistoryList) {
          //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
          if (rideDataType == RideDataType.mileage) {
            //chartData.add(ChartData(trip.startTime?.toDate(), trip.distance?.toDouble()));
            if (trip.startTime!.toDate().hour == dayTimeChartData[trip.startTime!.toDate().hour].x.hour) {
              var tripDistance = trip.distance!.toDouble() + dayTimeChartData[trip.startTime!.toDate().hour].y;
              dayTimeChartData[trip.startTime!.toDate().hour] = DayTimeChartData(trip.startTime?.toDate(), tripDistance);
            }
          }
          else if (rideDataType == RideDataType.noOfRide) {
            if (trip.startTime!.toDate().hour == dayTimeChartData[trip.startTime!.toDate().hour].x.hour) {
              var noOfRides = 1000 + dayTimeChartData[trip.startTime!.toDate().hour].y;
              dayTimeChartData[trip.startTime!.toDate().hour] = DayTimeChartData(trip.startTime?.toDate(), noOfRides);
            }
          }
          else if (rideDataType == RideDataType.carbonFootprint) {
            //chartData.add(ChartData(trip.startTime?.toDate(), trip.carbonPrint));
            if (trip.startTime!.toDate().hour == dayTimeChartData[trip.startTime!.toDate().hour].x.hour) {
              var carbonFP = (trip.carbonPrint!.toDouble() * 1000) + dayTimeChartData[trip.startTime!.toDate().hour].y;
              dayTimeChartData[trip.startTime!.toDate().hour] = DayTimeChartData(trip.startTime?.toDate(), carbonFP);
            }
          }
        }
        notifyListeners();
        return;
      case RideFormat.week:
        weekTimeChartData.clear();
        weekRideHistoryList.clear();
        await getWeekRideHistory(pickedDate);

        DateTime startOfWeek = pickedDate.subtract(Duration(days: pickedDate.weekday - 1));
        startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        //print('Start of Week : ' + startOfWeek.toString());

        for(int i = 0; i <= 6; i ++){
          weekTimeChartData.add((ChartData(startOfWeek.add(Duration(days: i)), 0)));
        }

        for (var trip in weekRideHistoryList) {
          //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
          if (rideDataType == RideDataType.mileage) {
            //chartData.add(ChartData(trip.startTime?.toDate(), trip.distance?.toDouble()));
            if (trip.startTime!.toDate().weekday == weekTimeChartData[trip.startTime!.toDate().weekday - 1].x.weekday) {
              var tripDistance = trip.distance!.toDouble() + weekTimeChartData[trip.startTime!.toDate().weekday - 1].y;
              weekTimeChartData[trip.startTime!.toDate().weekday - 1] = ChartData(trip.startTime?.toDate(), tripDistance);
            }
          }
          else if (rideDataType == RideDataType.noOfRide) {
            //chartData[trip.startTime!.toDate().weekday - 1] = ChartData(trip.startTime?.toDate(), 1000);

            if (trip.startTime!.toDate().weekday == weekTimeChartData[trip.startTime!.toDate().weekday - 1].x.weekday) {
              var noOfRides = 1000 + weekTimeChartData[trip.startTime!.toDate().weekday - 1].y;
              weekTimeChartData[trip.startTime!.toDate().weekday - 1] = ChartData(trip.startTime?.toDate(), noOfRides);
            }
          }
          else if (rideDataType == RideDataType.carbonFootprint) {
            //chartData[trip.startTime!.toDate().weekday - 1] = ChartData(trip.startTime?.toDate(), trip.carbonPrint! * 1000);
            if (trip.startTime!.toDate().weekday == weekTimeChartData[trip.startTime!.toDate().weekday - 1].x.weekday) {
              var carbonFP = (trip.carbonPrint!.toDouble() * 1000) + weekTimeChartData[trip.startTime!.toDate().weekday - 1].y;
              weekTimeChartData[trip.startTime!.toDate().weekday - 1] = ChartData(trip.startTime?.toDate(), carbonFP);
            }
          }
        }
        weekTimeChartData.sort((a, b) => a.x.compareTo(b.x));
        notifyListeners();
        return;
      case RideFormat.month:
        monthTimeChartData.clear();
        monthRideHistoryList.clear();
        await getMonthRideHistory(pickedDate);

        for(int i = 1; i <= 31; i ++){
          //chartData.add((ChartData(pickedDate.add(Duration(days: i)), 0)));
          monthTimeChartData.add((ChartData(DateTime(pickedDate!.year, pickedDate!.month, i), 0)));
        }

        for (var trip in monthRideHistoryList) {
          //print('Filtered Trip - Start Time: ${trip.startTime}, End Time: ${trip.endTime}');
          if (rideDataType == RideDataType.mileage) {
            if (trip.startTime!.toDate().day == monthTimeChartData[trip.startTime!.toDate().day - 1].x.day) {
              var tripDistance = trip.distance!.toDouble() + monthTimeChartData[trip.startTime!.toDate().day - 1].y;
              monthTimeChartData[trip.startTime!.toDate().day - 1] = ChartData(trip.startTime?.toDate(), tripDistance);
            }
          }
          else if (rideDataType == RideDataType.noOfRide) {
            if (trip.startTime!.toDate().day == monthTimeChartData[trip.startTime!.toDate().day - 1].x.day) {
              var noOfRide = 1000 + monthTimeChartData[trip.startTime!.toDate().day - 1].y;
              monthTimeChartData[trip.startTime!.toDate().day - 1] = ChartData(trip.startTime?.toDate(), noOfRide);
            }
          }
          else if (rideDataType == RideDataType.carbonFootprint) {
            if (trip.startTime!.toDate().day == monthTimeChartData[trip.startTime!.toDate().day - 1].x.day) {
              var carbonFP = (trip.carbonPrint!.toDouble() * 1000) + monthTimeChartData[trip.startTime!.toDate().day - 1].y;
              monthTimeChartData[trip.startTime!.toDate().day - 1] = ChartData(trip.startTime?.toDate(), carbonFP);
            }
          }
        }
        monthTimeChartData.sort((a, b) => a.x.compareTo(b.x));
        notifyListeners();
        return;
      case RideFormat.year:
        yearTimeChartData.clear();
        yearRideHistoryList.clear();
        await getYearRideHistory(pickedDate.year);

        for(int i = 1; i <= 12; i ++){
          yearTimeChartData.add((ChartData(DateTime(pickedDate!.year, i, 1), 0)));
        }

        for (var trip in yearRideHistoryList) {
          if (rideDataType == RideDataType.mileage) {
            if (trip.startTime!.toDate().month == yearTimeChartData[trip.startTime!.toDate().month - 1].x.month) {
              var tripDistance = trip.distance!.toDouble() + yearTimeChartData[trip.startTime!.toDate().month - 1].y;
              yearTimeChartData[trip.startTime!.toDate().month - 1] = ChartData(trip.startTime?.toDate(), tripDistance);
            }
          }
          else if (rideDataType == RideDataType.noOfRide) {
            if (trip.startTime!.toDate().month == yearTimeChartData[trip.startTime!.toDate().month - 1].x.month) {
              var noOfRide = 1000 + yearTimeChartData[trip.startTime!.toDate().month - 1].y;
              yearTimeChartData[trip.startTime!.toDate().month - 1] = ChartData(trip.startTime?.toDate(), noOfRide);
            }
          }
          else if (rideDataType == RideDataType.carbonFootprint) {
            if (trip.startTime!.toDate().month == yearTimeChartData[trip.startTime!.toDate().month - 1].x.month) {
              var carbonFP = (trip.carbonPrint!.toDouble() * 1000) + chartData[trip.startTime!.toDate().month - 1].y;
              yearTimeChartData[trip.startTime!.toDate().month - 1] = ChartData(trip.startTime?.toDate(), carbonFP);
            }
          }
        }

        yearTimeChartData.sort((a, b) => a.x.compareTo(b.x));
        notifyListeners();
        return;
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

  changeSelectedIndex(dynamic index, RideFormat rideFormat){
    selectedIndex = index;
    this.rideFormat = rideFormat;
  }

  clear(){
    tripHistorySubscription?.cancel();
    currentTripHistoryLists.clear();
    dayRideHistoryList.clear();
    weekRideHistoryList.clear();
    monthRideHistoryList.clear();
    yearRideHistoryList.clear();
  }
}

class ChartData {
  ChartData(this.x, this.y);

  dynamic x;
  dynamic y;
}

class DayTimeChartData{
  DayTimeChartData(this.x, this.y);
  dynamic x;
  dynamic y;
}

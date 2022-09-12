import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bike_model.dart';

class BikeProvider extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';

  LinkedHashMap bikeList = LinkedHashMap<int, String>();

  BikeModel? currentBikeModel;
  String? currentUserUID;
  int currentBikeList = 0;

  Future<void> init(uid) async {
    currentUserUID = uid;
    getCurrentBikeSP();
    getBikeList(currentUserUID);
    notifyListeners();
  }

  ///Get shared preference data
  Future<void> getCurrentBikeSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('currentBikeList')) {
      currentBikeList = prefs.getInt('currentBikeList') ?? 0;
      notifyListeners();
    } else {
      currentBikeList = 0;
    }
  }

  ///Read user's bike list
  Future<void> getBikeList(String? uid) async {
    try {
      Stream<QuerySnapshot> streamNumbers = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(bikesCollection)
          .snapshots();
      streamNumbers.listen((snapshot) {
        bikeList.clear();
        if (snapshot.docs.isNotEmpty) {
          var i = 0;
          for (var doc in snapshot.docs) {
            //   bikeList.add(doc.id);
            bikeList.putIfAbsent(i, () => doc.id);
            i++;
          }
          i = 0;
          getBike(bikeList[currentBikeList]);
          notifyListeners();
        } else {
          bikeList.clear();
          currentBikeModel = null;
        }
      });
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return;
    }
  }

  ///Get bike information based on selected current bike
  Future<void> getBike(String? imei) async {
    SharedPreferences prefs = await _prefs;
    FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(imei)
        .snapshots()
        .listen((event) {
      try {
        Map<String, dynamic>? obj = event.data();
        if (obj != null) {
          currentBikeModel = BikeModel.fromJson(obj, imei);
          prefs.setString('currentBikeName', currentBikeModel!.bikeName);
          notifyListeners();
        } else {
          currentBikeModel = null;
        }
      } on Exception catch (exception) {
        debugPrint(exception.toString());
      } catch (_) {
        return null;
      }
    });
  }

  void updateBikeName(name) async {
    try {
      var docUser = FirebaseFirestore.instance.collection(bikesCollection);
      docUser.doc(currentBikeModel?.deviceIMEI).update({
        'bikeName': name,
        'updated': Timestamp.now(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> controlBikeList(String action) async {
    SharedPreferences prefs = await _prefs;
    switch (action) {
      case "next":
        {
          if (currentBikeList < bikeList.length - 1) {
            currentBikeList += 1;
            prefs.setInt('currentBikeList', currentBikeList);
            getBike(bikeList[currentBikeList]);
            notifyListeners();
          }
        }
        break;
      case "back":
        {
          if (currentBikeList > 0 || currentBikeList! < 0) {
            currentBikeList -= 1;
            prefs.setInt('currentBikeList', currentBikeList);
            getBike(bikeList[currentBikeList]);
            notifyListeners();
          }
        }
        break;
      case "first":
        currentBikeList = 0;
        prefs.setInt('currentBikeList', currentBikeList);
        getBike(bikeList[currentBikeList]);
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  getBikeName() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('currentBikeName') ?? "Empty";
  }

  deleteBike(String imei) {
    controlBikeList("first");
    try {
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserUID)
          .collection(bikesCollection)
          .doc(imei)
          .delete();
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(imei)
          .collection(usersCollection)
          .doc(currentUserUID)
          .delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  clear() async {
    SharedPreferences prefs = await _prefs;
    prefs.remove('currentBikeName');
    prefs.remove('currentBikeList');
    bikeList.clear();
    currentBikeModel = null;
    currentBikeList = 0;
  }
}

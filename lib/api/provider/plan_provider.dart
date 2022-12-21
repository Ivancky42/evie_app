import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/model/plan_model.dart';
import 'package:evie_test/api/model/price_model.dart';
import 'package:flutter/widgets.dart';
import '../model/user_model.dart';

class PlanProvider extends ChangeNotifier {
  UserModel? currentUserModel;
  BikeModel? currentBikeModel;
  StreamSubscription? planListSubscription;
  StreamSubscription? priceListSubscription;
  LinkedHashMap availablePlanList = LinkedHashMap<String, PlanModel>();
  LinkedHashMap priceList = LinkedHashMap<String, PlanModel>();

  PlanProvider() {
    getPlanList();
  }

  Future<void> update(UserModel? userModel, BikeModel? bikeModel) async {
    if (userModel != null) {
      currentUserModel = userModel;
    }

    if (bikeModel != null) {
      currentBikeModel = bikeModel;
    }
  }

  Future<void> getPlanList() async {
    planListSubscription?.cancel();
    planListSubscription = FirebaseFirestore.instance.collection("plans").snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var docChange in snapshot.docChanges) {
          switch (docChange.type) {
            case DocumentChangeType.added:
              Map<String, dynamic>? obj = docChange.doc.data();
              availablePlanList.putIfAbsent(docChange.doc.id, () => PlanModel.fromJson(obj!));
              notifyListeners();
              break;
            case DocumentChangeType.removed:
              availablePlanList.removeWhere((key, value) => key == docChange.doc.id);
              notifyListeners();
              break;
            case DocumentChangeType.modified:
              Map<String, dynamic>? obj = docChange.doc.data();
              availablePlanList.update(docChange.doc.id, (value) => PlanModel.fromJson(obj!));
              notifyListeners();
              break;
          }
        }
      }
      else {
        availablePlanList.clear();
        notifyListeners();
      }
    });
  }

  Future<void> getPriceList(String deviceIMEI) async {
    priceListSubscription?.cancel();
    priceListSubscription = FirebaseFirestore.instance.collection("bikes").doc(deviceIMEI)
            .collection("prices").snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            for (var docChange in snapshot.docChanges) {
              switch (docChange.type) {
                case DocumentChangeType.added:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  priceList.putIfAbsent(docChange.doc.id, () => PriceModel.fromJson(obj!));
                  notifyListeners();
                  break;
                case DocumentChangeType.removed:
                  priceList.removeWhere((key, value) =>
                  key == docChange.doc.id);
                  notifyListeners();
                  break;
                case DocumentChangeType.modified:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  priceList.update(docChange.doc.id, (value) => PriceModel.fromJson(obj!));
                  notifyListeners();
                  break;
              }
            }
          }
          else {
            priceList.clear();
            notifyListeners();
          }
        });
  }
}
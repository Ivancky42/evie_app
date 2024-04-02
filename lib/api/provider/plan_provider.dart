import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/backend/stripe_api_caller.dart';
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
  LinkedHashMap priceList = LinkedHashMap<String, PriceModel>();
  PlanModel? currentPlanModel;
  PriceModel? currentPriceModel;

  PlanProvider() {
    getPlanList();
  }

  Future<void> update(UserModel? userModel, BikeModel? bikeModel) async {
    if (userModel != null) {
      currentUserModel = userModel;
      notifyListeners();
    }

    if (bikeModel != null) {
      if (bikeModel.deviceIMEI != currentBikeModel?.deviceIMEI) {
        getPlanList();
        currentBikeModel = bikeModel;
        notifyListeners();
      }
    }
  }

  Future<void> getPlanList() async {
    availablePlanList.clear();
    planListSubscription?.cancel();
    planListSubscription = FirebaseFirestore.instance.collection("plans").snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var docChange in snapshot.docChanges) {
          switch (docChange.type) {
            case DocumentChangeType.added:
              Map<String, dynamic>? obj = docChange.doc.data();
              if (obj!['active'] == true && obj['stripe_metadata_feature'] == 'EV-Secure') {
                availablePlanList.putIfAbsent(docChange.doc.id, () => PlanModel.fromJson(obj!, docChange.doc.id));
              }
              notifyListeners();
              break;
            case DocumentChangeType.removed:
              availablePlanList.removeWhere((key, value) => key == docChange.doc.id);
              notifyListeners();
              break;
            case DocumentChangeType.modified:
              Map<String, dynamic>? obj = docChange.doc.data();
              if (obj!['active'] == true && obj['stripe_metadata_feature'] == 'EV-Secure') {
                availablePlanList.putIfAbsent(docChange.doc.id, () => PlanModel.fromJson(obj!, docChange.doc.id));
              }
              else {
                availablePlanList.removeWhere((key, value) => key == docChange.doc.id);
              }
              notifyListeners();
              break;
          }
        }

        if (availablePlanList.isNotEmpty) {
          currentPlanModel = availablePlanList.values.elementAt(0);
          getPriceList(currentPlanModel!.id!);
        }
        notifyListeners();
      }
      else {
        availablePlanList.clear();
        notifyListeners();
      }
    });
  }
  
  // Future <PriceModel> getPrice(PlanModel planModel) async {
  //   return FirebaseFirestore.instance
  //       .collection("plans")
  //       .doc(planModel.id)
  //       .collection("prices")
  //       .get().then((querySnapshot) {
  //           Map<String, dynamic>? obj = querySnapshot.docs[0].data();
  //           return PriceModel.fromJson(obj, querySnapshot.docs[0].id);
  //       });
  // }

  Future<void> getPriceList(String planId) async {
    priceList.clear();
    priceListSubscription?.cancel();
    priceListSubscription = FirebaseFirestore.instance.collection("plans").doc(planId)
            .collection("prices").snapshots()
            .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            for (var docChange in snapshot.docChanges) {
              switch (docChange.type) {
                case DocumentChangeType.added:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  if (obj!['active'] == true) {
                    priceList.putIfAbsent(docChange.doc.id, () => PriceModel.fromJson(obj!, docChange.doc.id));
                  }
                  notifyListeners();
                  break;
                case DocumentChangeType.removed:
                  priceList.removeWhere((key, value) =>
                  key == docChange.doc.id);
                  notifyListeners();
                  break;
                case DocumentChangeType.modified:
                  Map<String, dynamic>? obj = docChange.doc.data();
                  //priceList.update(docChange.doc.id, (value) => PriceModel.fromJson(obj!, docChange.doc.id));

                  if (obj!['active'] == true) {
                    priceList.putIfAbsent(docChange.doc.id, () => PriceModel.fromJson(obj!, docChange.doc.id));
                  }
                  else {
                    priceList.removeWhere((key, value) => key == docChange.doc.id);
                  }

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

  Future<String> purchasePlan(String deviceIMEI, String planId, String priceId) {
    return StripeApiCaller.redirectToCheckout(deviceIMEI, planId, priceId, currentUserModel!.stripeId!).then((value) {
      if (value != null) {
        if (value == 'NO_SUCH_CUSTOMER') {
          return value;
        }
        else {
          return value;
        }
      }
      else {
        return 'unknown';
      }
    });
  }

  Future<String> createAndUpdateStripeCustomer() async {
    return StripeApiCaller.createStripeCustomer(currentUserModel!.email).then((customerId) {
      return FirebaseFirestore.instance.collection("users").doc(currentUserModel!.uid).update({
        'stripeId': customerId,
        'stripeLink': 'https://dashboard.stripe.com/customers/' + customerId,
      }).then((value) {
        return 'success';
      });
    });
  }

  Future<LinkedHashMap<String, String>> redeemEVSecureCode(String code) {
      return FirebaseFirestore.instance.collection("codes").where('code', isEqualTo: code).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String docId = querySnapshot.docs[0].id;
          Map<String, dynamic> data = querySnapshot.docs[0].data() as Map<String, dynamic>;
          print('Document Data: $data');
          int orderId = data['orderId'];
          String sentEmail = data['sentEmail'];
          bool available = data['available'];

          if (available) {
            return LinkedHashMap.from({
              'result': 'CODE_AVAILABLE',
              'orderId': orderId.toString(),
              'sentEmail': sentEmail,
              'docId': docId,
            });
          }
          else {
            return LinkedHashMap.from({
              'result': 'CODE_REDEEMED',
              'orderId': orderId.toString(),
              'sentEmail': sentEmail,
              'docId': docId,
            });
          }
        }
        else {
          return LinkedHashMap.from({'result': 'CODE_NOT_FOUND'});
        }
      });
  }

  clear() async {
    currentUserModel = null;
    currentBikeModel = null;
    await planListSubscription?.cancel();
    await priceListSubscription?.cancel();
    availablePlanList.clear();
    priceList.clear();
    currentPlanModel = null;
    currentPriceModel = null;
    notifyListeners();
  }
}
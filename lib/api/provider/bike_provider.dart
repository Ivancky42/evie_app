import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/movement_setting_model.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bike_model.dart';
import '../model/bike_plan_model.dart';
import '../model/bike_user_model.dart';
import '../model/location_model.dart';
import '../model/plan_model.dart';
import '../model/rfid_model.dart';
import '../model/user_bike_model.dart';
import '../model/user_model.dart';

enum ScanQRCodeResult {
  unknown,
  validateFailure,
  noBikeDataFailure,
  userExistFailure,
  userUploadFailure,
  success,
}

enum SwitchBikeResult {
  unknown,
  changing,
  failure,
  success,
}

class BikeProvider extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String rfidCollection = dotenv.env['DB_COLLECTION_RFID'] ?? 'DB not found';
  String eventsCollection = dotenv.env['DB_COLLECTION_EVENTS'] ?? 'DB not found';
  String plansCollection = dotenv.env['DB_COLLECTION_PLANS'] ?? 'DB not found';
  String inventoryCollection = dotenv.env['DB_COLLECTION_INVENTORY'] ?? 'DB not found';

  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();
  LinkedHashMap bikeUserDetails = LinkedHashMap<String, UserModel>();
  LinkedHashMap userBikeList = LinkedHashMap<String, UserBikeModel>();
  LinkedHashMap userBikeDetails = LinkedHashMap<String, BikeModel>();
  LinkedHashMap rfidList = LinkedHashMap<String, RFIDModel>();

  UserModel? currentUserModel;
  BikeModel? currentBikeModel;
  BikeUserModel? bikeUserModel;
  UserBikeModel? userBikeModel;
  BikePlanModel? currentBikePlanModel;
  RFIDModel? currentRFIDModel;

  int currentBikeList = 0;
  String? currentBikeIMEI;
  bool? isPlanSubscript;
  bool? isOwner;

  StreamSubscription? bikeListSubscription;
  StreamSubscription? currentBikeSubscription;
  StreamSubscription? bikeUserSubscription;
  StreamSubscription? currentBikeUserSubscription;
  StreamSubscription? currentUserBikeSubscription;
  StreamSubscription? currentBikePlanSubscription;
  StreamSubscription? rfidListSubscription;

  ScanQRCodeResult scanQRCodeResult = ScanQRCodeResult.unknown;
  SwitchBikeResult switchBikeResult = SwitchBikeResult.unknown;

  StreamController<SwitchBikeResult> switchBikeResultListener =
  StreamController.broadcast();

  ///Get current user model
  Future<void> update(UserModel? user) async {
    if (user != null) {
      if (currentUserModel != null) {
        if (currentUserModel!.uid != user.uid) {
          userBikeList.clear();
          getBikeList(user.uid);
        }
      }
      else {
        userBikeList.clear();
        getBikeList(user.uid);
      }
      currentUserModel = user;
      notifyListeners();
    }
    else {
      clear();
    }
  }

  ///Read user's bike list
  Future<void> getBikeList(String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentBikeModel = null;

    try {
      ///read doc change
      bikeListSubscription = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(bikesCollection)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                ///Key = imei, Val = get json object
                userBikeList.putIfAbsent(
                    docChange.doc.id, () => UserBikeModel.fromJson(obj!));
                getUserBikeDetails(docChange.doc.id);
                NotificationProvider().subscribeToTopic(docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                userBikeList
                    .removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                userBikeList.update(
                    docChange.doc.id, (value) => UserBikeModel.fromJson(obj!));
                notifyListeners();
                break;
            }
          }

          if (prefs.containsKey('currentBikeImei')) {
            currentBikeIMEI = prefs.getString('currentBikeImei') ?? "";
            notifyListeners();
          } else {
            currentBikeIMEI = userBikeList.keys.first.toString();
          }

          if (currentBikeIMEI != "") {
            getBike(currentBikeIMEI);
          }
        } else {
          userBikeList.clear();
          currentBikeModel = null;
          notifyListeners();
        }
      });
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return;
    }
  }

  ///Get bike information based on selected current bike
  Future getBike(String? imei) async {
    currentBikeModel = null;
    SharedPreferences prefs = await _prefs;
    isPlanSubscript = null;

    await currentBikeSubscription?.cancel();

    for (int index = 0; index < userBikeList.length; index++) {
      if (userBikeList.keys.elementAt(index) == imei) {
        ///Current bike model = userBikeList doc that match imei
        currentBikeSubscription = FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(imei)
            .snapshots()
            .listen((event) {
          try {
            Map<String, dynamic>? obj = event.data();
            if (obj != null) {
              currentBikeModel = BikeModel.fromJson(obj);
              prefs.setString('currentBikeImei', imei!);

              ///Switch case
              switchBikeResult = SwitchBikeResult.success;
              switchBikeResultListener.add(switchBikeResult);

              getPlanSubscript();

              notifyListeners();
            } else {
              currentBikeModel = null;
            }
          } on Exception catch (exception) {
            switchBikeResult = SwitchBikeResult.failure;
            switchBikeResultListener.add(switchBikeResult);
            debugPrint(exception.toString());
          } catch (_) {
            switchBikeResult = SwitchBikeResult.failure;
            switchBikeResultListener.add(switchBikeResult);
          }
          getRFIDList();
          getBikeUserList();
        });
      }
    }
  }

  Stream<SwitchBikeResult> switchBike() {
  return switchBikeResultListener.stream;
    }


   changeBikeUsingIMEI(String deviceIMEI) async {
    SharedPreferences prefs = await _prefs;
    await prefs.setString('currentBikeImei', deviceIMEI);

    await getBike(deviceIMEI);
  }



  /// ****************************************** ///
  /// Share bike
  /// ****************************************** ///
  /// Command for share bike
  ///
  updateSharedBikeStatus(String targetID) async {
    bool result;

    try {
      final ubsnapshot = await FirebaseFirestore.instance
          .collection('bikes')
          .doc(currentBikeModel!.deviceIMEI)
          .collection('users')
          .get();

      List<int> aList = [];
      int? userId;

      for (var element in ubsnapshot.docs) {
        aList.add(element.data()["userId"]);
      }
      aList = aList..sort();

      for (var i = 4; i > 0; i--) {
        if (!aList.contains(i)) {
          userId = i;
        }
      }

      //Update
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .doc(targetID)
          .set({
        'created': Timestamp.now(),
        'uid': targetID,
        'role': 'user',
        'status': 'pending',
        'justInvited': false,
        'userId': userId,
      }, SetOptions(merge: true));

      Future.delayed(const Duration(milliseconds: 500), () {
        FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(currentBikeModel!.deviceIMEI)
            .collection(usersCollection)
            .doc(targetID)
            .set({
          'justInvited': true,
        }, SetOptions(merge: true));
      });

      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }

    return result;
  }

  updateAcceptSharedBikeStatus(String targetIMEI, String currentUid) async {
    bool result;

    try {
      //Update
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(targetIMEI)
          .collection(usersCollection)
          .doc(currentUid)
          .set({
        'status': 'shared',
        'justInvited': true,
      }, SetOptions(merge: true));

      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }
    return result;
  }

  cancelSharedBikeStatus(String targetUID, String notificationId) async {
    bool result;
    try {
      //Update
       FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .doc(targetUID)
          .set({
        'status': 'removed',
        'justInvited': true,
      }, SetOptions(merge: true));

      ///Update user notification id status == removed
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(targetUID)
          .collection("notifications")
          .doc(notificationId)
          .set({
        'status': 'removed',
      }, SetOptions(merge: true));

      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }
    return result;
  }

  getBikeUserList() {
    bikeUserList.clear();
    bikeUserDetails.clear();
    try {
      //Update
      bikeUserSubscription = FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .orderBy("created", descending: false)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();

                bikeUserList.putIfAbsent(
                    docChange.doc.id, () => BikeUserModel.fromJson(obj!));
                bikeUserList.forEach((key, value) {
                  getBikeUserDetails(key);
                });
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                bikeUserList
                    .removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                bikeUserList.update(
                    docChange.doc.id, (value) => BikeUserModel.fromJson(obj!));
                notifyListeners();
                break;
            }
          }
        }
        checkIsOwner();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getBikeUserDetails(String uid) {
    try {
      currentBikeUserSubscription = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .snapshots()
          .listen((snapshot) {
        Map<String, dynamic>? obj = snapshot.data();
        if (obj != null) {
          bikeUserDetails.putIfAbsent(
              snapshot.id, () => UserModel.fromJson(obj));
          notifyListeners();
        }
        if (obj == null) {
          bikeUserDetails.removeWhere((key, value) => key == obj?.keys);
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getUserBikeDetails(String deviceIMEI) {
    try {
      currentUserBikeSubscription = FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .snapshots()
          .listen((snapshot) {
        Map<String, dynamic>? obj = snapshot.data();

        if (obj != null) {
          userBikeDetails.putIfAbsent(
              snapshot.id, () => BikeModel.fromJson(obj));
          notifyListeners();
        }
        if (obj == null) {
          userBikeDetails.removeWhere((key, value) => key == obj?.keys);
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  checkIsOwner() {
    if (bikeUserList.isNotEmpty) {
      for (var key in bikeUserList.keys) {
        if (currentUserModel!.uid == key) {
          if (bikeUserList[key].role == "owner") {
            isOwner = true;
            notifyListeners();
          } else {
            isOwner = false;
            notifyListeners();
          }
        }
      }
    }
    notifyListeners();
  }

  Future<bool> checkIsUserExist(String targetEmail) async {
    if (bikeUserDetails.isNotEmpty) {
      for (var i = 0; i < bikeUserDetails.length;i++) {
          if (bikeUserDetails.values.elementAt(i).email == targetEmail) {
            return true;
          } else {
            return false;
          }
      }
    }
    return false;
  }

  /// ****************************************** ///
  /// Connect bike
  /// ****************************************** ///
  /// Command for connect bike


  handleBarcodeData(String code) async {
    List<String> splitCode = code.split(',');
    String serialNumber = splitCode[0].split(':').last;
    String validationKey = splitCode[1].split(':').last;

    final snapshot = await FirebaseFirestore.instance
        .collection(inventoryCollection)
        .doc(serialNumber)
        .get();

    if (!snapshot.exists) {
      scanQRCodeResult = ScanQRCodeResult.validateFailure;
      notifyListeners();
      return false;
    } else if (validationKey == snapshot["validationKey"]) {
      await checkIsBikeExist(snapshot["bikeRef"]);
    } else {
      scanQRCodeResult = ScanQRCodeResult.validateFailure;
      notifyListeners();
      return false;
    }
  }

  Future checkIsBikeExist(DocumentReference docRef) async {
    await docRef.get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        final snapshot = await FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(documentSnapshot["deviceIMEI"])
            .collection(usersCollection)
            .get();

        if (snapshot.size == 0) {
          await uploadUserToFireStore(
              documentSnapshot["deviceIMEI"].toString());
        } else {
          scanQRCodeResult = ScanQRCodeResult.userExistFailure;

          notifyListeners();
          return "";
        }
      } else {
        scanQRCodeResult = ScanQRCodeResult.noBikeDataFailure;
        notifyListeners();
      }
    });
  }


  queryBikeEvents()async{
    return FirebaseFirestore.instance.collection(bikesCollection).doc(currentBikeModel!.deviceIMEI!).collection(eventsCollection).orderBy("created", descending: true);
  }

  /// ****************************************** ///
  /// Firestore update
  /// ****************************************** ///
  /// Command for firestore function

  updateMotionSensitivity(bool isEnabled, String sensitivity) {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .set({
        "movementSetting" : {
          'enabled' : isEnabled,
          'sensitivity' : sensitivity,
        }
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future uploadUserToFireStore(selectedDeviceId) async {
    try {
      ///uploadBikeToUserFireStore
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(bikesCollection)
          .doc(selectedDeviceId)
          .set(UserBikeModel(
        deviceIMEI: selectedDeviceId!,
        deviceType: "Evie",
        created: Timestamp.now(),
      ).toJson());

      ///uploadUserToBikeFireStore
      var role = "owner";
      await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(selectedDeviceId)
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .set(BikeUserModel(
        uid: currentUserModel!.uid,
        role: role,
        userId: 0,
        created: Timestamp.now(),
      ).toJson());

      scanQRCodeResult = ScanQRCodeResult.success;
      notifyListeners();

      getBike(selectedDeviceId);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      scanQRCodeResult = ScanQRCodeResult.userUploadFailure;
      notifyListeners();
      return false;
    }
  }

  Future uploadPlaceMarkAddressToFirestore(String deviceIMEI, String eventID, String address) async {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .collection("events")
          .doc(eventID)
          .set({
        'address': address,
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint(e.toString());
    }
  }


  updateBikeName(name) async {
    try {
      var docUser = FirebaseFirestore.instance.collection(bikesCollection);
      docUser.doc(currentBikeModel?.deviceIMEI).update({
        'deviceName': name,
        'updated': Timestamp.now(),
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  deleteBike(String imei) async {
    try {
      controlBikeList("first");
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel?.uid)
          .collection(bikesCollection)
          .doc(imei)
          .delete();

      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(imei)
          .collection(usersCollection)
          .doc(currentUserModel?.uid)
          .delete();

      currentBikeModel = null;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


  /// ****************************************** ///
  /// Plan Subscription
  /// ****************************************** ///
  /// Command for plan

  getPlanSubscript() async {
    currentBikePlanSubscription?.cancel();
    currentBikePlanSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(currentBikeModel!.deviceIMEI)
        .collection(plansCollection)
        .snapshots()
        .listen((snapshot) {
      {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
            ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                if ( snapshot.size == 0 ) {
                  isPlanSubscript = false;
                }else {
                  for(int i=0;i<snapshot.docs.length;i++){
                    currentBikePlanModel = BikePlanModel.fromJson(obj!);
                  }
                  final result = calculateDateDifference(currentBikePlanModel!.periodEnd!.toDate());
                  if(result < 0){
                    isPlanSubscript = false;
                  }else{
                    isPlanSubscript = true;
                  }
                }
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                currentBikePlanModel = null;
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                for(int i=0;i<snapshot.docs.length;i++){
                  currentBikePlanModel = BikePlanModel.fromJson(obj!);
                }
                final result = calculateDateDifference(currentBikePlanModel!.periodEnd!.toDate());
                if(result < 0){
                  isPlanSubscript = false;
                }else{
                  isPlanSubscript = true;
                }
                notifyListeners();
                break;
            }
          }
        }else{
          currentBikePlanModel = null;
          isPlanSubscript = false;
          notifyListeners();
        }
      }});
  }

  updatePurchasedPlan(String deviceIMEI, PlanModel planModel) async {
    DocumentReference ref = FirebaseFirestore.instance.collection("plans").doc(planModel.id);
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .collection("plans")
          .doc(planModel.id)
          .set({
        'name': planModel.name,
        'updated': Timestamp.now(),
        'created': Timestamp.now(),
        'periodStart': Timestamp.now(),
        'periodEnd': Timestamp.fromDate(DateTime.now().add(const Duration(days: 365))),
        'product': ref
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }



  /// ****************************************** ///
  /// RFID
  /// ****************************************** ///
  /// Command for RFID


  getRFIDList() {
    rfidList.clear();
    try {
      rfidListSubscription = FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .orderBy("created", descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                rfidList.putIfAbsent(docChange.doc.id,
                        () => RFIDModel.fromJson(obj!));
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                rfidList.removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                rfidList.update(docChange.doc.id,
                        (value) => RFIDModel.fromJson(obj!));
                notifyListeners();
                break;
            }
          }
        }else{
          rfidList.clear();
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  uploadRFIDtoFireStore(String rfidID, String rfidName) {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .doc(rfidID.toString())
          .set({
        'rfidID' : rfidID,
        'rfidName' : rfidName,
        'created': Timestamp.now(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  updateRFIDCardName(String rfidID, String rfidName) {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .doc(rfidID.toString())
          .update({
        'rfidName': rfidName,
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  deleteRFIDFirestore(String rfidID) {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .doc(rfidID.toString())
          .delete();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


  /// ****************************************** ///
  /// Calculation
  /// ****************************************** ///
  /// Command for calculation


  /// Yesterday : calculateDifference(date) == -1.
  /// Today : calculateDifference(date) == 0.
  /// Tomorrow : calculateDifference(date) == 1
  int calculateDateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }


  clear() async {
    SharedPreferences prefs = await _prefs;
    prefs.remove('currentBikeName');
    prefs.remove('currentBikeList');
    prefs.remove('currentBikeIMEI');

    userBikeList.keys.forEach((element) {
      NotificationProvider().unsubscribeFromTopic(element);
    });

    userBikeList.clear();
    userBikeDetails.clear();

    currentUserModel = null;
    currentBikeModel = null;
    userBikeModel = null;
    bikeUserModel = null;
    currentBikeList = 0;
    notifyListeners();
  }

  /// ****************************************** ///
  /// Likely abandon
  /// ****************************************** ///
  ///

  Future<void> controlBikeList(String action) async {
    SharedPreferences prefs = await _prefs;
    switch (action) {
      case "next":
        {
          if (currentBikeList < userBikeList.length - 1) {
            currentBikeList += 1;
            prefs.setInt('currentBikeList', currentBikeList);
            getBike(userBikeList.keys.elementAt(currentBikeList));
            notifyListeners();
          } else if (currentBikeList == userBikeList.length - 1) {
            controlBikeList("first");
          }
        }
        break;
      case "back":
        {
          if (currentBikeList > 0) {
            currentBikeList -= 1;
            prefs.setInt('currentBikeList', currentBikeList);
            getBike(userBikeList.keys.elementAt(currentBikeList));
            notifyListeners();
          } else if (currentBikeList <= 0) {
            controlBikeList("last");
          }
        }
        break;
      case "first":
        {
          currentBikeList = 0;
          prefs.setInt('currentBikeList', currentBikeList);
          getBike(userBikeList.keys.elementAt(currentBikeList));
          notifyListeners();
        }
        break;
      case "last":
        {
          currentBikeList = userBikeList.length - 1;
          prefs.setInt('currentBikeList', currentBikeList);
          getBike(userBikeList.keys.elementAt(currentBikeList));
          notifyListeners();
        }
        break;
    }
    notifyListeners();
  }

}

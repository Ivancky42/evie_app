import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/movement_setting_model.dart';
import 'package:evie_test/api/model/notification_setting_model.dart';
import 'package:evie_test/api/provider/firmware_provider.dart';
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
import '../model/theft_history_model.dart';
import '../model/threat_routes_model.dart';
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

enum UploadFirestoreResult {
  failed,
  partiallySuccess,
  success,
}

enum ThreatFilterDate {
  all,
  today,
  yesterday,
  last7days,
  custom,
}

class BikeProvider extends ChangeNotifier {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String rfidCollection = dotenv.env['DB_COLLECTION_RFID'] ?? 'DB not found';
  String eventsCollection = dotenv.env['DB_COLLECTION_EVENTS'] ?? 'DB not found';
  String plansCollection = dotenv.env['DB_COLLECTION_PLANS'] ?? 'DB not found';
  String notificationsCollection = dotenv.env['DB_COLLECTION_NOTIFICATIONS'] ?? 'DB not found';
  String inventoryCollection = dotenv.env['DB_COLLECTION_INVENTORY'] ?? 'DB not found';
  String theftHistoryCollection = dotenv.env['DB_COLLECTION_THEFTHISTORY'] ?? 'DB not found';
  String routesCollection = dotenv.env['DB_COLLECTION_ROUTES'] ?? 'DB not found';

  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();
  LinkedHashMap bikeUserDetails = LinkedHashMap<String, UserModel>();

  ///String uid, string name
  LinkedHashMap bikeUserOwnerUid = LinkedHashMap<String, String>();
  LinkedHashMap userBikeList = LinkedHashMap<String, UserBikeModel>();
  LinkedHashMap userBikeDetails = LinkedHashMap<String, BikeModel>();
  LinkedHashMap userBikePlans = LinkedHashMap<String, BikePlanModel>();
  LinkedHashMap rfidList = LinkedHashMap<String, RFIDModel>();
  LinkedHashMap threatRoutesLists = LinkedHashMap<String, ThreatRoutesModel>();

  ThreatHistoryModel? currentThreatHistoryModel;
  BikePlanModel? currentBikePlanModel;
  UserModel? currentUserModel;
  BikeModel? currentBikeModel;
  RFIDModel? currentRFIDModel;

  int currentBikeList = 0;
  String? currentBikeIMEI;
  bool? isPlanSubscript;
  bool? isOwner;
  bool isAddBike = false;
  bool isReadBike = false;
  List userBikeNotificationList = ["~connection-lost","~movement-detect","~theft-attempt","~lock-reminder","~plan-reminder","~fall-detect", "crash"];

  List<String> threatFilterArray = ["warning", "danger","fall","crash","lock"];
  DateTime? threatFilterDate1;
  DateTime? threatFilterDate2;

  StreamSubscription? bikeListSubscription;
  StreamSubscription? currentBikeSubscription;
  StreamSubscription? currentThreatRoutesSubscription;
  StreamSubscription? bikeUserSubscription;
  StreamSubscription? currentBikeUserSubscription;
  StreamSubscription? currentUserBikeSubscription;
  StreamSubscription? currentBikePlanSubscription;
  StreamSubscription? bikePlanSubscription;
  StreamSubscription? rfidListSubscription;

  StreamSubscription? currentSubscription;

  ScanQRCodeResult scanQRCodeResult = ScanQRCodeResult.unknown;
  SwitchBikeResult switchBikeResult = SwitchBikeResult.unknown;
  ThreatFilterDate threatFilterDate = ThreatFilterDate.all;

  StreamController<SwitchBikeResult> switchBikeResultListener = StreamController.broadcast();
  StreamController<UploadFirestoreResult> firestoreStatusListener = StreamController.broadcast();

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
      //  clear();
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
                userBikeList.putIfAbsent(docChange.doc.id, () => UserBikeModel.fromJson(obj!));

                notifyListeners();
                break;
              case DocumentChangeType.removed:
                userBikeList.removeWhere((key, value) => key == docChange.doc.id);
                userBikeDetails.removeWhere((key, value) => key == docChange.doc.id);
                NotificationProvider().unsubscribeFromTopic(docChange.doc.id);

                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                userBikeList.update(docChange.doc.id, (value) => UserBikeModel.fromJson(obj!));
                notifyListeners();
                break;
            }
          }

          userBikeList.forEach((key, value) {
            getUserBikeDetails(key);
            NotificationProvider().subscribeToTopic(key);

            if(value?.notificationSettings?.connectionLost == true ) {
              NotificationProvider().subscribeToTopic("${key}~connection-lost");
            }
            if(value?.notificationSettings?.movementDetect == true ) {
              NotificationProvider().subscribeToTopic("${key}~movement-detect");
            }
            if(value?.notificationSettings?.theftAttempt == true ) {
              NotificationProvider().subscribeToTopic("${key}~theft-attempt");
            }
            if(value?.notificationSettings?.lock == true ) {
              NotificationProvider().subscribeToTopic("${key}~lock-reminder");
            }
            if(value?.notificationSettings?.planReminder == true ) {
              NotificationProvider().subscribeToTopic("${key}~plan-reminder");
            }
          });

          ///Subscript to topic based on looping (for first time open app only)
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

        isReadBike = true;
        notifyListeners();

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
              getCurrentPlanSubscript();
              getThreatRoutes();

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

  getOwnerUid(String deviceIMEI, String ownerUid) async {

    final snapshot = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(ownerUid)
        .get();

    userBikeDetails[deviceIMEI].ownerName = snapshot['name'];
    notifyListeners();
  }

  getThreatRoutes() async {
    if(currentBikeModel?.location?.status == "danger"){
      if(currentBikeModel?.location != null){
        if(currentBikeModel?.location?.eventId != null){
          if(currentBikeModel?.location?.eventId != ""){
            currentThreatRoutesSubscription = FirebaseFirestore.instance
                .collection(bikesCollection)
                .doc(currentBikeModel!.deviceIMEI)
                .collection(theftHistoryCollection)
                .doc(currentBikeModel!.location!.eventId)
                .collection(routesCollection)
                .snapshots()
                .listen((snapshot) async {
              if (snapshot.docs.isNotEmpty) {
                for (var docChange in snapshot.docChanges) {
                  switch (docChange.type) {
                    case DocumentChangeType.added:
                      Map<String, dynamic>? obj = docChange.doc.data();
                      threatRoutesLists.putIfAbsent(docChange.doc.id, () => ThreatRoutesModel.fromJson(obj!));
                      notifyListeners();
                      break;
                    case DocumentChangeType.removed:
                      threatRoutesLists.removeWhere((key, value) => key == docChange.doc.id);
                      notifyListeners();
                      break;
                    case DocumentChangeType.modified:
                      Map<String, dynamic>? obj = docChange.doc.data();
                      threatRoutesLists.update(docChange.doc.id, (value) => ThreatRoutesModel.fromJson(obj!));
                      notifyListeners();
                      break;
                  }
                }
              }else{
                threatRoutesLists.clear();
                currentThreatRoutesSubscription?.cancel();
              }
            });
          }else{
            threatRoutesLists.clear();
            currentThreatRoutesSubscription?.cancel();
          }
        }else{
          threatRoutesLists.clear();
          currentThreatRoutesSubscription?.cancel();
        }
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
  /// Notification Setting
  /// ****************************************** ///
  ///

  Future updateFirestoreNotification(String type, bool value) async {

    switch(type){
      case "general":
      case "firmwareUpdate":
        try {
          await FirebaseFirestore.instance
              .collection(usersCollection)
              .doc(currentUserModel!.uid)
              .set({
            "notificationSettings": {
              type: value,
            }
          }, SetOptions(merge: true));

          return true;
        }catch(e){
          return false;
        }
        break;
      default:
        try {
          await FirebaseFirestore.instance
              .collection(usersCollection)
              .doc(currentUserModel!.uid)
              .collection(bikesCollection)
              .doc(currentBikeModel!.deviceIMEI)
              .set({
            "notificationSettings": {
              type: value,
            }
          }, SetOptions(merge: true));

          return true;
        }catch(e){
          return false;
        }
    }
  }

  /// ****************************************** ///
  /// Share bike
  /// ****************************************** ///
  /// Command for share bike


  Future updateSharedBike(UserModel userModel) async {
    bool result;

    try {

      ///Function to add userID
      // final ubsnapshot = await FirebaseFirestore.instance
      //     .collection(bikesCollection)
      //     .doc(currentBikeModel!.deviceIMEI)
      //     .collection(usersCollection)
      //     .get();
      //
      // List<int> aList = [];
      // int? userId;
      //
      // for (var element in ubsnapshot.docs) {
      //   aList.add(element.data()["userId"]);
      // }
      //
      // aList = aList..sort();
      //
      // for (var i = 4; i > 0; i--) {
      //   if (!aList.contains(i)) {
      //     userId = i;
      //   }
      // }

      //Update
      await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .doc(userModel.uid)
          .set({
        'created': Timestamp.now(),
        'uid': userModel.uid,
        'userEmail': userModel.email,
        'role': 'user',
        'status': 'pending',
        'justInvited': false,
      //  'userId': userId,
        'ownerUid': currentUserModel!.uid,
      }, SetOptions(merge: true));

      Future.delayed(const Duration(seconds: 2), () {
        FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(currentBikeModel!.deviceIMEI)
            .collection(usersCollection)
            .doc(userModel.uid)
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

  Stream<UploadFirestoreResult> acceptSharedBike(String targetIMEI, String currentUid) {
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

    } catch (e) {
      currentSubscription?.cancel();
      debugPrint(e.toString());
      firestoreStatusListener.add(UploadFirestoreResult.failed);
    }

    currentSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(targetIMEI)
        .collection(usersCollection)
        .doc(currentUid)
        .snapshots()
        .listen((event) async {
      Map<String, dynamic>? obj = event.data();

      if(obj!['justInvited'] == false){
        currentSubscription?.cancel();
        firestoreStatusListener.add(UploadFirestoreResult.success);
      }else{
        firestoreStatusListener.add(UploadFirestoreResult.partiallySuccess);
      }
    });
    return firestoreStatusListener.stream;
  }

  Stream<UploadFirestoreResult> cancelSharedBike(String targetUID, String notificationId) {
    try{
       FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .doc(targetUID)
          .set({
        'status': 'cancel',
        'justInvited': true,
      }, SetOptions(merge: true));

      ///Update user notification id status == removed
     FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(targetUID)
          .collection(notificationsCollection)
          .doc(notificationId)
          .set({
        'status': 'cancel',
      }, SetOptions(merge: true));

    } catch (e) {
      currentSubscription?.cancel();
      debugPrint(e.toString());
      firestoreStatusListener.add(UploadFirestoreResult.failed);
    }

    currentSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(currentBikeModel!.deviceIMEI)
        .collection(usersCollection)
        .doc(targetUID)
        .snapshots()
        .listen((event) async {
      Map<String, dynamic>? obj = event.data();
      if(obj == null){
        currentSubscription?.cancel();
        firestoreStatusListener.add(UploadFirestoreResult.success);
      }else{
        firestoreStatusListener.add(UploadFirestoreResult.partiallySuccess);
      }
    });

    return firestoreStatusListener.stream;
  }

  Stream<UploadFirestoreResult> removedSharedBike(String targetUID, String notificationId) {
    try{
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
          .collection(notificationsCollection)
          .doc(notificationId)
          .set({
        'status': 'removed',
      }, SetOptions(merge: true));

    } catch (e) {
      currentSubscription?.cancel();
      debugPrint(e.toString());
      firestoreStatusListener.add(UploadFirestoreResult.failed);
    }

    currentSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(currentBikeModel!.deviceIMEI)
        .collection(usersCollection)
        .doc(targetUID)
        .snapshots()
        .listen((event) async {
      Map<String, dynamic>? obj = event.data();
      if(obj == null){
        currentSubscription?.cancel();
        firestoreStatusListener.add(UploadFirestoreResult.success);
      }else{
        firestoreStatusListener.add(UploadFirestoreResult.partiallySuccess);
      }
    });

    return firestoreStatusListener.stream;
  }

  Stream<UploadFirestoreResult> leaveSharedBike(String targetUID, String notificationId) {
    try{
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(usersCollection)
          .doc(targetUID)
          .set({
        'status': 'leave',
        'justInvited': true,
      }, SetOptions(merge: true));

      ///Update user notification id status == removed
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(targetUID)
          .collection(notificationsCollection)
          .doc(notificationId)
          .set({
        'status': 'leave',
      }, SetOptions(merge: true));

    } catch (e) {
      currentSubscription?.cancel();
      debugPrint(e.toString());
      firestoreStatusListener.add(UploadFirestoreResult.failed);
    }

    currentSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(currentBikeModel!.deviceIMEI)
        .collection(usersCollection)
        .doc(targetUID)
        .snapshots()
        .listen((event) async {
      Map<String, dynamic>? obj = event.data();
      if(obj == null){
        currentSubscription?.cancel();
        firestoreStatusListener.add(UploadFirestoreResult.success);
      }else{
        firestoreStatusListener.add(UploadFirestoreResult.partiallySuccess);
      }
    });

    return firestoreStatusListener.stream;
  }

  Stream<UploadFirestoreResult> declineSharedBike(String targetIMEI, String notificationId) {
    try{
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(targetIMEI)
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .set({
        'status': 'decline',
        'justInvited': true,
      }, SetOptions(merge: true));

      ///Update user notification id status == removed
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(notificationsCollection)
          .doc(notificationId)
          .set({
        'status': 'decline',
      }, SetOptions(merge: true));

    } catch (e) {
      currentSubscription?.cancel();
      debugPrint(e.toString());
      firestoreStatusListener.add(UploadFirestoreResult.failed);
    }

    currentSubscription = FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(targetIMEI)
        .collection(usersCollection)
        .doc(currentUserModel!.uid)
        .snapshots()
        .listen((event) async {
      Map<String, dynamic>? obj = event.data();
      if(obj == null){
        currentSubscription?.cancel();
        firestoreStatusListener.add(UploadFirestoreResult.success);
      }else{
        firestoreStatusListener.add(UploadFirestoreResult.partiallySuccess);
      }
    });

    return firestoreStatusListener.stream;
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
                bikeUserList.putIfAbsent(docChange.doc.id, () => BikeUserModel.fromJson(obj!));
                bikeUserList.forEach((key, value) {
                  getBikeUserDetails(key);
                });
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                bikeUserList.removeWhere((key, value) => key == docChange.doc.id);

                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                bikeUserList.update(docChange.doc.id, (value) => BikeUserModel.fromJson(obj!));
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
        if (snapshot.data() != null) {
          Map<String, dynamic>? obj = snapshot.data();
          if (obj != null) {
            bikeUserDetails.putIfAbsent(
                snapshot.id, () => UserModel.fromJson(obj));
            notifyListeners();
          }
          if (obj == null) {
            bikeUserDetails.removeWhere((key, value) => key == obj?.keys);
            notifyListeners();
          };
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
          .listen((snapshot) async {
        if (snapshot.data() != null) {
          Map<String, dynamic>? obj = snapshot.data();
          if (obj != null) {
            userBikeDetails.update(
                snapshot.id, (value) => BikeModel.fromJson(obj),
                ifAbsent: () => BikeModel.fromJson(obj));

            notifyListeners();


              getOwnerUid(deviceIMEI, obj['ownerUid'] );



          } else if (obj == null) {
            userBikeDetails.removeWhere((key, value) => key == obj?.keys);
            notifyListeners();
          }
        }
      });


      bikePlanSubscription = FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .collection(plansCollection)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();

                ///Put in userBikeDetails as Model
                  //userBikeDetails[deviceIMEI].bikePlanModel = BikePlanModel.fromJson(obj!);

                userBikePlans.putIfAbsent(deviceIMEI, () => BikePlanModel.fromJson(obj!));
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                Map<String, dynamic>? obj = docChange.doc.data();

                userBikePlans.removeWhere((key, value) => key == deviceIMEI);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                 Map<String, dynamic>? obj = docChange.doc.data();

                userBikePlans.update(deviceIMEI, (value) => BikePlanModel.fromJson(obj!));
                break;
            }
          }
        }else{
          userBikePlans.clear();
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
    bool result = false;
    if (bikeUserList.isNotEmpty) {
      for (var i = 0; i < bikeUserList.length;i++) {
        if (bikeUserList.values.elementAt(i).userEmail == targetEmail) {
          result =  true;
        } else {
          result = false;
        }
      }
    }else {result = false;}
    return result;
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

      await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(selectedDeviceId)
          .set({
        'ownerUid': currentUserModel!.uid,
      }, SetOptions(merge: true));

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
          .collection(eventsCollection)
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

      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel?.uid)
          .collection(bikesCollection)
          .doc(imei)
          .delete();

      await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(imei)
          .collection(usersCollection)
          .doc(currentUserModel?.uid)
          .delete();

      currentBikeIMEI = null;
      currentBikeModel = null;
      notifyListeners();

      controlBikeList("first");

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  resetBike(String imei) async {
    try {

      await Future.forEach(bikeUserList.keys, (key) async{
        await FirebaseFirestore.instance
            .collection(bikesCollection)
            .doc(imei)
            .collection(usersCollection)
            .doc(key.toString())
            .delete();

        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(key.toString())
            .collection(bikesCollection)
            .doc(imei)
            .delete();
      });

      currentBikeIMEI = null;
      currentBikeModel = null;
      notifyListeners();

      controlBikeList("first");

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

  getCurrentPlanSubscript() async {
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
    DocumentReference ref = FirebaseFirestore.instance.collection(plansCollection).doc(planModel.id);
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(deviceIMEI)
          .collection(plansCollection)
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

  setIsAddBike(bool isAddBike){
    this.isAddBike = isAddBike;
    notifyListeners();
  }

  ///Compare bluetooth firmware version and firestore bike firmware version
  checkIsCurrentVersion(String firmVer){
    print("check ble firmware ver");
    firmVer = firmVer.split("V").last;
    if(currentBikeModel?.firmVer == null ||
        int.parse(currentBikeModel!.firmVer!.replaceAll('.', ''))
            != int.parse(firmVer.replaceAll('.', ''))) {
      FirmwareProvider().uploadFirmVerToFirestore(firmVer);
    }
  }

  ///Apply filter for threat history
  applyThreatFilter(List<String> filter, ThreatFilterDate pickedDate, DateTime? pickedDate1, DateTime? pickedDate2){

    threatFilterArray = filter;

    switch(pickedDate){
      case ThreatFilterDate.all:
        threatFilterDate = ThreatFilterDate.all;
        break;
      case ThreatFilterDate.today:
        threatFilterDate = ThreatFilterDate.today;
        break;
      case ThreatFilterDate.yesterday:
        threatFilterDate = ThreatFilterDate.yesterday;
        break;
      case ThreatFilterDate.last7days:
        threatFilterDate = ThreatFilterDate.last7days;
        break;
      case ThreatFilterDate.custom:
        if(pickedDate1 != null && pickedDate2 != null){
          threatFilterDate = ThreatFilterDate.custom;
          threatFilterDate1 = pickedDate1;
          threatFilterDate2 = pickedDate2;
        }else{
          threatFilterDate = ThreatFilterDate.all;
          threatFilterDate1 = null;
          threatFilterDate2 = null;
        }
        break;
    }

    notifyListeners();

  }

  clear() async {
    userBikeList.forEach((key, value) async {
      await NotificationProvider().unsubscribeFromTopic(key);

      if(value?.notificationSettings?.connectionLost == true ) {
        NotificationProvider().unsubscribeFromTopic("$key~connection-lost");
      }
      if(value?.notificationSettings?.movementDetect == true ) {
        NotificationProvider().unsubscribeFromTopic("$key~movement-detect");
      }
      if(value?.notificationSettings?.theftAttempt == true ) {
        NotificationProvider().unsubscribeFromTopic("$key~theft-attempt");
      }
      if(value?.notificationSettings?.lock == true ) {
        NotificationProvider().unsubscribeFromTopic("$key~lock-reminder");
      }
      if(value?.notificationSettings?.planReminder == true ) {
        NotificationProvider().unsubscribeFromTopic("$key~plan-reminder");
      }
    });



    SharedPreferences prefs = await _prefs;
    prefs.remove('currentBikeName');
    prefs.remove('currentBikeList');
    prefs.remove('currentBikeIMEI');


    bikeListSubscription?.cancel();
    currentBikeSubscription?.cancel();
    bikeUserSubscription?.cancel();
    currentBikeUserSubscription?.cancel();
    currentUserBikeSubscription?.cancel();
    currentBikePlanSubscription?.cancel();
    rfidListSubscription?.cancel();

    userBikeList.clear();
    userBikeDetails.clear();
    bikeUserList.clear();
    bikeUserDetails.clear();
    threatRoutesLists.clear();

    isPlanSubscript = null;
    currentBikeIMEI = null;
    currentUserModel = null;
    currentBikeModel = null;
    currentBikePlanModel = null;
    currentRFIDModel = null;
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
          getBike(userBikeList.keys.first);
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

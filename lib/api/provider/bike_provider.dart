import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bike_model.dart';
import '../model/bike_user_model.dart';
import '../model/location_model.dart';
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

class BikeProvider extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String rfidCollection = dotenv.env['DB_COLLECTION_RFID'] ?? 'DB not found';
  String inventoryCollection =
      dotenv.env['DB_COLLECTION_INVENTORY'] ?? 'DB not found';

  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();
  LinkedHashMap bikeUserDetails = LinkedHashMap<String, UserModel>();
  LinkedHashMap userBikeList = LinkedHashMap<String, UserBikeModel>();
  LinkedHashMap userBikeDetails = LinkedHashMap<String, BikeModel>();
  LinkedHashMap rfidList = LinkedHashMap<String, RFIDModel>();

  UserModel? currentUserModel;
  BikeModel? currentBikeModel;
  BikeUserModel? bikeUserModel;
  UserBikeModel? userBikeModel;
  RFIDModel? currentRFID;

  int currentBikeList = 0;
  String? currentBikeIMEI;

  StreamSubscription? bikeListSubscription;
  StreamSubscription? currentBikeSubscription;
  StreamSubscription? bikeUserSubscription;
  StreamSubscription? currentBikeUserSubscription;
  StreamSubscription? currentUserBikeSubscription;
  StreamSubscription? rfidListSubscription;

  ScanQRCodeResult scanQRCodeResult = ScanQRCodeResult.unknown;

  ///Get current user model
  Future<void> init(UserModel? user) async {
    userBikeList.clear();
    if (user == null) {
      clear();
    } else {
      currentUserModel = user;
      getBikeList(currentUserModel?.uid);

      notifyListeners();
    }
  }

  ///Read user's bike list
  Future<void> getBikeList(String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentBikeModel = null;

    // if(userBikeDetails.isNotEmpty){
    //   userBikeDetails.clear();
    // }
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

          if (prefs.containsKey('currentBikeIMEI')) {
            currentBikeIMEI = prefs.getString('currentBikeIMEI') ?? "";
            notifyListeners();
          } else {
            currentBikeIMEI = userBikeList.keys.first.toString();
          }

          if (prefs.containsKey('currentBikeList')) {
            currentBikeList = prefs.getInt('currentBikeList') ?? 0;
            notifyListeners();
          } else {
            currentBikeList = 0;
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
  Future<void> getBike(String? imei) async {
    currentBikeModel = null;
    SharedPreferences prefs = await _prefs;

    if (currentBikeSubscription != null) {
      await currentBikeSubscription?.cancel();
    }

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
              prefs.setString('currentBikeIMEI', imei!);
              prefs.setInt('currentBikeList', index);

              notifyListeners();
            } else {
              currentBikeModel = null;
            }
          } on Exception catch (exception) {
            debugPrint(exception.toString());
          } catch (_) {
            return null;
          }
          getRFIDList();
          getBikeUserList();
        });
      }
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

  Future<void> changeBikeUsingIMEI(String deviceIMEI) async {
    SharedPreferences prefs = await _prefs;
    currentBikeList = 0;
    await prefs.setInt('currentBikeList', currentBikeList);
    await getBike(deviceIMEI);
    notifyListeners();
  }

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

  updateAcceptSharedBikeStatus(String targetIMEI) async {
    bool result;

    try {
      //Update
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(targetIMEI)
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
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

  bool checkIsOwner() {
    if (bikeUserList.isNotEmpty) {
      for (var key in bikeUserList.keys) {
        if (currentUserModel!.uid == key) {
          if (bikeUserList[key].role == "owner") {
            return true;
          } else {
            return false;
          }
        }
      }
    }
    return false;
  }

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

  getQRCodeResult() {
    return scanQRCodeResult;
  }

  setQRCodeResult(ScanQRCodeResult result) {
    scanQRCodeResult = result;
    notifyListeners();
  }

  deleteBike(String imei) {
    controlBikeList("first");
    try {
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

  getRFIDList() {
    rfidList.clear();

    try {
      rfidListSubscription = FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .orderBy("created", descending: false)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                rfidList.putIfAbsent(docChange.doc.id,
                    () => RFIDModel.fromJson(obj!, docChange.doc.id));
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                rfidList.removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                rfidList.update(docChange.doc.id,
                    (value) => RFIDModel.fromJson(obj!, docChange.doc.id));
                notifyListeners();
                break;
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  uploadRFIDtoFireStore(List<int> rfidID) {
    try {
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .collection(rfidCollection)
          .doc(rfidID.toString())
          .set({
        'created': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint(e.toString());
    }
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

    currentBikeModel = null;
    userBikeModel = null;
    bikeUserModel = null;
    currentBikeList = 0;
    notifyListeners();
  }
}

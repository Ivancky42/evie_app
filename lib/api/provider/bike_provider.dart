import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bike_model.dart';
import '../model/bike_user_model.dart';
import '../model/user_bike_model.dart';
import '../model/user_model.dart';

class BikeProvider extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';

  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();
  LinkedHashMap bikeUserDetails = LinkedHashMap<String, UserModel>();
  LinkedHashMap userBikeList = LinkedHashMap<String, UserBikeModel>();

  BikeModel? currentBikeModel;
  BikeUserModel? bikeUserModel;
  UserBikeModel? userBikeModel;

  UserModel? currentUserModel;
  int currentBikeList = 0;
  String? currentBikeIMEI;

  ///Get current user model
  Future<void> init(UserModel? user) async {

    userBikeList.clear();
    if(user == null){
      clear();
    }
    else{
      currentUserModel = user;
      getBikeList(currentUserModel?.uid);
      notifyListeners();
    }
  }

  ///Read user's bike list
  Future<void> getBikeList(String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentBikeModel = null;
    try {
      ///read doc change
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(bikesCollection)
          .snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
        for (var docChange in snapshot.docChanges) {
          switch(docChange.type){   ///element.type
            case DocumentChangeType.added:
              Map<String, dynamic>? obj = docChange.doc.data();
              ///Key = imei, Val = get json object
              userBikeList.putIfAbsent(docChange.doc.id, () => UserBikeModel.fromJson(obj!));
              notifyListeners();
              break;
            case DocumentChangeType.removed:
              userBikeList.removeWhere((key, value) => key == docChange.doc.id);
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

          if(currentBikeIMEI != ""){
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

    SharedPreferences prefs = await _prefs;

    for(int index = 0; index < userBikeList.length; index++){
          if (userBikeList.keys.elementAt(index) == imei) {
            FirebaseFirestore.instance
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
              getBikeUserList();
            });
          }
        }
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
          if (currentBikeList < userBikeList.length - 1) {
            currentBikeList += 1;
            prefs.setInt('currentBikeList', currentBikeList);
            getBike(userBikeList.keys.elementAt(currentBikeList));
            notifyListeners();
          }else if(currentBikeList == userBikeList.length -1){
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
          }else if(currentBikeList <= 0){
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
        currentBikeList = userBikeList.length -1;
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
      //Update
      FirebaseFirestore.instance.
      collection(bikesCollection).
      doc(currentBikeModel!.deviceIMEI).
      collection(usersCollection)
          .doc(targetID)
          .set({
        'created':Timestamp.now(),
        'uid':targetID,
        'role':'user',
     //   'notificationId':'',
        'status':'pending',
        'justInvited': false,
        ///position,  0-4
        'userId': 4,
      }, SetOptions(merge: true));


      Future.delayed(const Duration(milliseconds: 500), () {

        FirebaseFirestore.instance.
        collection(bikesCollection).
        doc(currentBikeModel!.deviceIMEI).
        collection(usersCollection)
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


  updateAcceptSharedBikeStatus(String targetIMEI) async{
    bool result;

    try {
      //Update
      FirebaseFirestore.instance.
      collection(bikesCollection).

          ///target device imei
      doc(targetIMEI).
      collection(usersCollection)
          .doc(currentUserModel!.uid)
          .set({
        'status':'shared',
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
      FirebaseFirestore.instance.
      collection(bikesCollection).
      doc(currentBikeModel!.deviceIMEI).
      collection(usersCollection)
          .doc(targetUID)
          .set({
        'status':'removed',
        'justInvited': true,
      }, SetOptions(merge: true));


      ///Update user notification id status == removed

      FirebaseFirestore.instance.
      collection(usersCollection).
          doc(targetUID)
          .collection("notifications")
          .doc(notificationId)
          .set({
        'status':'removed',
      }, SetOptions(merge: true));



      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }


    return result;
  }


  getBikeUserList(){
    bikeUserList.clear();
    bikeUserDetails.clear();

    try {
      //Update
      FirebaseFirestore.instance.
      collection(bikesCollection).
      doc(currentBikeModel!.deviceIMEI).
      collection(usersCollection).orderBy("created",descending: false).
      snapshots().
      listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch(docChange.type){   ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
              ///  bikeUserList2.putIfAbsent(docChange.doc.id, () => BikeUserModel.fromJson(obj!));
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
              // TODO: Handle this case.
                break;
            }
          }
        }
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getBikeUserDetails(String uid){

    try {
      //Update
      FirebaseFirestore.instance.
      collection(usersCollection).
      doc(uid).
      snapshots().
      listen((snapshot) {

        Map<String, dynamic>? obj = snapshot.data();
        if (obj != null) {
          bikeUserDetails.putIfAbsent(snapshot.id, () => UserModel.fromJson(obj!));
          notifyListeners();
        }if(obj == null){
          bikeUserDetails.removeWhere((key, value) => key == obj?.keys);
          notifyListeners();
        }

      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool checkIsOwner(){
    if(bikeUserList.isNotEmpty){
      for(var key in bikeUserList.keys) {
        if (currentUserModel!.uid == key) {
           if(bikeUserList[key].role == "owner"){
             return true;
           }else{
             return false;
           }
        }
      }
    }

    return false;
  }


  Future uploadToFireStore(selectedDeviceId) async {
    try{
    ///Upload bike to firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('bikes')
        .get();

    //For each snapshot data match selected device id

    ///Check if have data
    if (snapshot.size == 0) {
      ///User name = provider current user
      FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(selectedDeviceId)
          .set(BikeModel(
        deviceType: "Reevo",
        deviceIMEI: selectedDeviceId!,
        isLocked: false,
        bikeName: "ReevoBike",
        created: Timestamp.now(),
        updated: Timestamp.now(),
      ).toJson());
    }

    ///uploadBikeToUserFireStore
    FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(currentUserModel!.uid)
        .collection(bikesCollection)
        .doc(selectedDeviceId)
        .set(UserBikeModel(
      deviceIMEI: selectedDeviceId!,
      deviceType: "Reevo",
      created: Timestamp.now(),
    ).toJson());


    ///uploadUserToBikeFireStore
    String role = "";
    //Check if first registration. Role is owner/rider
    final ubsnapshot = await FirebaseFirestore.instance
        .collection('bikes')
        .doc(selectedDeviceId)
        .collection('users')
        .get();

    if (ubsnapshot.size == 0) {
      role = "owner";
    } else if (ubsnapshot.size > 0) {
      role = "user";
    }else if (ubsnapshot.size >= 5) {
      role = "exceed limit";
    }

    FirebaseFirestore.instance
        .collection(bikesCollection)
        .doc(selectedDeviceId)
        .collection(usersCollection)
        .doc(currentUserModel!.uid)
        .set(BikeUserModel(
      uid: currentUserModel!.uid,
      role: role,
      created: Timestamp.now(),
    ).toJson());

    return true;
  }catch(e){
    debugPrint(e.toString());
    return false;
  }
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

  clear() async {
    SharedPreferences prefs = await _prefs;
    prefs.remove('currentBikeName');
    prefs.remove('currentBikeList');
    prefs.remove('currentBikeIMEI');
    userBikeList.clear();
    currentBikeModel = null;
    userBikeModel = null;
    bikeUserModel = null;
    currentBikeList = 0;
    notifyListeners();
  }
}
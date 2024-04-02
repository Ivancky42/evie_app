import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../model/user_model.dart';
import '../todays_quote.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';

class CurrentUserProvider extends ChangeNotifier {

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String? randomQuote;

  List userNotificationList = ["~general", "~firmware-update"];

  UserModel? currentUserModel;
  UserModel? get getCurrentUserModel => currentUserModel;

  get fetchCurrentUserModel async => currentUserModel;

  StreamSubscription? currentUserSubscription;
  StreamSubscription? checkUserAccountSub;
  StreamSubscription? isDeactivateSub;

  late Completer<String?> getUserCompleter;
  late Completer<String?> listenIsDeactivateCompleter;

  CurrentUserProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
  }

  Future<void> update(uid) async {
    if (uid != null) {
      getUser(uid);
      notifyListeners();
    }
    else {
      currentUserModel = null;
      notifyListeners();
    }
  }

  ///Get user information
  getUser(String? uid) {
    currentUserSubscription?.cancel();
    if (uid == null || uid == "") {
      currentUserModel = null;
    }
    else {
      currentUserSubscription = FirebaseFirestore.instance.collection(usersCollection).doc(uid).snapshots().listen((event) {
        Map<String, dynamic>? obj = event.data();
        if (obj != null) {
          currentUserModel = UserModel.fromJson(obj);
          // NotificationProvider().subscribeToTopic("abc");
          // if (currentUserModel?.uid != null) {
          //   NotificationProvider().subscribeToTopic(currentUserModel?.uid);
          // }
          notifyListeners();
        }
      });
    }
  }

  ///Get user information
  Future<String?> checkUserAccount(String? uid) {
    getUserCompleter = Completer<String?>();
    checkUserAccountSub?.cancel();

    if (uid == null || uid == '') {
      getUserCompleter.complete('NO_USER');
    }
    else {
      FirebaseFirestore.instance.collection(usersCollection).doc(uid).get().then((doc) {
        Map<String, dynamic>? obj = doc.data();
        if (obj != null) {
          currentUserModel = UserModel.fromJson(obj);
          if (obj['uid'] != null) {
            if (currentUserModel!.isDeactivated) {
              getUserCompleter.complete('INVALID_USER');
            }
            else {
              getUserCompleter.complete('VALID_USER');
            }
          }
          else {
            getUserCompleter.complete('MISSING_DATA_USER');
          }
        }
        else {
          getUserCompleter.complete('INVALID_USER');
        }
      });
    }

    // if (uid == null || uid == "") {
    //   currentUserModel = null;
    // }
    // else {
    //   checkUserAccountSub = FirebaseFirestore.instance.collection(usersCollection).doc(uid).snapshots().listen((event) {
    //     Map<String, dynamic>? obj = event.data();
    //     if (obj != null) {
    //       currentUserModel = UserModel.fromJson(obj);
    //       if (currentUserModel!.isDeactivated) {
    //         getUserCompleter.complete('INVALID_USER');
    //       }
    //       else {
    //         NotificationProvider().subscribeToTopic("fcm_test");
    //         NotificationProvider().subscribeToTopic(currentUserModel?.uid);
    //         //getUserCompleter.complete('VALID_USER');
    //         notifyListeners();
    //       }
    //     }
    //     else {
    //       getUserCompleter.complete('INVALID_USER');
    //     }
    //   });
    // }

    return getUserCompleter.future;
  }




  ///User update user profile
  Future updateUserName(String name) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;

      //Update
      var docUser = FirebaseFirestore.instance.collection(usersCollection);
      await docUser
          .doc(uid)
          .update({
        'name': name,
        'updated': Timestamp.now(),
      });
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  ///User update user profile
  Future updateUserProfileImage(String imageURL) async {
    try {
      ///Get current user id, might get from provider
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;

      //Update
      var docUser = FirebaseFirestore.instance.collection(usersCollection);
      docUser
          .doc(uid)
          .update({
        'profileIMG': imageURL,
        'updated': Timestamp.now(),
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  clear() async {
    // if(currentUserModel?.notificationSettings?.firmwareUpdate == true ){
    //   await NotificationProvider().unsubscribeFromTopic("~firmware-update");
    // }
    // if( currentUserModel?.notificationSettings?.general == true ){
    //   await NotificationProvider().unsubscribeFromTopic("~general");
    // }
    currentUserModel = null;
    currentUserSubscription?.cancel();
    checkUserAccountSub?.cancel();
    notifyListeners();
  }

  todayRandomQuote() {
    Random random = Random();
    int randomNumber = random.nextInt(TodaysQuote.quotes.length); // from 1-10
    var randomQuote = TodaysQuote.quotes[randomNumber];
    this.randomQuote = randomQuote;
    notifyListeners();
  }

  getGreeting(){
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    String greeting;

    if (currentTime.hour >= 5 && currentTime.hour < 12) {
      greeting = "Good Morning";
    } else if (currentTime.hour >= 12 && currentTime.hour < 18) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    return greeting;
  }


  getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    Map<String, dynamic> deviceData;

    if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      deviceData = {
        'platform' : 'ios',
        'machine': iosInfo.utsname.machine,
        'systemVer': iosInfo.systemVersion,
        'brand': iosInfo.model,
        'deviceId': iosInfo.identifierForVendor,
        'updated' : DateTime.now(),
      };

    } else{
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      deviceData = {
        'platform' : 'android',
        'machine': androidInfo.model,
        'systemVer': androidInfo.version.release,
        'brand': androidInfo.brand,
        'deviceId': androidInfo.id,
        'updated' : DateTime.now(),
      };
    }

    Future.delayed(const Duration(seconds: 8), () async {

      await uploadDeviceInfoToFirestore(deviceData);
      compareUserLocation();

    });
  }

  Future<String?> listenIsDeactivated(String currentUid) {
    listenIsDeactivateCompleter = Completer<String?>();
    isDeactivateSub?.cancel();
    isDeactivateSub = FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(currentUid)
        .snapshots().listen((event) {
      Map<String, dynamic>? obj = event.data();
      UserModel userModel = UserModel.fromJson(obj!);
      if (userModel.isDeactivated) {
        isDeactivateSub?.cancel();
        listenIsDeactivateCompleter.complete('Success');
      }
      else {

      }
    });

    return listenIsDeactivateCompleter.future;
  }

  compareUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placeMarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = placeMarks[0];

      if (currentUserModel?.lastLogin?.country == null ||
          currentUserModel?.lastLogin?.country == "" ||
          currentUserModel?.lastLogin?.country != place.country) {
        debugPrint("User country not match database info");
        //print(currentUserModel?.lastLogin?.country);

        Map<String, dynamic> deviceData = {
          'country': place.country,
          'updated': DateTime.now(),
        };

        Future.delayed(const Duration(seconds: 8), () async {
          await uploadDeviceInfoToFirestore(deviceData);
        });
      } else {
        debugPrint("User country match database info");
      }
    }
    catch(error) {
      print(error);
    }
  }

  uploadDeviceInfoToFirestore(Map<String, dynamic>? deviceData) async{
    if(deviceData != null && currentUserModel != null){
      try{
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(currentUserModel!.uid)
            .set(
            {'lastLogin' : deviceData,},
            SetOptions(merge: true));
      }catch(e){
        debugPrint(e.toString());
      }
    }
  }


}

